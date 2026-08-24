# Using the Skills

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Español](README.es.md)

Copy any complete directory into the Skills location of a `SKILL.md`-compatible agent runtime:

- `office-copilot-ppt-orchestrator`: configures the Copilot agents, shared library, governance, authoring contract, and QA workflow.
- `ppt-html-style-system`: matches content to approved 16:9 Style Packs, layout archetypes, and native chart treatments.
- `ppt-html-vba-compiler`: independently validates PPT-HTML, creates a deterministic compile plan, and invokes an approved fixed VBA host when available.

Example calls:

```text
Use $office-copilot-ppt-orchestrator to prepare this tenant's deployment bundle.
Use $ppt-html-style-system to choose the best approved style and chart treatment for this deck.
Use $ppt-html-vba-compiler to validate deck.html and compile it with the approved host.
```

The Orchestrator may delegate style selection to the Style System and a validated HTML artifact to the Compiler, but the directories remain siblings. Nested Skill directories are not reliably discovered by every runtime. The Compiler must not redesign slides, infer unknown types, inject new VBA into every document, or claim compilation without output evidence.

Microsoft 365 Copilot users do not install these Skills. They use the copy/paste files in `../office-copilot/`; the same contracts are internalized through Agent Instructions and SharePoint knowledge.
