# Object support

| Type | Native PowerPoint result | v0.1 status |
|---|---|---|
| `shape` | `Shapes.AddShape` plus contained `TextFrame2` | supported |
| `text` | `Shapes.AddTextbox` | supported |
| `image` | `Shapes.AddPicture` with local asset path | supported |
| `svg` | `Shapes.AddPicture` with SVG asset | supported |
| `line` | `Shapes.AddLine` | supported |
| `connector` | `Shapes.AddConnector` | supported |
| `table` | `Shapes.AddTable` from structured rows | supported |
| `chart` | `Shapes.AddChart2` and embedded chart data | supported; requires chart data/Excel integration |
| `group` | `ShapeRange.Group` using child IDs | supported after child creation |

## Style coverage

The initial engine covers geometry, rotation, z-order, stable metadata tags, solid/no fill, basic two-color gradients, line visibility/color/width/dash/transparency, text margins, font, alignment, wrapping, autosize policy, vertical alignment, basic shadow, picture insertion, chart/table data, and grouping.

Complex browser effects remain governed by declared fidelity classes. Masking, blend modes, arbitrary CSS filters, complex clip paths, and dynamic JavaScript layout are not inferred.

Every enhancement requires a schema-compatible fixture, expected compile plan, and PowerPoint regression deck before release.
