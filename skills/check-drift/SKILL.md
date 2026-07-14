---
name: check-drift
description: >
  Use after ANY change and before opening a PR to verify every coupled artifact
  moved together. Fires on: changed an env var / port / endpoint / MCP tool /
  dependency / LLM model / DB schema; "did I update everything"; "check drift";
  "reconcile the docs". Reads the repo's .skills/change-map.yaml and reports which
  coupled files did NOT move.
version: 0.1.0
category: consistency
---

# check-drift — no change is done until every coupled artifact moves with it

A change is silent drift until the same PR updates all its coupled artifacts.
This skill turns that discipline into a check.

## Procedure

1. **Load the map**: read `.skills/change-map.yaml` at the repo root. It lists
   `couplings`, each with a `trigger`, an optional `ssot`, a `must_update` list,
   and optional `revalidate` steps.
2. **Diff the change**: get the working-tree / PR diff (changed files).
3. **Match couplings**: for each coupling whose `ssot` or trigger-owned file
   appears in the diff, treat it as fired.
4. **Report gaps**: for each fired coupling, list every `must_update` path that
   is NOT in the diff. That list is the drift. Be specific — path by path.
5. **Delegate the mechanizable half**: if the repo has a consistency linter
   (e.g. `scripts/check-consistency.sh`), run it and fold its output in — it
   catches the grep-able stale refs; this skill catches the rest.
6. **Flag revalidation**: if a fired coupling has `revalidate` steps (a golden
   lane, a rebuild), remind the user to run them — a moved file can still be
   semantically stale.
7. **Self-check**: verify the `tools/agent-skills/` pointer + index block exist
   and match across the project's docs (this skill's own wiring is a coupling).

## Output

A short verdict: `OK — all couplings satisfied`, or a per-coupling list of
missing artifacts. No prose padding. If nothing in the diff matches any
coupling, say so plainly rather than inventing findings.

## Extending

When a new mechanically-checkable coupling appears, add it to
`.skills/change-map.yaml` (not to this body) — that is how the "automat" grows
without editing the skill.
