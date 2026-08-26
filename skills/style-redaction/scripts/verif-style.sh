#!/usr/bin/env bash
#
# verif-style.sh : controle mecanique des marqueurs de texte genere.
#
# Usage :
#   bash verif-style.sh <fichier|repertoire> [...]
#   bash verif-style.sh --strict README.md          # sortie 1 s'il reste une alerte
#   bash verif-style.sh --langue en docs/           # force l'anglais
#
# Sans --langue, le script cherche la cle « prose » dans .style-redaction.yml,
# puis dans le premier .md du meme repertoire qui porte le marqueur
# <!-- style-redaction -->, en remontant les repertoires. A defaut il devine
# fichier par fichier en comptant les mots outils. Une langue inconnue n'est
# pas controlee.
#
# Le script attrape ce qui se detecte sans comprendre le texte : ponctuation,
# vocabulaire, formules toutes faites. Le rythme des phrases et le rythme
# ternaire ne se detectent pas comme ca, ils se relisent.
#
# Ce qui est ignore : le frontmatter YAML, les blocs de code, le code inline
# entre accents graves. Et pour le vocabulaire, ce qui est cite entre « » ou
# entre guillemets droits : un texte qui parle d'un tic a le droit de le nommer.
#
set -euf

STRICT=0
LANGUE=auto
CIBLES=""

while [ $# -gt 0 ]; do
  case "$1" in
    --strict)  STRICT=1; shift ;;
    --langue)  LANGUE="${2:-}"
               [ -n "$LANGUE" ] || { echo "--langue attend fr ou en." >&2; exit 2; }
               shift 2 ;;
    --langue=*) LANGUE="${1#*=}"; shift ;;
    -h|--help) sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)         CIBLES="$CIBLES $1"; shift ;;
  esac
done

[ -n "$CIBLES" ] || { echo "Usage : bash verif-style.sh [--strict] [--langue fr|en] <fichier|repertoire> [...]" >&2; exit 2; }

case "$LANGUE" in
  auto|fr|en) ;;
  *) echo "Langue inconnue : $LANGUE. Attendu fr, en, ou rien." >&2; exit 2 ;;
esac

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
sans_citations() { sed -e 's/«[^»]*»//g' -e 's/"[^"]*"//g' -e "s/[lL]'essentiel/…/g"; }

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

# --- langue -----------------------------------------------------------------

# Cherche « prose: xx » dans la config du projet, en remontant depuis le
# repertoire courant. Premier trouve, premier servi.
#
# Le fichier dedie d'abord, puis n'importe quel .md du meme repertoire qui porte
# le marqueur <!-- style-redaction -->. Aucun nom de fichier n'est code en dur :
# c'est le marqueur qui designe le bloc, pas l'emplacement. Pose-le a un seul
# endroit, sinon c'est le premier par ordre alphabetique qui gagne.
langue_config() {
  local d="$PWD" v="" c
  while [ "$d" != "/" ]; do
    if [ -f "$d/.style-redaction.yml" ]; then
      v="$(sed -n 's/^[[:space:]]*prose[[:space:]]*:[[:space:]]*\([a-zA-Z-]*\).*/\1/p' "$d/.style-redaction.yml" | head -1)"
      [ -n "$v" ] && { echo "$v"; return 0; }
    fi
    for c in $(find "$d" -maxdepth 1 -type f -name '*.md' 2>/dev/null | sort); do
      grep -q '<!--[[:space:]]*style-redaction[[:space:]]*-->' "$c" 2>/dev/null || continue
      v="$(awk '/<!--[[:space:]]*style-redaction[[:space:]]*-->/ { m = NR }
                m && NR > m && NR <= m + 14 && /^[[:space:]]*prose[[:space:]]*:/ { print; exit }' "$c" \
           | sed -n 's/^[[:space:]]*prose[[:space:]]*:[[:space:]]*\([a-zA-Z-]*\).*/\1/p')"
      [ -n "$v" ] && { echo "$v"; return 0; }
    done
    d="$(dirname "$d")"
  done
  return 0
}

