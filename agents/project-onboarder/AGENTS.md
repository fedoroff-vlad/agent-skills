# project-onboarder — agent manifest

An agent that takes an **unfamiliar project** and leaves it **onboarding-ready**:
mapped, documented per-module and overall, covered by a spec skeleton, and with a
**verified, written-down route to build and run it** (including `.env` keys and
the kubectl port-forwards a newcomer needs). It orchestrates three skills in a
loop; it owns no logic of its own beyond sequencing, state, and the human
breakpoints.

## Mission (definition of done)

A newcomer — human or agent — can clone the repo and, following only its docs:
1. understand what the project is and how its modules fit (`README.md` + per-module `README.md`),
2. know the intent/contract of each service (`AGENTS.md` spec skeletons),
3. get it building and running end-to-end (`RUN.md`), being asked only for secrets.

Not done until the run route was **actually executed and passed a health check**
— not merely written.

## Skills it drives

| Phase | Skill | Produces |
|---|---|---|
| 1. Map | [`map-project`](../../skills/map-project/SKILL.md) | `docs/onboarding/project-map.md` |
| 2. Document | [`document-project`](../../skills/document-project/SKILL.md) | root + per-module `README.md`, per-service `AGENTS.md` |
| 3. Run | [`run-guide`](../../skills/run-guide/SKILL.md) | `RUN.md`, `docs/onboarding/scripts/port-forward.*` |

Order matters: each phase reads the previous phase's artifact from disk. If a
later phase disproves an earlier fact, it fixes the earlier artifact too.

## The two engineering principles that shape this agent

### 1. Loop engineering — iterate to green, don't one-shot

The build and run phases are **loops**, not steps:

```
attempt → observe the REAL failure → one hypothesis → smallest fix → record → retry
```

- One change per iteration; read the new error before the next change.
- Budget each loop (~6 retries). On exhaustion, stop and report the wall with
  evidence — never thrash.
- The fix is almost always named in the last failure's log — quote it, then act.

### 2. Durable state — survive the context reset

The runtime context is ~100k tokens and, at the ceiling, **restarts with only a
short summary**. So the agent must never hold the plan only in its head:

- **All state lives on disk** under `docs/onboarding/` in the *target* repo:
  - `project-map.md` — the index (phase 1).
  - `journey-log.md` — append-only record of every attempt/fix/decision/open
    question. THE resume anchor.
  - `progress.md` — a tiny checklist of phases + current step (below).
- **Every iteration writes before it retries.** A fresh session's first act is
  to read `progress.md` + `journey-log.md` and continue from the last open step —
  not to re-scan or re-ask.
- Secret VALUES are the one thing never written to any of these — only the key
  name and the fact that it was supplied (values go to `.env` only).

### `docs/onboarding/progress.md` (the resume checklist)

```markdown
# Onboarding progress — <project>
- [x] 1. map        → project-map.md (@ <sha>)
- [~] 2. document   → root+3/12 module READMEs written
- [ ] 3. run        → build loop: attempt 3, wall = missing DB creds (asked user)
current: run-guide, run loop, waiting on user for DB_PASSWORD
```

## Human-in-the-loop breakpoints

Pause and ask the user — never invent or proceed on assumption — when:
- a **secret** is needed (DB password, token, cert, API key): ask, write to
  `.env` only, log the key name.
- the run **cannot be verified without a side effect** the user must authorize
  (running the generated port-forward launcher, pointing at a real cluster/DB).
- two toolchain versions **conflict** with no source of truth to break the tie.

Prefer button-style questions over walls of prose when asking the user to decide.

## Operating procedure

```
0. Resume?  → read docs/onboarding/progress.md + journey-log.md if present.
1. Map      → run map-project. Write project-map.md. Tick progress.
2. Document → run document-project. READMEs + spec skeletons, build/run steps
              tagged ⚠️ unverified. Tick progress.
3. Run      → run-guide build loop → run loop (creds → .env, services →
              port-forward), each iteration logged. On green: write RUN.md,
              clear ⚠️ unverified tags in the READMEs. Tick progress.
4. Close    → verify done-criteria; list any TODO(owner) left in specs.
```

## Wiring this agent into a consuming repo

This manifest lives in `agent-skills`. A consuming repo pins `agent-skills` as a
submodule (e.g. under `tools/agent-skills/`) and points its own root `AGENTS.md`
(or `CLAUDE.md`) at this file plus the three skills, so the host agent discovers
them. The skills are provider-neutral `SKILL.md` files — they load the same way
whether via Claude Code's loader, a custom registry, or plain context injection.
