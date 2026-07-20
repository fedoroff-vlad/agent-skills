#!/usr/bin/env bash
#
# check-private-terms — refuse to commit a third party's identity.
#
# Greps the staged diff (or the whole tree with --all) for terms listed in a
# LOCAL, GITIGNORED `.private-terms` file at the repo root. See the scrub-identity
# skill for what belongs in that file and why the identity must not be recorded.
#
# Why local and not CI: on a public repo, CI logs are public, and a failing check
# would print the very term it matched. The denylist itself is sensitive — a file
# naming what you are hiding is the leak with an index attached. Keep it out of
# the repo (.gitignore) and off the build server.
#
# Install as a pre-commit hook (once per clone):
#   printf '#!/bin/sh\nexec "$(git rev-parse --show-toplevel)"/scripts/check-private-terms.sh\n' \
#     > .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
#
# Exit: 0 clean, 1 a term was found, 2 misconfigured (no terms file).
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
terms_file="${PRIVATE_TERMS_FILE:-$root/.private-terms}"
mode="${1:-staged}"
# Absolute, so the self-exclusion below compares like with like whatever the cwd.
terms_file_abs="$(cd "$(dirname "$terms_file")" 2>/dev/null && pwd)/$(basename "$terms_file")"

if [ ! -f "$terms_file" ]; then
  # Loud, not silent: an absent denylist and a clean one look identical otherwise,
  # and "the check passed" would be a false reassurance.
  echo "check-private-terms: no terms file at $terms_file" >&2
  echo "  → create it (one term per line, '#' comments) and add it to .gitignore." >&2
  echo "  → it must NEVER be committed: a published denylist is the leak, indexed." >&2
  exit 2
fi

# Blank lines and comments out; everything else is a literal, case-insensitive term.
mapfile -t terms < <(grep -vE '^\s*(#|$)' "$terms_file" || true)
if [ "${#terms[@]}" -eq 0 ]; then
  echo "check-private-terms: $terms_file lists no terms — nothing to check." >&2
  exit 2
fi

case "$mode" in
  # cached + others: tracked files AND untracked-but-not-ignored ones, which is where a
  # brand-new doc or fixture lives before it is staged.
  --all) files=$(git ls-files --cached --others --exclude-standard) ;;
  staged|"") files=$(git diff --cached --name-only --diff-filter=ACM) ;;
  *) echo "usage: $0 [--all]" >&2; exit 2 ;;
esac

[ -n "$files" ] || exit 0

fail=0
for term in "${terms[@]}"; do
  term_lc=$(printf '%s' "$term" | tr '[:upper:]' '[:lower:]')
  hits=""
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    # Never match the denylist against itself: it is a file full of the very terms we
    # look for. It should be gitignored, but a repo that forgot the .gitignore line
    # would otherwise fail on every run — noise that teaches people to ignore the check.
    [ "$(cd "$(dirname "$f")" && pwd)/$(basename "$f")" != "$terms_file_abs" ] || continue
    # Literal, case-insensitive, and deliberately not `grep -iF`: on MSYS/Git-Bash
    # that combination aborts (SIGABRT), and escaping the term into a regex instead
    # is its own bug farm — a term legitimately contains `/`, `.`, `+`, `(`.
    # Lowercasing the stream and matching literally sidesteps both.
    if tr '[:upper:]' '[:lower:]' < "$f" 2>/dev/null | grep -qF -- "$term_lc" 2>/dev/null; then
      hits="$hits $f"
    fi
  done <<< "$files"
  if [ -n "$hits" ]; then
    fail=1
    # The term is printed only here, on the developer's own terminal — which is
    # precisely why this check does not belong in CI.
    echo "✗ private term '$term' appears in:" >&2
    printf '    %s\n' $hits >&2
  fi
done

if [ "$fail" -ne 0 ]; then
  cat >&2 <<'EOF'

A repository artifact is about to record whose data this is.

Replace the identity with its SHAPE — keep every number and structural fact,
drop only the name ("a 143-file production Java service", not the repo name).
See the scrub-identity skill.

This is the cheap moment. Once pushed to a public remote the string is
effectively permanent: GitHub serves refs/pull/<N>/head forever, so a
force-push does not remove it — only deleting the repository does.
EOF
  exit 1
fi
exit 0
