# Déploiement Office Copilot

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Español](README.es.md)

Ce dossier est le kit de déploiement à copier dans Microsoft 365 Copilot Agent Builder. Microsoft 365 Copilot n'installe pas les Skills du dépôt : il utilise les trois Agent Prompts et les connaissances SharePoint approuvées.

## Prérequis

- Agent Builder et une bibliothèque SharePoint approuvée
- PowerPoint pour Windows pour la compilation locale
- une politique de macros approuvée et un hôte `.pptm`/`.ppam` approuvé ou signé
- des responsables désignés pour la création, la curation, le QA, la sécurité et les versions

## Déploiement

1. Copiez `../shared-library-template/PPT-Skill-Library` dans SharePoint sans modifier sa structure.
2. Exécutez `python ../tools/configure_package.py --root-url "https://TENANT.sharepoint.com/sites/SITE/LIBRARY/PPT-Skill-Library" --output PATH` ou remplacez `{{SHARED_LIBRARY_ROOT_URL}}`.
3. Dans Agent Builder, collez chaque `*-agent-generator.txt` dans une nouvelle conversation Agent distincte.
4. Authoring et QA ne consultent que `Published/Current`. Curator peut consulter `Registry`, `Incoming`, `Draft`, `Test`, `Published/Current` et `Published/Releases`.
5. Si les Generator Prompts ne sont pas disponibles, collez directement le fichier correspondant de `instructions/` dans Instructions.
6. Créez l'hôte de compilation approuvé depuis `../skills/ppt-html-vba-compiler/vba/` ; voir `references/compiler-host.md`.
7. Testez en privé avec `../ppt-html/examples/sample-deck/deck.html`, contrôlez l'inventaire d'objets, puis publiez après validation humaine.

Les Prompts normatifs restent en anglais afin de servir un environnement multilingue contrôlé ; les Agents répondent dans la langue de l'utilisateur. Les libellés peuvent être traduits, mais pas les chemins, espaces réservés, clés Schema, commandes ni versions.

## Flux d'exécution

Contexte utilisateur → Authoring Agent → PPT-HTML contraint et manifest → VBA compiler fixe → objets PowerPoint natifs → QA Agent → approbation humaine.

Copilot prépare, révise et explique les artefacts ; il ne doit pas prétendre avoir exécuté VBA. Le contenu GitHub externe reste en quarantaine jusqu'au contrôle de provenance et de licence, aux tests, à l'approbation et à la publication d'une version interne immuable.
