<#
.SYNOPSIS
  check-private-terms -- refuse to commit a third party's identity. (Twin of check-private-terms.sh.)

.DESCRIPTION
  Greps the staged diff (or the whole tree with -All) for terms listed in a LOCAL,
  GITIGNORED `.private-terms` file at the repo root. See the scrub-identity skill for
  what belongs in that file and why the identity must not be recorded.

  Why local and not CI: on a public repo, CI logs are public, and a failing check would
  print the very term it matched. The denylist itself is sensitive -- a file naming what
  you are hiding is the leak with an index attached.

.EXAMPLE
  scripts\check-private-terms.ps1          # staged changes
  scripts\check-private-terms.ps1 -All     # whole working tree

  Exit: 0 clean, 1 a term was found, 2 misconfigured (no terms file).
#>
[CmdletBinding()]
param([switch]$All)

$ErrorActionPreference = 'Stop'
$root = (git rev-parse --show-toplevel).Trim()
$termsFile = if ($env:PRIVATE_TERMS_FILE) { $env:PRIVATE_TERMS_FILE } else { Join-Path $root '.private-terms' }

if (-not (Test-Path $termsFile)) {
    # Loud, not silent: an absent denylist and a clean one look identical otherwise.
    # The message is built first: in Windows PowerShell a here-string terminator must be
    # alone on its line, so `"@ -ErrorAction Continue` is a parse error, not a style choice.
    $msg = @"
check-private-terms: no terms file at $termsFile
  -> create it (one term per line, '#' comments) and add it to .gitignore.
  -> it must NEVER be committed: a published denylist is the leak, indexed.
"@
    Write-Error $msg -ErrorAction Continue
    exit 2
}

$terms = Get-Content $termsFile | Where-Object { $_ -notmatch '^\s*(#|$)' }
if (-not $terms) {
    Write-Error "check-private-terms: $termsFile lists no terms -- nothing to check." -ErrorAction Continue
    exit 2
}

# --cached --others: tracked files AND untracked-but-not-ignored ones, which is where a
# brand-new doc or fixture lives before it is staged.
$files = if ($All) { git ls-files --cached --others --exclude-standard } else { git diff --cached --name-only --diff-filter=ACM }
if (-not $files) { exit 0 }

$fail = $false
# Filter once, then one Select-String per term over the whole batch. A Select-String call
# per file takes minutes on a 1300-file repo, and a check that slow gets bypassed.
$scan = @()
foreach ($f in $files) {
    if (-not (Test-Path $f -PathType Leaf)) { continue }
    # Never match the denylist against itself: it is a file full of the very terms we look
    # for. It should be gitignored, but a repo that forgot the .gitignore line would
    # otherwise fail on every run - noise that teaches people to ignore the check.
    if ((Resolve-Path $f).Path -eq (Resolve-Path $termsFile).Path) { continue }
    $scan += $f
}
if (-not $scan) { exit 0 }

foreach ($term in $terms) {
    # -Path, not the pipeline: piping file NAMES into Select-String searches the names
    # themselves, which silently finds nothing and reports the tree clean.
    # -SimpleMatch keeps the term literal (a term legitimately contains . / + ( );
    # Select-String is case-insensitive by default, which is what we want here.
    $hits = Select-String -Path $scan -SimpleMatch -Pattern $term -List -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -Unique
    if ($hits) {
        $fail = $true
        # Printed only on the developer's own terminal - which is why this is not a CI step.
        Write-Host "x private term '$term' appears in:" -ForegroundColor Red
        $hits | ForEach-Object { Write-Host "    $_" }
    }
}

if ($fail) {
    Write-Host @"

A repository artifact is about to record whose data this is.

Replace the identity with its SHAPE -- keep every number and structural fact,
drop only the name ("a 143-file production Java service", not the repo name).
See the scrub-identity skill.

This is the cheap moment. Once pushed to a public remote the string is
effectively permanent: GitHub serves refs/pull/<N>/head forever, so a
force-push does not remove it -- only deleting the repository does.
"@
    exit 1
}
exit 0
