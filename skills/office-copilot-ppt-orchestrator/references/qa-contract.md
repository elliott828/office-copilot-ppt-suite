# PPT QA contract

QA reports only what the supplied evidence can prove.

## Evidence modes

1. **HTML preflight**: HTML, embedded manifest, assets, and build manifest.
2. **Structural PowerPoint QA**: PPTX object inventory or extracted object metadata plus compiler report.
3. **Visual QA**: HTML slide renders and PowerPoint/PDF slide renders at the same dimensions.

Missing post-build evidence does not fail HTML preflight, but the report must label structural and visual results as `not-tested`.

## Required gates

- Compatible standard, schema, and compiler versions.
- Exactly 960 × 540 slide coordinate system.
- Stable and unique slide/object IDs.
- All object bounds and z-order declared.
- No unintended overflow, clipping, overlap, or hidden text.
- No unknown object types or undeclared fallbacks.
- Shape-contained text remains within the same Shape.
- Charts and tables remain native when required.
- Fonts are approved or have declared substitutes.
- Assets resolve and include provenance/hash where required.
- Accessibility metadata is present for meaningful visuals.
- No Draft, Incoming, or historical rule source influenced production output.

## Severity

- `BLOCKER`: cannot compile, corrupt output, incompatible schema, missing evidence presented as passed.
- `HIGH`: content loss, unreadable text, wrong data, large geometry error, unexpected rasterization.
- `MEDIUM`: visible fidelity problem, inconsistent spacing, accessibility omission, editability degradation.
- `LOW`: minor polish issue with no material content or workflow impact.

## Output

Produce a concise executive verdict plus machine-readable findings. Every finding includes slide ID, object ID when available, evidence, expected behavior, observed behavior, severity, and recommended correction. Separate confirmed defects from uncertain observations.

A deck passes only when there are no BLOCKER or HIGH findings and every mandatory evidence mode requested by the user has actually been tested.
