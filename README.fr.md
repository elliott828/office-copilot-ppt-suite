# Office Copilot PPT Agent Suite

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Español](README.es.md)

Un pack de capacités déployable destiné aux environnements d’entreprise où les Skills communautaires ne peuvent pas être installés, mais où les agents Microsoft 365 Copilot sont disponibles. Il permet de produire des présentations composées d’objets PowerPoint natifs et modifiables.

> Ce dépôt n’est pas un Skill installable nativement dans Microsoft 365 Copilot. Il fournit des capacités réutilisables au moyen d’agents Copilot, de connaissances SharePoint gouvernées, d’un format PPT-HTML contraint et d’un compilateur VBA fixe. Les plateformes compatibles avec `SKILL.md` peuvent installer les deux Skills du dossier `skills/`.

## Contenu

| Composant | Fonction |
|---|---|
| PPT Authoring Agent | Transforme le chat et les contenus Word, PowerPoint, Excel, PDF, texte, HTML, Markdown et image en PPT-HTML 16:9 |
| PPT Skill Curator | Examine les Skills de présentation externes et publie des normes internes approuvées selon un processus de mise en production contrôlé |
| PPT QA Agent | Contrôle le Schema, la modification des objets natifs, la géométrie, la fidélité visuelle, l’intégrité du contenu et l’accessibilité |
| PPT-HTML VBA Compiler Skill | Valide le PPT-HTML et compile le modèle intégré en objets PowerPoint natifs avec un moteur VBA fixe |
| Orchestrator Skill | Déploie et maintient l’ensemble des agents Office Copilot |
| Modèle Shared Library | Fournit les zones `Incoming`, `Draft`, `Test`, `Registry`, `Published/Current` et les versions immuables |

## Démarrage rapide avec Office Copilot

1. Copiez `shared-library-template/PPT-Skill-Library` dans une bibliothèque de documents SharePoint approuvée.
2. Remplacez `{{SHARED_LIBRARY_ROOT_URL}}` par l’URL SharePoint se terminant par `PPT-Skill-Library`.
3. Ouvrez Microsoft 365 Copilot Agent Builder et collez chaque fichier `office-copilot/*-agent-generator.txt`.
4. Ajoutez les dossiers de connaissances indiqués dans chaque Generator Prompt.
5. Créez un hôte compilateur `.pptm` ou `.ppam` approuvé à partir de `skills/ppt-html-vba-compiler/vba/`.
6. Effectuez des tests privés avant de partager les agents.

Les étapes détaillées figurent dans le [guide de configuration Office Copilot](office-copilot/README.fr.md).

## Installer les Skills

Copiez l’un des dossiers suivants, ou les deux, dans le dossier Skills d’une plateforme compatible avec `SKILL.md` :

```text
skills/office-copilot-ppt-orchestrator
skills/ppt-html-vba-compiler
```

Ils peuvent être appelés séparément :

```text
Use $office-copilot-ppt-orchestrator to configure this tenant's PPT agent suite.
Use $ppt-html-vba-compiler to validate and compile deck.html.
```

Le Compiler Skill appartient logiquement à la suite, mais reste physiquement indépendant afin d’assurer une détection fiable des Skills.

## Organisation du dépôt

```text
office-copilot/           Prompts et Instructions à coller dans Agent Builder
shared-library-template/  Connaissances SharePoint et modèle de publication
ppt-html/                 Schema, contrat de mappage et exemples
skills/                   Deux Skills installables séparément
docs/                     Documentation d’architecture et de gouvernance
tools/                    Outils de configuration et de validation du dépôt
```

## État actuel

Ce dépôt est une première implémentation. Il contient le PPT-HTML Schema, le validateur déterministe, le plan d’objets, le code VBA, les Agent Prompts, le processus de gouvernance, le contrat QA, les tests et un exemple de présentation. La compilation sur poste de travail nécessite toujours un hôte de macros approuvé par l’organisation et Microsoft PowerPoint pour Windows. Les effets de navigateur complexes doivent déclarer un traitement natif, SVG, raster ou non pris en charge.

Avant toute publication, exécutez :

```powershell
python tools/validate_repository.py
python -m unittest discover -s skills/ppt-html-vba-compiler/tests -v
```

## Sécurité et gouvernance

Les agents de production consultent uniquement `Published/Current`. Le contenu GitHub et les fichiers placés dans `Incoming`, `Draft`, `Test` ou les anciennes versions ne constituent pas des instructions de production. Toute mise à jour externe exige une traçabilité, un examen de la licence, des tests de compatibilité, une validation humaine, un instantané immuable et un plan de retour arrière.

Les macros ne doivent être exécutées qu’à partir d’hôtes approuvés ou signés, conformément aux règles de l’organisation. Le compilateur refuse les versions majeures inconnues du Schema et les types d’objets inconnus au lieu de les deviner.

## Documentation

- [Configuration Office Copilot](office-copilot/README.fr.md)
- [Architecture et gouvernance](docs/architecture.fr.md)
- [Utilisation des Skills](skills/README.fr.md)
- [Exemple PPT-HTML](ppt-html/examples/sample-deck/deck.html)

## Licence

Le contenu créé pour ce projet est distribué sous licence MIT. Les dépendances VBA intégrées conservent leurs propres avis MIT dans `skills/ppt-html-vba-compiler/vba/vendor/`.
