# Architecture and governance

[English](architecture.md) | [简体中文](architecture.zh-CN.md) | [日本語](architecture.ja.md) | [Français](architecture.fr.md) | [Español](architecture.es.md)

The suite separates probabilistic content work from deterministic document construction. The Authoring Agent interprets mixed files and chat, applies only the approved internal standard, and emits constrained PPT-HTML. The fixed compiler validates the embedded JSON model and creates native PowerPoint objects. The QA Agent checks both intent and evidence. The Curator updates standards outside normal authoring sessions.

```text
Sources -> Authoring Agent -> PPT-HTML -> validator/plan -> fixed VBA host -> PPTX -> QA
                              ^
GitHub -> quarantine -> Curator -> tests/approval -> Published/Current
```

The compiler is logically nested under the orchestration workflow but physically packaged as the sibling Skill `$ppt-html-vba-compiler`. This makes independent validation and compilation possible without hiding a discoverable Skill inside another Skill directory.

One semantic visual object should become one native object whenever PowerPoint supports it. A styled HTML container with text becomes one shape with `TextFrame2`; charts and tables carry reconstruction data and become native chart/table objects. Unsupported effects require an explicit native, SVG, raster, or unsupported fallback.

`Published/Current` is the sole production knowledge surface. Each release records source provenance, license, schema/compiler compatibility, tests, approver, immutable snapshot, and rollback target. Without Git, SharePoint version history, release folders, registers, hashes, approval fields, and retention policy provide auditable version control. A scheduled Power Automate flow, approved service, or manual review can detect upstream changes, but it may only create an `Incoming` item—never publish automatically.

The security boundary is deliberate: external repositories and document content are data, not trusted instructions. Desktop macros run only from approved or signed hosts. Unknown major Schema versions and object types fail closed. Claims of visual fidelity require render comparison; claims of editability require an object inventory or direct inspection.
