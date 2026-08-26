# style-redaction

Un plugin Claude Code qui empêche tout ce que tu écris de ressembler à du texte généré. En
français, en anglais, ou les deux dans le même dépôt.

Il se charge dès qu'un texte destiné à être lu se produit ou se relit. Documentation, README,
rapport, analyse, synthèse, article, note, mail. Ou sur demande directe, du genre « relis ça, ça
fait trop IA ».

## La langue se décide zone par zone

Un projet n'a pas une langue, il en a une par zone, et c'est là que ce genre de règle dérape.
Une doc en français ne veut pas dire des constantes en français. Le skill lit un fichier
`.style-redaction.yml` à la racine du dépôt :

```yaml
prose: fr          # doc, README, rapport, note, mail
code: en           # fonctions, variables, constantes, noms de fichiers
commentaires: en
interface: fr      # libellés affichés, messages d'erreur, logs
git: en            # commits, branches, titres de PR
fautes: oui        # fautes volontaires dans la prose
```

Le même bloc se pose dans le `CLAUDE.md` du projet, sous un marqueur `<!-- style-redaction -->`,
si tu préfères tout garder au même endroit. Le fichier gagne quand les deux existent.

Sans rien de déclaré, le skill regarde le dépôt et te propose sa lecture en une question. La
config s'écrit avec ta réponse. Il ne devine jamais en silence. Et quoi qu'il y ait dans la config, le code
déjà écrit gagne : on ne renomme pas un symbole pour changer sa langue.

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

Sur Codex d'OpenAI, même standard, dossier différent :

```bash
cp -r skills/style-redaction .agents/skills/      # portée dépôt
cp -r skills/style-redaction ~/.agents/skills/    # portée utilisateur
```

## Claude web et Cowork

Claude Chat n'installe pas de plugin, mais il installe un skill. L'archive est attachée à la
[dernière release](https://github.com/fullya99/style-redaction/releases/latest).

1. Active **Code execution and file creation** dans tes réglages, sinon la section n'apparaît pas.
2. Réglages → **Capacités** → **Skills** → **Add Skill** → **Upload skill**.
3. Dépose `style-redaction.zip`, puis active l'interrupteur.

Le skill est partagé entre Claude Chat et Cowork, c'est la même bibliothèque personnelle. En
Enterprise, le propriétaire doit d'abord autoriser Skills et Code execution pour l'organisation.

Le contrôle mécanique ne tournera pas là-bas, sa boucle de résolution ne connaît pas l'emplacement où
Claude web monte les skills. Tu gardes la règle et les cinq questions de relecture.

## Hermes Agent et OpenClaw

Le skill suit le standard [agentskills.io](https://agentskills.io/specification), donc il marche sur
les deux, script de contrôle compris.

```bash
# Hermes Agent
cp -r skills/style-redaction ~/.hermes/skills/writing/style-redaction

# OpenClaw
cp -r skills/style-redaction ~/.openclaw/workspace/skills/style-redaction
```

Chez Hermes il devient une slash command au passage, `/style-redaction`, les skills installés y sont
exposés comme commandes. Si ton workspace OpenClaw n'est pas à l'emplacement par défaut, regarde
`agents.defaults.workspace` dans `~/.openclaw/openclaw.json`.

Une seule règle, trois plateformes. Il n'y a pas de version dédiée par agent, ça donnerait deux
copies qui finiraient par diverger.

## Ce qu'il fait

Ton direct, du concret plutôt que du général. En français : pas de tiret cadratin, pas de
point-virgule, pas de virgule d'Oxford, pas de « ce n'est pas X, c'est Y », pas de vocabulaire
passe-partout du genre « crucial » ou « par ailleurs », pas d'anglicisme de modèle entraîné en
anglais.

En anglais, même discipline et autres tics. L'em dash reste interdit, la virgule d'Oxford et la
capitale de titre redeviennent correctes, et la liste de mots change : `delve`, `robust`,
`seamless`, `leverage`, `tapestry`, *in today's fast-paced world*, *it's not just X, it's Y*.

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
bash $SR/scripts/verif-style.sh --strict README.md    # sortie 1 s'il reste une alerte
bash $SR/scripts/verif-style.sh --langue en docs/     # force l'anglais
```

Le script attrape une dizaine de familles de marqueurs, celles qui se détectent sans comprendre le
texte. Il ignore le contenu des blocs de code, parce qu'une commande shell a le droit de contenir
un point-virgule. `--strict` en fait un contrôle de CI.

Sans `--langue`, il lit la config du projet, et à défaut il devine fichier par fichier en comptant
les mots outils. Un dépôt qui mélange une doc française et une doc anglaise se contrôle en un seul
passage, chaque fichier avec les motifs de sa langue.

Le rythme ternaire et l'uniformité de longueur des phrases ne se grepent pas, ils se relisent. Le
skill pose les cinq questions qui restent après le script.

Bash seul suffit. Aucune dépendance, aucun serveur MCP.

## Ce qu'il ne fait pas

Il ne réécrit pas ton style à toi. Un texte qui a un auteur se lit mieux qu'un texte neutre, et le
skill pousse à assumer un point de vue plutôt qu'à le lisser.

Il ne s'applique pas au code. Un identifiant en anglais avec un tiret dedans n'est pas une faute de
français, et la ligne `code` de la config n'existe que pour choisir la langue des symboles à venir,
jamais pour renommer ceux qui sont là.

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
