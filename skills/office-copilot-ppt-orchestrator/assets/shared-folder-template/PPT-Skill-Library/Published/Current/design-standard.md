# Internal PPT design standard 0.1.0

## Outcome

Create decision-ready 16:9 presentations whose content is traceable, whose layout is deliberate, and whose major elements remain editable as native PowerPoint objects.

## Narrative

- Give each content slide one main message.
- Prefer takeaway titles over topic labels.
- Separate source facts, calculations, inference, and recommendation.
- Use the fewest slides that preserve the decision logic; do not compress unreadably to hit an arbitrary count.
- Match the visual form to the reasoning: comparison, sequence, hierarchy, relationship, trend, distribution, composition, or evidence.

## Canvas and grid

- Slide canvas: 960 × 540 logical units.
- Default safe margin: 36 units.
- Default content grid: 12 columns with consistent gutters.
- Use an 8-unit spacing rhythm where practical; exceptions must be intentional.
- Important objects should align to a shared edge or centerline.

## Typography

- Use organization-approved installed fonts. Declare every fallback.
- Default title range: 26–34 units.
- Default body range: 14–20 units.
- Avoid body text below 12 units except legal/source notes.
- Prefer weight, size, and spacing hierarchy before adding decorative colors.
- Do not rely on PowerPoint auto-shrink as the normal fit mechanism.

## Color and effects

- Use a restrained palette with one primary accent and limited semantic colors.
- Meet organizational accessibility requirements; do not encode meaning by color alone.
- Use gradients, shadows, glow, reflection, soft edges, and 3-D only when the mapping specification supports them and they clarify hierarchy.
- Prefer native approximation over rasterization for noncritical effect differences.

## Images

- Record source and usage rights.
- Preserve aspect ratio unless intentional distortion is declared.
- Use explicit crop mode and focal point.
- Add concise alt text for meaningful images; mark decorative images accordingly.

## Charts and data

- State the insight in the title or annotation.
- Preserve structured source data for native Chart creation.
- Keep axes, units, time periods, categories, and calculations unambiguous.
- Avoid 3-D charts and decorative chart effects that impair comparison.
- Use consistent number formats and disclose transformed or indexed data.

## Tables

- Use native tables for structured grids.
- Emphasize the comparison path; do not apply heavy borders to every cell by default.
- Keep numeric alignment and formats consistent.

## Native-object simplicity

- One semantic shape with contained text becomes one PowerPoint Shape with TextFrame2.
- Use a separate textbox only for independently positioned or independently editable text.
- Do not construct charts from dozens of decorative shapes when native Chart supports the requirement.
- Group only elements that should behave as a unit.
- Declare SVG and raster fallbacks in the build manifest.

## Approved layout archetypes

- Hero/title statement
- Executive summary
- KPI strip
- Two-column comparison
- Problem/evidence/implication
- Process or journey
- Timeline or roadmap
- Matrix or quadrant
- Before/after
- Data chart with annotation
- Table with highlighted decision cells
- Portfolio/gallery
- Quote or customer evidence
- Closing decision and next actions

These are archetypes, not templates to repeat mechanically. Choose the structure that best represents the content.
