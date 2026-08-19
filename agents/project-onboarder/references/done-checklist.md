# Definition of done — the onboarding quality gate

Walk this before declaring a project onboarded. Each item is verifiable, not a
vibe. If an item fails, the onboarding is not done — fix it or record why it is
deliberately skipped (with the owner's sign-off).

## Understanding (document-project)
- [ ] Root `README.md` exists: overview, module map, toolchain, links to `RUN.md`.
- [ ] Root README has the **Mermaid** module graph (and deployment topology if
      there are backing services).
- [ ] Tiering honoured: every top-level group has a README; every **non-trivial**
      module has one; trivial leaves are listed, not carpet-bombed.
- [ ] Cross-links resolve both ways (root ⇄ group ⇄ module ⇄ spec) — no dead links.

## Agent-readiness (SDD)
- [ ] Root `AGENTS.md` exists (English): map, how-to-work, invariants/never-do,
      where intent lives, reading order.
- [ ] Every runnable service has an `AGENTS.md` spec skeleton (English).
- [ ] No `TODO(owner)` that blocks a first build or run (design TODOs are fine).

## Verified run (run-guide)
- [ ] `RUN.md` exists and was **actually executed**, not just written.
- [ ] **Zero `⚠️ unverified` tags** remain in any README or RUN.md.
- [ ] `.env` keys documented (names + which are secrets); no secret VALUES in any
      committed file, README, RUN.md, or the journey log.
- [ ] Backing-service access documented (compose up, or generated port-forward).
- [ ] A health check / smoke test passed and is written down.

## Durability (anti-drift + hygiene)
- [ ] `.skills/change-map.yaml` seeded with the couplings onboarding revealed
      (env-key ↔ .env.example ↔ manifest ↔ docs; port ↔ manifest ↔ RUN.md).
- [ ] Working state (`docs/onboarding/journey-log.md`, `progress.md`) is either
      gitignored or intentionally kept — decided, not accidental.
- [ ] Language policy held: human docs in `ONBOARDING_LANG`, machine artifacts in
      English; code/commands/keys/paths verbatim everywhere.
- [ ] Secrets sweep clean; for a public repo, `scrub-identity` ran with no hits.

## Sign-off
Report the checklist result plainly: what passed, what was skipped and why. Do
not claim "done" while any run item above is red.
