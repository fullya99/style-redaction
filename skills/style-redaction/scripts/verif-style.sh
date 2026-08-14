#!/usr/bin/env bash
#
# verif-style.sh : controle mecanique des marqueurs de texte genere.
#
# Usage :
#   bash verif-style.sh <fichier|repertoire> [...]
#   bash verif-style.sh --strict README.md      # sortie 1 s'il reste une alerte
#
# Le script attrape ce qui se detecte sans comprendre le texte : ponctuation,
# vocabulaire, formules toutes faites. Le rythme des phrases et le rythme
# ternaire ne se detectent pas comme ca, ils se relisent.
#
# Ce qui est ignore : le frontmatter YAML, les blocs de code, le code inline
# entre accents graves. Et pour le vocabulaire, ce qui est cite entre « » :
# un texte qui parle d'un tic a le droit de le nommer.
#
set -euf

STRICT=0
CIBLES=""

while [ $# -gt 0 ]; do
  case "$1" in
    --strict)  STRICT=1; shift ;;
    -h|--help) sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)         CIBLES="$CIBLES $1"; shift ;;
  esac
done

[ -n "$CIBLES" ] || { echo "Usage : bash verif-style.sh <fichier|repertoire> [...]" >&2; exit 2; }

ALERTES=0

# Les lignes ignorees sont blanchies, pas supprimees, pour que les numeros
# affiches correspondent bien au fichier.
nettoie() {
  awk '
    NR == 1 && /^---[[:space:]]*$/ { fm = 1; print ""; next }
    fm == 1 && /^---[[:space:]]*$/ { fm = 0; print ""; next }
    fm == 1                        { print ""; next }
    /^[[:space:]]*```/             { code = !code; print ""; next }
    code == 1                      { print ""; next }
                                   { print }
  ' "$1" | sed 's/`[^`]*`//g'
}

# « l'essentiel » est un nom courant, pas le tic adjectival. On le retire avant
# de chercher le vocabulaire, sinon il pollue chaque rapport.
sans_citations() { sed -e 's/«[^»]*»//g' -e "s/[lL]'essentiel/…/g"; }

signale() { # <fichier> <libelle> <motif> [lex]
  local f="$1" libelle="$2" motif="$3" mode="${4:-}" trouves
  if [ "$mode" = "lex" ]; then
    trouves="$(nettoie "$f" | sans_citations | grep -nEi -- "$motif" || true)"
  else
    trouves="$(nettoie "$f" | grep -nEi -- "$motif" || true)"
  fi
  [ -n "$trouves" ] || return 0
  printf '  [!] %s\n' "$libelle"
  printf '%s\n' "$trouves" | head -4 | sed 's/^/        /'
  ALERTES=$((ALERTES + 1))
}

indice() { # comme signale, mais ne compte pas dans les alertes et ne fait pas echouer --strict
  local f="$1" libelle="$2" motif="$3" trouves
  trouves="$(nettoie "$f" | grep -nEi -- "$motif" || true)"
  [ -n "$trouves" ] || return 0
  printf '  [?] %s\n' "$libelle"
  printf '%s\n' "$trouves" | head -3 | sed 's/^/        /'
}

fichiers() {
  for c in $CIBLES; do
    if [ -d "$c" ]; then
      # archives/ est du contenu fige, ecrit avant la regle. Le linter ne le regarde pas.
      find "$c" -name '*.md' -not -path '*/.git/*' -not -path '*/node_modules/*' \
                -not -path '*/archives/*' 2>/dev/null
    elif [ -f "$c" ]; then
      echo "$c"
    else
      echo "Cible introuvable : $c" >&2
    fi
  done
}

for f in $(fichiers | sort); do
  AVANT=$ALERTES
  printf '\n%s\n' "$f"

  # --- ponctuation ---
  signale "$f" "tiret cadratin ou demi-cadratin" '—|–'
  signale "$f" "point-virgule" ';'
  signale "$f" "points de suspension en un seul caractere" '…'
  # La classe [[:alpha:]] remplace une plage [A-Za-zÀ-ÿ] qui echouait en
  # « Invalid collation character » sur les locales ou À et ÿ ne sont pas
  # collationnables. Le controle ne tournait alors pas du tout, et seule cette
  # erreur de grep le signalait. Vu sur un banc d'essai Codex le 2026-08-14.
  signale "$f" "guillemets droits au lieu de « »" '"[[:alpha:]]'
  # La virgule d'Oxford ne se detecte pas de facon fiable : « A, B, et C » est
  # fautif, mais « il se survole, et au bout d'un moment on arrete » est correct.
  # Aucune regex ne separe les deux, donc c'est un indice, pas une alerte.
  indice "$f" "virgule avant « et », a verifier a l'oeil" \
    ',[^,.:;!?]{3,60},[[:space:]]+et[[:space:]]'

  # --- lexique, hors citations ---
  signale "$f" "vocabulaire passe-partout" \
    '\b(crucial|cruciale|cruciaux|cruciales|essentiel|essentielle|essentiels|essentielles|notamment|par ailleurs|en outre|robuste|robustes|puissant|puissante|pertinent|pertinente|incontournable|veritable|véritable)\b' lex
  signale "$f" "formule toute faite" \
    '(il convient de|dans un souci de|a l.ere de|à l.ère de|dans le paysage|plonger dans|demystifier|démystifier|dans cet article, nous)' lex
  signale "$f" "participe present decoratif" \
    '\b(permettant de|offrant|garantissant|assurant une|visant a|visant à)\b' lex
  signale "$f" "anglicisme" \
    '(faire du sens|adresser (le|un|ce|les) probl|supporter (le|la|les|une|un) [a-z]|impacter|initier (le|la|un|une))' lex
  signale "$f" "balancier « ce n.est pas X, c.est Y »" \
    "(ce n'est pas .{3,40}, c'est|il ne s'agit pas de .{3,40}, mais)" lex

  [ "$ALERTES" -eq "$AVANT" ] && printf '  [ok] aucune alerte\n'
done

printf '\n'
if [ "$ALERTES" -eq 0 ]; then
  echo "Aucun marqueur automatique. Reste la relecture : longueur des phrases,"
  echo "rythme ternaire, concret plutot que general."
else
  echo "$ALERTES type(s) de marqueur trouve(s). Voir le skill style-redaction."
fi

[ "$STRICT" -eq 1 ] && [ "$ALERTES" -gt 0 ] && exit 1
exit 0
