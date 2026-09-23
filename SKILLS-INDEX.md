# Skills index

One line per skill — the trigger surface. When this list grows past ~10, keep
`CLAUDE.md` pointing here (one link) instead of inlining the skills, so the host
doc stays flat regardless of skill count.

| Skill | Use when |
|---|---|
| [`new-skill`](skills/new-skill/SKILL.md) | Authoring or fixing a SKILL.md so it triggers reliably. |
| [`new-module`](skills/new-module/SKILL.md) | Scaffolding a new module / service / agent / migration from the canonical layout. |
| [`check-drift`](skills/check-drift/SKILL.md) | After any change, before a PR — verify every coupled artifact moved. |
| [`close-pr`](skills/close-pr/SKILL.md) | Finishing a PR — status→history, freshness pass, squash-merge on green. |
| [`bump-deps`](skills/bump-deps/SKILL.md) | Raising an incoming dependency's version across SSOT + lockfile + pins. |
| [`release-version`](skills/release-version/SKILL.md) | Cutting a stable outgoing version — semver + changelog + tag. |
| [`run-goldens`](skills/run-goldens/SKILL.md) | Running the golden LLM tests against a real model — one, several, or all. |
| [`new-golden`](skills/new-golden/SKILL.md) | Deciding unit-vs-golden, authoring a golden test or a fixture that can actually fail. |
| [`add-observability`](skills/add-observability/SKILL.md) | Adding logging to a service/pipeline — event vocabulary, sink, levels, and the never-log-payloads rule. |
| [`scrub-identity`](skills/scrub-identity/SKILL.md) | About to record WHOSE data a run was against — a client/employer repo name, package path or domain vocabulary — in docs, commits, tests or fixtures. |
| [`architecture-checkup`](skills/architecture-checkup/SKILL.md) | Auditing a repo/change against agent-engineering standards — manifests, SDD, TDD, drift, canon, runtime/hardware fit, secrets hygiene. |
| [`map-project`](skills/map-project/SKILL.md) | Starting to onboard/document an unknown repo — scan + index it into a durable project map before writing docs. |
| [`document-project`](skills/document-project/SKILL.md) | Project is mapped — write per-module + root READMEs and per-service AGENTS.md spec skeletons. |
| [`run-guide`](skills/run-guide/SKILL.md) | Getting an unknown project to build & run — iterate-to-green loop (toolchain/certs/.env creds/kubectl port-forwards), then write RUN.md. |
| [`dev-driver`](skills/dev-driver/SKILL.md) | Driving a whole dev task end-to-end — diagnose → spec → implement (TDD) → verify → close, orchestrating the other skills with durable on-disk state. |
| [`plan-change`](skills/plan-change/SKILL.md) | Before coding — turn a task/bug/idea into a small SDD change-spec (intent, given/when/then criteria, artifacts, tests, open questions). Planning only. |
| [`implement-change`](skills/implement-change/SKILL.md) | Writing code against an approved change-spec — the TDD core: failing test (red) → smallest change (green) → refactor, per criterion. |
| [`diagnose`](skills/diagnose/SKILL.md) | Something fails and you need the real cause first — reproduce → read the real failure → quote the decisive line → one hypothesis → smallest probe. |
| [`decompose`](skills/decompose/SKILL.md) | A task with no ready-made workflow skill — map it onto capability skills and propose an ordered plan with confirmation points before changing anything. |
| [`onboard-repo`](skills/onboard-repo/SKILL.md) | Creating or enriching a repo-root AGENTS.md — module map + build commands (grounded in the build file), domain glossary, gotchas. Kept local (git-ignored). |
| [`api-call`](skills/api-call/SKILL.md) | Sending a raw REST or gRPC request (Postman-style) — read a JSON API, or POST/PUT a prepared body to an endpoint. gRPC via grpcurl, REST via curl. |
| [`read-excel`](skills/read-excel/SKILL.md) | Reading an Excel file (`.xlsx`/`.xls`) into structured data (TSV/JSON) for downstream processing. Utility skill for workflow runners. |
