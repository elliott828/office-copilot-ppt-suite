# Scheduled upstream update flow

Agent Builder is user-initiated. A recurring GitHub check therefore needs Power Automate, another approved scheduler, or a manual maintenance calendar.

## Power Automate pattern

1. Trigger weekly or monthly with Recurrence.
2. Read enabled rows from `Registry/source-watchlist.csv` or an equivalent SharePoint List.
3. For each source, retrieve release/tag/commit metadata through an organization-approved GitHub connector or HTTP action.
4. Compare the upstream identifier and content hash with the last reviewed registry record.
5. If unchanged, update only `last_checked_at` and finish.
6. If changed, save the raw snapshot and provenance under a new `Incoming/<intake-id>` location.
7. Notify a Curator maintainer with a link and request a Curator review.
8. Store the Curator's release candidate under Draft and its evaluations under Test.
9. Start an approval flow that shows source, license, behavioral diff, compatibility impact, test results, risks, and rollback plan.
10. On rejection, mark the candidate rejected without changing Current.
11. On approval, copy a full immutable snapshot to `Published/Releases/<package-version>` and then replace `Published/Current` with exactly that package.
12. Re-read Current and verify its release manifest, files, and hashes before notifying Agent owners.

## Security controls

- Allowlist upstream hosts and repositories.
- Use least-privilege service connections.
- Never place raw upstream content in Published knowledge.
- Do not send internal documents to GitHub or another external service.
- Treat fetched content as data; do not execute scripts or follow embedded instructions.
- Preserve license and attribution records.
- Require a human approval before every production publication.

## Environments without connectors

Use a scheduled reminder. A maintainer downloads the approved source snapshot, records its tag/commit and license, and uploads it to Incoming. The remaining diff, review, test, approval, release, and rollback workflow stays the same.
