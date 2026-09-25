# Single-page print fitting

## Root cause

Chrome's print engine does not reliably honor `break-inside: avoid` /
`page-break-inside: avoid` on children of a `display: grid` container.
A two-column resume body built with CSS Grid (`.body { display: grid;
grid-template-columns: 1fr 200px; }`) will often split a job entry or the
sidebar across a page boundary when printed, even though it renders fine
on screen and even with `break-inside: avoid` set on `.job`.

**Fix**: switch the two-column body to `display: table` /
`display: table-cell` specifically inside `@media print`. Chrome's table
layout engine paginates far more predictably than grid. Keep `display:
grid` for screen (nicer to maintain/read) and override only for print:

```css
@media print {
  body { padding: 0; background: white; font-size: 94%; }
  .page { box-shadow: none; border: none; max-width: 100%; }

  /* display:table — единственный надёжный способ держать колонки
     в Chrome при печати */
  .body {
    display: table;
    width: 100%;
    table-layout: fixed;
  }
  .main {
    display: table-cell;
    width: 68%;
    padding: 10px 16px 10px 20px;
    border-right: 1px solid var(--border);
    vertical-align: top;
  }
  .sidebar {
    display: table-cell;
    width: 32%;
    padding: 10px 14px;
    background: #f4efe6; /* or var(--card-bg)/similar */
    vertical-align: top;
  }

  .job { break-inside: avoid !important; page-break-inside: avoid !important; }
  .comp-grid { break-inside: avoid; page-break-inside: avoid; }
}
```

Also set a fixed page size/margin so Chrome doesn't guess:
```css
@page {
  size: A4;
  margin: 8mm;
}
```

This combination (table-based print layout + `@page` + `break-inside:
avoid` on `.job`) is the tested, reliable fix — don't try to solve
pagination with `display: grid` + `break-inside` alone, it will
intermittently fail.

## Content-budget mindset

Every time new content is requested (a bullet, a stat, a competency card,
a sidebar tag), it risks pushing the resume past one page. Treat page
space as a budget, not an afterthought:

- Before adding, glance at how full the page already looks. If it's
  already tight, either something else needs to shrink/go, or say up
  front that a compression pass will be needed.
- After adding, actually re-check (render/print if you have the means in
  this session) rather than assuming it fits.

## Escalation ladder (apply in this order when content overflows)

1. **Reduce `@page` margin.** Start at 8mm, drop to 6mm, then 5mm if
   needed. Cheap, no visual quality loss until quite small.
2. **Reduce the print-only body font-size.** The template's screen size
   is 100%; print already starts around 94%. Drop in ~2–3% steps (94% →
   91% → 88%) — still legible printed at these sizes on A4.
3. **Tighten spacing values** in `.job` (margin-bottom/padding-bottom),
   `.section` (margin-bottom), and `.achievements li` (margin-bottom) —
   shave 1–2px at a time from each, print CSS only, don't touch the
   screen values.
4. **Remove duplicated content** between the header summary / Key
   Competencies cards and the job bullets — if the same claim appears in
   both, cut it from the shorter/higher-level spot.
5. **Trim redundant sidebar tags** — dedupe skills that are implied by a
   broader tag already present (e.g. don't list both "Spring Boot" and
   "Spring" if "Spring Boot" already covers it), or merge near-duplicate
   skill groups.
6. **Last resort: merge or cut a bullet.** Only after 1–5 haven't gotten
   it under one page. Prefer merging two related bullets into one dense
   bullet over deleting a bullet's information outright — check with the
   user before cutting a whole achievement rather than compressing it.

Never skip straight to step 6 — steps 1–3 alone usually recover a full
extra line or two of vertical space with zero content loss.

## Sanity checks

- If a page-2 overflow is only a few millimeters, step 1 or 2 alone
  usually fixes it.
- If it's overflowing by more than ~15–20%, you likely need several
  steps combined, or genuinely too much content was added for one page —
  say so rather than shrinking the font past ~85% (illegible when
  printed).
- Photo/header layout issues (e.g. sidebar dropping below the main
  column instead of staying beside it) are usually the same grid/print
  bug — check that `.header` and `.body` both have print-mode table
  overrides, not just `.body`.
