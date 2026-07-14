---
name: close-pr
description: >
  Use when finishing a PR — before or right after merge. Fires on: "close the
  PR", "wrap up this PR", "PR is green", "move this to history". Moves finished
  work out of the live status file into the archive, runs a docs freshness pass,
  and squash-merges once CI is green.
version: 0.1.0
category: release
---

# close-pr — keep the live status lean, land on green

The live status file is read in full every session, so finished work must not
accumulate there. Closing a PR is a mechanical ritual — this is it.

## Procedure

1. **Move status → history**: cut the completed items out of the live status
   file (e.g. `plans/STATUS.md`) and append a terse timeline row to the archive
   (e.g. `plans/HISTORY.md`): `date · milestone · → domain plan + PR`. Never leave
   `✅ DONE` bullets in the live "Now" section — that append-only drift is exactly
   what bloats it.
2. **Detail lives at the source**: the authoritative "what was done" is the
   domain plan + module README. Status/history only *link* to them; do not
   duplicate detail.
3. **Freshness pass** over the blind spots nothing else forces a look at:
   - root README status line + layout,
   - the closed domain's module README status headers,
   - any consumer's `§who-uses-me` list you touched.
4. **Drift gate**: run the `check-drift` skill. Do not merge with open drift.
5. **Merge on green**: confirm CI is green, then squash-merge and delete the
   branch (only if the project authorizes self-merge — check its rules first).
   Never direct-push to the default branch.

## Output

What moved to history, what the freshness pass changed, drift verdict, and the
merge result (or why merge was withheld). If CI is not green, stop and report —
do not merge.
