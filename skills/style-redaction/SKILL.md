---
name: style-redaction
description: "Règle de rédaction, français ou anglais, à appliquer dès qu'un texte destiné à être lu est produit ou relu. Fixe d'abord le périmètre, quelle zone du projet s'écrit dans quelle langue, parce que la prose et les identifiants du code ne suivent pas la même règle. Impose ensuite un ton direct et supprime les marqueurs de texte généré par IA (tiret cadratin, em dash, point-virgule, rythme ternaire, \"ce n'est pas X c'est Y\", crucial, delve, robuste, seamless, participes présents décoratifs). À charger AVANT d'écrire. Se déclenche sur : rédiger, écrire ou reformuler un document, une doc, un README, un rapport, une analyse, une synthèse, un article, un post, un mail, une note, une description, du contenu. Aussi sur : humaniser, déslopifier, \"ça fait trop IA\", \"rends ça plus naturel\", \"relis mon texte\", \"corrige le style\", ton, tournure, write, rewrite, proofread. Et sur la langue : \"en quelle langue j'écris\", \"le code est en français\", \"ce projet est en anglais\"."
version: 1.3.0
author: fullya99
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [writing, style, french, english, review, anti-slop]
---

# Style de rédaction

> À charger **avant** d'écrire. Repasser un texte après coup marche mal, les tournures générées
> s'incrustent dans la structure du texte et pas seulement dans les mots.

Deux questions dans l'ordre. **Quelle langue, pour quelle zone du projet**, puis **comment
écrire** pour que ça ne sente pas la machine. La deuxième ne sert à rien si on rate la première.

---

## 1. Le périmètre, avant tout le reste

Un projet n'a pas une langue, il en a une par zone. Écrire un README en français ne dit rien de
la langue dans laquelle il faut nommer une constante.

| Zone | Ce que ça couvre | Clé |
|---|---|---|
| Prose | doc, README, rapport, note, mail, description, message | `prose` |
| Identifiants | fonctions, variables, constantes, classes, noms de fichiers, clés JSON, colonnes SQL, routes | `code` |
| Commentaires | ce qui est écrit dans le code, docstrings comprises | `commentaires` |
| Interface | libellés affichés, messages d'erreur, textes de log | `interface` |
| Git | messages de commit, noms de branche, titres de PR | `git` |

Trois règles qui ne se discutent pas, quelle que soit la config :

- **Le code déjà écrit gagne.** Si les identifiants sont en anglais, le suivant est en anglais,
  même sur un projet dont toute la doc est en français. On ne renomme jamais un symbole pour
  changer sa langue, et on ne mélange jamais deux langues dans un même module.
- **La langue de la prose ne déborde pas sur le code.** C'est le défaut le plus courant de ce
  skill quand on ne lui a rien dit. Une doc en français ne rend pas `calculerMontantTotal`
  préférable à `computeTotal`.
- **Les mots imposés par la plateforme restent tels quels.** Un mot-clé, une API, un nom de
  fichier de convention, un en-tête HTTP. Personne ne traduit `package.json`.

Le reste du skill, ton et marqueurs, ne s'applique qu'à la ligne `prose`, et à `interface` quand
les textes affichés sont des phrases.

---

## 2. Lire la config du projet

Dans cet ordre, on prend le premier qui répond.

**1. `.style-redaction.yml` à la racine du dépôt.**

```yaml
prose: fr
code: en
commentaires: en
interface: fr
git: en
fautes: oui        # fautes volontaires dans la prose, oui ou non
```

**2. Un bloc dans le `CLAUDE.md` du projet**, ou dans son `AGENTS.md`. Même contenu, précédé du
marqueur qui le rend trouvable. C'est le marqueur qui compte, pas le nom du fichier : le script
prend le premier `.md` de la racine qui le porte, donc pose-le à un seul endroit.

```markdown
<!-- style-redaction -->
prose: fr
code: en
commentaires: en
interface: fr
git: en
```

**3. Rien de déclaré.** Alors tu ne devines pas en silence. Tu regardes la langue des `.md` à la
racine et celle des identifiants dans deux ou trois fichiers de code, puis tu poses une seule
question courte avec ta lecture dedans. La réponse part dans le fichier ou dans le bloc. Une fois
par projet, pas à chaque session.

