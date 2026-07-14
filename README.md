# agent-skills

Portable, provider-neutral **dev-workflow skills** shared across my repositories
(`ai-life`, `coding-agent`, and any future project). A *skill* is a `SKILL.md`
file — a prompt plus an I/O contract that an agent reads and follows. It owns no
state and names no host-specific tools, so the same file works whether it is:

- auto-discovered by Claude Code's skill loader,
- loaded by a custom `SkillRegistry`-style runtime, or
- injected as plain context into a bare LLM.

## The idea

Every project accumulates the same mechanical rituals — scaffolding a module,
checking that a change propagated to all its coupled files, closing a PR, bumping
a dependency, cutting a release. Copy-pasted into each repo, they drift. This
repo is the **single source of truth** for those rituals: each consuming project
pins a commit via git submodule, so upgrades are deliberate, not surprises.

## How a skill gets used (the one thing to get right)

Only a skill's `description` sits in the model's context (call it *level-1*); the
body loads when the skill actually runs (*level-2*). So an agent decides to use a
skill by **matching the request against the description** — which means the
description must be written as a **"use when …"** trigger, not a "this does X"
summary.

- Weak: `Checks documentation consistency.`
- Strong: `Use when you changed an env var / port / tool / dependency and are
  preparing a PR — verifies every coupled artifact moved.`

This is why adding many skills stays cheap: you pay for the one-line descriptions
always, and for a skill's full body only when it fires. Full authoring guidance
lives in [`skills/new-skill/SKILL.md`](skills/new-skill/SKILL.md).

## The skills

| Skill | Use when |
|---|---|
| [`new-skill`](skills/new-skill/SKILL.md) | Authoring a new skill, or fixing a `SKILL.md` so it triggers reliably. |
| [`new-module`](skills/new-module/SKILL.md) | Scaffolding a new module / service / agent / migration from the canonical layout. |
| [`check-drift`](skills/check-drift/SKILL.md) | After any change, before a PR — verify every coupled artifact moved together. |
| [`close-pr`](skills/close-pr/SKILL.md) | Finishing a PR — status→history, docs freshness pass, squash-merge on green. |
| [`bump-deps`](skills/bump-deps/SKILL.md) | Raising an incoming dependency's version across the SSOT + lockfile + pins. |
| [`release-version`](skills/release-version/SKILL.md) | Cutting a stable outgoing version — semver + changelog + tag. |

The one-line index also lives in [`SKILLS-INDEX.md`](SKILLS-INDEX.md); when the
list grows past ~10, point `CLAUDE.md` at that index (one link) instead of
inlining the skills, so the host doc stays flat regardless of skill count.

## Generic logic, per-repo config

The trick that makes these portable: **the skill logic is generic; the project
specifics live in the target repo.** `check-drift` reads a
`.skills/change-map.yaml` at the consuming repo's root — the table of what must
move together. So one `check-drift` works everywhere, and each repo keeps its own
coupling table (the machine-checkable half of its change-propagation discipline).

- Schema: [`schemas/change-map.schema.json`](schemas/change-map.schema.json)
- Ready-made tables: [`examples/`](examples) (one per repo)

## Consuming from a project

```bash
# one-shot bootstrap: submodule + starter change-map + CLAUDE.md pointer block
path/to/agent-skills/scripts/init-project.sh /path/to/your-repo   # or .ps1 on Windows
```

Then drop the matching `examples/<repo>.change-map.yaml` at your repo root as
`.skills/change-map.yaml`, and move the appended `CLAUDE.md` block into your
session reading order.

## Layout

```
skills/<name>/SKILL.md          # the skills (frontmatter + provider-neutral body)
SKILLS-INDEX.md                 # one-line "use when" per skill (the trigger surface)
schemas/change-map.schema.json  # schema for a repo's .skills/change-map.yaml
examples/*.change-map.yaml      # ready-made coupling tables per repo
scripts/init-project.{sh,ps1}   # wire this repo into a target project
```

## Adding a skill

Use the [`new-skill`](skills/new-skill/SKILL.md) skill. In short: a kebab-case
name, a "use when" description, a lean body (push long reference material to
sibling files the body links to), then add a row to `SKILLS-INDEX.md` — and, if
the skill introduces a new coupling, a line to the consuming repo's
`.skills/change-map.yaml`.

## License

[MIT](LICENSE) — do what you like; keep the copyright notice.
