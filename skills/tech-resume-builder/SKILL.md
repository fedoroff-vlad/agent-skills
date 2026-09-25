---
name: tech-resume-builder
description: >
  Use when building or revising a tech resume (Java/backend/IT) as a styled
  single-page HTML/PDF document — covers colortype-based palette selection
  from a photo, the HTML/CSS template, single-page print fitting, and
  HR-style content/positioning rules (ATS keywords, IC vs management
  framing, honesty checks). Fires on: "сделай резюме", "перепиши резюме",
  "собери резюме для [роль]", "сделай мне резюме как для [вакансия]",
  "build me a resume", "rewrite my resume".
version: 0.1.0
category: content
---

# Tech Resume Builder

Builds a polished, single-page, print-ready HTML resume (opens in browser →
"Print to PDF") for a tech/IT candidate, following the full methodology
developed with Vlad: HR-expert-style content rewrite, ATS/LinkedIn
optimization, colortype-matched visual design, and a battle-tested print-CSS
fix that reliably keeps everything on one printed page.

Work through these phases in order. Don't skip the analysis phases even
when the user is in a hurry — weak positioning is the #1 recurring failure
mode, not CSS.

## Phase 1 — Intake & role framing

1. Get the source material: an existing resume (PDF/text), or a raw
   description of the person's experience, jobs, dates, stack.
2. Get a headshot photo if one is available/wanted in the header. Not
   required — a version without a photo is fine (drop the `.header-photo`
   column and the CSS `grid-template-columns` shifts to `1fr 130px`).
3. **Ask (once) or infer**: which role/persona is this resume for? The
   same person may need multiple resumes side-by-side, e.g. "Team Lead"
   vs "Senior Java Developer" — see `references/content-rules.md` →
   "IC vs management framing" for why this matters and how the framing
   differs between them. If ambiguous and the user is present, ask; if
   not, default to the framing implied by the person's actual current
   title and say which reading you took.
4. Note target market/language. If the user wants both RU and EN
   versions, build the RU one first, get it fully approved, THEN
   translate (see `references/content-rules.md` → "Translation rules").
   Don't translate a version that's still being edited — you'll redo the
   translation work.

## Phase 2 — Colortype → palette

If a photo is supplied, determine an accent palette that matches the
person's coloring rather than defaulting to generic blue/corporate:

1. Look at the photo (skin undertone, hair, eye color, natural contrast)
   and classify into a rough seasonal colortype (warm/Autumn or Spring vs
   cool/Winter or Summer — see `references/colortype-palettes.md` for the
   full mapping and ready-made CSS variable sets for each type).
2. Propose ONE palette derived from that colortype, not a menu of
   unrelated colors. Warm/Autumn → terracotta/ochre/brown-black header.
   Cool/Winter → navy or teal, never a generic "corporate blue."
