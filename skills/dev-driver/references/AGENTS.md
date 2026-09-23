# dev-driver — agent operating manifest

Point an LLM at this file to have it **drive a development task end-to-end** in
the monorepo: from a task/bug/idea to a tested, built, merged change. This is the
full operating doc behind the lean [`SKILL.md`](../SKILL.md); the skill is the
trigger surface, this is the how.

The agent owns **only** sequencing, durable state, and human breakpoints. Every
mechanical action is a sub-skill — it never re-implements their logic inline.

## Mission (definition of done)

A task is done when **all** hold:
1. An **approved change-spec** exists (`.dev/<task>/plan.md`) — the contract.
2. Every acceptance criterion has a test that **fails without** the change and
   **passes with** it.
3. The **build is green at the depth the change warrants** — compile for a
   coordinate/config fix, `mvn clean install` when behaviour/packaging is under
   test; a phase blocked by missing infra is scoped out in the spec, not ignored.
4. `check-drift` is clean — every coupled artifact moved together.
5. The change is on a branch, in a PR, and (on the owner's yes) merged; the Jira
   task is closed via `task-done`.

Not done because "the code looks right" — done because it was **built, run, and
tested green**, and the trail on disk proves it.

## The three principles that shape this agent

### 1. SDD-lite — the spec is the contract, before code

The agent does not start editing code from a prose request. It first produces a
small change-spec (`plan-change`): intent, acceptance criteria as *given/when/
then*, the exact artifacts to touch, and the test that proves each criterion.
That spec is approved by the owner, then it is what `implement-change` verifies
against and what `check-drift` guards. One spec mechanism — no parallel
framework. (This is the lightweight core idea of spec-driven / OpenSpec-style
work, expressed in the repo's own format, not a second toolchain.)

### 2. Loop engineering — iterate to green, never one-shot

Diagnosis, implementation, and verification are **loops**, not steps:

```
attempt → observe the REAL failure → ONE hypothesis → smallest change → RECORD → retry
```

- One change per iteration; read the new error before the next change.
- Red before green: a test must fail for the right reason before you make it pass.
- Budget each loop (~6 retries per AC / per build wall). On exhaustion, stop and
  report the wall with its evidence — never thrash.
- The fix is almost always named in the last failure's log — quote it, then act.

### 3. Durable state — survive the context reset

The runtime context is finite and, at the ceiling, restarts with only a short
summary. So the plan never lives only in the agent's head — it lives on disk in
the **target** repo under `.dev/<task>/`:

- `plan.md` — the approved change-spec (`plan-change`). THE contract.
- `dev-log.md` — append-only: every diagnose finding and every red/green/build
  attempt (`diagnose`, `implement-change`). THE resume anchor.
- `progress.md` — a tiny phase checklist + the current step.

Every iteration **writes before it retries**. A fresh session's first act is to
read `progress.md` + `dev-log.md` and continue from the last open step — not
re-scan, not re-ask. Secret VALUES never enter these files (values go to `.env`
only; log the key name).

### `.dev/<task>/progress.md` (the resume checklist)

```markdown
# Dev progress — <task / key>
- [x] 1. diagnose   → cause: <one line> (dev-log @ <ts>)
- [x] 2. spec       → plan.md approved @ <date>
- [~] 3. implement  → AC 2/4 green; AC3 red (wall? no)
- [ ] 4. verify     → module build green; full `mvn clean install` pending
- [ ] 5. close      → PR + task-done
current: implement-change, AC3, writing the failing test
```

## Operating procedure

```
0. Resume/branch → read .dev/<task>/progress.md + dev-log.md if present (RESUME:
   continue the open step). Else, if a git repo: create a branch OFF the default
   branch (never work on main). Create .dev/<task>/ (gitignore it if the repo
   prefers). Resolve the task: a Jira key/link → read via `jira`.

1. Diagnose  → if this is a bug/failure, run `diagnose`: reproduce, quote the
   decisive line, confirm ONE cause, record it. (Pure new feature → skip to 2.)

2. Spec      → run `plan-change`: write .dev/<task>/plan.md (intent + given/when/
   then acceptance + affected artifacts + test plan + open questions). ★ ASK the
   owner to approve; button-style for choices. Do NOT proceed unapproved.

3. Implement → run `implement-change`: per acceptance criterion, red → green →
   refactor, one AC per iteration, module build between. On an unexpected
   failure, drop into `diagnose`, then resume. Stay inside the spec's artifact
   list; a needed change outside it → back to 2 to amend the spec.

4. Verify    → build at the depth the change warrants (compile → test →
   `mvn clean install`); run the verifying build without `-q` and confirm
   BUILD SUCCESS + exit code. A deeper phase blocked by infra you lack (DB,
   secret, stand) → scope it out in `plan.md` with a follow-up, don't thrash. Run
   it where it matters: `run-guide` (fresh build/run loop) or `local-dev`
   (port-forward a stand + run with a profile) for a real boot + health check;
   `run-goldens` for LLM golden tests; `check-drift` for coupled artifacts.
   Anything still red → `diagnose` → back to 3.

5. Close     → tick plan.md + progress.md. ★ ASK the owner to open the PR/merge.
   On yes: `close-pr` (status→history, freshness pass, squash-merge on green) or
   `gitlab` (MR); then `task-done` to close the Jira task (verbatim text, its
   template). Hand the owner the link. Never merge to main by bypassing the flow.
```

## Language policy — English for the agent, the owner's language for the human

The split is by *who reads it*, not by file type:

- **Agent-facing → always English.** This manifest and every `SKILL.md`; the
  working state on disk (`.dev/<task>/plan.md`, `dev-log.md`, `progress.md`); and
  code identifiers, test names, and existing-convention symbols in the target
  repo. English keeps them portable and diff-stable regardless of who runs them.
- **Human-facing → the owner's language (default `ru`).** The workflow
  conversation with the owner (spec approval, questions, explanations); and prose
  the agent writes *into the target repo* — code comments, commit messages, PR/MR
  descriptions, and any project README it touches — go in the owner's language,
  matching that repo's existing convention. Only prose is translated: commands,
  identifiers, paths, env-key names stay verbatim (a translated command is a
  broken command).

When in doubt, follow the target repo's own convention for in-repo prose; ask the
owner if the repo is inconsistent.

## Human-in-the-loop breakpoints

Pause and ask — never invent or proceed on assumption — when:
- the **spec** is ready but not yet approved (phase 2);
- an action is **irreversible/outward**: commit, push, MR/merge, a Jira status
  change, a yuchat notice, or running a stand-touching command (any ★ step);
- a **secret** is needed (DB password, token, cert): ask, write to `.env` only,
  log the key name;
- two sources of truth **conflict** with no tiebreaker (which behaviour is
  correct, which module owns it).

Prefer button-style questions over walls of prose when asking the owner to decide.

## Skills it drives

| Role | Skill |
|------|-------|
| read the task | `jira` |
| find the real cause | `diagnose` (→ `kubectl`/`grafana` for stand logs) |
| write the contract | `plan-change` |
| write code + tests (TDD) | `implement-change` |
| build & run for real | `run-guide` · `local-dev` |
| tests | `run-goldens` (LLM goldens) + the project's unit/integration build |
| coupled-artifact guard | `check-drift` |
| observability, deps | `add-observability` · `bump-deps` |
| land it | `close-pr` · `gitlab` · `task-done` |

Delegate mechanics to these; the agent's own job is only the loop above.

## Runtime notes (this repo)

- opencode does **not** auto-apply skills — the agent's first action for a request
  is `skill(dev-driver)` (or the specific sub-skill), then it follows the loaded
  procedure. See the repo's `work/AGENTS.md`.
- The shell is **Windows PowerShell**: `mvn`, `Start-Process -PassThru`/
  `Stop-Process` (no bash `&`/`$!`/`kill`), `$env:VAR`, `python` (not `python3`).
- Config-as-data: build/run/port-forward/log specifics come from the sub-skills'
  config (`config/infra/*.yaml`, `projects.*`), never hard-coded here.
- Never print secrets; never commit straight to `main`.
