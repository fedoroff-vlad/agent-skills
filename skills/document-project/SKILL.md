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

## Language: reader's language for READMEs, English for specs

The READMEs are **human-facing** → write them in **`ONBOARDING_LANG`** (env var,
default `ru`; `en`/other to override). The per-service `AGENTS.md` spec skeletons
are **agent-facing** → always English. In every language, keep code, commands,
identifiers, env-key names, ports and paths verbatim — translate only prose and
headings. (Full policy in the orchestrator's `AGENTS.md`.)

## Principle: document what is TRUE, mark what is UNVERIFIED

Write only what the map and the code support. A build or run step you have not
executed yet is **not** yet fact — tag it `> ⚠️ unverified` until `run-guide`
confirms it, then the tag comes off. Never invent an env var, a port, or a
command that is not in the repo. This keeps the docs honest across the onboarding
loop instead of accumulating plausible fiction.

## Scale: tier the docs, don't carpet-bomb

A 60-module monorepo does **not** get 60 hand-written READMEs on the first pass —
that is noise no one reads. Tier by value:

1. **Root** — always. The map + diagrams + how it fits.
2. **Group/domain level** — one README per top-level grouping (`platform/`,
   `domains/<x>/`, `libs/`) describing that group and listing its modules.
3. **Leaf modules** — a full README only for the **non-trivial** ones (a service,
   a module with a public API/contract, anything a newcomer will actually edit).
   Trivial leaves get a one-line entry in their group README, not their own file.

State the tiering you chose in `progress.md` so a resumed session continues it.

## Refresh, don't clobber

If a doc already exists (human-written or a previous pass), this is an **update**,
not a rewrite: preserve human edits, change only what the map says changed, and
never delete a section you did not generate. On a re-run, diff intent against the
current file and touch the minimum.

## Procedure

1. **Read the map.** `docs/onboarding/project-map.md` is the source. If it is
   missing, run `map-project` first — do not scan ad hoc here.

   All templates live in [`references/templates/`](references/templates/) — one
   per artifact, with a fixed section order and `{{TOKEN}}` / `REPEAT` / `OPTIONAL`
   fill markers so every onboarding comes out the same shape. The conventions are
   in [`references/templates/README.md`](references/templates/README.md).

2. **Per-module README** (`<module>/README.md`) — one per NON-TRIVIAL module (see
   tiering). Fill [`templates/module-readme.md.tmpl`](references/templates/module-readme.md.tmpl);
   for a tiering group use [`templates/group-readme.md.tmpl`](references/templates/group-readme.md.tmpl).
   Each answers: what this module is, its public surface (API / events / CLI),
   how it fits the whole, its own build/run/test commands, its config keys. Keep
   it to what a newcomer needs to touch this module — link up to the root.

3. **Root README** (`README.md`) — the entry point. Overview, the **module map**
   (a table linking each module's README), the stack + required toolchain, and a
   short "getting started" that links to `RUN.md` (owned by `run-guide`) rather
   than duplicating the run steps. Fill [`templates/root-readme.md.tmpl`](references/templates/root-readme.md.tmpl).

4. **Diagrams** — the root README earns one or two **Mermaid** diagrams (they
   render on GitHub and in artifacts, no tooling): a **module dependency graph**
   (`flowchart` of internal module → module edges, read from the build files)
   and, when there are backing services, a **deployment topology** (app →
   service:port, from the map's services table). A diagram of the real mechanism
   beats three paragraphs; keep it to the edges that matter, not every arrow.

5. **Root agent manifest** (`AGENTS.md` at the repo root) — the single entry
   point for **agent-driven development** (this is the "с агентом вести
   разработку" deliverable). Agent-facing → English. It gives a coding agent, in
   reading order: what the project is, the module map (link the specs), the
   conventions (build/test commands, layering rules, the never-do list), how to
   run (link `RUN.md`), and where the per-service specs live. Fill
   [`templates/root-agents.md.tmpl`](references/templates/root-agents.md.tmpl). If
   the repo already wires an `AGENTS.md`/`CLAUDE.md`, extend it — do not replace it.

6. **Spec skeleton** (`<service>/AGENTS.md`) — for each runnable service, fill
   [`templates/service-agents.md.tmpl`](references/templates/service-agents.md.tmpl):
   responsibility, boundaries (what it must NOT do), its wire contracts
   (endpoints / events / tools), and its invariants. This is the "covered by
   specification" half — it is what lets an agent develop the module safely
   later. A skeleton with the right headings and the known facts beats a perfect
   doc that never gets written; leave `TODO(owner)` where intent is unknown.

7. **Cross-link.** Root ⇄ modules ⇄ specs must link both ways. A README a reader
   can get lost in is half-done.

8. **Record freshness.** In each doc footer, note the source (`generated from
   project-map.md @ <sha>`) so drift is later detectable by `check-drift`.

## Output layout

```
README.md                     # root: overview + module map + Mermaid diagrams
AGENTS.md                     # root: agent-dev entry point (English)
<group>/README.md             # per top-level group (platform/ domains/x/ libs/)
<module>/README.md            # per NON-TRIVIAL module (tiering — not every leaf)
<service>/AGENTS.md           # per runnable service: spec skeleton (English)
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
