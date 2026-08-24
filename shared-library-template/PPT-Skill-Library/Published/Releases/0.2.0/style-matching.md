# Style matching

Match from the user's content and setting, not from personal taste or a fixed default.

## Signals

Extract these signals when available:

- audience: board, executive, client, specialist, general internal, public;
- objective: decide, align, persuade, inform, explain, teach, inspire;
- delivery: live presentation, read-ahead, workshop, leave-behind;
- content density: low, medium, high;
- data intensity: low, medium, high;
- imagery availability: none, limited, strong;
- tone: restrained, authoritative, analytical, technical, editorial, expressive, cinematic;
- brand strictness: none, flexible, strict;
- accessibility, language, confidentiality, and runtime constraints.

Do not ask for a signal already inferable from the context. Ask only when competing choices would change the structure or risk acceptance.

## Scoring

For each compatible pack, add:

- `+3` audience and objective both match;
- `+2` data intensity matches;
- `+2` content density matches;
- `+2` tone matches;
- `+1` imagery level matches;
- `+1` delivery mode matches;
- `+1` fidelity tier meets runtime needs.

Subtract:

- `-4` imagery-dependent pack with no usable imagery;
- `-4` art-directed pack when all content must remain native-safe;
- `-3` density mismatch;
- `-3` tone conflicts with audience or confidentiality;
- `-2` pack relies on unavailable fonts or unapproved assets.

Choose the highest compatible score. If the lead is at least three points and no brand conflict exists, proceed and state the choice. Otherwise present at most three materially different options with one-sentence trade-offs. A user choice overrides the score when it remains compatible and accessible.

## Layout matching

- single claim or decision: statement or hero;
- prioritized findings: executive summary;
- category comparison: comparison or aligned bars;
- change over time: chart with annotation;
- process or sequence: process/timeline;
- relationship or positioning: matrix, scatter, or network only when supported;
- structured detail: native table;
- evidence plus interpretation: problem/evidence/implication;
- image-led narrative: image-text or full-bleed only when rights and crop are known.

## Consistency

Use one Style Pack for the deck. Vary rhythm through approved layouts, one or two backgrounds, image scale, and density. Do not switch visual systems between slides. Record pack/version and selection rationale in `build-manifest.json`.
