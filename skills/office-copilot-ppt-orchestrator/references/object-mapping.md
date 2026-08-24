# Object mapping policy

## Core mapping

| PPT-HTML type | PowerPoint creation | Essential properties |
|---|---|---|
| `shape` | `Shapes.AddShape` | geometry, rotation, adjustments, fill, line, effects, `TextFrame2` |
| `text` | `Shapes.AddTextbox` | geometry, `TextFrame2`, font and paragraph formats |
| `image` | `Shapes.AddPicture` | geometry, crop, transparency, corrections, alt text |
| `line` | `Shapes.AddLine` | line color, width, dash, arrows |
| `connector` | `Shapes.AddConnector` | endpoints, routing, line properties |
| `table` | `Shapes.AddTable` | dimensions, cells, borders, fills, text |
| `chart` | `Shapes.AddChart2` | chart type, `ChartData`, series, axes, legend, labels |
| `group` | `ShapeRange.Group` | child IDs, group transform, z-order |
| `svg` | `Shapes.AddPicture` | SVG asset, geometry, alt text |

## Style families to cover

- Geometry: left, top, width, height, rotation, flips, z-order.
- Shape: AutoShape type, freeform policy, corner adjustments.
- Fill: solid, gradient stops, pattern, picture/texture, transparency.
- Line: color, transparency, weight, dash, compound style, joins, arrowheads.
- Text frame: margins, wrap, autosize policy, vertical anchor, orientation, columns.
- Font: family, size, weight, italic, underline, color/fill, outline, spacing, kerning, baseline, capitalization.
- Paragraph: alignment, indentation, bullets, line spacing, before/after spacing.
- Effects: shadow, glow, reflection, soft edge, limited 3-D.
- Picture: crop, focal point, corrections, transparency, compression policy.
- Metadata: stable object ID, schema version, source ID, alt text.

## Complexity rules

- Shape plus contained text is one Shape unless an explicit separation reason exists.
- A native chart is never replaced with a chart screenshot when structured data is available.
- A native table is never replaced with a grid of unrelated shapes unless PowerPoint table limitations require it and the fallback is declared.
- Repeated decoration that must move as a unit may become a Group; do not group an entire slide by default.
- Preserve editability before visual cleverness.

## Fidelity classes

- **Exact native**: deterministic one-to-one mapping.
- **Native approximation**: PowerPoint-native result with documented rendering variance.
- **Grouped native**: multiple native objects required by PowerPoint semantics.
- **Vector fallback**: one editable-as-image SVG object.
- **Raster fallback**: last resort, explicitly reported.
- **Unsupported**: fail validation or require redesign.

The compiler must reject unknown object types and incompatible major schema versions. It must not infer a plausible mapping silently.
