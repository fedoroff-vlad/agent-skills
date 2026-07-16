# Rubric — Runtime & hardware fit

The axis that separates "correct on paper" from "boots on the box". Needs a stated
hardware target (host RAM, GPU/unified-memory ceiling, local vs cloud models). No
target → say so and skip the numeric checks rather than guess.

## Contents
- Model memory budget vs the ceiling
- Embedding dimension chain (the classic silent blocker)
- Model swap / multi-tenant residency
- Per-process resource caps
- Cold-start & lifecycle assumptions

## Model memory budget vs the ceiling
- [ ] Sum the **resident model footprint** for each declared runtime profile
  (weights at the actual quantization + KV cache + context) and compare to the
  host's real ceiling. On unified-memory Macs the GPU working set caps at ~75% of
  RAM (≈48 GB on a 64 GB box) — the models must fit *under that*, with margin, not
  under total RAM.
- [ ] Every model **named in a deploy config** is one the sizing math accounts for.
  A doc that lists a 70B-class "candidate" while the box is sized for 32B is a 🔴/🟠
  contradiction — 70B at Q4 alone (~40 GB) can exceed the ceiling.
- [ ] Backing services + JVM/process heaps + OS are included in the peak, not just
  the models.

## Embedding dimension chain — verify end to end (common 🔴 blocker)
The output dimension of the embedding model must equal the config dim must equal the
DB column dimension. A break here passes every mock test and fails on the first real
insert. Check all three, for the **real deploy config** (not the mock/dev one):
- [ ] **Model → dim**: what does the configured embedding model actually emit?
  (e.g. `nomic-embed-text` = 768, `bge-m3` = 1024, `all-MiniLM`-class = 384.)
- [ ] **Config dim** (`*_EMBED_DIM` / settings): equals the model's output dim.
- [ ] **DB column** (`vector(N)` in the migration): equals both. Watch for a column
  hard-coded to the *mock* provider's dim (often 384) that never moved when the real
  model was chosen.
- [ ] **Is this coupling in the repo's `change-map.yaml`?** If model↔dim↔column isn't
  a tracked coupling, the drift is structural — flag the missing coupling too.
- [ ] Changing the model implies a **migration + re-embed**, not just an env flip, if
  the column dim changes. Confirm that path is documented.

## Model swap / multi-tenant residency
- [ ] If two tenants/models share one engine on a tight box, the design must
  guarantee **they are never both resident at peak** (e.g. downshift tenant A when
  tenant B activates). Verify the numbers of the *peak* profile, not the normal one.
- [ ] A **clean unload before load** on swap is load-bearing on a tight box — if the
  outgoing model isn't evicted before the incoming one loads, peak momentarily needs
  both. Is that guarded by a test / health-gate, or only an env flag? Flag-only on a
  tight box is a 🟡 risk.

## Per-process resource caps
- [ ] Long-lived processes (JVMs, workers) have **explicit heap/memory caps**; a
  fleet of uncapped runtimes on a fixed box is a latent OOM. Count them × cap ≤
  budget.
- [ ] Container/process count for the always-on set fits the "hot" budget; on-demand
  components are actually startable on demand (health endpoint to poll, stateless
  over shared storage so start/stop is safe).

## Cold-start & lifecycle assumptions
- [ ] Any "start cold on demand" plan has a real trigger path and a discovery model
  that can **route to a stopped component** (a startup-static registry that only
  knows live components is incompatible with lazy activation — a known prerequisite,
  flag if unaddressed).
- [ ] Cold-start latency budget is met by a real mechanism (e.g. AOT/CDS), not hope.

## Verdict shape for this axis
Lead with anything that fails at boot/first-real-request (dimension mismatch,
over-ceiling model set) as 🔴. Then residency/swap risks as 🟡. Always tie each to the
stated hardware target and the exact `file:line` of the offending value.
