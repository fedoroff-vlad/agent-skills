---
name: new-golden
description: >
  Use when deciding what to cover with a unit test vs a golden test, when writing
  a NEW golden test or fixture, or after a bug escaped to production/a real repo
  and you are asking why the tests missed it. Fires on: "write a golden test",
  "нужен golden на это", "add a fixture", "what should this test assert",
  "почему тесты это не поймали", "unit or golden?". Produces the split, a fixture
  that can actually fail, and structure-not-text assertions. To *run* existing
  goldens, use `run-goldens` instead.
version: 0.1.0
category: testing
---

# new-golden — decide the split, then build a fixture that can fail

Two different tools, constantly confused:

- **Unit test** — pure logic, no network, no DB, no model. Fast, runs in CI on
  every PR, asserts exact behaviour.
- **Golden test** — an **LLM surface** (routing, extraction, synthesis, an
  enrichment pass) against a **real model**. Opt-in, excluded from CI, slow,
  asserts **structure, not text**.

## The split

Put in a **unit test** everything that does not need a model: parsing, tree
building, prompt *construction* (not its answer), digests and cache keys,
triviality gates, ordering, rendering, pruning. Most of a pipeline is this, and
it should be — pure functions are where cheap certainty lives.

Put in a **golden test** only what a model's behaviour decides: does retrieval
rank the right thing, does the pass produce a well-formed artifact, does the
router pick the right agent, does the JSON parse.

If you find yourself wanting a golden to check something deterministic, extract
the deterministic part into a pure function and unit-test *that*. A golden is
the most expensive test you own — spend it only where a real model is the thing
under test.

## The fixture is the test

**A fixture that only contains shapes the code already handles proves nothing.**
This is the single most common way a suite passes while the code is broken: the
sample repo/document/payload is small, flat and friendly, and every hard case
lives only in production data.

Real example: a documentation pipeline had a small flat fixture repo. Three
defects shipped anyway and only surfaced on a 148-class codebase — an aggregate
step ran on the wrong size budget (the fixture's inputs were never big enough to
overflow), a model swap silently skipped regeneration (the fixture was never
re-run under a second model), and a deep nesting chain cost N redundant calls
(the fixture was two levels deep).

So when you build one, deliberately include:

- **Depth and degenerate shapes** — a long single-child chain, an empty
  container, a leaf at the top level, a cycle if the domain allows one.
- **Something big enough to hit a limit** — a batch, window, timeout or page
  size must be reachable, or the budget is untested by construction.
- **A second run under changed conditions** — different model/config/version —
  to prove incremental keys invalidate instead of silently skipping.
- **The boring-but-wrong case** — the input that *looks* processable and is not.

Ask out loud: **"which shape, if it appeared in real data, would break this
code?"** Then put that shape in the fixture.

## Assertions: structure, not text

A model's wording changes between runs and versions; asserting it makes the test
flaky and worthless. Assert instead:

- the right **item** was selected/ranked/produced (identity, not phrasing);
- the artifact's **shape** — required fields present, parses, non-empty, within
  bounds;
- **relationships** — the child resolved, the reference points somewhere real;
- **counts and tiers** — N produced, the trivial ones skipped;
- **idempotence** — a rerun with nothing changed does no work.

Never assert a full generated sentence. If you need semantic quality, assert a
required *token* the answer cannot be right without (a domain identifier), and
accept anything around it.

## Procedure

1. **Classify** what you are testing: deterministic → unit; model-decided →
   golden. Split the thing in two if it is both.
2. **Extend the existing fixture** rather than inventing a parallel one, unless
   the new shape would distort the old assertions — then add a second, named for
   the shape it carries (`…-deep-chain`, `…-oversized`).
3. **Write the failure first**: state the defect this test would have caught. If
   you cannot name one, you are writing a test that can only pass.
4. **Gate it** the way the repo gates goldens (marker/env flag), so it stays out
   of CI and does not need a model on a laptop.
5. **Run it against a real model** before shipping. Do not commit a golden you
   have not seen pass — an unverified golden is worse than none, because it
   looks like coverage. If no engine is available right now, say so explicitly
   and record it as pending rather than merging it green-by-assumption.
6. **Record the cost**: goldens are slow. Note roughly how long the lane takes,
   so the next person knows what they are opting into.

## Triggering contract

Should fire: "нужен golden на новый пайплайн" · "unit or golden for this?" ·
"почему фикстура это не поймала".
Should NOT fire: "прогони голдены" (that is `run-goldens`) · "this golden is
flaky, rerun it" (running/diagnosing, not authoring).
