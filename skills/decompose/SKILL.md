---
name: decompose
description: >
  Use when a task has no ready-made workflow skill and must be broken into steps
  first — read the task, map it onto capability skills, and propose an ordered
  plan with confirmation points BEFORE changing anything. Fires on phrases like
  «разбей задачу на шаги» / "break the task into steps", «что нужно сделать по
  {link}» / "what needs to be done for {link}", «декомпозируй» / "decompose",
  «составь план по задаче» / "draft a plan". Planning-only; hands execution to the
  capability skills.
version: 0.1.0
category: meta
languages:
  - en
  - ru
---

# decompose — break a task into a plan over the skills

Meta skill. When no ready workflow skill (`terminations`, `release-deploy`) fits, break an
arbitrary task into steps and propose a plan **before** any mutation.

## Procedure
1. **Gather context** (read-only): read the task (`jira`), attachments, related MRs/branches
   (`gitlab`), and the wiki if needed (`confluence`) — changing nothing.
2. **Break into steps**: for each step state
   - which capability skill runs it (`jira`/`gitlab`/`api-call`/`kubectl`/`grafana`/`yuchat`/`confluence`),
   - the step's input/output,
   - whether it is a mutation or a read (mark ★).
3. **Find unknowns**: what is missing (which status, which stand, which endpoint, which field) — collect
   into an explicit list of questions instead of guessing.
4. **Propose the plan**: numbered steps + confirmation points (every ★) + the questions from step 3.
   **Do not execute** until the plan is approved.
5. After approval — run the steps via the matching skills, confirming the ★ steps.
6. **Notice the pattern**: if such a task recurs, propose turning it into a dedicated workflow skill
   (per the `agent-skills/new-skill` conventions) + a row in `REGISTRY.md`.

## Guardrails
- The planning stage **changes nothing** — reads only.
- The plan is always shown and approved before the first mutation.
- Do not invent values (statuses/fields/endpoints) — surface them as questions.

## Triggers / non-triggers
- ✅ "break KEY-123 into steps", "what needs to be done for {link}".
- ❌ an explicit known case (terminations / release rollout) → go straight to the matching workflow skill.

## Output
A numbered plan (step → skill → input/output → ★?), a list of open questions, and — if this is a
recurring case — a proposal to turn it into a workflow skill.
