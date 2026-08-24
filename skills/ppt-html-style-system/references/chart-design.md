# Native chart design

Charts are first-class Style Pack components. Their visual treatment follows the selected pack, while their data and semantic encoding remain independent and native-editable.

## Choose from the question

- change over time: line; area only when cumulative magnitude matters;
- compare categories: sorted horizontal bars, preserving natural order only when meaningful;
- part of whole: stacked bars; pie/donut only for one whole with five or fewer clearly different parts;
- distribution: histogram; box plot for comparing group distributions;
- relationship: scatter; bubble only when a third quantitative variable is meaningful;
- signed variance: diverging bar around a meaningful zero;
- flow: Sankey only when the compiler and fallback policy explicitly support it; otherwise use a native process alternative.

Avoid dual axes, 3-D charts, decorative perspective, unexplained truncated bar baselines, and more than six equally emphasized series. Use small multiples or one highlighted series with neutral context when series count is high.

## Required structured data

Every chart object preserves chart type, categories, series names, values, number formats, units, missing values, source IDs, and formatting intent. Missing values remain gaps, not zero. Transforms, exclusions, aggregation, indexes, and calculated measures are disclosed.

## Style tokens

Each pack supplies:

- categorical colors for no more than seven unordered series;
- sequential and diverging ramps;
- positive, negative, warning, benchmark, and neutral context colors;
- plot, grid, axis, label, annotation, and background colors;
- chart font, title, label, source-note sizes, line widths, marker sizes, and corner policy.

Use direct labels when they fit. Otherwise place a legend close to the plot and preserve series order. Axes show units and readable formats such as `12k` only when the abbreviation is unambiguous. Bar charts start at zero. Line charts may use a nonzero domain only when disclosed and not misleading.

## PowerPoint object model

Emit one native `chart` object with structured data rather than dozens of shapes or a chart screenshot. Annotations that are semantically part of the chart may be native chart labels when supported; independent commentary may be a separate text or callout shape. Do not merge an independently editable chart title or source note into a decorative background object.

## Accessibility and QA

- never encode meaning by color alone; add labels, patterns where supported, or direct annotation;
- provide concise alt text stating chart purpose and key conclusion;
- maintain legible labels at the final 960 × 540 size;
- verify category order, units, number format, baseline, missing data, and source mapping;
- record native approximation or fallback when a requested chart type is not supported.
