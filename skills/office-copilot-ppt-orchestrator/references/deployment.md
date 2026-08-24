# Deployment

## 1. Prepare SharePoint

Copy `assets/shared-folder-template/PPT-Skill-Library` into a controlled SharePoint document library. Preserve these top-level paths:

```text
PPT-Skill-Library/
  Incoming/
  Draft/
  Test/
  Published/
    Current/
    Releases/
  Registry/
```

Enable version history. Prefer major/minor versions and content approval. Grant ordinary Agent users read access only to `Published/Current`; limit Curator maintainers to the remaining areas. Do not add `Published/Releases` or draft folders as production Agent knowledge.

## 2. Configure local copy

Replace `{{SHARED_LIBRARY_ROOT_URL}}` in all files with the actual SharePoint root URL. The helper script can create a configured copy:

```powershell
python scripts/configure_package.py --root-url "https://tenant.sharepoint.com/sites/site/Shared%20Documents/PPT-Skill-Library" --output dist/tenant
```

The derived production path is `<root>/Published/Current`.

## 3. Create agents

For each file in `office-copilot/*-agent-generator.txt`:

1. Open Microsoft 365 Copilot Agent Builder and choose **New agent**.
2. Paste the whole generator prompt into the Describe experience.
3. Open **Configure** and verify the name, description, instructions, knowledge, and starter prompts.
4. If Agent Builder paraphrased or omitted constraints, replace Instructions with the matching file in `office-copilot/instructions/`.
5. Add the exact SharePoint folders listed in the generator prompt as knowledge sources.
6. Enable document/code creation when available.
7. Test privately before sharing.

The Authoring Agent and QA Agent use only `Published/Current`. The Curator Agent additionally needs the Incoming, Draft, Test, Releases, and Registry paths, subject to the user's permissions.

## 4. Connect agents only when supported

The default deployment does not require Agent-to-Agent calls. The Authoring Agent consumes approved Curator output through SharePoint. This works in environments limited to Agent Builder or SharePoint agents.

If the tenant supports declarative-agent connected agents or Copilot Studio, the QA Agent may be connected to the Authoring Agent for text-only review tasks. Do not rely on that connection to transfer HTML, images, or PPTX binaries; store artifacts in an approved SharePoint work folder or have the user attach them.

## 5. Compiler prerequisite

Deploy a fixed VBA compiler separately. Record its version in `Published/Current/release-manifest.json`. The Authoring Agent must generate only packages compatible with that version. Run macros only in trusted desktop PowerPoint under organizational policy.

## 6. Acceptance checks

- Authoring Agent reports the current internal standard and schema versions.
- Authoring Agent never retrieves Draft or historical rules.
- Curator produces a change proposal but cannot publish without approval.
- QA Agent distinguishes preflight, structural, and visual evidence.
- A test HTML package validates against the published schema.
- The compiler rejects incompatible schema versions instead of guessing.

For a periodic upstream process, implement the tenant-appropriate option in [scheduled-update-flow.md](scheduled-update-flow.md). Agent Builder alone is user-initiated and does not create a scheduler.
