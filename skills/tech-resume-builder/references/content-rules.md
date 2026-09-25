# Content & positioning rules

These are the HR-expert-style rules learned across multiple simulated
feedback rounds while building resumes for real candidates. Apply them
during the Phase 4 rewrite pass, not as an afterthought.

## Bullet writing

- Lead with an action verb (Спроектировал / Реализовал / Руководил /
  Внедрил / Провёл — Designed / Built / Led / Implemented / Drove).
- End with a concrete result or number where one honestly exists:
  percentage improvement, count of releases/microservices/team size,
  scale indicator ("тысячи транзакций/сутки", "federal-scale").
- One idea per bullet. Don't compress two different achievements into
  one bullet just to save space (e.g. "built the Kafka pipeline AND
  handled the integration modules" reads as vague and undersells both).
  Split them, or cut the weaker one — don't merge unrelated claims.
- Cut generic/junior-sounding filler even if it's technically true:
  "tested endpoints with Postman", "handled JSON/XML payloads" reads as
  junior-level noise on a Senior resume and dilutes stronger claims
  around it. If the user calls a bullet "so-so" ("так себе"), don't
  defend it — replace it with something that actually differentiates
  the candidate.

## Honesty checks

Never let a bullet imply the candidate built infrastructure they didn't
build. If a claim about scope sounds too clean or too impressive for the
context described, ask directly what the person actually did before
writing it up.

Concrete example from this project: an early draft said "Внедрил
event-driven pipeline на Apache Kafka — zero data loss при пиковых
нагрузках," which implied the candidate built the Kafka platform itself.
The real situation: Kafka was pre-provisioned by the platform team; the
candidate's actual contribution was adding consumer-group instances plus
a DLQ-persist-and-retry pattern (failed messages go to a DLQ topic,
persisted to a DB table, then replayed back to the target topic). The
corrected bullet described exactly that scope — still a strong, specific
technical bullet, just accurate:
"Реализовал consumer-логику в рамках платформенного Kafka: подключил
consumer groups, настроил обработку сбоев через DLQ-топик с
персистентностью в БД и механизмом повторной отправки в целевой топик."

When in doubt, ask a specific clarifying question ("what exactly did you
build vs. what was already there?") rather than writing the punchier but
riskier version.

## Architecture-first ordering (senior/lead-facing resumes)

For anyone senior enough that architecture matters (Team Lead, Senior
Developer, Tech Lead), order both the Key Competencies grid and each
job's bullet list so system-design/architecture content comes FIRST,
ahead of process/delivery/people-management content. ATS scanners and
human reviewers both weight the first 1–2 lines of a section most
heavily — don't bury the technical differentiator under process bullets.

## IC vs management framing (the overquailification problem)

A resume aimed at a **Team Lead / Engineering Manager** role should keep
explicit people-management language: hiring, 1-on-1s, team size,
sprint/agile ceremonies, headcount growth. This is expected and wanted
for that role.

A resume aimed at a **Senior IC role** (e.g. "Senior Java Developer")
built from the SAME person's real experience needs the leadership content
**reframed**, not deleted:

- Drop or de-emphasize: hiring, 1-on-1s, headcount, formal "manager of N
  people" framing, explicit "People Management" competency cards.
- Keep and reframe as Tech Lead–style contribution instead: system
  design and architecture decisions, code review practices, mentoring
  junior developers, decomposition/tech-debt calls, driving adoption of
  AI tooling in the team's delivery process.
- Rationale: hiring managers reviewing a Senior IC application may read
  visible management experience as a signal the candidate has moved into
  management and won't want to write code day-to-day — this triggers an
  "overqualified, will leave for a management role" rejection, especially
  in markets/companies hiring strictly for an IC seat.
- Don't literally copy header stats between the two resume versions of
  the same person: e.g. "1.5+ years Team Lead / 3–8 team size" belongs on
  the Team Lead resume; the IC resume should use IC-appropriate stats
  instead (release count, SLA/automation metrics, years of hands-on
  experience) even when it would be technically true to include the
  management stat too.
- If the user asks to copy management-framed content into the IC resume
  verbatim, flag the conflict with this rule and propose the reframed
  substitute rather than silently complying or silently refusing.

A practical hedge worth mentioning to the person: maintaining BOTH
versions in parallel (Team Lead + Senior Developer) as two "hypotheses"
for the job search is a legitimate strategy, since Lead/EM-level roles
often fill through networking rather than open postings and take longer
to close — having a parallel IC-track resume keeps the search moving.

## Consistency across sibling resumes

When the same person has multiple resume files (different role framing,
different language), keep these invariant across all of them unless the
person explicitly wants a version to diverge:

- Employment date ranges.
- Job-title progression (a title shown as "Java Developer → Team Lead"
  in one timeframe shouldn't silently become just "Team Lead" for that
  same period in a sibling file).
- Any technical fact/number (release counts, team size, percentages) —
  fix it in one place, then check whether the others need the same fix.
- Contact details (phone, email, location, Telegram, GitHub).

When moving content between sibling resumes (e.g. "move the AI-agent
achievements from the Team Lead resume into the Developer resume"),
check whether the achievement is chronologically valid in the target
resume's job structure — an achievement true only from a certain date
onward must land inside whichever job entry actually covers that date in
THAT file's timeline, which may differ from where it lived in the source
file if the job ordering/dates differ between versions.

## Key Competencies grid

Use a 2×2 (or up to 3×2) card grid for the 3–6 headline strengths that
most differentiate this candidate for the target role — not a restated
job summary. Each card: a short bold title (emoji + label is fine, e.g.
"🏗 System Design & Architecture") and one dense descriptive line. Order
per the architecture-first rule above. Skip this section entirely if
there isn't genuinely distinct content for it — don't pad it with
generic cards.

## ATS / LinkedIn keyword pass

Before finishing a version, check that the following are visibly present
as real text (not just implied) somewhere in the document, matched to
what the target job postings for this role actually use:
- Exact role title terms ("Java Developer", "Team Lead", "Backend
  Engineer") in the badge/title line.
- Core stack keywords in both the stack-line under each job AND the
  sidebar tag groups (redundancy here is intentional and good for ATS).
- Domain/methodology keywords relevant to the target companies
  (microservices, event-driven, CI/CD, Agile/Scrum, etc.) somewhere in
  competencies or stack lines.
- Contact/profile links (Telegram, GitHub) if the candidate wants to be
  reachable/verifiable — include as an inline SVG-icon contact-row item
  with an `<a href>`.

## Translation rules (RU → EN)

Only translate once the source-language version is fully approved by the
user — translating a version still under active edits means redoing the
translation work.

- Russian-government/institution acronyms are translated **descriptively
  in English**, not transliterated and not left in Cyrillic. Examples
  used in this project:
  - ЕПГУ (Единый портал государственных услуг) → "state services portal"
  - ЕГИССО (Единая государственная информационная система социального
    обеспечения) → "benefits registry" (social-benefits information
    system)
  - МФЦ (Многофункциональный центр) → "public service centers"
  - СФР (Социальный фонд России) → "Russian Social Fund" or contextually
    "federal social-services agency," matching how it's used elsewhere
    in that resume.
- "Неформальную роль Tech Lead" style phrasing → "informal Tech Lead
  role" (keep the "informal"/organic-growth nuance, don't overstate it
  into a formal title change).
- Keep every CSS/palette/photo/print setting byte-identical between
  language versions — only the visible text content changes. Copy the
  file and translate in place rather than rebuilding the HTML from
  scratch, to avoid introducing a print-fitting regression in the new
  file.
- Re-check page-fit independently after translating — English text is
  often ~10–15% longer than the equivalent Russian for the same content,
  which can push a resume that fit in Russian onto a second page in
  English. Apply the escalation ladder in `print-fitting.md` again if so.
