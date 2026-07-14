#!/usr/bin/env bash
# init-project.sh — wire agent-skills into a target repo so the skills are
# available "at start". Idempotent: safe to re-run.
#
# Usage:  scripts/init-project.sh <target-repo-dir> [skills-repo-url]
#
# Does three things:
#   1. adds this repo as a git submodule at tools/agent-skills
#   2. drops a starter .skills/change-map.yaml (if absent)
#   3. injects the "Reusable dev-workflow skills" pointer block into CLAUDE.md
set -euo pipefail

TARGET="${1:?usage: init-project.sh <target-repo-dir> [skills-repo-url]}"
SKILLS_URL="${2:-https://github.com/fedoroff-vlad/agent-skills}"

cd "$TARGET"
[ -d .git ] || { echo "error: $TARGET is not a git repo"; exit 1; }

# 1. submodule
if [ ! -d tools/agent-skills ]; then
  git submodule add "$SKILLS_URL" tools/agent-skills
else
  echo "· tools/agent-skills already present — skipping submodule add"
fi

# 2. starter change-map
mkdir -p .skills
if [ ! -f .skills/change-map.yaml ]; then
  cat > .skills/change-map.yaml <<'YAML'
# Repo-local coupling table for the check-drift skill.
# See tools/agent-skills/schemas/change-map.schema.json and the examples/ dir.
version: 1
couplings: []
YAML
  echo "· wrote starter .skills/change-map.yaml (fill in your couplings)"
else
  echo "· .skills/change-map.yaml already present — skipping"
fi

# 3. CLAUDE.md pointer block
BLOCK_MARKER="## Reusable dev-workflow skills"
if [ -f CLAUDE.md ] && grep -qF "$BLOCK_MARKER" CLAUDE.md; then
  echo "· CLAUDE.md already has the skills block — skipping"
else
  cat >> CLAUDE.md <<'MD'

## Reusable dev-workflow skills  (submodule: tools/agent-skills/)
Portable skills shared across my repos. Before doing one of these classes of
work, read the matching `tools/agent-skills/skills/<name>/SKILL.md` and follow
it instead of re-deriving:
- `new-skill`       — author or fix a SKILL.md so it triggers reliably.
- `new-module`      — scaffold a new module / service / agent / migration.
- `check-drift`     — after any change, verify every coupled artifact moved
                      (reads `.skills/change-map.yaml`).
- `close-pr`        — move finished work out of the live status file, freshness
                      pass, squash-merge on green.
- `bump-deps`       — bump an incoming dependency across SSOT + lockfile + pins.
- `release-version` — cut a stable outgoing version (semver + changelog + tag).

The coupling table they consume lives at `.skills/change-map.yaml`.
MD
  echo "· appended skills pointer block to CLAUDE.md"
fi

echo "done. Review CLAUDE.md placement (move the block into your reading order if needed)."
