# Colortype → palette mapping

Goal: pick ONE accent palette that matches the person's natural coloring
(skin undertone, hair, eyes) instead of a generic "corporate blue" default.
This is a lightweight seasonal-colortype read from a photo, not a formal
consultation — good enough to make the resume look intentionally designed
for this person rather than templated.

## How to read the photo

Look at:
- **Undertone**: warm (golden/peachy/olive skin, looks good in gold
  jewelry) vs cool (pink/blue undertone, looks good in silver).
- **Hair**: warm browns/auburns/golden blonde → warm. Ash/cool brown,
  black, or cool blonde → cool.
- **Eyes**: warm hazel/amber/warm brown → warm. Blue, grey, cool brown,
  green-grey → cool.
- **Overall contrast**: high contrast between hair/skin/eyes → Winter
  (cool+deep) or Deep Autumn; low/soft contrast → Summer (cool+soft) or
  Spring/soft Autumn (warm+soft).

You don't need to nail the exact 12-season label — just warm-vs-cool plus
soft-vs-deep is enough to choose a palette family.

## Palette families (CSS `:root` variable sets)

Drop any of these straight into the template's `:root { ... }` block.

### Warm — Autumn / Deep Autumn (terracotta/ochre) — used for Vlad's resumes
```css
:root {
  --bg: #f0ece4;
  --paper: #faf7f2;
  --ink: #1e1a14;
  --accent: #7b3f1e;
  --accent2: #b8621a;
  --accent3: #c9922a;
  --muted: #7a6e5f;
  --border: #d8cfc0;
  --tag-bg: #ede5d8;
  --tag-text: #5c3010;
  --header-bg: #2a1a0e;
  --header-text: #f5efe6;
  --card-bg: #efe7d6;
}
```

### Warm — Spring (lighter, brighter warm) — golden/coral accent
```css
:root {
  --bg: #f4efe6;
  --paper: #fdfaf4;
  --ink: #22190f;
  --accent: #b5451a;
  --accent2: #e07a2e;
  --accent3: #e3a83c;
  --muted: #8a7a63;
  --border: #e6d9c4;
  --tag-bg: #f5e6d3;
  --tag-text: #7a3a10;
  --header-bg: #3a230f;
  --header-text: #fbf3e6;
  --card-bg: #f6e9d6;
}
```

### Cool — Winter (deep, high-contrast) — navy accent
```css
:root {
  --bg: #eceef2;
  --paper: #f8f9fb;
  --ink: #141a24;
  --accent: #1c3a5e;
  --accent2: #2f5d8a;
  --accent3: #4a90c4;
  --muted: #667080;
  --border: #d3d9e2;
  --tag-bg: #e4e9f0;
  --tag-text: #1c3a5e;
  --header-bg: #0f1c2e;
  --header-text: #eef2f7;
  --card-bg: #e6ebf2;
}
```

### Cool — Winter/Summer (teal/turquoise) — alternative to navy or green
Use when the person rejects both plain blue and plain green but is
clearly cool-toned; teal sits between the two and reads as more distinct/
designed than navy.
```css
:root {
  --bg: #e9f1f0;
  --paper: #f7fbfa;
  --ink: #12211f;
  --accent: #0f5c56;
  --accent2: #1d8a80;
  --accent3: #3fb3a6;
  --muted: #5f7876;
  --border: #cfe0dd;
  --tag-bg: #dcefec;
  --tag-text: #0f5c56;
  --header-bg: #0b2e2a;
  --header-text: #edf7f5;
  --card-bg: #e0efec;
}
```

### Cool — Summer (soft, muted cool) — dusty rose/mauve accent
```css
:root {
  --bg: #f0edf0;
  --paper: #faf8fa;
  --ink: #201c22;
  --accent: #6b4a5e;
  --accent2: #99697f;
  --accent3: #b98ba0;
  --muted: #7d7480;
  --border: #ddd4db;
  --tag-bg: #ece2e8;
  --tag-text: #5c3f4f;
  --header-bg: #2c1f28;
  --header-text: #f5eef2;
  --card-bg: #ede3ea;
}
```

## Process

1. Classify warm/cool + soft/deep from the photo.
2. Propose exactly ONE palette (the matching family above, or a close
   variant) — don't present a menu of unrelated colors.
3. If rejected, don't jump to a random other family — narrow within the
   same warm/cool axis (e.g. cool rejects blue+green → try teal, which is
   still cool but visually distinct from both).
4. Every other color in the template (borders, tag backgrounds, dividers)
   derives from these same variables — never hardcode a one-off hex value
   elsewhere in the CSS.
