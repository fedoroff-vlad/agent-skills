---
name: implement-change
description: >
  Use to actually write or change code against an approved change-spec — the TDD
  core of the dev loop: for each acceptance criterion, write a failing test
  (red), make it pass with the smallest change (green), then refactor, one
  criterion at a time, building/running between steps. Fires on «пиши / правь код
  по плану», «реализуй фичу / фикс», «сделай по change-spec», «implement this»,
  «write the code», «make the test pass». Expects an approved `.dev/<task>/plan.md`
  from `plan-change`; if there is none, it stops and asks to plan first.
version: 0.1.0
category: workflow
languages:
  - en
  - ru
---

# implement-change — red → green → refactor, one acceptance criterion at a time

The execution core. Turns an approved change-spec into working, tested code by
running a bounded TDD loop per acceptance criterion. It writes tests and code; it
does **not** decide *what* to build (that was `plan-change`) or *why it failed*
(that was `diagnose`).

## Preconditions

- An **approved** `.dev/<task>/plan.md` exists (from `plan-change`). No approved
  spec → stop and route to `plan-change`; never freelance a change without a
  contract.
- You can build and run the module. If not, get it green first via `run-guide` /
  `local-dev`. Runtime is **PowerShell** (`mvn`, `Start-Process`, no bash).

## The loop (per acceptance criterion)

```
pick next AC → write a test that FAILS for the right reason (red)
→ smallest code change to pass it (green) → run the module's tests
→ refactor with tests green → RECORD → next AC
```

Rules that keep it safe, honest, and resumable:

- **Red before green.** Write the test first and watch it fail *for the reason
  the AC names* — a test that passes immediately, or fails on a compile error,
  proves nothing. Quote the red failure before you make it green.
- **Smallest change to green.** Make just this one AC pass. No drive-by edits, no
  building three criteria at once — you lose which change did what.
- **One AC per iteration; build/run between.** After green, run the module build
  so a later AC never hides an earlier regression. On an unexpected failure →
  `diagnose`. Use the **tightest build phase that actually proves the AC** —
  `compile`/`test-compile` for a build/config/coordinate fix, `test` when a test
  asserts behaviour, `verify`/`install` only when packaging/integration is what's
  under test. Run the *verifying* build **without `-q`** (quiet mode hides the
  `BUILD SUCCESS`/`FAILURE` line) and confirm by both that line and the exit code.
- **Acceptance gate ≠ always a new unit test.** For most changes the AC is proven
  by a test you write first (below). But for a build/config/dependency fix the
  gate *is* the build or an existing test going green — do not invent a hollow
  unit test just to satisfy the ritual. Write a new test when it pins *behaviour*;
  otherwise name the build/existing-test as the gate in the spec.
- **Infra-blocked deeper phase → scope it in the spec, don't thrash.** If a fuller
  build phase can't pass because of infra you lack (no datasource, a secret, a
  stand), stop: record the wall, and mark that phase out-of-scope in `plan.md`
  (with the follow-up) rather than fighting it. A provable compile-green is a real
  done; a blocked `install` on missing DB is not this change's failure.
- **Refactor only on green.** Clean up with the tests passing; rerun after. Never
  refactor and change behaviour in the same red step.
- **State on disk, not in context.** Append every iteration to
  `.dev/<task>/dev-log.md` *before* moving on (format below). The context resets
  with only a summary; the dev-log + `plan.md` are the memory a fresh session
  reads to continue from the last unfinished AC — it does not re-plan or re-ask.
- **Budget the loop.** Cap retries per AC (~6). If an AC will not go green, stop
  and report the wall with its evidence and the last red line — do not thrash.
- **Stay in scope.** Only touch the artifacts the spec listed. If the work
  reveals a needed change outside that list, stop and amend the spec with the
  owner (back to `plan-change`) rather than silently widening the blast radius.

## Definition of done (all ACs, before handoff)

1. Every acceptance criterion has a gate that fails without the change and passes
   with it — a test you wrote for a *behaviour* change, or the build / an existing
   test for a build/config/dependency fix.
2. The build is green at the **depth the change warrants** (see the loop rules):
   compile-green for a coordinate/config fix; `mvn clean install -pl <module>` (or
   the project's equivalent) when behaviour/packaging is under test. A phase
   blocked by missing infra is scoped out in `plan.md`, not counted as failure.
3. `check-drift` is clean — any coupled artifact (config, docs, another module)
   the change implied has moved with it.
4. `plan.md` is ticked (each AC → done) and `dev-log.md` closed. Then hand off to
   `dev-driver`'s close phase (`close-pr` / `task-done`) — this skill does not
   open the PR itself.

## dev-log.md entry format (append-only)

```markdown
### AC<n> attempt <k> — <date-time>
- red:   `<test cmd>` → FAIL "<decisive assertion line>"
- green: <the smallest change> → `<test cmd>` OK
- build: `<module build cmd>` → OK | FAIL→diagnose
- refactor: <what, or none>
- next: AC<n+1> | wall (evidence: "<line>") | done
```

## Language

Code identifiers, test names, and existing-convention symbols stay in the target
repo's convention (agent-facing → English by default). Prose the change adds —
**code comments, commit messages, PR/MR descriptions** — is the **owner's
language (default `ru`)**, matching that repo. `.dev/<task>/` state stays English.
Commands and paths are verbatim in any language.

## Guardrails

- No approved spec → do not code; route to `plan-change`.
- Tests are written to *fail first*; a green-on-first-run test is a bug in the
  test — fix the test, not the log.
- Do not weaken or delete a failing test to get green — that hides the defect.
- **Never print secrets**; never commit. Committing / MR / status is the close
  phase (`close-pr`, `gitlab`, `task-done`) behind its own confirmation.

## Triggers / non-triggers

- ✅ «реализуй по плану», «сделай красный тест зелёным», «write the code for the
  approved spec», «add the unit test for AC2».
- ❌ «как будем делать» (no spec yet) → `plan-change`; «почему упало» →
  `diagnose`; «залей ветку / закрой задачу» → `close-pr` / `gitlab` / `task-done`.

## Output

The code + tests for the change, a green module build, a clean `check-drift`, and
a ticked `plan.md` / closed `dev-log.md` — ready for the close phase. No commit or
PR is made here.
