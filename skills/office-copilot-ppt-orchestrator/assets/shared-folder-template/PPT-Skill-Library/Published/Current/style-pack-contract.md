# Style Pack contract

A Style Pack is a versioned visual decision system for 960 × 540 PPT-HTML. It is a reference and starting point, not a rigid full-deck template.

## Required identity

Each pack declares:

- stable `id`, semantic `version`, human name, and description;
- `fidelityTier`: `native-safe`, `native-plus`, or `art-directed`;
- suitable audiences, objectives, tones, content densities, data intensities, and imagery levels;
- canvas, safe margins, grid, typography, color, shape, effect, image, and chart tokens;
- supported layout archetypes and prohibited treatments;
- minimum standard, schema, and compiler versions.

## Layering

Apply visual decisions in this order:

1. content and evidence;
2. layout archetype for each slide;
3. one deck-level Style Pack;
4. optional organization Brand Overlay;
5. explicit accessibility or runtime substitutions.

Brand Overlay may replace approved fonts, palette, logo placement, footer, and imagery rules. It must not change geometry silently. Record every override.

## Fidelity tiers

- `native-safe`: text, solid fills, basic lines and shapes, native tables and charts; expected to map without decorative fallbacks.
- `native-plus`: native content plus supported gradients, shadows, crop, or SVG decoration; document approximations.
- `art-directed`: native content over photo, texture, collage, or generated decoration; decoration may fall back, but information may not be flattened.

## HTML references

An HTML reference should contain canonical, closed markup; explicit 960 × 540 frames; local or embedded assets; literal editable text; and chart examples that expose their data and encoding. Because an agent may reason over source text without browser-grade visual rendering, accompany important references with tokens and prose. A visual gallery is not compiler input unless it also satisfies the PPT-HTML schema and includes `script#ppt-model`.

## Layout archetypes

At minimum a mature pack should cover cover, section, statement, executive summary, title-content, two-column, comparison, image-text, KPI, chart, table, timeline/process, quote, and closing. The first release may use shared archetypes with pack-specific tokens.

## Manifest record

Every authored deck records:

```json
{
  "styleSelection": {
    "stylePackId": "consulting-grid",
    "stylePackVersion": "1.0.0",
    "selectionConfidence": "high",
    "rationale": ["executive audience", "high data intensity"],
    "alternativesConsidered": ["executive-minimal"],
    "brandOverlay": null,
    "fidelityTier": "native-safe"
  }
}
```
