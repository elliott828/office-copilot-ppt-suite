# PPT-HTML contract

PPT-HTML is a constrained static authoring format, not arbitrary browser HTML.

## Coordinate system

- One slide is exactly 960 × 540 logical units.
- Use absolute final coordinates.
- Map one HTML coordinate unit to one PowerPoint point.
- No final Flexbox or Grid dependency; the authoring model may reason with them, but emitted objects must have resolved bounds.
- Bounds must stay within the slide unless the manifest explicitly declares intentional clipping.

## Required document metadata

The HTML root contains:

```html
<meta name="ppt-html-schema" content="1.0.0">
<meta name="ppt-standard-version" content="0.1.0">
<meta name="ppt-min-compiler" content="0.1.0">
```

Each slide is a `section.ppt-slide` with a stable `data-slide-id`. Each object has a unique `data-ppt-id`, a `data-ppt-type`, and explicit `data-x`, `data-y`, `data-w`, `data-h` values.

## Semantic object rule

A single semantic visual object should normally become one PowerPoint object. A container with fill, border, effects, and text maps to one Shape using `TextFrame2`. Use a separate textbox only when the text is independently positioned, animated, linked, or edited as a separate semantic object.

## Supported object families

- `shape`
- `text`
- `image`
- `line`
- `connector`
- `table`
- `chart`
- `group`
- `svg`

Charts include chart type, categories, series, and formatting data. Tables include rows, columns, spans, cell text, and cell styles. Images include source, crop mode, alt text, and optional focal point.

## Styling

Use declared data attributes or the embedded `ppt-model` as the compilation source of truth. CSS provides browser preview only. Avoid relying on cascading, inheritance, pseudo-elements, JavaScript layout, browser filters, masks, blend modes, or unbounded web fonts.

Every unsupported visual uses one of these explicit dispositions:

- `native-approximation`
- `grouped-native`
- `svg-fallback`
- `raster-fallback`
- `unsupported`

Silent rasterization is prohibited.

## Embedded manifest

Include a `<script id="ppt-model" type="application/json">` block containing slide and object records. The VBA compiler reads the manifest rather than reverse-engineering computed CSS. HTML preview and PowerPoint generation therefore share a single object model.

## Output package

```text
deck.html
build-manifest.json
source-map.md
assets/
```

The build manifest records source versions, requested fonts, asset hashes, fallbacks, unresolved assumptions, and target compiler version.
