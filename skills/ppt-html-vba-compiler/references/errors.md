# Compiler errors

| Error | Meaning | Action |
|---|---|---|
| Missing `ppt-model` | HTML has no embedded compiler model | Regenerate the PPT-HTML package |
| Unsupported schema major | Compiler cannot safely interpret the model | Use a compatible compiler or migrate the package |
| Duplicate ID | Stable object identity is ambiguous | Fix the authoring output |
| Unknown type | No deterministic mapping exists | Redesign or add a versioned mapping |
| Missing asset | Image/SVG path cannot be resolved | Package the local asset and update its path |
| Chart data unavailable | Native chart cannot be populated | Add categories and series; do not silently rasterize |
| Macro blocked | Office security prevented execution | Use an approved signed host or trusted location |
| PowerPoint unavailable | Desktop COM cannot start | Run validation only and hand off to an approved Windows environment |

When compilation fails, keep the invalid package and report unchanged. Do not modify the user's source automatically.
