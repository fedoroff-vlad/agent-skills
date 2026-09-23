---
name: plan-change
description: >
  Use before writing or changing code for a task — turn a task/bug/idea into a
  small SDD change-spec that is the contract for the work: intent, acceptance
  criteria as given/when/then, the exact artifacts to touch, the tests that will
  prove it, and open questions to resolve with the owner. Nothing is mutated —
  planning only. Fires on «составь план по задаче / как будем делать {key|link}»,
  «спланируй правку / фичу», «what's the plan for», «write a change-spec»,
  «before we code». The coding cousin of `decompose` (which plans ops over the
  capability skills); this one plans a CODE change.
version: 0.1.0
category: meta
languages:
  - en
  - ru
---

# plan-change — a small SDD change-spec that is the contract before any code

The **spec-first** step of the dev loop (`dev-driver` phase 2). Produces the
contract a code change is written *against*, so the work has a definition of done
before a line is touched. Reads only — no code, no tests, no commits change here.

## When it fires vs `decompose`

- `plan-change` → the deliverable is a **code change** (fix/feature/refactor):
  its output is acceptance criteria + affected code artifacts + a test list.
- `decompose` → the deliverable is an **ops task** over jira/gitlab/kubectl/etc.:
  its output is an ordered plan over the capability skills.
Cross-linked on purpose; if a request is half-and-half, run `decompose` for the
ops shell and `plan-change` for the code inside it.

## Procedure

1. **Gather context (read-only).** If a Jira key/link is given → read it via
   `jira`. Read the relevant code and its tests. If the task is a bug, also run
   `diagnose` first so the spec targets the real cause, not the symptom.
2. **Write the change-spec** to `.dev/<task>/plan.md` in the target repo
   (template below). The heart of it:
   - **Intent** — one sentence: what changes and why.
   - **Acceptance criteria** — *given / when / then*, one row per observable
     behaviour. These are the tests-to-be; if you cannot phrase a criterion as
     given/when/then, the requirement is still fuzzy — raise it as a question.
   - **Affected artifacts** — the exact files/modules to touch (code + tests +
     config + docs), so the blast radius is explicit up front.
   - **Test plan** — for each acceptance row, the test that will prove it (unit /
     golden / integration) and where it lives. Mark which are new vs edited.
   - **Out of scope** — what this change deliberately does *not* do.
   - **Match the acceptance depth to the task's real intent.** "Fix a value" is
     proven by a unit test; **"make it build" by a compile; "make it run" by a
     real boot + health check — not by compile-green.** Do not quietly narrow the
     DoD below what the request actually asked (compile-green is not "it runs");
     if infra forces a narrower gate, that narrowing is an explicit, owner-agreed
     out-of-scope line, not a convenience.
3. **Collect open questions.** Anything ambiguous (which behaviour is correct,
   which module owns it, a missing id/endpoint) → an explicit numbered list.
   **Never invent an answer** — a guessed requirement is a wrong feature.
4. **Confirm with the owner (★ breakpoint).** Show the spec + the questions as
   buttons where it is a choice. Do not hand off to `implement-change` until the
   spec is approved. On approval, record it in `plan.md` (approved @ date).

## `.dev/<task>/plan.md` template

```markdown
# Change-spec — <task / key>
status: draft | approved (@ <date>)

## Intent
<one sentence: what & why>

## Acceptance criteria
| # | Given | When | Then |
|---|-------|------|------|
| 1 | <state> | <action> | <observable result> |

## Affected artifacts
- code:   <path> — <what changes>
- tests:  <path> — <new | edited>
- config/docs: <path> — <what moves>

## Test plan
| AC# | Test | Kind | Location | New/Edit |
|-----|------|------|----------|----------|

## Out of scope
- <...>

## Open questions
1. <...>
```

## Language

The change-spec (`.dev/<task>/plan.md`) is an agent-facing working artifact →
**English**. The **approval conversation** with the owner (showing the spec,
asking the open questions) is in the **owner's language (default `ru`)**.

## Guardrails

- **Planning changes nothing** — read-only until the spec is approved.
- Do not invent behaviour, ids, or endpoints — surface them as questions.
- The spec lives on disk (`.dev/<task>/plan.md`), not only in context — it is the
  resume anchor and the contract `implement-change` verifies against.

## Triggers / non-triggers

- ✅ «как будем делать KEY-123», «спланируй фичу X», «write a change-spec before coding».
- ❌ «разбей ops-задачу на шаги» → `decompose`; «почему падает» → `diagnose`;
  «пиши код» (spec already approved) → `implement-change`.

## Output

`.dev/<task>/plan.md` (the change-spec) + a numbered open-questions list, awaiting
owner approval. Nothing else is touched.