Une clé absente vaut « comme le code existant » pour `code`, `commentaires` et `git`, et « comme
la prose » pour `interface`.

---

## 3. Ce qui ne dépend pas de la langue

Les marqueurs les plus tenaces sont structurels. Ils traversent le français et l'anglais à
l'identique, et ce sont eux qu'on voit le moins sur son propre texte.

**Le rythme ternaire.** Trois éléments à chaque fois, trois adjectifs, trois exemples. La
signature la plus dure à repérer. Casse-la : deux éléments, ou quatre, ou un seul bien choisi.

**Le balancier.** « Ce n'est pas X, c'est Y. » En anglais, *it's not just X, it's Y*. Dis
directement ce que c'est.

**Les participes présents décoratifs.** Écris « une fonction qui valide ».
Pas « une fonction permettant de valider ». En anglais, *a function that validates*,
pas *a function enabling validation*.

**Les doublets d'adjectifs redondants.** « claire et lisible », *simple and effective*. Un seul
suffit, choisis lequel.

**L'évitement du verbe être.** Les modèles fuient « être » et *to be*, et enchaînent des tournures
alambiquées pour ne pas les employer. Ces verbes vont très bien.

**Les phrases toutes de la même longueur.** C'est ce qui produit l'effet lisse, celui qu'on repère
sans savoir le nommer. Alterne. Une phrase de trois lignes, puis une de cinq mots.

**Le sur-listage.** Une puce par idée sur vingt lignes, c'est illisible. Un paragraphe qui raconte
vaut mieux qu'une liste qui énumère. Garde les listes pour ce qui en est vraiment une, des étapes,
des fichiers, des options.

**L'introduction qui n'introduit rien.** « Dans cet article, nous allons voir », *in this article
we'll explore*. Commence par le contenu.

**La conclusion qui résume ce qu'on vient de lire.** Si le texte est court, elle est inutile. Si
le texte est long, c'est qu'il fallait le structurer autrement.

**Le ton flagorneur.** Pas de « excellente question », pas de *great question*, pas de « ce projet
ambitieux ».

### Ce qui rend un texte humain

Écris **du concret**. Un chiffre, un nom de fichier, une erreur exacte vaut mieux que trois phrases
d'introduction. « Le parsing plantait sur les fichiers de plus de 2 Mo » se retient. « Des
problèmes de performance ont été identifiés » ne se retient pas.

Assume **un point de vue**. « J'ai essayé Redis, ça marchait, mais installer un serveur pour trois
clés c'était disproportionné. » Un texte qui a un auteur se lit mieux qu'un texte neutre.

Garde **les hésitations vraies**. « Je ne sais pas si ça tient à la charge, à vérifier » est une
information. La fausse assurance en est une aussi, mais une mauvaise.

Autorise-toi un registre parlé quand le document le permet. « Ça casse », « c'est moche mais ça
marche ». Et varie les attaques de phrase, si trois paragraphes d'affilée commencent par le sujet,
réécris-en un.

---

## 4. Marqueurs du français

Ton direct, sans emballage. Tu écris comme quelqu'un qui laisse une note à celui qui va reprendre
derrière lui, pas comme un rapport d'audit. Tutoiement ou vouvoiement selon le destinataire, mais
constant dans un même document.

| Signe | Pourquoi | À la place |
|---|---|---|
| `—` cadratin | le marqueur numéro un du texte généré, et en français on l'utilise très peu | virgule, parenthèse, deux-points, ou deux phrases |
| `–` demi-cadratin en incise | même problème | pareil |
| `;` point-virgule | quasiment disparu de l'écrit courant, sa présence systématique trahit la machine | un point, ou une virgule |
| `,` avant « et » | la virgule d'Oxford vient de l'anglais, elle n'existe pas chez nous | rien du tout |
| `…` caractère unique | tic typographique | trois points, et rarement |

Guillemets français « comme ça », jamais les doubles droits. Le tiret simple `-` reste bon pour
les listes et les mots composés. Les flèches `→` dans un tableau technique passent très bien,
c'est de la notation, pas de la prose.

Vocabulaire à jeter, ces mots que les modèles placent partout et qui sonnent faux dès la deuxième
occurrence :

