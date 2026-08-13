# style-redaction

Un plugin Claude Code qui empêche tout ce que tu écris de ressembler à du texte généré. En français.

Il se charge dès qu'un texte destiné à être lu se produit ou se relit. Documentation, README,
rapport, analyse, synthèse, article, note, mail. Ou sur demande directe, du genre « relis ça, ça
fait trop IA ».

Il ne touche pas au code, ni aux noms de variables.

## Installation

```
/plugin marketplace add fullya99/style-redaction
/plugin install style-redaction@style-redaction
```

Ou à la main, sans passer par le marketplace :

```bash
mkdir -p ~/.claude/skills
cp -r skills/style-redaction ~/.claude/skills/
```

## Ce qu'il fait

Ton direct, du concret plutôt que du général. Pas de tiret cadratin, pas de point-virgule, pas de
virgule d'Oxford, pas de rythme ternaire, pas de « ce n'est pas X, c'est Y », pas de vocabulaire
passe-partout du genre « crucial » ou « par ailleurs », pas d'anglicisme de modèle entraîné en
anglais.

La partie qui compte le plus est aussi la plus dure à voir sur son propre texte : le rythme
ternaire, les phrases toutes de la même longueur, les participes présents décoratifs, les
introductions qui n'introduisent rien. C'est ce qui produit l'effet lisse, celui qu'on repère sans
savoir le nommer.

Il se charge **avant** d'écrire. Repasser un texte après coup marche mal, les tournures générées
s'incrustent dans la structure et pas seulement dans les mots.

## Le contrôle mécanique

```bash
SR=skills/style-redaction                 # ou ~/.claude/skills/style-redaction
bash $SR/scripts/verif-style.sh <fichier|repertoire> [...]
bash $SR/scripts/verif-style.sh --strict README.md   # sortie 1 s'il reste une alerte
```

Le script attrape dix familles de marqueurs, celles qui se détectent sans comprendre le texte. Il
ignore le contenu des blocs de code, parce qu'une commande shell a le droit de contenir un
point-virgule. `--strict` en fait un contrôle de CI.

Le rythme ternaire et l'uniformité de longueur des phrases ne se grepent pas, ils se relisent. Le
skill pose les quatre questions qui restent après le script.

Bash seul suffit. Aucune dépendance, aucun serveur MCP.

## Ce qu'il ne fait pas

Il ne réécrit pas ton style à toi. Un texte qui a un auteur se lit mieux qu'un texte neutre, et le
skill pousse à assumer un point de vue plutôt qu'à le lisser.

Il ne s'applique pas au code. Un identifiant en anglais avec un tiret dedans n'est pas une faute de
français.

Il ne remplace pas la relecture. Le script ne voit que ce qui se compte.

## Un mot sur les fautes volontaires

Le skill autorise une faute par document au maximum, souvent zéro, uniquement dans la prose. Jamais
dans une commande, un chemin, un identifiant, un chiffre, une date, un nom propre, ni dans un
document contractuel. Une faute à ces endroits transforme le document en piège et tout le bénéfice
est perdu.

Si ça ne te va pas, la règle se retire en une ligne dans `skills/style-redaction/SKILL.md`.

## Le plugin compagnon

`cloture-session` maintient une documentation vivante dans un projet, pour qu'un `/clear` ne coûte
jamais une information. Il charge cette règle de style avant d'écrire quoi que ce soit.

```
/plugin marketplace add fullya99/cloture-session
/plugin install cloture-session@cloture-session
```
