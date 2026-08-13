---
name: style-redaction
description: Règle de rédaction en français, à appliquer dès qu'un texte destiné à être lu est produit ou relu. Impose un ton direct et humain, et supprime tous les marqueurs de texte généré par IA (tiret cadratin, point-virgule, virgule d'Oxford, rythme ternaire, "ce n'est pas X c'est Y", crucial, essentiel, notamment, par ailleurs, participes présents décoratifs, anglicismes). À charger AVANT d'écrire, pas après. Se déclenche sur : rédiger ou écrire ou reformuler un document, une doc, un README, un rapport, une analyse, une synthèse, un compte-rendu, un article, un post, un mail, une note, une fiche, une description, du contenu. Se déclenche aussi sur : humaniser, déslopifier, "ça fait trop IA", "rends ça plus naturel", "relis mon texte", "corrige le style", ton, formulation, tournure.
---

# Style de rédaction

> À charger **avant** d'écrire. Repasser un texte après coup marche mal, les tournures générées
> s'incrustent dans la structure du texte et pas seulement dans les mots.

S'applique à tout ce qui sera lu par quelqu'un. Documentation, README, rapport, analyse, note,
article, message, fiche produit, contenu éditorial. Pas au code, pas aux noms de variables.

---

## La base

Français, accents compris. Ton direct, sans emballage. Tu écris comme quelqu'un qui laisse une
note à celui qui va reprendre derrière lui, pas comme un rapport d'audit.

Guillemets français « comme ça », jamais les doubles droits. Espace insécable avant `:` `!` `?`
quand l'outil le permet, sinon espace simple, on ne se bat pas là-dessus.

Le tutoiement ou le vouvoiement dépend du destinataire, mais reste constant dans un même document.

---

## Ponctuation interdite

| Signe | Pourquoi | À la place |
|---|---|---|
| `—` cadratin | le marqueur numéro un du texte généré, et en français on l'utilise très peu | virgule, parenthèse, deux-points, ou deux phrases |
| `–` demi-cadratin en incise | même problème | pareil |
| `;` point-virgule | quasiment disparu de l'écrit courant, sa présence systématique trahit la machine | un point, ou une virgule |
| `,` avant « et » | la virgule d'Oxford vient de l'anglais, elle n'existe pas chez nous | rien du tout |
| `…` caractère unique | tic typographique | trois points, et rarement |

Le tiret simple `-` reste bon pour les listes et les mots composés. Les flèches `→` dans un
tableau technique passent très bien, c'est de la notation, pas de la prose.

---

## Vocabulaire à éviter

Les mots que les modèles placent partout, et qui sonnent faux dès la deuxième occurrence :

`crucial` · `essentiel` · `notamment` · `par ailleurs` · `en outre` · `robuste` · `puissant` ·
`clé` en adjectif · `optimiser` · `pertinent` · `il convient de` · `permettant de` · `offrant` ·
`garantissant` · `dans un souci de` · `à l'ère de` · `dans le paysage actuel` · `véritable` ·
`incontournable` · `plonger dans` · `démystifier`

Les anglicismes qui viennent d'un modèle entraîné en anglais : « faire du sens » (dis « avoir du
sens »), « adresser un problème » (« traiter »), « supporter une option » (« prendre en charge »),
« délivrer » (« livrer », « rendre »), « impacter » (« toucher », « changer »), « initier »
(« lancer », « démarrer »).

Remplace par le mot juste. Si un mot te vient trop facilement, c'est souvent qu'il ne dit rien.

---

## Structures à éviter

**Le rythme ternaire.** Trois éléments à chaque fois, trois adjectifs, trois exemples. C'est la
signature la plus tenace, et la plus dure à voir sur son propre texte. Casse-la : mets deux
éléments, ou quatre, ou un seul bien choisi.

**« Ce n'est pas X, c'est Y. »** Formule de balancier dont les modèles raffolent. Dis directement
ce que c'est.

**Les participes présents décoratifs.** Écris « une fonction qui valide ».
Pas « une fonction permettant de valider ». Écris « un cache plus rapide ».
Pas « un cache offrant de meilleures performances ».

**Les doublets d'adjectifs redondants.** « claire et lisible », « simple et efficace ». Un seul
suffit, choisis lequel.

**L'évitement de la copule.** Les modèles fuient le verbe « être » et enchaînent des tournures
alambiquées pour ne pas l'employer. Le verbe « être » va très bien.

**Les phrases toutes de la même longueur.** C'est ce qui produit l'effet lisse, celui qu'on
repère sans savoir le nommer. Alterne. Une phrase de trois lignes, puis une de cinq mots. Une
phrase courte, ça réveille.

**Le sur-listage.** Une puce par idée sur vingt lignes, c'est illisible. Un paragraphe qui
raconte vaut mieux qu'une liste qui énumère. Garde les listes pour ce qui est vraiment une liste :
des étapes, des fichiers, des options.