`crucial` · `essentiel` · `notamment` · `par ailleurs` · `en outre` · `robuste` · `puissant` ·
`clé` en adjectif · `optimiser` · `pertinent` · `il convient de` · `permettant de` · `offrant` ·
`garantissant` · `dans un souci de` · `à l'ère de` · `dans le paysage actuel` · `véritable` ·
`incontournable` · `plonger dans` · `démystifier`

Les anglicismes qui viennent d'un modèle entraîné en anglais : « faire du sens » (dis « avoir du
sens »), « adresser un problème » (« traiter »), « supporter une option » (« prendre en charge »),
« délivrer » (« livrer »), « impacter » (« toucher »), « initier » (« lancer »).

Et pas de **Titres Avec Des Majuscules Partout**, en français seule la première lettre en prend une.

---

## 5. Marqueurs de l'anglais

Même discipline, autres tics. Ici la capitale de titre est correcte, la virgule d'Oxford aussi,
et le point-virgule existe pour de vrai. Ce qui reste interdit :

| Signe | Pourquoi | À la place |
|---|---|---|
| `—` em dash | exactement le même marqueur qu'en français, et encore plus voyant en anglais | comma, parentheses, colon, or two sentences |
| `;` en série | légitime, mais un texte qui en pose un tous les deux paragraphes n'a pas été écrit à la main | a period |
| `…` caractère unique | même tic typographique | three dots, rarely |

Vocabulaire à jeter :

`delve` · `crucial` · `pivotal` · `robust` · `seamless` · `leverage` (verbe) · `utilize` ·
`comprehensive` · `intricate` · `tapestry` · `testament to` · `realm` · `landscape` ·
`underscores` · `boasts` · `elevate` · `unlock` · `harness` · `foster` · `myriad` · `plethora` ·
`meticulous` · `game-changer` · `dive into` · `unleash`

Formules à jeter : *in today's fast-paced world*, *it's worth noting that*, *when it comes to*,
*at the end of the day*, *let's dive in*, *in conclusion*, et la chaîne
*furthermore / moreover / additionally* qui ouvre trois paragraphes de suite.

Participes décoratifs, les mêmes qu'en français sous un autre costume : *enabling you to*,
*allowing for*, *ensuring that*, *providing a*, *offering*. Écris le verbe.

Pour une troisième langue, garde la section 3 entière et laisse tomber les deux tableaux de
marqueurs. Le script de contrôle ne saura pas la lire, la relecture reste.

---

## 6. Calibrer selon le document

Les règles ci-dessus ne bougent pas. Le registre, si.

| Type | Registre | Ce qui change |
|---|---|---|
| Doc technique interne, README | direct, parlé autorisé | on peut dire « ça casse », on cite des chemins et des erreurs exactes |
| Rapport, analyse, synthèse | sobre, mais toujours concret | pas de familiarité, mais des chiffres plutôt que des généralités |
| Contenu éditorial, post, article | vivant, voix assumée | on peut prendre parti, raconter, faire des phrases courtes |
| Message, mail, note | bref | on va au fait dès la première ligne |

---

## 7. Fautes volontaires

Actives par défaut sur la prose, coupées par `fautes: non` dans la config. Très peu, et jamais
n'importe où.

- **Une par document au maximum.** Souvent zéro. Deux fautes sur la même page, ça ne fait plus
  humain, ça fait négligé.
- **Uniquement dans la prose.** Jamais dans une commande, un chemin, un nom de fichier, une
  variable, un identifiant, un bloc de code, un chiffre, une date, un nom propre. Une faute à cet
  endroit transforme le document en piège, et tout le bénéfice est perdu.
