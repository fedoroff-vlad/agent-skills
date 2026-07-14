# agent-skills

Portable, provider-neutral dev-workflow skills shared across my repos
(`ai-life`, `coding-agent`, …). A skill is **prompt + I/O contract** — a
`SKILL.md` an agent reads and follows. No host-specific tools in the bodies, so
the same file works whether it is loaded by Claude Code's skill auto-discovery,
by a custom `SkillRegistry`-style loader, or injected as context into a bare LLM.

## Why a separate repo

One source of truth for the rituals that otherwise drift, copy-pasted, across
projects: scaffolding a module, checking change-propagation, closing a PR,
bumping deps, cutting a release. Each consuming repo pins a commit via git
submodule, so upgrades are deliberate.

## How selection works (the one thing to get right)

Only a skill's `description` sits in context (level-1); the body loads when the
skill runs (level-2). So the model decides to use a skill by matching the request
against the **description** — write it as **"use when …"**, not "this does X".
Full guidance: [`skills/new-skill/SKILL.md`](skills/new-skill/SKILL.md).

## Layout

```
skills/<name>/SKILL.md        # the skills (frontmatter + provider-neutral body)
SKILLS-INDEX.md               # one-line "use when" per skill (the trigger surface)
schemas/change-map.schema.json# schema for a repo's .skills/change-map.yaml
examples/*.change-map.yaml    # ready-made coupling tables per repo
scripts/init-project.{sh,ps1} # wire this repo into a target project
```

## Consuming from a project

```bash
# one-shot bootstrap (submodule + starter change-map + CLAUDE.md pointer)
path/to/agent-skills/scripts/init-project.sh /path/to/your-repo
```

Then drop the matching `examples/<repo>.change-map.yaml` at your repo root as
`.skills/change-map.yaml`, and move the appended `CLAUDE.md` block into your
session reading order.

`check-drift` reads that `.skills/change-map.yaml`: the skill logic is generic,
the coupling table is per-repo config. That split is what makes the skills
portable — and it is the machine-checkable half of each repo's
change-propagation discipline.

## Adding a skill

Use the [`new-skill`](skills/new-skill/SKILL.md) skill. In short: kebab-case
name, a "use when" description, a lean body (push long reference material to
sibling files), then add a row to `SKILLS-INDEX.md`.
