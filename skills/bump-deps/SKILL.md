---
name: bump-deps
description: >
  Use when raising the version of an INCOMING dependency. Fires on: "bump the
  dependency", "update the library", "upgrade <lib>", "refresh the lockfile",
  "dependencies are outdated". Bumps the version in the single source of truth,
  syncs the lockfile, rebuilds, revalidates, and fixes any pinned references.
version: 0.1.0
category: release
---

# bump-deps — one version, propagated to every pin

A dependency version usually lives in more than one place. Bump the source of
truth, then chase every pin — a half-bumped dependency is drift that compiles.

## Procedure

1. **Identify the SSOT**: the manifest that declares the version — e.g.
   `pom.xml` dependency management, `pyproject.toml`, `package.json`. Bump there.
2. **Sync the lockfile**: regenerate the lock so it matches (`uv lock`,
   `npm install`, etc.). Lockfile and manifest must move together — CI likely
   runs `--locked` / `--frozen` and will fail otherwise.
3. **Chase pinned references**: grep for the old version string in scripts,
   Dockerfiles, docs, `.env` examples, README badges — bump each. Consult
   `.skills/change-map.yaml` if a "new dependency" coupling is listed.
4. **Respect load-bearing pins**: some pins are intentional (a BOM, a
   Testcontainers version). Do not "upgrade" those blindly — confirm before
   touching a pin the project marks as deliberate.
5. **Rebuild + revalidate**: run the build and the relevant tests / golden lane.
   A dependency bump is not done until the suite is green.
6. **Report breaking changes**: if the bump pulled a breaking transitive change,
   surface it — do not silently paper over it.

## Output

Old → new version, every file touched, build/test result. If the build breaks,
report the failing assertion — do not leave a half-applied bump.
