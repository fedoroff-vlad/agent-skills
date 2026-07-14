# init-project.ps1 — Windows mirror of init-project.sh (kept in sync per the
# change-propagation rule). Wires agent-skills into a target repo.
#
# Usage:  scripts/init-project.ps1 <target-repo-dir> [skills-repo-url]
param(
    [Parameter(Mandatory = $true)][string]$Target,
    [string]$SkillsUrl = "https://github.com/fedoroff-vlad/agent-skills"
)
$ErrorActionPreference = "Stop"

Set-Location $Target
if (-not (Test-Path .git)) { throw "error: $Target is not a git repo" }

# 1. submodule
if (-not (Test-Path tools/agent-skills)) {
    git submodule add $SkillsUrl tools/agent-skills
} else {
    Write-Host "- tools/agent-skills already present - skipping submodule add"
}

# 2. starter change-map
New-Item -ItemType Directory -Force .skills | Out-Null
if (-not (Test-Path .skills/change-map.yaml)) {
@'
# Repo-local coupling table for the check-drift skill.
# See tools/agent-skills/schemas/change-map.schema.json and the examples/ dir.
version: 1
couplings: []
'@ | Out-File -Encoding utf8 .skills/change-map.yaml
    Write-Host "- wrote starter .skills/change-map.yaml (fill in your couplings)"
} else {
    Write-Host "- .skills/change-map.yaml already present - skipping"
}

# 3. CLAUDE.md pointer block
$marker = "## Reusable dev-workflow skills"
if ((Test-Path CLAUDE.md) -and (Select-String -SimpleMatch -Quiet -Path CLAUDE.md -Pattern $marker)) {
    Write-Host "- CLAUDE.md already has the skills block - skipping"
} else {
@'

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
'@ | Add-Content -Encoding utf8 CLAUDE.md
    Write-Host "- appended skills pointer block to CLAUDE.md"
}

Write-Host "done. Review CLAUDE.md placement (move the block into your reading order if needed)."
