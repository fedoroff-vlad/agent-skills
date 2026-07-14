---
name: new-module
description: >
  Use when creating a new module from the project's canonical layout — a new
  service, MCP module, agent, or migration. Fires on: "add a new module",
  "scaffold a service", "new MCP module", "new agent", "new migration". Copies
  the canonical layout, wires it in, and runs check-drift so no coupled artifact
  is forgotten.
version: 0.1.0
category: scaffolding
---

# new-module — scaffold from the canonical example, then reconcile

Do not re-derive a module's layout by reading a sibling wholesale. Start from the
project's designated canonical example and copy its shape.

## Procedure

1. **Find the canonical example**: read the project's patterns pointer (e.g.
   `plans/PATTERNS.md`) which names the canonical module for this kind. If none
   exists, ask the user which existing module to mirror.
2. **Copy the layout**: replicate the directory structure, build file, and
   required boilerplate from the canonical example. Substitute the new name
   everywhere (package, artifact id, resource paths, ports).
3. **Register it**: add the module wherever the project expects it (root build
   file / module list / compose file / plan index).
4. **Reconcile**: run the `check-drift` skill immediately. A new module fires
   several couplings (compose, root README layout, module README, architecture,
   index, env vars) — let check-drift enumerate them rather than trusting memory.
5. **Contract stubs**: create the module's README with its purpose, port, env,
   endpoints/tools, and a one-line index of key classes — the README is read
   before the source, so it must exist from birth.
6. **Test surface**: if the module has an LLM surface, add a golden test; if it
   introduces a cross-service wire contract, add an end-to-end test. State which
   applies.

## Output

The created paths, the couplings check-drift flagged, and a checklist of what the
user must still fill in (real logic, real env values). Never claim the module is
"done" — it is scaffolded.
