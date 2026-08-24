---
name: ppt-html-style-system
description: Match presentation content to a governed 16:9 visual style, layout archetype, and native-editable chart treatment, then author compiler-safe PPT-HTML from approved Style Packs. Use when selecting, creating, updating, or validating presentation styles and HTML templates for the Office Copilot PPT suite; do not use it to execute VBA or compile arbitrary web pages.
---

# PPT-HTML Style System

Turn presentation intent into a documented Style Pack selection before authoring slide objects. This Skill is independently callable in `SKILL.md` runtimes and is consumed as approved SharePoint knowledge by Microsoft 365 Copilot agents.

## Workflow

1. Read [references/style-matching.md](references/style-matching.md) and extract audience, objective, decision pressure, content density, data intensity, imagery availability, tone, brand strictness, and accessibility needs from the user's context.
2. Read `assets/style-catalog.json`. Score compatible packs, choose one primary pack, and retain up to two alternatives only when their trade-offs materially differ.
3. Read [references/style-pack-contract.md](references/style-pack-contract.md). Bind the deck to one pack and version; apply a separate brand overlay when supplied. Do not blend packs slide by slide.
4. For charts or quantitative evidence, also read [references/chart-design.md](references/chart-design.md). Choose the chart from the question the evidence must answer, preserve structured data, and keep it native-editable.
5. Use `assets/templates/style-gallery.html` as a visual/source reference and `assets/templates/chart-slide.html` as the canonical compiler-safe chart-slide example.
6. Record the selection, version, rationale, rejected alternatives, brand overlay, chart decisions, and any fallback in the build manifest.

## Invariants

- Every slide is 960 × 540. Final compiler geometry is absolute even when exploratory HTML used layout helpers.
- Semantic content remains native: text, shapes, charts, tables, lines, connectors, and supported images. Decorative art may use a declared SVG or raster fallback.
- A styled shape with contained text is one shape with text, not a shape plus an unnecessary textbox.
- Style never changes facts, calculations, citations, or the meaning of the visual encoding.
- Use no more than one primary style pack per deck. Section variation comes from the pack's own layout and background rules.
- Do not imitate a living artist's signature style or copy unlicensed commercial templates.
- Do not claim the visual HTML reference is itself compiler input unless it contains a valid embedded `ppt-model`.

## Office Copilot packaging

Microsoft 365 Copilot does not install this Skill. Publish the approved files from `assets/` and the normalized reference rules into `Published/Current`, then update the Authoring, Curator, and QA Agent Instructions to use them. The Authoring Agent performs the match during each deck task; the Curator versions the packs; QA verifies selection, adherence, accessibility, and native chart structure.
