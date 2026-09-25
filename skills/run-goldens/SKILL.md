---
name: run-goldens
description: >
  Use when you want to run the golden LLM tests against a real model — one, a
  few, or all. Fires on: "прогони голдены" / "run the goldens", "прогони golden
  тесты", "проверь роутинг/синтез на реальной модели", "did my prompt/skill/router
  change break the goldens", after editing a prompt, SKILL.md, classifier, or any
  LLM surface. Discovers the repo's golden tests, lets you pick a scope, runs them
  through the repo's golden runner, and reads the result (real regression vs flaky
  borderline case).
version: 0.1.0
category: testing
---

# run-goldens — run the golden LLM tests against a real model, by choice

Golden tests (`@GoldenLlmTest`-style) exercise an **LLM surface** — routing,
strict-JSON extraction, synthesis grounding — against a **real local model**,
asserting *structure, not exact text*. They are **opt-in** (a `GOLDEN_LLM` gate),
skipped in CI, and slow (a real model call per assertion), so you run the ones
that touch what you changed — not the whole suite reflexively.

## Procedure

1. **Discover the goldens.** Find the repo's golden classes — grep for the golden
   marker (this repo family uses `@GoldenLlmTest`):
   `grep -rl "@GoldenLlmTest" --include=*.java` (adapt the marker/glob to the
   repo's language). Group the hits by module (the Maven `-pl` path / package
   root) so each has a runnable address.
2. **Present the inventory + get a scope.** Show the discovered classes grouped by
   module and ask which to run: **one** class, **several** (comma-separated), a
   whole **module**, or **all**. You can narrow to a single method with
   `Class#method`. Prefer the smallest scope that covers the surface just changed.
3. **Check prerequisites.** The golden lane needs a real model. Use the repo's
   golden runner (`scripts/golden.sh` in this repo family) — it auto-starts the
   local inference engine + an LLM gateway pointed at it, sets `GOLDEN_LLM=true`,
   and handles model quirks (e.g. suppressing "thinking" so a call is seconds not
   minutes). The required model must already be pulled; the runner names the pull
   command rather than downloading multi-GB blobs unasked. Do NOT hand-roll the
   env — go through the runner so the setup stays identical to everyone else's.
4. **Run the chosen scope** through the runner, e.g.:
   - one class: `scripts/golden.sh -pl <module> -Dtest=<GoldenClass>`
   - several:   `scripts/golden.sh -pl <module> -Dtest='<GoldenA>,<GoldenB>'`
   - one method: `scripts/golden.sh -pl <module> -Dtest=<GoldenClass>#<method>`
   - all: run per module (loop the `-pl <module> -Dtest=<its Golden*>` addresses).
   The runner leaves the engine + gateway up, so the next run is instant.
5. **Read the result — real regression vs flaky case.** On failure, extract only
   the failing assertion (e.g. `«…» should route to 'finance' but went to 'tasks'`),
   not the full log. Then apply the flakiness rule below before calling it a bug.
6. **Report.** A short per-class pass/fail; for each failure, the assertion + a
   verdict: *real regression* (stable, reproducible) or *flaky borderline case*
   (input too ambiguous for the model — tighten the test, not the product).

## Flakiness — the rule that keeps goldens trustworthy

A small local model is **non-deterministic on borderline inputs** — a phrasing
sitting between two domains can route one way now and another next run. So:

- A golden case must be **crisp**: unambiguous intent, one obvious answer. Vague
  or "clever" phrasings belong in exploratory notes, not a must-pass golden.
- On a failure, **re-run that case once** before concluding. If the verdict flips
  between identical runs, the case is too borderline — **fix the test input**
  (make it crisp) rather than chasing the model or loosening the assertion. Only a
  **stable, reproducible** failure is a real regression to investigate in the
  product (prompt / manifest / router).
- When you *add* a golden case, run it **twice** to confirm it is stable before
  committing — a flaky green is a debt that fails someone else later.

## Stop the stack before a full build

The runner deliberately leaves the engine + gateway **up** so the next run is instant — which means a
**running gateway jar** is still holding its own build output. On Windows the next full `verify`/`package`
then dies in `spring-boot:repackage` with *"Unable to rename target/<gateway>.jar to
<gateway>.jar.original"*, and the message says nothing about goldens, so it reads as a broken build.

So: **after the golden run, before the pre-PR full build, stop the stack** (`scripts/golden.sh down` in
this repo family — it stops the gateway it started, and the inference daemon only if it started that
too). Same trap for any long-lived process started off a build artifact, not just this lane.

## What a failure usually means (real experience)

A stable failure is **most often the prompt/SKILL, not the model** — and the SKILL's own *examples* are
the first place to look:

- **Few-shot index leakage.** A pick-one-of-a-list skill whose examples show `{"pick": 2}` for a sentence
  teaches the model to answer `2` for that sentence, whatever the list holds. Give every example its own
  candidate list and state that the index comes from *this* message's list.
- **The fixture repeats the example.** If the test's input and candidates are the example's own literals,
  the model can pass by copying — the test proves nothing. Keep the fixture's wording off the examples.
- **A value the code drops.** When production normalises an enum (dropping anything unknown), the model
  answering in the user's language means the action silently does nothing. Make the skill state the exact
  allowed values, and let the golden assert the normalised one.

## When NOT to reach for this

- You changed only non-LLM code (plumbing, DB, config with no prompt/router
  effect) — there is no LLM surface to re-validate; the normal unit/slice tests
  cover it.
- You just want the fast inner loop — goldens are the real-model gate, not the
  iterate loop. Use mocked slice tests while iterating; run the goldens before the
  PR for the surface you touched.

## Triggering contract (examples)

SHOULD fire: "прогони голдены по роутингу", "run the finance golden", "проверь,
не сломал ли я синтез на реальной модели", "run all the goldens before I open the
PR". SHOULD NOT fire: "run the unit tests" (not the real-model gate), "why is my
build failing" (compile, not goldens), "add a golden test" (that is authoring —
`new-skill` / write the test; this skill only *runs* them).
