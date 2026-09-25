# V2 — 伙伴与时间

Created 2026-09-14 in the existing Penpot file. This is a proposed visual direction for user review, not a new product specification or an approved final brand.

## Scope

Exactly three new screen boards: Home, Restriction active, Completion. Original exploration boards and V1 screens are preserved on their original page. No extra setup, navigation, or error screens were created.

## Visual direction

- Editable vector sprout companion, working name 小芽. Three poses: waiting with a time droplet, reading quietly, celebrating.
- Time Pool is a physical basin in the scene. Completion changes its color and presents the balance credit, 60 → 90 minutes.
- Warm ivory #FAF7EF, indigo #29314F / #283150, apricot #F18A58, lavender #E8E3F3, seed yellow #F5D184.
- Retains B-2 depth on primary actions, selective S-2 surfaces, T-1 Nunito numbers with Noto Sans SC, D-2 spacing, C-1 filled status chips, N-1 quiet text navigation placeholders.
- Bottom navigation icons and final Rive motion remain undecided. Current character artwork consists of editable vector shapes, not a Rive animation.

## Prototype

- Home → Start 30 minutes → Active.
- Active → after 8 seconds, or tap companion → Completion.
- Completion → Return home.
- Fixed demonstration: TikTok and 小红书, 30-minute restriction, initial balance 60 minutes, completed balance 90 minutes. Returning home restarts the demonstration. Timer is static; no real blocking or persistent ledger is implemented.
- Bottom labels and the selection summary are visual placeholders, not additional implemented flows. Prototype boundaries are written outside the three screens in Penpot.

## Penpot locations

- File: f3fd0af9-0404-8150-8008-9e2ae16d5720
- Page: 6420ea78-4e1c-80cb-8008-a2af97708cc4 — V2 · 伙伴与时间 / 三屏体验
- Home: 6420ea78-4e1c-80cb-8008-a2b046f8d259
- Active: 6420ea78-4e1c-80cb-8008-a2b0c27d0454
- Completion: 6420ea78-4e1c-80cb-8008-a2b1830acc1d
- Flow: V2 · 从首页开始
- Saved version label: V2 · 伙伴与时间 · 三屏可交互原型

## Verification

All three PNG exports visually reviewed. File referential integrity returned no errors; screen text bounds showed no overflow. All three click interactions read back with the expected destinations; the active screen delay read back as 8000 milliseconds. The page has exactly three top-level boards. Browser playback itself was not independently clicked through.
