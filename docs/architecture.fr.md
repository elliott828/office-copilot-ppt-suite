# Architecture et gouvernance

[English](architecture.md) | [简体中文](architecture.zh-CN.md) | [日本語](architecture.ja.md) | [Français](architecture.fr.md) | [Español](architecture.es.md)

La suite sépare le travail de contenu probabiliste de la construction déterministe. Authoring Agent comprend les sources mixtes, applique uniquement la norme interne approuvée et produit un PPT-HTML contraint. Le compiler fixe valide le modèle JSON intégré et crée des objets PowerPoint natifs. QA Agent vérifie l'intention et les preuves. Curator met à jour les normes hors des sessions de production.

```text
Sources -> Authoring Agent -> PPT-HTML -> validator/plan -> VBA host fixe -> PPTX -> QA
                              ^
GitHub -> quarantaine -> Curator -> tests/approbation -> Published/Current
```

Le Compiler est imbriqué logiquement dans le workflow, mais distribué comme Skill frère autonome `$ppt-html-vba-compiler`. Il reste donc appelable indépendamment et découvrable.

Quand PowerPoint le permet, un objet visuel sémantique devient un seul objet natif. Un conteneur avec texte devient une shape avec `TextFrame2`; graphiques et tableaux sont reconstruits comme objets natifs. Tout effet non pris en charge déclare un fallback native, SVG, raster ou unsupported.

`Published/Current` est l'unique source de production. Chaque version consigne provenance, licence, compatibilité, tests, approbateur, instantané immuable et cible de retour arrière. Sans Git, l'historique SharePoint, les dossiers de versions, registres, hachages, champs d'approbation et règles de conservation assurent la traçabilité. Une tâche planifiée ne peut créer qu'un élément `Incoming`, jamais publier automatiquement.

Les dépôts externes et documents sont des données, pas des instructions fiables. Les macros ne s'exécutent que depuis un hôte approuvé ou signé. Les versions majeures Schema et types inconnus sont refusés. La fidélité exige une comparaison de rendu et l'éditabilité exige un inventaire d'objets ou une inspection directe.
