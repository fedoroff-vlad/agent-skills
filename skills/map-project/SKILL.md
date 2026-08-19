---
name: map-project
description: >
  Use at the START of onboarding or documenting an unfamiliar project — to scan
  and index it before writing a line of docs. Fires on: "просканируй проект",
  "проиндексируй репозиторий", "разберись в проекте X", "map the project",
  "scan the repo", "что это за проект и из чего он состоит". Runs a mechanical
  scanner, then reads the flagged files to produce a durable project map:
  modules, build system, toolchain, deploy manifests, services/ports, env keys,
  entry points — written to docs/onboarding/project-map.md.
version: 0.1.0
category: onboarding
---

# map-project — scan an unknown repo into a durable, verifiable map

The first phase of onboarding. Produce ONE artifact — `docs/onboarding/project-map.md`
— that every later phase (`document-project`, `run-guide`) reads instead of
re-deriving the repo from scratch. It is written to **disk**, not held in
context: a fresh session after a context reset re-reads it and continues.

The map is **agent-facing** — write it in **English** always (like the
journey-log and spec skeletons), regardless of `ONBOARDING_LANG`. Only the
human-facing READMEs/RUN.md follow the reader's language.

## Two-step rule: machine gathers, you interpret

The scanner emits **candidates with `file:line`** — it never decides meaning.
You (the agent) open the flagged files and extract the semantics. Never copy a
scanner hit into the map as fact without reading the source line.

## Procedure

1. **Locate the target.** Get the project root (by name or path). Everything
   below runs against it, not against this skills repo.

2. **Run the scanner** (pick the platform twin; both are multi-platform):
   ```
   # macOS / Linux / Git-Bash
   sh <agent-skills>/skills/map-project/scripts/scan-project.sh <target-root>
   # Windows
   powershell -NoProfile -File <agent-skills>\skills\map-project\scripts\scan-project.ps1 -Root <target-root>
   ```
   (`<agent-skills>` = `tools/agent-skills` when consumed as a submodule.) It
   prints Markdown sections: build system, modules, toolchain, deploy manifests,
   service/port candidates, env keys, entry points, existing docs.

3. **Interpret, don't transcribe.** For each section, open the real files and
   resolve them into facts:
   - **Modules** → for each, its purpose (read its build file + top package),
     what it depends on, whether it is a service (has a `main`/entrypoint) or a
     library.
   - **Toolchain** → the exact required versions (JDK, Node, …), reconciling
     build files, `.tool-versions`, Dockerfile `FROM`, and CI — flag any
     disagreement, it is a real onboarding trap.
   - **Services & ports** → map each port to the service that owns it; note the
     protocol and whether it is internal or exposed.
   - **Env keys** → dedup the names; for each, what it configures and whether it
     is a **secret** (DB creds, tokens, keys). **Never read or record a secret
     value** — record the key name and where it is consumed.
   - **Deploy manifests** → what backing services exist (DB, cache, broker) and
     how they are wired (compose service names, k8s Services/namespaces).

4. **Write the map** to `docs/onboarding/project-map.md` using the shape below.
   Cite `file:line` for every non-obvious fact — the map must be auditable.

5. **List the open questions.** Anything the scan could not settle (a service
   with no obvious purpose, an env key with no template, a version conflict)
   goes in an explicit "Unknowns" section — these become questions for the user
   or things the `run-guide` loop will resolve empirically.

## Output — `docs/onboarding/project-map.md`

```markdown
# Project map — <name>
_scanned <date> · commit <sha>_

## What it is
<2–4 sentences: domain, shape (monolith / multi-module / microservices), stack.>

## Toolchain (required to build)
| Tool | Version | Source of truth |
|---|---|---|
| JDK | 25 | pom.xml:15, Dockerfile FROM, ci.yml:32 |

## Modules
| Module | Kind | Purpose | Key deps | Port |
|---|---|---|---|---|

## Backing services (from deploy manifests)
| Service | Image / kind | Port | Wired via |
|---|---|---|---|

## Environment / config keys
| Key | Configures | Secret? | Consumed at |
|---|---|---|---|

## Entry points
<how each runnable module starts — main class / command.>

## Unknowns / to resolve
- …
```

## Triggering

SHOULD fire: "просканируй и опиши проект"; "map this repo before we document it";
"проиндексируй монорепу". SHOULD NOT fire: "write the README" (that is
`document-project`, which reads the map this skill produced); "audit the
architecture" (that is `architecture-checkup`). This skill *maps*; it does not
write user-facing docs and does not judge quality.

## Handing off

The map is the input contract for `document-project` (turns modules → READMEs)
and `run-guide` (turns toolchain + services + env into a verified run route).
Keep it current: if a later phase discovers the map was wrong, fix the map too.
