# Rubric — Secrets & config hygiene

Where secrets live, how config is templated, and whether the repo's *platform*
settings back that up. Grade the **actual git and platform state**, never the
`.gitignore`'s good intentions.

## Contents
- Are secrets actually untracked?
- Templates vs values
- Platform-side scanning (the layer gitignore cannot provide)
- Visibility & licence are deliberate decisions
- Where secrets hide
- If something leaked: rotate
- Anti-pattern: the "private repo as a vault"

## Are secrets actually untracked?
- [ ] **Ask git, not `.gitignore`**: `git ls-files | grep -E '(^|/)\.env'`. A rule in
  `.gitignore` does **not** untrack a file that was already committed — the classic
  false sense of safety. Only `git ls-files` tells the truth.
- [ ] The ignore rule is **deny-by-default with a narrow allowlist**, e.g.
  `.env` + `.env.*` ignored, then `!.env.example` / `!.env.<target>.example`. A bare
  `.env` rule misses `.env.mac`, `.env.local`, `.env.prod`.
- [ ] Check the **history**, not just the tip, when the repo is public and a secret
  is plausible: a value deleted in a later commit is still in the history forever.

## Templates vs values
- [ ] Every secret-bearing key appears in a **committed template** (`*.example`) with
  a placeholder, so a new deploy is "copy the template, fill it in" — not "guess the
  keys". The template is the SSOT for *which* keys exist; it must never carry a real
  value.
- [ ] Template ↔ code parity: every env var the code reads is in the template, and
  every template key is still read. Drift here is silent (a missing key fails at
  boot, an orphaned key misleads forever).
- [ ] Real values are created **once on the deploy host** from the template. If that
  is the whole story, the repo has *no* secret-sync problem — do not invent one.

## Platform-side scanning (the layer gitignore cannot provide)
Gitignore only protects files you *remembered* to ignore. Scanning catches a token
pasted anywhere — a README, a test fixture, a compose file, an attached log.
- [ ] **Public repo → secret scanning + push protection ON.** On public repos these
  are free; push protection blocks the push **before** the secret enters history,
  which is the only cheap moment to stop it.
- [ ] Optional local-side belt: a pre-commit secret scanner (e.g. gitleaks) for
  defence-in-depth. Nice-to-have, not a substitute for push protection.

## Visibility & licence are deliberate decisions
- [ ] Repo visibility matches intent — a public repo is a *choice*; confirm it was one.
- [ ] A **public** repo has a deliberate licence answer. No `LICENSE` file means
  **all rights reserved** by default: nobody may reuse it. That is a legitimate
  choice — but it must be the *chosen* one, not an oversight, and it must not
  contradict a README that advertises a licence. Check both: does `LICENSE` exist
  **and is it tracked** (`git ls-files LICENSE`), and does the host report a licence?

## Where secrets hide
Sweep beyond `.env`: test fixtures and VCR/cassette files · README/docs examples ·
compose + CI workflow files (prefer the platform's secret store) · committed logs ·
notebooks (output cells!) · IDE/run configs · comments in the template itself.

## If something leaked: rotate
- [ ] A secret pushed to a public repo is **compromised permanently** — forks,
  caches, and scrapers act within minutes. Rewriting history is *not* a fix.
- [ ] The only real remediation is **rotate the credential**, then clean history as
  hygiene. Verify the rubric's repo documents that path for anything sensitive.

## Anti-pattern: the "private repo as a vault"
Storing plaintext secrets in a second, private git repo *feels* tidy and is a common
proposal. Flag it: it has no rotation, no audit trail, gets cloned to every machine,
and sits one visibility-flip away from a public leak — usually **weaker** than a
committed template + values created on the host. If secrets genuinely must be
versioned, prefer **encrypted-in-repo** (SOPS + age) or a password/secret manager
over a plaintext private repo. Match the tool to the real problem: if there is one
deploy target and one template, there is no sync problem to solve.

## Verdict shape for this axis
🔴 for anything tracked-and-secret (or a public repo with scanning off *and* a
plausible secret path). 🟠 for template↔code drift. 🟢 for an undecided licence /
visibility that merely needs a conscious answer. Always prove tracking claims with
`git ls-files` output, not by reading `.gitignore`.
