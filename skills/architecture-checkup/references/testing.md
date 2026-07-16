# Rubric — TDD & test strategy

Grade how the repo proves its behaviour. For agent systems the hard part is the
*non-deterministic* surface (LLM output), so a plain unit-test count is not enough.

## Contents
- Test pyramid & altitude
- LLM surfaces: golden / eval lanes
- Wire contracts: E2E
- TDD flow & slice discipline
- CI as the authority

## Test pyramid & altitude
- [ ] Fast **unit / slice** tests are the default while iterating; heavyweight
  integration (containers, real DB) is reserved for repository / migration tests.
- [ ] Each test sits at the **lowest altitude that still proves the thing** — no
  spinning a full context to assert a pure function.
- [ ] The full suite runs **once before a PR** and green **main** is the authority
  for the full run; PR CI may be incremental but must still validate build-config
  changes fully.

## LLM surfaces — golden / eval lanes (the part most repos miss)
Any behaviour that depends on a model needs an **eval**, not just a mock assertion:
- [ ] Every prompt/skill with a strict-output contract (JSON, routing decision,
  classification) has a **golden lane** that drives a *real* model and asserts the
  contract holds (right route, parseable JSON, right fields).
- [ ] Evals exist **before** extensive skill prose (eval-driven development): baseline
  without the skill → three scenarios → minimal instructions that pass them.
- [ ] The lane is runnable on demand (a documented command), and separated from the
  deterministic suite so a flaky borderline case is distinguishable from a real
  regression.
- [ ] For a coding/generation agent: is *end-to-end solution quality* graded, or only
  the pipeline structure? "Structurally checked only" is an honest-gap finding, not a
  pass.

## Wire contracts — E2E
- [ ] **Every cross-service wire contract** (shared DTO / schema) is covered by an
  end-to-end test that proves the DTO survives serialization across the real HTTP/
  transport boundary, both directions.
- [ ] Naming is consistent and discoverable (e.g. `E2E<Feature>…Test`).
- [ ] Transport quirks are handled honestly (if one transport can't be mocked, the
  test routes through the path that can — documented, not silently skipped).

## TDD flow & slice discipline
- [ ] **One PR = one small vertical slice.** A change touching many files with no
  split is a process finding — it defeats review and bisection.
- [ ] Spec/test before code for nontrivial work (pairs with the SDD axis).
- [ ] A failing check blocks "done": the definition of done includes the tests +
  the coupled-artifact updates (see the change-propagation axis).

## CI as the authority
- [ ] CI runs on every PR **including docs-only** (so consistency lints fire) and the
  full suite on main.
- [ ] Locked dependencies are enforced in CI (`--locked` / lockfile check), not just
  locally.
- [ ] Consistency / drift lints run in CI, not only as a human checklist.

## Verdict shape for this axis
Call out: LLM surfaces with no eval lane, wire contracts with no E2E, slices that are
too big, and any "tested" claim the suite doesn't back. Distinguish *structural*
coverage from *quality* coverage explicitly.
