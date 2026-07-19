---
name: add-observability
description: >
  Use when adding logging/observability to a new or existing service, module, or
  pipeline — or when a long-running job turned out to be unexplainable after the
  fact. Fires on: "add logging", "нужно логирование", "what do we log here",
  "structured logs", "ship logs to Kibana/Elasticsearch/Loki", "why did this run
  fail and we can't tell", "add metrics/tracing to this pass". Produces a logging
  design (event vocabulary, sink, levels, payload rule) written into the
  architecture doc first, then the wiring.
version: 0.1.0
category: observability
---

# add-observability — design the event stream, then wire it

Logging is a **contract**, not a scattering of `log.info` calls. Ad-hoc logging
produces a stream nobody can query and everybody is afraid to delete. Decide the
shape first, write it into the project's architecture doc, then implement
against it.

## Rule 0 — never log payloads

**Content does not go into logs. At any level. By design.** Prompts, request and
response bodies, document text, source code, personal data — none of it. Log
**names and metrics**: the input's identifier, the output's identifier, sizes,
counts, durations, outcome.

Why this is a rule and not a level:

- Logs are built to *leave the machine* — into a central, searchable, retained
  index that far more people can read than can read the source data.
- A "log payloads only at DEBUG" switch is a switch someone flips during an
  incident and forgets. There should be no switch.
- The content already exists somewhere authoritative (the DB, the artifact on
  disk, the request store). The log's job is to tell you *which* one to go read.

If you cannot debug from names + sizes + durations, add a **field**, not the
payload — e.g. `prompt_chars` instead of the prompt, `result_count` instead of
the results.

## Procedure

1. **Read the project's architecture doc** and find where a cross-cutting
   concern is documented (a `## Storage`-style section). You are adding a
   sibling `## Observability` section.

2. **Choose the sink, and justify it.** Default: **stderr**. Check whether
   stdout is already spoken for — an MCP server, a CLI that pipes structured
   output, anything whose stdout is a protocol. If so, stderr is a *correctness*
   constraint, not a preference: one stray line corrupts the channel. Say that
   in the doc so nobody "tidies" it later.

3. **Choose the format from the destination, not from taste.** If the logs will
   ever reach a log stack (Elasticsearch/Kibana, Loki, Splunk), the answer is
   **JSON Lines — one self-contained event per line**, parseable with no custom
   grok pattern. Offer a `text` renderer for local terminal use; it renders the
   *same* events and is a display choice only.

4. **Write the event vocabulary as a table** — `event.action` → emitter →
   fields. An event is a noun-ish `area.thing` (`enrich.note`, `tool.search`,
   `embed.batch`), not a sentence. This table is the artifact that stops the
   stream drifting into free-form prose.

5. **Fix the field names, and treat them as an interface.** Stable and flat.
   Align with ECS where it costs nothing: `@timestamp` (ISO-8601 UTC),
   `log.level`, `event.action`, `event.duration`. Renaming a field later breaks
   every saved query and dashboard built on it — so decide once, in the doc.

6. **Add correlation.** A `run_id` (or request/trace id) minted per process or
   per request, on **every** event, so one invocation groups into a trace. Add
   the tenant-ish dimension too (`repo`, `service`, `customer`) — several of
   them will share one index.

7. **Keep records single-line.** An exception becomes `error.type` +
   `error.message` on one line. A multi-line traceback gets split by the shipper
   into unrelated documents, and you lose the very failure you were chasing.

8. **The app writes a stream — it does not talk to the log stack.** No
   Elasticsearch client, no network calls on the logging path. A collector
   (Filebeat/Promtail/vector) ships it. This keeps the service runnable offline
   and independent of whether a log stack exists yet.

9. **Log the invisible failure modes.** Every pipeline has at least one failure
   that raises nothing — a truncated prompt, a silently dropped batch, a
   fallback that quietly returns empty. Find it and emit a **warning** with the
   measurement that reveals it (e.g. prompt size vs the context window). This is
   usually the highest-value event in the whole stream.

10. **Levels change volume, never content.** `INFO` = start/finish, counts,
    warnings. `DEBUG` = per-item events with timings. Payload logging is not a
    level (see Rule 0). Level and format come from **env** — a new env var, so
    follow the project's change-propagation map: config + env example + README +
    architecture doc, same PR.

11. **Wire it at the boundaries**, not everywhere: every outbound call (model,
    HTTP, DB batch), every per-item loop in a long pass, every tool/endpoint
    entry point, and the run itself. Use a timing context manager so
    `event.duration` and `outcome=ok|error` are automatic rather than
    remembered.

12. **Test the payload rule.** Write a test that puts a recognizable identifier
    (a class name, a secret-looking token) through the logging path and asserts
    it does **not** appear in the serialized events, while its *size* does. The
    rule then survives the next person who wants to "just temporarily log the
    request".

## Sanity check before you finish

- Can you answer these from the logs alone, with no payloads? *What was slowest?
  Which items failed and where? Did anything approach a limit? How did this run
  compare to the last one?* If not, add fields.
- Would a run that crashed halfway be distinguishable from one still running?
- Is every field name one you are willing to keep for years?

## Triggering contract

Should fire: "add logging to the new service" · "нужно логирование, потом в
Kibana" · "we can't tell what this job did — add observability".
Should NOT fire: "why is this test failing" (debugging, not designing a log
stream) · "add a metrics dashboard" (visualization of an existing stream).