3. If the user rejects a proposed hue family (e.g. "не нравится синий и
   зелёный"), don't just swap to another generic color — pick the next
   plausible option consistent with their actual colortype (e.g.
   teal/turquoise sits between blue and green and can satisfy both
   objections while staying cool-toned).
4. Everything is theme-able through the `:root` CSS custom properties in
   the template (`--bg`, `--paper`, `--ink`, `--accent`, `--accent2`,
   `--accent3`, `--muted`, `--border`, `--tag-bg`, `--tag-text`,
   `--header-bg`, `--header-text`, `--card-bg`) — never hand-edit colors
   throughout the file; change the variables.

## Phase 3 — Photo crop (if a photo is used)

The photo is embedded as a base64 JPEG data URI inside a circular
`<img>` (74×74 display, `border-radius: 50%`, `object-fit: cover`).
Getting the crop right on the first or second try saves a lot of
back-and-forth:

1. Load the source image with PIL, get dimensions.
2. Render a percentage grid overlay (or just crop-and-preview
   iteratively) to locate the hairline, eye-line, nose-tip and chin as
   fractions of image height/width — don't eyeball a crop box from the
   raw image alone.
3. Compute a SQUARE crop box centered on the nose x-position
   horizontally, with enough headroom above the hairline that the
   circular mask doesn't clip the top of the head, then resize down to
   a reasonable embed size (~300–400px square is plenty for a 74px
   display box) before base64-encoding — don't embed a multi-MB original.
4. If the user gives directional feedback ("голову обрезал", "нос не по
   центру", "чуть ниже и правее", "чуть увеличь"), recompute the crop
   math from their words (shift the box, or shrink the square side for
   "увеличь"/zoom-in) rather than guessing a new box freehand.

## Phase 4 — Content: the HR-rewrite pass

Read `references/content-rules.md` in full before writing bullets — it
encodes every positioning rule learned across many rounds of simulated
HR feedback. Highlights (full detail in that file):

- Every achievement bullet leads with an action verb and ends with a
  concrete number/result where one honestly exists. Never invent a
  metric — ask the person what actually happened if a claim sounds
  overstated (see "Honesty checks" in content-rules.md).
- **Architecture-first ordering** for anything senior/lead-facing: put
  system-design/architecture bullets before process/people bullets in
  both the "Key Competencies" grid and each job's bullet list.
- **IC vs management framing**: a resume aimed at a Senior IC role
  (e.g. "Java Developer") should downplay pure people-management
  language (hiring, 1-on-1s, headcount) to avoid an "overqualification"
  rejection — repackage real leadership experience as Tech
  Lead–flavored (system design, code review, mentoring, AI-tooling
  adoption) instead. A resume aimed at a Team Lead/EM role keeps the
  people-management framing front and center.
- Keep employment dates and job titles consistent and
  career-progression-coherent across every version of this person's
  resume — if you change a date or title in one file, check whether
  sibling resumes for the same person need the same fix.
- Don't pad with generic/junior-sounding bullets (Postman testing,
  "handled JSON/XML") just to add length — cut them if the user flags
  them as weak; substitute a real differentiator instead.
- ATS/LinkedIn keyword pass: make sure the stack, role title and
  domain keywords the target job postings use actually appear in the
  visible text (title line, competencies grid, stack lines, sidebar
  tags) — not just implied.

## Phase 5 — Build the HTML

1. Start from `references/template.html` — a complete, working,
   already-print-tested single-page resume template with placeholder
   content and `{{PLACEHOLDER}}` markers. Copy it, don't rebuild from
   scratch.
2. Fill in the palette variables from Phase 2, the photo from Phase 3,
   and the content from Phase 4.
3. Sections available in the template: header (photo + badge/name/
   title/summary + stat blocks), contacts row (phone/email/location/
   Telegram/GitHub — SVG icons inline, no external assets), Key
   Competencies grid (2×2 cards — use for 3–5 headline strengths, skip
   if there's nothing distinct to say), Experience (jobs newest-first,
   each with title/period/company/team-badge/bullets/stack-line),
   sidebar (Tech Stack by group, Education, Languages).
4. Everything must be self-contained in one `.html` file: inline
   `<style>`, inline SVG icons, base64 photo, Google Fonts `@import`
   only external reference. No JS needed.

## Phase 6 — Single-page print fitting

This is the most recurring failure mode: every content addition risks
pushing the resume onto a second printed page. Read
`references/print-fitting.md` for the full explanation (the root
cause is that Chrome doesn't honor `break-inside: avoid` inside
`display: grid` during print — the template already works around this
with a `display: table` override under `@media print`, don't remove
it).

Before adding new content in response to a follow-up request, budget
for it: a new bullet, stat, or sidebar tag has to come from somewhere
if the page is already near full — either it earns its place by
cutting something weaker, or fitting will need another compression
pass. Say so if you can already tell it won't fit.

After every content change, mentally re-check page budget and, if
needed, apply this escalation ladder (details/values in
`references/print-fitting.md`):
1. Reduce `@page { margin: }`.
2. Reduce the print-only `font-size: %` on `body`.
3. Tighten `.job`/`.section` spacing values.
4. Remove content duplicated between the summary/competency cards and
   the job bullets.
5. Trim redundant sidebar tags.
6. Last resort: merge or cut a bullet.

Don't guess — if you have a way to render/print the HTML and check
page count in this session, do that before telling the user it fits.

## Phase 7 — Translation (if an English version is requested)

Only translate once the source-language version is fully approved.
Follow `references/content-rules.md` → "Translation rules" — in
particular: Russian-specific institution names/acronyms (e.g. ЕПГУ,
ЕГИССО, МФЦ) get translated descriptively (e.g. "state services
portal", "benefits registry", "public service centers"), not
transliterated or left in Cyrillic. Keep the exact same CSS, palette,
photo, and print settings — only the text content changes.

## Phase 8 — Deliver

Save the finished file(s) to the outputs location and send them to the
user (do not just describe them). If several resume variants exist for
the same person (e.g. Developer + Team Lead, RU + EN), name files
clearly and consistently, e.g. `resume_<role>_<lastname>[_en].html`.
