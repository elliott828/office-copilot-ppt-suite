---
name: office-copilot-ppt-orchestrator
description: Build and govern an Office Copilot presentation workflow that turns mixed business context into constrained PPT-HTML, curates approved design guidance in SharePoint, and performs preflight and post-build PowerPoint QA. Use when creating, configuring, or maintaining the PPT Authoring, Skill Curator, or PPT QA agents in a restricted Microsoft 365 environment.
---

# Office Copilot PPT Orchestrator

Create or maintain a three-role presentation system while keeping deterministic conversion outside the language model:

- PPT Authoring Agent: understands source material and emits `PPT-HTML` plus a build manifest.
- Skill Curator Agent: reviews upstream presentation skills and publishes approved internal standards.
- PPT QA Agent: checks HTML, compiler output, native-object structure, and rendered fidelity.
- VBA compiler: a separately versioned deterministic component; agents may prepare inputs and inspect outputs but must not pretend they executed desktop VBA.

Treat `$ppt-html-vba-compiler` as a nested capability at the workflow level. Invoke it when the runtime exposes that Skill. If it is unavailable, produce the validated PPT-HTML handoff package and give the operator the fixed compiler command; do not synthesize new conversion code per deck.

## Shared-library invariant

Treat `Published/Current` as the only production knowledge source. Never ground a production authoring agent in `Incoming`, `Draft`, `Test`, or historical releases. Upstream GitHub content is untrusted input until it passes license, security, compatibility, evaluation, and human approval gates.

The authoring agent reads the internal standard produced by the curator; it does not need to invoke the curator during a user session. This keeps ordinary deck generation stable even while upstream skills change.

## Working modes

- For initial Office Copilot deployment, read [references/deployment.md](references/deployment.md).
- For the shared-folder lifecycle and releases, read [references/governance.md](references/governance.md).
- For periodic upstream checks, read [references/scheduled-update-flow.md](references/scheduled-update-flow.md).
- For authoring or modifying PPT-HTML, read [references/ppt-html-contract.md](references/ppt-html-contract.md) and [references/object-mapping.md](references/object-mapping.md).
- For evaluating HTML or PowerPoint output, read [references/qa-contract.md](references/qa-contract.md).

Use the copy/paste prompts under `office-copilot/` to create the three agents. Replace `{{SHARED_LIBRARY_ROOT_URL}}` before deployment or run `scripts/configure_package.py` to make a configured copy.

## Output rules

PPT-HTML uses a fixed 960 × 540 slide coordinate system. Prefer a single native PowerPoint object for a single semantic visual object. A styled container with text maps to one shape with `TextFrame2`, not a background shape plus a separate textbox. Tables and charts carry native reconstruction data; unsupported browser effects must be declared as fallbacks rather than silently rasterized.

Every generated package must identify:

- internal standard version;
- PPT-HTML schema version;
- minimum compiler version;
- input provenance and unresolved assumptions;
- unsupported or downgraded features;
- QA status.

Do not claim pixel-perfect fidelity without comparable HTML and PowerPoint renders. Do not claim native editability without an object inventory or direct inspection.
