---
name: release-version
description: >
  Use when cutting a stable/production release of THIS project. Fires on: "cut a
  release", "bump the version", "tag a release", "ship to prod", "release notes".
  Determines the semver bump from merged PRs, updates version files, generates a
  changelog, and tags. Distinct from bump-deps (incoming deps vs outgoing version).
version: 0.1.0
category: release
---

# release-version — cut a stable outgoing version

This is about the project's OWN version, not its dependencies. Reproducible and
deliberate — production cadence, not a routine merge.

## Procedure

1. **Find the last release**: the latest tag / version file value.
2. **Gather the delta**: list merged PRs / commits since that tag.
3. **Decide the bump** (semver): breaking change → major, new feature → minor,
   fix only → patch. State the reasoning from the delta; ask the user if the
   delta is ambiguous rather than guessing major/minor.
4. **Update version files**: bump every place the version is declared (manifest,
   about screen, `__version__`, etc.). Consult `.skills/change-map.yaml` for a
   "project version" coupling if present.
5. **Changelog**: generate a human-readable changelog section from the delta,
   grouped (Added / Changed / Fixed). Link PRs.
6. **Green gate**: confirm the default branch is green before tagging — never tag
   a red build.
7. **Tag**: create the annotated tag. Pushing the tag / triggering the prod
   deploy is outward-facing — confirm with the user before pushing.

## Output

The chosen version + why, the changelog section, files bumped, and the tag
command (executed only after the user confirms the push). Stop before any
irreversible publish step and ask.
