---
name: document-project
description: >
  Use after the project is mapped, to write the human- and agent-facing docs:
  a per-module README, a root README with the module map, and an AGENTS.md spec
  skeleton so an agent can develop against it. Fires on: "сделай ридми по
  проекту", "напиши README по каждому модулю", "задокументируй проект",
  "нужна документация для онбординга", "write the READMEs", "document each
  module". Reads docs/onboarding/project-map.md; writes README.md per module +
  at the root, and a spec skeleton.
version: 0.1.0
category: onboarding
---

# document-project — turn the project map into READMEs a newcomer can follow

The documentation phase. Input is `docs/onboarding/project-map.md` (from
`map-project`); output is a layered doc set: every module gets a README, the
root gets an overview + module map, and each service gets an `AGENTS.md` spec
skeleton so future work (human or agent) has intent-in-repo to build against.

## Principle: document what is TRUE, mark what is UNVERIFIED

Write only what the map and the code support. A build or run step you have not
executed yet is **not** yet fact — tag it `> ⚠️ unverified` until `run-guide`
confirms it, then the tag comes off. Never invent an env var, a port, or a
command that is not in the repo. This keeps the docs honest across the onboarding
loop instead of accumulating plausible fiction.

## Procedure

1. **Read the map.** `docs/onboarding/project-map.md` is the source. If it is
   missing, run `map-project` first — do not scan ad hoc here.

2. **Per-module README** (`<module>/README.md`) — one per module in the map.
   Use the module template in
   [`references/readme-templates.md`](references/readme-templates.md). Each
   answers: what this module is, its public surface (API / events / CLI), how it
   fits the whole, its own build/run/test commands, its config keys. Keep it to
   what a newcomer needs to touch this module — link up to the root for the big
   picture rather than repeating it.

3. **Root README** (`README.md`) — the entry point. Overview, the **module map**
   (a table linking each module's README), the stack + required toolchain, and a
   short "getting started" that links to `RUN.md` (owned by `run-guide`) rather
   than duplicating the run steps. Use the root template in the references file.

4. **Spec skeleton** (`<service>/AGENTS.md`) — for each runnable service, a lean
   manifest: responsibility, boundaries (what it must NOT do), its wire contracts
   (endpoints / events / tools), and its invariants. This is the "covered by
   specification" half — it is what lets an agent develop the module safely
   later. A skeleton with the right headings and the known facts beats a perfect
   doc that never gets written; leave `TODO(owner)` where intent is unknown.

5. **Cross-link.** Root ⇄ modules ⇄ specs must link both ways. A README a reader
   can get lost in is half-done.

6. **Record freshness.** In each doc footer, note the source (`generated from
   project-map.md @ <sha>`) so drift is later detectable by `check-drift`.

## Output layout

```
README.md                     # root: overview + module map + toolchain
<module>/README.md            # per module
<service>/AGENTS.md           # per runnable service: spec skeleton
docs/onboarding/project-map.md# (input, from map-project — kept in sync)
```

## Triggering

SHOULD fire: "напиши README по каждому модулю и общий"; "задокументируй проект
для онбординга"; "write module + root docs". SHOULD NOT fire: "просканируй
проект" (that is `map-project`, the prerequisite); "напиши инструкцию по запуску
/ RUN.md" (that is `run-guide`). This skill writes understanding docs; the
verified run route is `run-guide`'s.

## Handing off

Leave every build/run claim tagged `⚠️ unverified`. `run-guide` runs the loop
that verifies (or corrects) them and clears the tags as it proves each step.
