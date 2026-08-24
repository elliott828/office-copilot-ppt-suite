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

## Logique de fond de l’architecture

1. **Partir des contraintes de l’entreprise.** De nombreuses organisations disposent de Microsoft 365 Copilot sans autoriser les Skills communautaires, les paquets arbitraires ni l’exécution directe de code téléchargé. Les points d’extension disponibles sont alors les Copilot Agents, les connaissances SharePoint approuvées et l’automatisation locale contrôlée. Le dépôt respecte cette frontière au lieu de supposer un poste de développement sans restrictions.
2. **Utiliser HTML comme surface de conception.** Les méthodes actuelles de génération de présentations et de pages Web sont particulièrement efficaces pour composer une mise en page avec HTML et CSS. Un canevas 16:9 fixe rend les positions et dimensions prévisibles : la composition visuelle peut donc être réalisée en HTML avant la construction PowerPoint.
3. **Compiler un contrat, pas une page Web quelconque.** PPT-HTML est un format restreint fondé sur un repère 960 × 540 et un modèle JSON sémantique intégré. Le Compiler lit ce modèle sans tenter de reconstituer tout le DOM et la cascade CSS. Le périmètre de mappage reste ainsi fini, testable et versionné.
4. **Conserver un Compiler fixe.** L’Agent produit un modèle de présentation différent pour chaque demande, mais ne réécrit pas le moteur de conversion VBA. Un Compiler stable peut être contrôlé, signé, testé en régression et approuvé une fois, tandis que seul le contenu varie.
5. **Préserver l’édition native sans multiplier les objets.** Lorsqu’il existe un équivalent dans le PowerPoint object model, un objet visuel sémantique devient un seul objet PowerPoint. Un conteneur stylé avec texte devient une shape avec `TextFrame2`, et non une shape de fond accompagnée d’une textbox. Les tableaux et graphiques conservent des données de reconstruction afin de rester natifs.
6. **Internaliser les Skills externes sous gouvernance.** Les Skills GitHub en amont sont considérés comme des sources de recherche non fiables. Curator consigne la provenance et la licence, extrait les méthodes utiles, teste la compatibilité, obtient une approbation humaine et publie une norme interne. Les Agents de production ne lisent que `Published/Current`, ce qui empêche une évolution externe de modifier silencieusement la production courante.
7. **Séparer les responsabilités.** La création, la curation, la compilation et le QA n’ont ni les mêmes échecs ni le même rythme de version. Ils sont répartis entre des Agents ou capacités distincts avec des livrables de transfert explicites. Le Compiler est logiquement imbriqué dans le workflow, mais physiquement distribué comme Skill frère `$ppt-html-vba-compiler`, afin de rester détectable et appelable seul.
8. **Exiger des preuves plutôt que des affirmations optimistes.** Les versions majeures Schema et types d’objets inconnus sont refusés. La fidélité visuelle exige une comparaison de rendu, l’édition native un inventaire ou une inspection directe, et la compilation locale des fichiers de sortie accompagnés d’un compile report. Le modèle de langage ne doit pas prétendre avoir exécuté VBA lorsqu’il n’a fait que préparer les entrées.

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
