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
# Run from the repo root: git then reports root-relative paths, so the terms-file
# comparison below is a string compare instead of a subshell per file.
cd "$root"
terms_file="${PRIVATE_TERMS_FILE:-$root/.private-terms}"
terms_rel="${terms_file#"$root"/}"
mode="${1:-staged}"

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
  --all) mapfile -d '' -t files < <(git ls-files -z --cached --others --exclude-standard) ;;
  staged|"") mapfile -d '' -t files < <(git diff --cached -z --name-only --diff-filter=ACM) ;;
  *) echo "usage: $0 [--all]" >&2; exit 2 ;;
esac

# NUL-delimited throughout: a path may contain spaces, and a whole-tree scan is the one
# place where a single mangled path would silently drop a file from the check.
keep=()
for f in "${files[@]}"; do
  [ -n "$f" ] && [ -f "$f" ] || continue
  # Never match the denylist against itself: it is a file full of the very terms we look
  # for. It should be gitignored, but a repo that forgot the .gitignore line would
  # otherwise fail on every run - noise that teaches people to ignore the check.
  [ "$f" != "$terms_rel" ] || continue
  keep+=("$f")
done
[ "${#keep[@]}" -gt 0 ] || exit 0

fail=0

# Escape the term into a basic regex. `grep -iF` would need no escaping, but that exact
# combination aborts (SIGABRT) on MSYS/Git-Bash, so the term is matched as a BRE with -i.
# Only . * [ ] ^ $ \ are metacharacters in a BRE - + ? ( ) { } | are literal - which keeps
# this short and means a term containing / + ( ) needs no special handling.
bre_escape() {
  local s=$1 out='' i c
  # A `case` pattern cannot carry a quoted backslash without the parser treating it as an
  # escape for the following `|`, and ${s//./\.} silently drops the backslash. A containment
  # test on a metachar string avoids both.
  local meta='\.*[]^$'
  for (( i=0; i<${#s}; i++ )); do
    c=${s:i:1}
    [[ $meta == *"$c"* ]] && out+='\'
    out+=$c
  done
  printf '%s' "$out"
}

for term in "${terms[@]}"; do
  # One grep over the whole batch, not one per file: a two-process-per-file loop takes
  # minutes on a 1300-file repo, and a check that slow gets bypassed.
  hits=$(printf '%s\0' "${keep[@]}" | xargs -0 grep -Ili -e "$(bre_escape "$term")" 2>/dev/null || true)
  if [ -n "$hits" ]; then
    fail=1
    # The term is printed only here, on the developer's own terminal - which is
    # precisely why this check does not belong in CI.
    echo "x private term '$term' appears in:" >&2
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
