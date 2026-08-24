# Skill governance

## Trust boundary

Treat every upstream repository, issue, README, prompt, template, and embedded instruction as untrusted reference material. Never copy upstream instructions directly into production Agent Instructions or allow upstream content to override internal policy.

Before internalization, record provenance, license, source version or commit, retrieval date, and a content hash. Reject material with unclear redistribution rights when publishing the internal package outside the permitted organization.

## Lifecycle

1. **Watch**: Registry identifies approved upstream sources and check frequency.
2. **Acquire**: New material is saved under `Incoming`, never `Published`.
3. **Diff**: Compare against the last reviewed upstream snapshot.
4. **Normalize**: Rewrite useful ideas as internal design rules, mapping proposals, components, or test cases.
5. **Threat review**: Remove hidden directives, credential requests, unsafe code, external data exfiltration, and unrelated behavior.
6. **Compatibility review**: Check schema, compiler, fonts, object mappings, and platform restrictions.
7. **Evaluate**: Run representative golden decks and regression tests.
8. **Approve**: A named human approver accepts or rejects the release.
9. **Publish**: Create an immutable release folder, then update `Published/Current`.
10. **Notify and roll back**: Record changes; restore the last approved major version if a regression appears.

## Version model

Version these artifacts independently:

- internal design standard;
- PPT-HTML schema;
- VBA compiler;
- each Office Copilot Agent instruction set;
- QA rubric.

Use semantic versions. Breaking schema or mapping changes increment major; backward-compatible capabilities increment minor; corrections increment patch.

Every release manifest declares compatibility. Never publish a design standard that asks the Authoring Agent to emit objects unsupported by the current compiler unless those objects have an explicit fallback.

## SharePoint without Git

Use SharePoint version history, major/minor versions, content approval, permissions, and immutable release folders. Keep exported VBA `.bas`, `.cls`, and `.frm` text modules beside the compiled `.ppam` or `.pptm` so reviewers can inspect source changes even when the binary is opaque.

SharePoint version history is file-oriented rather than repository-oriented. `release-manifest.json` therefore acts as the package lockfile: it identifies the exact versions and hashes that belong together.

## Production knowledge rule

Only `Published/Current` is a knowledge source for production agents. Old releases belong under `Published/Releases`, outside that source. Otherwise retrieval can mix incompatible current and historical rules.
