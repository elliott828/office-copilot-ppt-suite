# Compiler host

The fixed VBA source lives under `vba/`. Build a trusted macro host once; do not embed newly generated VBA in each deck.

## PowerPoint host

1. Create a macro-enabled PowerPoint file (`.pptm`) or add-in (`.ppam`) in desktop PowerPoint for Windows.
2. Import `vendor/Dictionary.cls`.
3. Import `vendor/JsonConverter.bas`.
4. Import `PptHtmlCompiler.bas`.
5. Save the host in an organization-approved trusted location or sign it according to company policy.
6. Test the host with `tests/fixtures/sample-deck.html`.

The resulting user deck is saved as a normal `.pptx`; it does not need to contain macros.

## Entry point

```vb
CompilePptHtmlFile HtmlPath, OutputPath, ReportPath
```

All paths must be absolute. The macro reads UTF-8 HTML, extracts the embedded JSON model, creates a new presentation, and writes a JSON compile report.

## Automation

`scripts/compile.ps1` opens the host in desktop PowerPoint and invokes the entry point. Macro policy, trusted locations, code signing, DLP, and endpoint automation policy remain under organizational control.

Programmatic access to the VBA project is not required at runtime because modules are imported when the host is built, not injected for every deck.