**L'introduction qui n'introduit rien.** « Dans cet article, nous allons voir... ». Commence par
le contenu.

**La conclusion qui résume ce qu'on vient de lire.** Si le texte est court, elle est inutile. Si
le texte est long, c'est qu'il fallait le structurer autrement.

**Le ton flagorneur.** Pas de « excellente question », pas de « ce projet ambitieux ».

**Les Titres Avec Des Majuscules Partout.** En français, seule la première lettre prend la majuscule.

---

## Ce qui rend un texte humain

Écris **du concret**. Un chiffre, un nom de fichier, une erreur exacte vaut mieux que trois
phrases d'introduction. « Le parsing plantait sur les fichiers de plus de 2 Mo » se retient.
« Des problèmes de performance ont été identifiés » ne se retient pas.

Assume **un point de vue**. « J'ai essayé Redis, ça marchait, mais installer un serveur pour trois
clés c'était disproportionné. » Un texte qui a un auteur se lit mieux qu'un texte neutre.

Garde **les hésitations vraies**. « Je ne sais pas si ça tient à la charge, à vérifier » est une
information. La fausse assurance en est une aussi, mais une mauvaise.

Autorise-toi un registre parlé de temps en temps, quand le document le permet. « Ça casse »,
« c'est moche mais ça marche », « attention, piège ».

Varie les attaques de phrase. Si trois paragraphes d'affilée commencent par le sujet, réécris-en un.

---

## Calibrer selon le document

Les règles ci-dessus ne bougent pas. Le registre, si.

| Type | Registre | Ce qui change |
|---|---|---|
| Doc technique interne, README | direct, parlé autorisé | on peut dire « ça casse », on cite des chemins et des erreurs exactes |
| Rapport, analyse, synthèse | sobre, mais toujours concret | pas de familiarité, mais toujours des chiffres plutôt que des généralités |
| Contenu éditorial, post, article | vivant, voix assumée | on peut prendre parti, raconter, faire des phrases courtes |
| Message, mail, note | bref | on va au fait dès la première ligne |

Dans tous les cas, aucun cadratin, aucun point-virgule, aucun rythme ternaire.

---

## Fautes volontaires

Oui, on en met. Très peu, et jamais n'importe où.

- **Une par document au maximum.** Souvent zéro. Deux fautes sur la même page, ça ne fait plus
  humain, ça fait négligé.
- **Uniquement dans la prose.** Jamais dans une commande, un chemin, un nom de fichier, une
  variable, un identifiant, un bloc de code, un chiffre, une date, un nom propre. Une faute à
  cet endroit transforme le document en piège, et tout le bénéfice est perdu.
- **Des fautes plausibles**, du type qu'on fait vraiment en tapant vite. Une élision qui saute
  (« on a pas » au lieu de « on n'a pas »), un accord qui traîne, une lettre doublée ou manquante
  dans un mot long. Pas des fautes d'école.
- **Jamais sur un mot porteur d'un sens critique.** Si le mot conditionne la compréhension d'une
  consigne de sécurité, d'un montant ou d'une manipulation irréversible, il est écrit correctement.
- **Jamais dans un document contractuel ou juridique.** Là, zéro.

Si la faute te gêne à la relecture, enlève-la. Le but c'est que le texte respire, pas qu'il ait
l'air bâclé.

---

## Relecture avant de rendre

Contrôle mécanique, il prend dix secondes :

```bash
bash "$SKILL/scripts/verif-style.sh" <fichier|repertoire>
bash "$SKILL/scripts/verif-style.sh" --strict <fichier>   # sortie 1 s'il reste une alerte
```

`$SKILL` est le répertoire de ce skill. Tu travailles depuis le projet, pas depuis le skill, donc
`scripts/verif-style.sh` tout court ne résout pas. Résous-le une fois, avant le premier appel :

```bash
SKILL="$(for d in "$CLAUDE_PLUGIN_ROOT/skills/style-redaction" \
  ".claude/skills/style-redaction" "$HOME/.claude/skills/style-redaction" \
  $(find "$HOME/.claude/plugins" -maxdepth 7 -type d -path '*/skills/style-redaction' 2>/dev/null); do
  [ -f "$d/scripts/verif-style.sh" ] && echo "$d" && break
done)"
```

Si la résolution échoue, tu relis à la main avec les quatre questions ci-dessous. Le script fait
gagner du temps, il n'est pas la règle.

Puis quatre questions, celles que le script ne sait pas poser.

1. Est-ce que toutes mes phrases font la même longueur ?
2. Est-ce que j'ai écrit trois choses là où deux suffisaient ?
3. Est-ce qu'un lecteur pressé retient un fait concret, ou juste une impression générale ?
4. Est-ce que ce texte pourrait être recopié tel quel dans un autre projet ?

Si la réponse à la quatrième est oui, c'est qu'il ne dit rien du tien. Recommence.
