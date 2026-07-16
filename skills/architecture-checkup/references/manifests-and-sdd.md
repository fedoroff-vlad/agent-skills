# Rubric — Manifests & Spec-Driven Development

Verify the repo's instruction/spec surface against the open standards. Read the
actual files; grade what they *do*, not what a README *claims*.

## Contents
- AGENTS.md (repo-root agent instructions)
- Per-module agent manifests
- SKILL.md (Anthropic Agent Skills spec)
- SDD / OpenSpec (spec-first discipline)

## AGENTS.md — the [agents.md](https://agents.md) standard
Open format, no required fields — but presence and shape still matter.
- [ ] An `AGENTS.md` exists at the **repo root** (a predictable place for agent
  context, complementing README which is for humans).
- [ ] In a monorepo, nested `AGENTS.md` may sit in subdirs; the **closest file to
  the edited code takes precedence**. Check that nested files don't contradict the
  root without intending to.
- [ ] Covers the useful sections (all optional, but their absence is a gap):
  project overview · build & test commands · code-style / architecture patterns ·
  testing instructions (how to run checks + fix failures) · security gotchas ·
  commit/PR conventions · deploy steps.
- [ ] Instructions are **executable-check-friendly** — an agent is expected to run
  the programmatic checks named here and fix failures before finishing. Vague prose
  that can't be acted on is a finding.
- Note: some repos use a bespoke per-module manifest (e.g. `AGENT.md`) instead of /
  alongside the root `AGENTS.md`. That is legitimate but is **the repo's own
  convention, not the agents.md standard** — flag any doc that calls it "the
  standard".

## Per-module agent manifests
If the repo registers agents from a manifest file (role, bound skills, bound
tools, routing intents):
- [ ] Each agent has one, at a predictable path.
- [ ] It is the **single source of routing truth** the orchestrator reads — adding
  an agent should extend routing with *no code edit*. If routing facts are also
  hard-coded somewhere, that's drift waiting to happen.
- [ ] Manifest ↔ reality: every skill/tool/intent it lists actually exists.

## SKILL.md — the Anthropic Agent Skills spec
Authoritative rules (see the platform docs, "Skill authoring best practices"):
- [ ] **Required frontmatter is exactly two fields**: `name` and `description`.
  - `name`: ≤64 chars, lowercase letters / numbers / hyphens only, no XML tags,
    **no reserved words** `anthropic` / `claude`.
  - `description`: ≤1024 chars, non-empty, **third person** ("Processes X. Use when
    …"), states *what it does* **and** *when to use it*. Not "I/you can …".
- [ ] Extra fields (version, domain, inputs, triggers, …) are **allowed but not part
  of the spec** — the loader ignores unknown keys. If a repo carries them, they must
  be consumed by the repo's own runtime; a doc claiming a superset file is
  "spec-compatible" should say **superset**, not imply the extras are standard.
- [ ] **Body < 500 lines.** Over that → split into sibling files.
- [ ] **Progressive disclosure**: heavy detail in `references/*.md` linked **one
  level deep** from SKILL.md; scripts executed, not inlined.
- [ ] Names prefer gerund/noun-phrase, consistent across the collection; no vague
  `helper` / `utils`.
- [ ] Every reference link resolves; no dead pointers, no two-level-deep chains.

## SDD / OpenSpec — specification-driven development
From the spec-first philosophy (*"спецификация первична, код — производное от неё"*):
- [ ] **Intent is stored in the repo**, not only in a chat/session — the model has
  no memory across sessions, so the spec must be a committed artifact.
- [ ] **Spec precedes code**: for a nontrivial change there is a spec / change
  proposal (OpenSpec-style) that is the source of truth, and the code derives from
  it. A PR that adds behaviour with no spec delta is a finding.
- [ ] Context is **thin and consistent** — one authoritative spec per concern, not
  the same fact restated in five docs (that guarantees drift).
- [ ] Reusable patterns are captured as **skills/prompts**, not re-derived each time
  ("промпт и скилл — переиспользуемый инструмент, не разовое заклинание").
- [ ] A glossary / shared terminology exists where terms are load-bearing.

## Verdict shape for this axis
List: manifests present/absent, spec-conformance violations (with the exact rule),
and any "standard" over-claim. A repo can be fully functional and still fail here
— these are the maintainability foundations, so grade honestly.
