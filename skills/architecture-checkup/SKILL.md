---
name: architecture-checkup
description: >
  Use when auditing whether a repo — or one change — conforms to AI-agent
  engineering standards: manifests (AGENTS.md, per-module agent manifests,
  Anthropic SKILL.md), SDD (spec-first), TDD / test strategy, change-propagation
  discipline, architecture canon + security doctrine, and runtime / hardware fit.
  Fires on: "архитектурный чекап", "architecture review", "проверь соответствие
  стандартам / манифестам / спецификации", "is the architecture canonical",
  "will it run on the target hardware", "audit the repo before a milestone".
  Produces a prioritized, evidence-linked findings report (🔴 blocker → 🟢 hygiene).
version: 0.1.0
category: consistency
---

# architecture-checkup — is this repo canonical, and will it actually run?

A structured audit of an agent codebase against the standards that make agent
systems maintainable and safe. It does **not** rewrite anything — it reads,
verifies against a fixed rubric, and reports findings ranked by severity, each
tied to concrete evidence (`file:line`). The detailed rubric per axis lives in
the sibling `references/` files; this body is the procedure and the report shape.

## The six axes (each has a reference rubric)

| Axis | What it verifies | Rubric |
|---|---|---|
| **1. Manifests & SDD** | AGENTS.md (root, [agents.md](https://agents.md) standard), per-module agent manifests, SKILL.md (Anthropic spec), spec-before-code / intent-in-repo. | [references/manifests-and-sdd.md](references/manifests-and-sdd.md) |
| **2. TDD & test strategy** | Test pyramid, golden/eval lanes for LLM surfaces, E2E on every wire contract, one-PR-one-slice. | [references/testing.md](references/testing.md) |
| **3. Change-propagation** | Every coupled artifact moves together; stale facts (models, ports, dims, hosts) across docs. | delegate to `check-drift` + the doc-drift hunt below |
| **4. Architecture canon** | Service boundaries, thin router, MCP domain-vs-capability, tools=MCP / reasoning=agent / instructions=skill / rules=data. | [references/architecture-canon.md](references/architecture-canon.md) |
| **5. Security doctrine** | Untrusted-input-as-data, outbound confirm-gate, MCP trust boundary, OWASP LLM + MCP Top-10. | [references/architecture-canon.md](references/architecture-canon.md#security) |
| **6. Runtime & hardware fit** | Model sizing vs RAM/GPU ceiling, embedding-model↔dim↔column consistency, resource caps, model-swap safety. | [references/runtime-fit.md](references/runtime-fit.md) |

## Procedure

Copy this checklist into your working notes and tick each axis as you finish it:

```
Checkup:
- [ ] 0. Scope: whole repo, or a diff? Which target hardware?
- [ ] 1. Manifests & SDD    (read references/manifests-and-sdd.md)
- [ ] 2. TDD & test strategy (read references/testing.md)
- [ ] 3. Change-propagation  (run check-drift + doc-drift hunt)
- [ ] 4. Architecture canon  (read references/architecture-canon.md)
- [ ] 5. Security doctrine   (same file, §Security)
- [ ] 6. Runtime & hardware  (read references/runtime-fit.md)
- [ ] 7. Compile report
```

1. **Scope.** Establish what is under audit (a whole repo vs a single change) and
   the *target deployment* (host RAM/GPU, local vs cloud models). Runtime-fit
   findings are meaningless without a stated hardware target — get it first.
2. **Per axis, read its rubric file, then verify against the real repo.** Open
   the actual manifests, test dirs, config/env, migrations — do not judge from
   the docs' *claims*; judge from what the code and config *do*. Every finding
   must cite a real `file:line`, never a hunch.
3. **Change-propagation (axis 3).** Run the `check-drift` skill if present. Then
   do the **doc-drift hunt** it cannot: grep the whole repo for facts that live
   in more than one place — model tags, ports, embedding dimensions, host sizes,
   RAM ceilings — and flag any value that disagrees with the source-of-truth
   file. Note whether the repo's `change-map.yaml` even *has* a coupling for each
   drifted fact; a missing coupling is itself a finding (the automat has a hole).
4. **Runtime & hardware fit (axis 6).** This is where "looks fine on paper" meets
   "won't boot". Apply `references/runtime-fit.md` literally — especially the
   embedding-dimension chain (model output dim ↔ config dim ↔ DB `vector(N)`
   column) and the model-memory budget vs the host ceiling.
5. **Compile the report** (shape below). Rank by severity, not by axis order.

## Output — the report

For each finding: **severity · one-line claim · evidence (`file:line`) · why it
matters · fix.** Then one prioritized recommendation table. Severity legend:

- 🔴 **Blocker** — will fail at build/boot/runtime, or a security hole. (e.g. a
  `vector(384)` column fed 768-dim embeddings → every recall insert rejected.)
- 🟠 **Drift** — an artifact that did not move with its coupled change; misleads
  future work but does not crash today.
- 🟡 **Risk** — load-bearing assumption with no guard (e.g. a model swap that
  needs a clean unload but has no test).
- 🟢 **Hygiene** — naming, an over-claimed "compatible", a stale comment.

End with: **verdict** (one line) + the **prioritized fix table** (# · severity ·
action). If an axis is clean, say so in one line — do not invent findings to
fill it.

## Triggering

SHOULD fire: "сделай архитектурный чекап проекта"; "проверь, каноничная ли
архитектура и заработает ли на этом железе"; "audit the repo against agents.md /
SDD / the skill spec before the milestone".

SHOULD NOT fire: "fix this drift" (that is `check-drift` + edits); "scaffold a new
module" (`new-module`); "write a SKILL.md" (`new-skill`). This skill *finds*, it
does not *fix* — hand its findings to those skills.

## Extending

A new standard to check = a new `references/<axis>.md` + one row in the axes
table above. Keep the rubric in the reference file, not in this body — same
discipline as `check-drift` keeping couplings in `change-map.yaml`.
