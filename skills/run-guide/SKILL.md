---
name: run-guide
description: >
  Use to get an unfamiliar project actually building and running, and to capture
  the working route as a staged RUN.md. Drives an iterate-until-green loop:
  attempt → read the failure → fix (toolchain, certs, .env creds, port-forwards)
  → record → retry. Fires on: "собери и запусти проект", "почему не собирается /
  не запускается", "нужна инструкция по запуску", "какие сервисы и порты
  прокинуть через kubectl", "что положить в .env", "make it build/run",
  "write RUN.md". Asks the user for secrets it cannot derive; never invents them.
version: 0.1.0
category: onboarding
---

# run-guide — make it build, make it run, then write down the route that worked

The verification phase. `document-project` wrote build/run steps tagged
`⚠️ unverified`; this skill runs the **loop** that proves or corrects them, then
distills the happy path into `RUN.md`. It is where "looks right on paper" meets
"actually boots".

## Language

`RUN.md` is **human-facing** → write it in **`ONBOARDING_LANG`** (env var,
default `ru`; `en`/other to override), translating only prose — every command,
env-key name, port and path stays verbatim. The working state
(`journey-log.md`, `project-map.md`) and the generated scripts are agent-facing
→ always English. (Full policy in the orchestrator's `AGENTS.md`.)

## Loop engineering: bounded, stateful, resumable

Two loops — **build**, then **run** — each the same shape:

```
attempt → observe the real failure → form ONE hypothesis → apply the smallest
fix → RECORD it → retry        (until green, or budget exhausted)
```

Rules that make the loop safe and durable:

- **One change per iteration.** Change one thing, retry, read the new error.
  Never batch fixes — you lose which one worked.
- **State lives on disk, not in context.** Append every iteration to
  `docs/onboarding/journey-log.md` *before* retrying (format below). The LLM
  context is ~100k and resets with only a summary — the journey log is the
  memory that survives. On resume, read it and continue from the last open step.
- **Budget the loop.** Cap retries (e.g. 6 per phase). On exhaustion, stop and
  report the wall with its evidence — do not thrash.
- **Secrets come from the human.** When a failure needs a credential/token/key
  you cannot derive (DB password, registry cert, API key), **pause and ask the
  user**. Write the value into the local `.env` (never into a doc, a commit, or
  the journey log — log only the *key name* and that it was supplied).
- **Read logs, don't guess.** The next fix is almost always named in the last
  failure's output (wrong Java version, missing cert, "connection refused" to a
  service that needs a port-forward). Quote the decisive log line in the log.

## Procedure

0. **Load state.** Read `docs/onboarding/project-map.md` (toolchain, services,
   env keys) and `docs/onboarding/journey-log.md` if it exists (resume point).

1. **Build loop.** Run the project's build. On failure, consult
   [`references/failure-playbook.md`](references/failure-playbook.md) for the
   common classes (wrong JDK, no corporate cert in the trust store, missing
   build args), apply one fix, record, retry — until the build is green.

2. **Run loop.** Start the app. Typical wall sequence, each a loop iteration:
   - **Missing config / DB creds** → the app logs what it cannot find. Collect
     the exact env keys, **ask the user** for secret values, write them into
     `.env`, retry.
   - **Backing service unreachable** ("connection refused", timeouts) → the
     service isn't forwarded. Map it from the deploy manifests, then generate a
     launcher with
     [`scripts/gen-port-forward.sh`](scripts/gen-port-forward.sh) /
     [`.ps1`](scripts/gen-port-forward.ps1), save it as
     `docs/onboarding/scripts/port-forward.{sh,ps1}`, run it, retry.
   - **Health check** → hit the health/readiness endpoint (or the first real
     request) to confirm it is genuinely up, not just process-alive.

3. **Distill the route.** Once green, turn the *successful* path — not the dead
   ends — into `RUN.md` using
   [`references/run-md-template.md`](references/run-md-template.md): prerequisites,
   toolchain, `.env` keys (names + which are secrets, values redacted), start
   backing services, port-forwards, build, run, verify. Every step you actually
   executed; nothing you didn't.

4. **Clear the unverified tags.** Go back to the module/root READMEs and remove
   `⚠️ unverified` from each build/run claim the loop confirmed; fix the ones it
   corrected. Documentation and reality now agree.

## journey-log.md entry format (append-only)

```markdown
### <phase> attempt <n> — <date-time>
- ran: `<command>`
- result: FAIL | OK
- evidence: "<the decisive log line>"
- hypothesis: <what you think is wrong>
- fix: <the one change> (secret VALUES redacted — log key names only)
- next: <retry / ask user / done>
```

## Triggering

SHOULD fire: "собери и запусти проект и зафиксируй как"; "какие порты прокинуть
через kubectl"; "что нужно в .env чтобы стартануло"; "почему падает сборка".
SHOULD NOT fire: "напиши README по модулям" (`document-project`); "просто
опиши структуру" (`map-project`). This skill *runs and proves*; the pure-doc
phases don't execute anything.

## Safety

Building and running locally is fine. But treat as confirm-first: writing
secrets the user supplied (into `.env` only), and running the generated
port-forward launcher. Show the generated launcher before running it. Never
print or commit a secret value.
