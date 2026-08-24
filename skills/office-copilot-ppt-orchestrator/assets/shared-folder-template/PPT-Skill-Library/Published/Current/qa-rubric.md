# PPT QA rubric 1.0.0

## Mandatory gates

| Gate | Pass condition | Default severity when violated |
|---|---|---|
| Version compatibility | Standard, schema, and compiler versions agree | BLOCKER |
| Canvas | Every slide uses 960 × 540 | BLOCKER |
| Stable identity | Slide and object IDs are unique and traceable | HIGH |
| Bounds | No unintended off-slide object or clipping | HIGH |
| Text fit | No clipped, unreadable, or accidental overlapping text | HIGH |
| Mapping | Object types are supported and declared | BLOCKER |
| Shape complexity | Shape-contained text remains one Shape | MEDIUM |
| Chart editability | Structured chart remains native | HIGH |
| Table editability | Structured table remains native or has approved fallback | HIGH |
| Assets | Assets resolve with permitted provenance | HIGH |
| Fallback disclosure | Every approximation/fallback is declared | MEDIUM |
| Accessibility | Meaningful visuals have alt text and readable contrast | MEDIUM |
| Source integrity | Claims and values trace to supplied evidence | HIGH |

## Default tolerances

- Geometry: 2 points for left, top, width, and height.
- Rotation: 0.5 degree.
- Z-order: exact where it changes visibility or meaning.
- Text: no content loss; wrap differences are defects when they change hierarchy, alignment, or meaning.

## Verdicts

- PASS: no BLOCKER/HIGH findings and all required evidence modes tested.
- CONDITIONAL PASS: no BLOCKER/HIGH in tested scope, but a requested evidence mode is incomplete or a documented acceptance is pending.
- FAIL: any BLOCKER/HIGH finding, incompatible version, or false claim of completed testing.