# Repli quand rien n'est declare : on compte les mots outils des deux langues.
# Grossier, mais suffisant sur de la prose, et le code est deja retire.
langue_devinee() {
  local fr en
  fr="$(nettoie "$1" | grep -oiwE 'le|la|les|des|une|qui|que|pour|dans|est|pas|sur|avec|cette|aux|du' | wc -l)"
  en="$(nettoie "$1" | grep -oiwE 'the|and|of|to|is|that|with|this|are|from|it|as|you|be' | wc -l)"
  [ "$fr" -ge "$en" ] && echo fr || echo en
}

# --- controles par langue ---------------------------------------------------

controle_fr() {
  local f="$1"
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
}

controle_en() {
  local f="$1"
  # Ni la virgule d'Oxford ni les guillemets droits ne sont fautifs ici, et le
  # point-virgule est legitime en anglais. Seule sa presence en serie trahit.
  signale "$f" "em dash or en dash" '—|–'
  signale "$f" "single-character ellipsis" '…'
  indice "$f" "semicolons, a tic if they come every other paragraph" ';'

  signale "$f" "filler vocabulary" \
    '\b(delve[sd]?|delving|crucial|pivotal|robust|seamless|seamlessly|leverag(e|es|ed|ing)|utiliz(e|es|ed)|comprehensive|intricate|tapestry|realm|myriad|plethora|meticulous|meticulously|boasts|underscores|unleash|elevat(e|es|ing) your)\b' lex
  signale "$f" "canned phrase" \
    "(in today's [a-z-]+ world|it's worth noting|when it comes to|at the end of the day|let's dive in|dive into|game.changer|in conclusion|testament to|navigating the|in this article, we)" lex
  signale "$f" "decorative participle" \
    '\b(enabling (you|us|them|the)|allowing for|ensuring that|providing a|offering a|designed to (help|empower))\b' lex
  signale "$f" "balancing act, it is not X it is Y" \
    "(it'?s not (just )?.{3,40}, it'?s|this isn'?t .{3,40}, it'?s)" lex
  indice "$f" "furthermore / moreover / additionally, check the chain" \
    '^[[:space:]]*(furthermore|moreover|additionally)\b'
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

DECLAREE=""
[ "$LANGUE" = auto ] && DECLAREE="$(langue_config)"
[ "$LANGUE" != auto ] && DECLAREE="$LANGUE"

IGNORES=0
CONTROLES=0

for f in $(fichiers | sort); do
  AVANT=$ALERTES
  if [ -n "$DECLAREE" ]; then
    LF="$DECLAREE"
  else
    LF="$(langue_devinee "$f")"
  fi

  case "$LF" in
    fr) printf '\n%s  [fr]\n' "$f"; controle_fr "$f" ;;
    en) printf '\n%s  [en]\n' "$f"; controle_en "$f" ;;
    *)  IGNORES=$((IGNORES + 1)); continue ;;
  esac
  CONTROLES=$((CONTROLES + 1))

  [ "$ALERTES" -eq "$AVANT" ] && printf '  [ok] aucune alerte\n'
done

printf '\n'
[ "$IGNORES" -gt 0 ] && echo "$IGNORES fichier(s) ignore(s), langue « $DECLAREE » non controlee par ce script."
if [ "$CONTROLES" -eq 0 ]; then
  echo "Rien de controle. La relecture reste entiere, voir le skill style-redaction."
elif [ "$ALERTES" -eq 0 ]; then
  echo "Aucun marqueur automatique. Reste la relecture : longueur des phrases,"
  echo "rythme ternaire, concret plutot que general."
else
  echo "$ALERTES type(s) de marqueur trouve(s). Voir le skill style-redaction."
fi

[ "$STRICT" -eq 1 ] && [ "$ALERTES" -gt 0 ] && exit 1
exit 0
