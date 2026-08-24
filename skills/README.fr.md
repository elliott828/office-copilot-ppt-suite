# Utiliser les Skills

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Español](README.es.md)

Copiez l'un des dossiers complets dans l'emplacement Skills d'un environnement compatible avec `SKILL.md` :

- `office-copilot-ppt-orchestrator` configure les Agents Copilot, la bibliothèque, la gouvernance, le contrat de création et le QA.
- `ppt-html-vba-compiler` valide PPT-HTML de manière autonome, produit un plan déterministe et appelle un VBA host fixe approuvé lorsqu'il est disponible.

```text
Use $office-copilot-ppt-orchestrator to prepare this tenant's deployment bundle.
Use $ppt-html-vba-compiler to validate deck.html and compile it with the approved host.
```

L'Orchestrator peut transmettre le HTML validé au Compiler, mais les dossiers restent frères car tous les environnements ne découvrent pas les Skills imbriqués. Le Compiler ne doit ni remanier les diapositives, ni deviner des types inconnus, ni injecter un nouveau VBA par document, ni annoncer une compilation sans preuve.

Les utilisateurs Microsoft 365 Copilot n'installent pas ces Skills. Ils utilisent les fichiers de `../office-copilot/`, et les mêmes contrats sont intégrés dans Agent Instructions et SharePoint.
