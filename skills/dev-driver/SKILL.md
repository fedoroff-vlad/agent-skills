---
name: dev-driver
description: >
  Use to drive a whole development task end-to-end — take a task/bug/idea in the
  monorepo from diagnosis to a merged change, running the loop: diagnose → spec
  (plan-change) → implement (TDD) → verify (build/run/tests) → close (PR + Jira).
  It orchestrates the other skills and keeps durable state on disk so it survives
  a context reset. Fires on «веди разработку по {key|link}», «займись задачей X от
  и до», «сделай фичу / фикс полностью», «drive this task», «develop this feature
  end to end». For a single sub-step, call that skill directly instead.
version: 0.1.0
category: workflow
languages:
  - en
  - ru
---

# dev-driver — the development loop, from a task to a merged change

The orchestrator ("agent brain"). It owns **no mechanics of its own** — only the
sequencing, the durable state, and the human breakpoints. Every real action is a
sub-skill. Full operating manifest (the doc you can also point a bare LLM at):
[`references/agent.md`](references/agent.md). Read it before a first run.

## Methodology (house-style composition)

- **SDD-lite** — a change-spec is the contract *before* code (`plan-change`).
- **Loop engineering** — diagnose and implement are bounded red→green loops:
  one change per iteration, read the REAL failure, budget the retries.
- **Durable state** — the plan and log live on disk in the target repo, so a
  context reset resumes instead of restarting.
- **Prompt engineering** — each sub-skill is loaded by its `description`; this
  skill just decides *which* and *when*.

**Language** (see the manifest): agent-facing text — this skill, the `.dev/<task>/`
state, code identifiers — is **English**; human-facing text — the workflow
conversation with the owner and prose written into the target repo (comments,
commit/PR messages, READMEs) — is the **owner's language (default `ru`)**,
matching that repo's convention. Commands/paths/identifiers stay verbatim.

## Phases

| # | Phase | Skill(s) | Gate |
|---|-------|----------|------|
| 0 | Resume/branch | — read `.dev/<task>/progress.md`; branch off default | — |
| 1 | Diagnose | `diagnose` (bug) · `jira` (read task) | — |
| 2 | Spec | `plan-change` | ★ owner approves the spec |
| 3 | Implement | `implement-change` (TDD) ← `diagnose` on failure | — |
| 4 | Verify | build (`mvn clean install`) · `run-guide`/`local-dev` · `run-goldens` · `check-drift` | — |
| 5 | Close | `close-pr` / `gitlab` · `task-done` | ★ owner approves the PR/merge |

Order matters — each phase reads the previous phase's artifact from disk. If a
later phase disproves an earlier fact, fix the earlier artifact too.

## Durable state (in the TARGET repo, under `.dev/<task>/`)

- `plan.md` — the approved change-spec (from `plan-change`).
- `dev-log.md` — append-only record of every diagnose/red/green/build attempt.
- `progress.md` — the tiny resume checklist (phases + current step).

A fresh session's first act is to read `progress.md` + `dev-log.md` and continue
from the last open step — never re-plan or re-ask. Secret VALUES never enter any
of these (only key names).

## Human breakpoints (★ — ask, never assume)

- The **spec** before any code (phase 2).
- Anything **irreversible/outward**: commit, push, MR/merge, Jira status change,
  running a stand-touching command (phase 5, and any ★ step a sub-skill marks).
- A **missing secret** → ask, write to `.env` only, log the key name.
Prefer button-style questions over prose when asking the owner to decide.

## Guardrails

- Never skip the spec: no approved `plan.md` → do not implement.
- Never commit to `main` / bypass the flow: branch → PR → merge on green.
- Delegate mechanics to the sub-skills — do not re-implement their logic inline.

## Triggers / non-triggers

- ✅ «веди задачу KEY-123 от и до», «сделай эту фичу полностью», «drive this bug to a PR».
- ❌ a single step — «спланируй» → `plan-change`; «почему падает» → `diagnose`;
  «пиши код» → `implement-change`; «закрой задачу» → `task-done`.

## Output

A merged (or PR-ready) change with tests, a green build, an approved spec, and the
`.dev/<task>/` trail — task closed in Jira when the owner approves.
