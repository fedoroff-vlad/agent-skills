---
name: scrub-identity
description: >
  Use when a repository artifact is about to record WHOSE data a tool was run
  against — an employer's or client's repo name, package path, hostname, ticket
  key, or domain vocabulary — in docs, commit messages, PR bodies, tests or
  fixtures. Fires on: "we proved it on <real repo>", "обезличь", "убери
  упоминания", "anonymize this", "is this safe to commit", "can this be public",
  writing a fixture modelled on real data, or a status/architecture note about a
  production run. Produces the de-identified wording plus a local terms check so
  the name cannot come back.
version: 0.1.0
category: consistency
---

# scrub-identity — record the shape of the data, never whose it is

## The boundary that decides every case

**The tool may read anything. The repository may record only shape and scale.**

An indexer, a scraper, a migration script — its whole job is to run against a
real, named system, and inside that run the real names are load-bearing. That is
*input*, and input is not the concern here.

The concern is *artifacts*: files you commit, messages you write, fixtures you
author. There the name is almost never load-bearing. "We proved it on
`acme-billing-aggregate-server`" and "we proved it on a 143-file production Java
service" carry the same engineering weight — the second one just does not hand a
reader your employer's internal system inventory.

Ask of every mention: **does the argument still stand if I replace the name with
its shape?** If yes — and it nearly always is yes — replace it.

## What counts as identifying

Not just the obvious name. In order of how often each is missed:

| Kind | Example | Replace with |
|---|---|---|
| Repo / service name | `acme-billing-aggregate-server` | "a production Java service" |
| Package / namespace path | `ru/gov/agency/dept/product/module` | `com/example/app/module/...`, or describe it: "a seven-level single-child chain" |
| **Domain vocabulary** | industry terms as fixture headings, table rows, class names | neutral equivalents (`Refunds`, `Billing`, `Claim`) |
| Ticket keys | `PROJ-4417` | drop, or "the ticket that asked for X" |
| Hosts / URLs | `wiki.corp.internal`, an intranet Confluence space key | "the internal wiki" |
| People | a colleague's name in a commit message | role: "the reviewer", "the owner" |
| Schema names | real DB / table / topic names copied into a fixture | invented ones |
| Counts that are already public | 143 files, 868 fragments, 7201 edges | **keep** — this is the shape, and it is the part that argues |

The domain-vocabulary row is the one that gets rationalised away: "the fixture is
invented, so it is fine". A fixture written entirely in one industry's terms
reads as a description of a real system, and it points at the same employer as
the repo name did. Invented content in real vocabulary is still a fingerprint.

## Where it leaks from (the non-obvious surfaces)

Docs are the surface everyone checks. These are the ones that get missed:

- **Commit messages and PR bodies** — not reachable by a `grep` over the tree.
- **Test fixtures and synthetic paths** — see above.
- **Golden/perf notes** — "measured on X" is exactly the sentence that names X.
- **Agent memory files** — a note about a measurement carries the name forward
  into every future session, and from there into the next document.
- **Logs, screenshots, `.jsonl` transcripts** pasted into an issue.

## Why the only cheap moment is before the commit

On GitHub, `refs/pull/<N>/head` is served **forever** and a force-push does not
touch it. A merged PR's pre-squash commits stay fetchable by anyone even after
they are gone from `main` — verify it yourself with
`git fetch origin refs/pull/<N>/head`. Rewriting history therefore does **not**
remove a leaked string from a public repo; only deleting the repository does,
and that destroys every PR, discussion and CI record with it.

So: prevention is not merely tidier than cleanup, it is a different order of
cost. Treat this as a pre-commit concern, never a "we can scrub it later" one.

## Procedure

1. **Decide the surface.** Working tree only, or also commit messages / PR
   bodies? A public repo means both.
2. **Sweep.** Grep the tree for the real names *and* their fragments (an org
   abbreviation inside a package path will not match the full repo name). Include
   untracked files; exclude vendor/`.venv`/build output.
3. **Replace with shape, not with a blank.** Keep every number and structural
   fact; drop only the identity. If a replacement makes a sentence vague
   ("proven on a repo"), you removed too much — restore the scale.
4. **Preserve test semantics.** A renamed synthetic path must keep its original
   *depth* and *branching* if a test counts levels; a renamed fixture string must
   be updated at both the fixture and the assertion. Re-run the suite and read
   the failures: a test that now passes for a different reason is worse than the
   leak you fixed.
5. **Record the terms locally** in a gitignored `.private-terms` file (one term
   per line) and run the checker — see below.
6. **Check the non-tree surfaces**: `git log --all -S"<term>"`, PR titles/bodies,
   and any agent memory files.
7. **If it is already published**, say so plainly and separately: what remains
   reachable (history, PR refs, forks, search caches), and that removal may need
   deleting the repo — or a conversation with the data's owner, which is not a
   git operation.

## The mechanical half

`scripts/check-private-terms.sh` (and the `.ps1` twin) greps staged changes — or
the whole tree with `--all` — against a **local, gitignored** terms file.

```sh
scripts/check-private-terms.sh          # staged changes (use in a pre-commit hook)
scripts/check-private-terms.sh --all    # whole working tree
```

**The terms file must never be committed.** A denylist naming what you are
hiding, published in a public repo, *is* the leak — with a helpful index. So:

- keep it at `.private-terms`, and add that path to `.gitignore`;
- keep the check **local** (a pre-commit hook), not a CI step: CI logs on a
  public repo are public, and a failing check would print the very term it
  matched;
- share the file between machines out of band, never through the repo.

Install the hook once per clone:

```sh
printf '#!/bin/sh\nexec "$(git rev-parse --show-toplevel)"/scripts/check-private-terms.sh\n' \
  > .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
```

A missing terms file is reported loudly rather than passing silently — an absent
denylist and a clean one look identical otherwise.

## Triggering contract

**Should fire:**
- "add to STATUS that we proved the indexer on `<real-repo-name>`"
- "обезличь упоминания заказчика в доках"
- "write a fixture based on our production claims wiki"
- "is it safe to make this repo public?"

**Should NOT fire:**
- "index `/path/to/real-repo` and search it" — that is runtime input; the tool is
  supposed to see real names, and nothing is being recorded.
- "rename this variable" — ordinary refactoring with no identity involved.
