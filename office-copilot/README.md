# Office Copilot deployment

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Español](README.es.md)

This directory is the copy/paste deployment kit for Microsoft 365 Copilot Agent Builder. Microsoft 365 Copilot does not install these repository Skills. It uses the three agent prompts and approved SharePoint knowledge instead.

## Prerequisites

- Microsoft 365 Copilot Agent Builder and an approved SharePoint document library
- PowerPoint for Windows for the desktop compilation step
- an approved macro policy and a trusted or signed `.pptm`/`.ppam` compiler host
- named owners for authoring, curation, QA, security, and release approval

## Deployment

1. Copy `../shared-library-template/PPT-Skill-Library` to SharePoint without changing its folders.
2. Run `python ../tools/configure_package.py --root-url "https://TENANT.sharepoint.com/sites/SITE/LIBRARY/PPT-Skill-Library" --output PATH` or replace `{{SHARED_LIBRARY_ROOT_URL}}` manually.
3. In Agent Builder, paste each `*-agent-generator.txt` into a separate new agent conversation. The generator returns the name, description, Instructions, knowledge paths, and test prompts.
4. Authoring and QA agents may read only `Published/Current`. The Curator may access `Registry`, `Incoming`, `Draft`, `Test`, `Published/Current`, and `Published/Releases`.
5. If a tenant cannot use the generator prompts, paste the matching file under `instructions/` directly into the Instructions field.
6. Build the approved compiler host from `../skills/ppt-html-vba-compiler/vba/`; see its `references/compiler-host.md`.
7. Test privately with `../ppt-html/examples/sample-deck/deck.html`, inspect the object inventory, and publish only after human approval.

The prompts are normative English so one controlled copy can serve a multilingual tenant. Each agent is instructed to answer in the user's language. Localize labels if desired, but do not translate paths, placeholders, Schema keys, commands, or version strings.

## Runtime flow

User context → Authoring Agent → constrained PPT-HTML + manifest → fixed VBA compiler → native PowerPoint objects → QA Agent → human approval.

Copilot prepares, reviews, and explains artifacts; it must not claim that it executed desktop VBA. External GitHub content is quarantined until the Curator records provenance and license, tests it, obtains approval, and publishes an immutable internal release.
