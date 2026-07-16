---
name: new-skill
description: >
  Use when you are about to author a NEW reusable skill in this repo, or rewrite
  an existing skill's frontmatter so it triggers reliably. Fires on: "create a
  skill", "add a skill", "why doesn't my skill fire", "write a SKILL.md",
  "make this skill discoverable". Produces a correctly-shaped SKILL.md with a
  trigger-style description and updates the skills index.
version: 0.1.0
category: meta
---

# new-skill — author a SKILL.md the right way

You are creating a portable skill for this repo. A skill is **prompt + I/O
contract**, not an agent: it owns no state. Provider-neutral by rule — the body
must read the same to Claude Code, to a custom `SkillRegistry` loader, or to a
bare LLM that gets the body injected as context. Do not name host-specific tools.

## The one rule that decides everything: the description IS the trigger

A skill is selected because its `description` sits in context (level-1) and the
model matches the user's request against it. So write the description as a
**"use when …"** statement, not a "this does X" statement.

- Weak (describes WHAT): `Checks documentation consistency.`
- Strong (describes WHEN + WHAT): `Use when you changed an env var / port / tool
  / dependency and are preparing a PR — verifies every coupled artifact moved.`

Embed concrete trigger phrases, in every language the users speak, when the
skill is user-invoked (e.g. `"разбери инбокс" / "help me clarify my inbox"`).

## Two kinds of skill — pick the selection mechanism first

1. **Intent skill** (`triggers: []`): selected by an LLM classifier over the
   description. The `description` is load-bearing — invest in "use when".
2. **Trigger skill** (`triggers: [some.kind]`): selected by a deterministic
   string match on an event `kind`, no LLM. Here the `triggers:` list IS the
   "use when"; the description is documentation only. Do not add "use when"
   phrasing to a trigger skill — it is never read for selection.

## Keep the body lean (progressive disclosure)

Only the `description` is always in context. The body loads when the skill runs.
So: put the trigger surface in the description; put the full procedure in the
body; push long reference material into sibling files the body links to and the
agent opens on demand. A bloated body is a tax paid on every invocation.

## Procedure

1. **Name**: short kebab-case verb-or-noun, unique in the repo.
2. **Frontmatter** (see shape below). Write the `description` last, as "use
   when …", and read it back asking *"from this line alone, would I know to
   reach for this skill?"*
3. **Body**: the numbered procedure the agent follows. Reference `.skills/change-map.yaml`
   or other repo config rather than hard-coding project specifics — that is what
   keeps the skill portable.
4. **Index**: add a one-line entry to `SKILLS-INDEX.md` (name — one-line "use when").
5. **Coupling**: if the skill introduces a new coupled artifact, add it to the
   consuming repo's `.skills/change-map.yaml` so `check-drift` covers it.
6. **Verify triggering**: state 2-3 example user requests that SHOULD fire it and
   1-2 that should NOT. If a skill-eval tool is available, run it; otherwise keep
   these examples in the body as a manual triggering contract.

## Frontmatter shape

```yaml
---
name: <kebab-case>
description: >
  Use when <situation/trigger phrases>. <One sentence on what it produces.>
version: 0.1.0
category: <scaffolding | consistency | release | meta | ...>
# triggers: [event.kind]   # ONLY for deterministic trigger skills; omit for intent skills
---
```

Required by the Anthropic spec (all a stock loader reads): `name`, `description`.
`version` + `category` are **this repo's own convention metadata** (provenance +
grouping for `SKILLS-INDEX.md`) — keep them. Beyond those, do not add frontmatter
that *nothing* reads — simplicity over completeness.