- **Des fautes plausibles**, du type qu'on fait vraiment en tapant vite. Une élision qui saute
  (« on a pas » au lieu de « on n'a pas »), un accord qui traîne, une lettre doublée dans un mot
  long. Pas des fautes d'école.
- **Jamais sur un mot porteur d'un sens critique.** Si le mot conditionne une consigne de sécurité,
  un montant ou une manipulation irréversible, il est écrit correctement.
- **Jamais dans un document contractuel ou juridique.** Là, zéro.

---

## 8. Relecture avant de rendre

Contrôle mécanique, il prend dix secondes :

```bash
bash "$SKILL/scripts/verif-style.sh" <fichier|repertoire>
bash "$SKILL/scripts/verif-style.sh" --strict <fichier>       # sortie 1 s'il reste une alerte
bash "$SKILL/scripts/verif-style.sh" --langue en <fichier>    # force l'anglais
```

Sans `--langue`, il lit `.style-redaction.yml` ou le bloc du `CLAUDE.md`, et à défaut il devine
fichier par fichier en comptant les mots outils. Un dépôt qui mélange une doc française et une doc
anglaise se contrôle donc en un seul passage.

`$SKILL` est le répertoire de ce skill. Tu travailles depuis le projet, pas depuis le skill, donc
`scripts/verif-style.sh` tout court ne résout pas. Résous-le une fois, avant le premier appel :

```bash
ANCETRES="$(d="$PWD"; while [ "$d" != "/" ]; do echo "$d/.agents/skills/style-redaction"; d="$(dirname "$d")"; done)"

SKILL="$(for d in "$CLAUDE_PLUGIN_ROOT/skills/style-redaction" \
  ".claude/skills/style-redaction" $ANCETRES \
  "$HOME/.claude/skills/style-redaction" \
  "$HOME/.codex/skills/style-redaction" "$HOME/.agents/skills/style-redaction" \
  $(find "$HOME/.claude/plugins/cache" -maxdepth 5 -type d -path '*/skills/style-redaction' 2>/dev/null | sort -r) \
  $(find "$HOME/.claude/plugins/marketplaces" -maxdepth 5 -type d -path '*/skills/style-redaction' 2>/dev/null) \
  $(find "$HOME/.hermes/skills" "$HOME/.openclaw" -maxdepth 4 -type d -name style-redaction 2>/dev/null) \
  $(find skills -maxdepth 2 -type d -name style-redaction 2>/dev/null); do
  [ -f "$d/scripts/verif-style.sh" ] && echo "$d" && break
done)"
```

Quatre plateformes couvertes par une seule boucle, parce que ce skill est au format agentskills.io
et qu'il s'installe pareil partout. L'ordre suit les portées : le plugin d'abord, puis le projet
pour Claude Code et pour Codex, puis l'utilisateur pour les deux, puis les copies de plugin propres
à Claude Code.

Codex a deux répertoires de portée utilisateur, `~/.codex/skills/` où son installeur dépose, et
`~/.agents/skills/` du standard ouvert. Les deux sont scannés, vérifié le 2026-08-14. Le premier
passe avant parce qu'il porte la version que l'utilisateur a réellement installée, quand l'autre
peut garder une copie posée à la main et devenue vieille.

Chez Claude Code, `cache/` passe avant `marketplaces/` : le cache porte la version installée, le clone
du marketplace la pointe de `master`, et les deux divergent dès que le dépôt avance.

Codex n'a pas d'équivalent de `CLAUDE_PLUGIN_ROOT`, la demande a été fermée en « not planned », donc
cette boucle de repli est son seul mécanisme de résolution. Il remonte l'arborescence jusqu'à la
racine du dépôt pour trouver `.agents/skills/`, et `$ANCETRES` fait la même chose avant la boucle,
en testant chaque ancêtre du répertoire courant. Vérifié sur un banc d'essai Codex du 2026-08-14.

Chez Hermes, `~/.hermes/skills/`, avec ou sans dossier de catégorie. Chez OpenClaw,
`~/.openclaw/workspace/skills/`, avec ou sans sous-dossier de rangement.

La dernière entrée, relative, existe pour un workspace OpenClaw déplacé par
`agents.defaults.workspace`. Ce workspace est le seul répertoire de travail de l'agent, donc
`skills/<nom>/` y résout depuis le cwd quel que soit son emplacement réel. Sans elle, un workspace
non standard n'était pas trouvé.

Si la résolution échoue, tu relis à la main avec les questions ci-dessous. Le script fait gagner
du temps, il n'est pas la règle.

Puis les cinq questions, celles que le script ne sait pas poser.

1. Est-ce que j'ai écrit dans la langue de la zone, ou dans celle du document d'à côté ?
2. Est-ce que toutes mes phrases font la même longueur ?
3. Est-ce que j'ai écrit trois choses là où deux suffisaient ?
4. Est-ce qu'un lecteur pressé retient un fait concret, ou juste une impression générale ?
5. Est-ce que ce texte pourrait être recopié tel quel dans un autre projet ?

Si la réponse à la cinquième est oui, c'est qu'il ne dit rien du tien. Recommence.
