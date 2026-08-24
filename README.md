# Office Copilot PPT Agent Suite

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Español](README.es.md)

A deployable capability pack for producing editable, native-object PowerPoint presentations in restricted Microsoft 365 Copilot environments.

> This repository is not a natively installable Microsoft 365 Copilot Skill. It delivers reusable capabilities through Copilot agents, governed SharePoint knowledge, a constrained PPT-HTML format, and a fixed VBA compiler. Platforms that support `SKILL.md` can install the Skills under `skills/`.

## What is included

| Component | Purpose |
|---|---|
| PPT Authoring Agent | Converts chat and Word, PowerPoint, Excel, PDF, text, HTML, Markdown, and image context into 16:9 PPT-HTML |
| PPT Skill Curator | Reviews upstream presentation skills and publishes approved internal standards through a controlled release process |
| PPT QA Agent | Audits schema, native-object editability, geometry, visual fidelity, content integrity, and accessibility |
| PPT-HTML Style System Skill | Matches user context to a versioned 16:9 Style Pack, layout archetype, and native-editable chart treatment |
| PPT-HTML VBA Compiler Skill | Validates PPT-HTML and compiles the embedded model into native PowerPoint objects through a fixed VBA engine |
| Orchestrator Skill | Deploys and maintains the complete Office Copilot agent suite |
| Shared library template | Provides `Incoming`, `Draft`, `Test`, `Registry`, `Published/Current`, and immutable release areas |

## Why this architecture exists

1. **Start from the enterprise constraint.** Many organizations provide Microsoft 365 Copilot but do not allow community Skills, arbitrary packages, or direct execution of downloaded code. The usable extension points are Copilot Agents, approved SharePoint knowledge, and controlled desktop automation. The repository is designed around that boundary rather than assuming an unrestricted developer workstation.
2. **Use HTML as the design surface.** Current presentation and web-generation methods are strongest at composing layouts in HTML and CSS. A fixed 16:9 canvas makes positions and dimensions predictable, so visual composition can happen in HTML before PowerPoint construction begins.
3. **Compile a contract, not arbitrary web pages.** PPT-HTML is a restricted authoring format with a 960 × 540 coordinate system and an embedded semantic JSON model. The compiler reads that model instead of reverse-engineering the full DOM and CSS cascade. This keeps the mapping finite, testable, and versioned.
4. **Keep the compiler fixed.** The agent produces a different deck model for each request, but it does not rewrite the VBA conversion engine. A stable compiler can be reviewed, signed, regression-tested, and approved once, while deck content remains variable.
5. **Preserve native editability without object inflation.** One semantic visual object should become one PowerPoint object whenever the PowerPoint object model supports it. A styled container with text becomes one shape with `TextFrame2`, not a background shape plus a separate textbox. Tables and charts carry reconstruction data so they can remain native tables and charts.
6. **Internalize external Skills through governance.** Upstream GitHub Skills are treated as untrusted research input. The Curator records provenance and license, extracts useful patterns, tests compatibility, obtains human approval, and publishes an internal standard. Production agents read only `Published/Current`, so upstream changes cannot silently alter normal deck generation.
7. **Separate responsibilities.** Authoring, style matching, curation, compilation, and QA have different failure modes and release rhythms. They are separate agents or capabilities with explicit handoffs. The Style System and compiler are logically nested in the complete workflow but physically packaged as sibling Skills, which keeps them independently discoverable and callable.
8. **Require evidence instead of optimistic claims.** Unknown Schema major versions and object types fail closed. Visual fidelity requires render comparison; native editability requires an object inventory or direct inspection; desktop compilation requires output files and a compile report. The language model must not claim that it executed VBA when it only prepared inputs.

## Office Copilot quick start

1. Copy `shared-library-template/PPT-Skill-Library` into an approved SharePoint document library.
2. Replace `{{SHARED_LIBRARY_ROOT_URL}}` with the SharePoint URL ending in `PPT-Skill-Library`.
3. Open Microsoft 365 Copilot Agent Builder and paste each file in `office-copilot/*-agent-generator.txt`.
4. Add the knowledge folders listed in each generator prompt.
5. Build a trusted `.pptm` or `.ppam` compiler host from `skills/ppt-html-vba-compiler/vba/`.
6. Test privately before sharing the agents.

Detailed instructions are available in [the Office Copilot setup guide](office-copilot/README.md).

## Install the Skills

Copy the required directories into the Skills directory of a platform that supports `SKILL.md`:

```text
skills/office-copilot-ppt-orchestrator
skills/ppt-html-style-system
skills/ppt-html-vba-compiler
```

They can be invoked independently:

```text
Use $office-copilot-ppt-orchestrator to configure this tenant's PPT agent suite.
Use $ppt-html-style-system to match this deck to an approved 16:9 style and chart system.
Use $ppt-html-vba-compiler to validate and compile deck.html.
```

The Style System and compiler Skills are logically part of the suite but physically independent so skill discovery works reliably.

## Repository map

```text
office-copilot/           Copy/paste Agent Builder prompts and instructions
shared-library-template/  SharePoint knowledge and release template
ppt-html/                 Schema, mapping contract, and examples
skills/                   Independently discoverable Orchestrator, Style System, and Compiler Skills
docs/                     Architecture and governance documentation
tools/                    Configuration and repository validation tools
```

## Current status

This repository is an early implementation. The PPT-HTML schema, deterministic validator, object plan, VBA source, agent prompts, governance workflow, QA contract, tests, and sample deck are included. Desktop compilation still requires an organization-approved macro host and Microsoft PowerPoint for Windows. Complex browser effects must use declared native, SVG, raster, or unsupported fallbacks.

Run validation before publishing a release:

```powershell
python tools/validate_repository.py
python -m unittest discover -s skills/ppt-html-vba-compiler/tests -v
```

## Security and governance

Production agents read only `Published/Current`. GitHub content and files under `Incoming`, `Draft`, `Test`, or historical releases are not production instructions. Upstream updates require provenance, license review, compatibility tests, human approval, an immutable release snapshot, and a rollback plan.

Macros should run only from trusted or signed hosts under organizational policy. The compiler rejects unknown schema major versions and unknown object types instead of guessing.

## Documentation

- [Office Copilot setup](office-copilot/README.md)
- [Architecture and governance](docs/architecture.md)
- [Skills usage](skills/README.md)
- [PPT-HTML example](ppt-html/examples/sample-deck/deck.html)

## License

Project-authored content is provided under the MIT License. Vendored VBA dependencies retain their own MIT notices under `skills/ppt-html-vba-compiler/vba/vendor/`.
