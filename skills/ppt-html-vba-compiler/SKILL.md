---
name: ppt-html-vba-compiler
description: Validate constrained 16:9 PPT-HTML packages and compile their embedded object model into editable native PowerPoint objects through a fixed VBA engine. Use when a deck.html package is ready for deterministic compilation, compile-plan inspection, object inventory generation, or compiler diagnostics; do not use for presentation strategy or visual redesign.
---

# PPT-HTML VBA Compiler

Compile only declared PPT-HTML. Do not infer layout from arbitrary browser rendering and do not generate new VBA per deck.

## Inputs

Require `deck.html` with an embedded `script#ppt-model`. Prefer the accompanying `build-manifest.json`, `source-map.md`, and local assets. The supported canvas is 960 × 540 and schema major version 1.

Before invoking PowerPoint:

1. Run `scripts/validate_ppt_html.py` on the HTML package.
2. Run `scripts/build_compile_plan.py` when a human-readable or machine-readable object plan is useful.
3. Stop on incompatible schema, duplicate IDs, unknown object types, invalid bounds, missing assets, or undeclared fallbacks.

## Desktop compilation

On Windows with desktop PowerPoint and an approved compiler host, run `scripts/compile.ps1`. This launches PowerPoint COM and calls the fixed `CompilePptHtmlFile` VBA entry point. Request authorization immediately before launching a desktop application when the environment requires it.

Read [references/compiler-host.md](references/compiler-host.md) when creating the trusted `.pptm` or `.ppam` host. Read [references/object-support.md](references/object-support.md) for exact and fallback coverage. Read [references/errors.md](references/errors.md) when compilation fails.

## Outputs

Successful desktop compilation produces:

- `.pptx` with native PowerPoint objects;
- `compile-report.json` with versions, counts, warnings, and errors;
- object inventory records carrying stable PPT-HTML IDs in PowerPoint tags.

Do not claim visual fidelity from compilation alone. Submit HTML and PowerPoint renders plus the compiler report to the PPT QA Agent.

## Invariants

- A shape containing text becomes one Shape with `TextFrame2`.
- Structured charts become native Chart objects.
- Structured tables become native Table objects.
- Unknown types or incompatible major versions fail closed.
- Raster and SVG fallbacks are explicit.
- The compiler never rewrites deck content or changes the story.
