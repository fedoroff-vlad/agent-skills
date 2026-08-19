# Onboarding doc templates

One template per artifact, so every onboarding produces the **same structure** —
the sections, order and tables are fixed; only the values change. Fill from
`docs/onboarding/project-map.md`. Do not invent sections, do not reorder them.

## The templates

| Template | Produces | Audience → language |
|---|---|---|
| [`root-readme.md.tmpl`](root-readme.md.tmpl) | root `README.md` | human → `ONBOARDING_LANG` |
| [`group-readme.md.tmpl`](group-readme.md.tmpl) | `<group>/README.md` (tiering) | human → `ONBOARDING_LANG` |
| [`module-readme.md.tmpl`](module-readme.md.tmpl) | `<module>/README.md` | human → `ONBOARDING_LANG` |
| [`root-agents.md.tmpl`](root-agents.md.tmpl) | root `AGENTS.md` (agent-dev entry) | agent → **English** |
| [`service-agents.md.tmpl`](service-agents.md.tmpl) | `<service>/AGENTS.md` spec skeleton | agent → **English** |

(RUN.md has its own template in `run-guide/references/run-md-template.md`, same
conventions.)

## Fill conventions (the only syntax)

- `{{TOKEN}}` — replace with one value from the map. If a token has no value and
  its line is not inside an OPTIONAL/REPEAT block, delete that line.
- `<!-- REPEAT <thing>: -->` … `<!-- /REPEAT -->` — emit the block once per
  item (one table row per module, etc.). Remove the markers in the output.
- `<!-- OPTIONAL <condition>: -->` … `<!-- /OPTIONAL -->` — keep only if the
  condition holds; otherwise drop the whole block. Remove the markers.
- `> ⚠️ unverified` — leave verbatim on any build/run claim; `run-guide` clears
  it once proven.
- Everything NOT in `{{...}}` is fixed structure — keep it as written (translate
  only prose/headings when `ONBOARDING_LANG` ≠ en; never translate code,
  commands, identifiers, env-key names, ports, paths).

## Discipline

- An empty section is worse than an absent one: drop a section (OPTIONAL) rather
  than ship a heading with `{{…}}` left in it.
- The footer `_generated from project-map.md @ {{SHA}}_` stays — it is what lets
  `check-drift` detect staleness later.
- Never leave a raw `{{TOKEN}}` in a delivered file.
