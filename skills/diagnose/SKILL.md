---
name: diagnose
description: >
  Use when something fails and you need the real cause before fixing — a failing
  build/test, a stack trace, an error in logs, or "works on the stand, not
  locally". Runs one loop-engineering pass: reproduce → read the REAL failure →
  quote the decisive line → one hypothesis → the smallest probe/fix to confirm.
  Pulls logs via `kubectl`/`grafana` when the failure is on a stand. Fires on
  «почему падает / не собирается / не проходит тест», «разбери ошибку / стектрейс
  / логи», «why is this failing», «diagnose this error». Diagnoses; the fix is
  applied by `implement-change` (code) or the matching skill (ops).
version: 0.1.0
category: meta
languages:
  - en
  - ru
---

# diagnose — find the real cause from the real failure, one hypothesis at a time

The loop-engineering front of the dev cycle. A failure is not a mystery to
brainstorm — the next move is almost always **named in the last failure's
output**. This skill's whole job is to get to that decisive line and turn it into
exactly one testable hypothesis, so the fix that follows is aimed, not sprayed.

## Principle

```
reproduce → observe the REAL failure → quote the decisive line → ONE hypothesis
→ smallest probe that confirms/refutes it → conclude
```

Read logs, don't guess. One hypothesis at a time. Never propose a fix whose
evidence you have not seen in the actual output.

## Procedure

1. **Reproduce.** Run the failing thing yourself (build / test / request) and
   capture the actual output — do not diagnose from the user's paraphrase alone.
   Build/test locally; for a stand failure, pull logs via `kubectl` (`логи {pod}
   на {stand}`) or metrics/alerts via `grafana`. Runtime is **PowerShell**.
2. **Find the decisive line.** In the output, locate the *first* real error (not
   the downstream cascade): the root exception, the assertion that failed, the
   "connection refused", the wrong-version line. Quote it verbatim.
3. **One hypothesis.** State a single, specific, falsifiable cause tied to that
   line ("the local run has no port-forward to `svc/api`, so the client 111s",
   not "networking issue"). If two causes are equally likely, name the cheapest
   probe that tells them apart.
4. **Smallest probe.** Do the minimum that confirms or kills the hypothesis — a
   targeted rerun, one log line, one assertion, a config check. No code changes
   here beyond a throwaway probe; the real fix is a separate step.
5. **Conclude + hand off.** Record the finding in `.dev/<task>/dev-log.md` (the
   decisive line + confirmed cause). Route the fix:
   - a **code** cause → `implement-change` (write the failing test first, per its
     TDD loop),
   - an **ops/config** cause → the matching capability skill (`kubectl`,
     `local-dev`, `gitlab`, `bump-deps`, `check-drift`),
   - a **spec** gap (the behaviour itself is undecided) → back to `plan-change`.

## dev-log.md finding format (append-only)

```markdown
### diagnose — <date-time>
- ran: `<command>`  (result: FAIL)
- decisive line: "<the first real error, verbatim>"
- cause (confirmed by <probe>): <the one hypothesis, now proven>
- fix goes to: implement-change | <skill> | plan-change
```

## Language

The `.dev/<task>/dev-log.md` finding is agent-facing → **English**; quoted log
lines stay verbatim. Explaining the cause to the owner is in the **owner's
language (default `ru`)**.

## Guardrails

- Reproduce before diagnosing; a cause you cannot reproduce is a guess.
- One hypothesis / one probe at a time — never batch speculative fixes.
- **Never print secrets** from logs (tokens, creds) — quote only the error text.
- Reading logs/metrics is free; anything that mutates a stand stays behind its
  skill's confirmation gate.

## Triggers / non-triggers

- ✅ «почему не собирается», «разбери этот стектрейс», «logs say connection
  refused — why», «тест падает только в CI».
- ❌ «пиши фикс» (cause already known) → `implement-change`; «собери и запусти с
  нуля» → `run-guide` / `local-dev`; «что в релизе» → `release-notes`.

## Output

The decisive log line, the one confirmed cause, and a routed fix — recorded in
`.dev/<task>/dev-log.md`. No production change is made by this skill.
