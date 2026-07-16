# Rubric — Architecture canon & Security doctrine

Two axes in one file (they're read together): is the shape canonical, and is the
untrusted-input surface defended.

## Contents
- Service & module boundaries
- Orchestration: thin router vs monolith planner
- MCP: domain vs capability
- The placement rule (tools / reasoning / instructions / rules)
- LLM access & provider independence
- Security doctrine  ← §Security

## Service & module boundaries
- [ ] **Monorepo ≠ monolith**: each service is its own deployable (own build unit,
  own container, own config, own migrations) depending only on shared libs.
- [ ] A module depends on **shared compile-time libs**, not on sibling services'
  internals. Cross-service talk goes over the declared transport only.
- [ ] Adding a component = a new folder + registration; **no edits to existing
  services**. If adding an agent forces edits across the codebase, boundaries leak.
- [ ] Clear split between *shared compile-time code* (a library dependency) and
  *shared deployable runtime capability* (a service) — two different "shared".

## Orchestration — thin router, not a monolith planner
- [ ] The orchestrator/router is **thin**: it routes; the *reasoning* happens in the
  LLM (and in the specialist agents it routes to).
- [ ] Routing is **data-driven** — the classifier reads agent manifests, so a new
  agent extends routing with no orchestrator edit.
- [ ] Multi-domain work is **agent-led coordination** (a specialist gathers others
  through the hub/bus), *not* a growing central planner.
- [ ] Agents never call each other directly — only via the router (sync) or the bus
  (async). Direct agent→agent calls are a finding.

## MCP — domain vs capability
- [ ] **domain-MCP** owns a bounded-context schema (one per domain).
- [ ] **capability-MCP** is a stateless wrapper over an external surface with **no
  schema**, bound by any agent (the shared toolbox).
- [ ] Rule of thumb held: a *raw external capability* → capability-MCP; *reasoning/
  multi-step over the external world* → a specialist agent that binds those MCPs.
  Don't build a "thinking" agent for what is just a tool; don't hide reasoning in an
  MCP.
- [ ] Deterministic inter-service tool calls don't pay MCP/transport overhead when a
  plain internal REST call with the same DTOs would do; the MCP surface is for
  *LLM tool-selection* and *external clients*.

## The placement rule
- [ ] **tools = MCP · reasoning = agent · instructions = skill · editable rules =
  data.** Check each artifact is in the right bucket: a user-editable rule (budgets,
  who-is-who) is *data in the store*, not a prompt (a prompt can't be edited at
  runtime); an instruction is a skill, not code.

## LLM access & provider independence
- [ ] All LLM access flows through **one gateway/client** — one place for provider
  switch, tracing, rate-limit, retry, cache.
- [ ] Provider/model is chosen by **config/env only, no code change**. Agents address
  a *channel* (default/fast/vision/embedding), not a hard model name.

## Security {#security}
Agent systems ingest untrusted text (web, OCR, STT, feeds, forwarded content, recall,
third-party MCP tool descriptions). To an LLM, retrieved text is indistinguishable
from instructions — so defense is doctrine, not a per-feature afterthought.
- [ ] **Retrieved / tool output = data, not instructions.** Fetched / OCR'd /
  recalled content is framed explicitly as quoted untrusted data; the agent never
  follows instructions embedded in it.
- [ ] **Outbound confirm-gate is the backstop.** Any action with external effect
  (messaging others, purchase, booking, sharing/permission change, delete) happens
  only after explicit user confirmation. Injection can *propose*, never *act*.
- [ ] **Memory can be poisoned.** Ambient/auto-captured notes are stored as data and
  resurfaced as "use only if helpful"; a note's text never becomes an instruction.
- [ ] **MCP trust boundary.** First-party MCPs are trusted; **binding any external/
  third-party MCP requires review** — its tool descriptions and outputs are
  untrusted (tool-poisoning vector).
- [ ] **Least authority.** Outward-reaching fetchers are read-only; they never
  execute actions derived from fetched content.
- [ ] Reference frameworks named and actually mapped: **OWASP LLM Top-10** +
  **MCP Top-10**. A checklist exists for adding an ingestion source (provenance
  tagged · framed as data · outbound behind confirm · third-party MCP reviewed).

## Verdict shape for these axes
Separate *canon* findings (boundary leaks, a thickening router, misfiled artifacts)
from *security* findings (an outbound path with no confirm-gate, an unreviewed
external MCP, recall injected as instructions). Security gaps outrank canon gaps.
