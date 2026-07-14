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
