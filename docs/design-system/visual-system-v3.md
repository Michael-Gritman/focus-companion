# V3 — Static Home, Time Pool and completion

Updated 2026-09-14. Proposed design for review, not an approved final visual system.

## User direction

Make the static UI work without characters or animation. Replace character artwork with small blank reserved slots. Modify existing Home and completion screens, preserve the existing second screen, and add Time Pool.

## Result

- Home: 390 × 1080. Daily completed minutes and count, app/duration selection, primary start action, two recurring rules, recent completed sessions, quiet text navigation.
- Time Pool: 390 × 1080. Available balance, cumulative credits/debits, seven-day focus chart and recent ledger entries.
- Completion: 390 × 844. Prominent +30, before/after balance 60 → 90, reduced contextual copy and links to Time Pool/Home.
- All three edited screens use a 52 × 52 blank dashed slot for future characters. No character illustration or new animation in these screens.
- Exactly one board added; two existing boards rebuilt. The original second board and descendants were compared before/after and remained unchanged.

## Working visual choices

Warm background #FAF7EF; indigo text #29314F and balance surface #283150; apricot action #F29467 with #BC5E3D depth; pale elevated surfaces #FFFDF8 and #E7E1D6 boundaries. Nunito numbers paired with Noto Sans SC. These are V3 proposals, not newly approved design tokens.

## Palette trial — 2026-09-14

User requested a more energetic palette inspired by Duolingo's use of clear bright colors. Applied directly to Home, Time Pool and completion; still a trial awaiting visual review.

- White background #FFFFFF, neutral surface #F5F7FB, ink #253047, muted text #687386, boundaries #E3E7EF.
- Action/selected blue #3067F2, button depth #2049B5, light blue balance surface #EDF4FF.
- Lemon #FFC800 highlights the new balance on completion, with dark ink text.
- Grass green #58C832 fills completion badges with #193D21 text; readable positive figures use #287235.
- Debit figures use #B33A35 on pale red #FFF0EE accents.
- Existing layouts, reserved character slots, navigation, and original second board retained. No extra boards created.
- Saved version: V3 · 配色试验 / 明亮蓝、柠檬黄、草绿. Previous warm palette backed up before editing.
- Reviewed all three color-trial PNGs, checked file integrity, and verified the second board was unchanged.

## Palette trial A — fresh orange, yellow and white

User found the blue palette too cold and businesslike, and requested a trial of the proposed orange direction. Applied directly to the same three screens without changing geometry, text or navigation.

- White background retained. Neutral surfaces #F6F6F3, boundaries #E7E6E1, ink #302E2A, secondary text #72716C.
- Fresh orange #FF8A1F for actions, selected duration, enabled rules and today's chart column. Button depth #C65A12; labels and arrows use dark ink for readability.
- Yellow #FFD43B highlights the new completed balance. Green success feedback and ledger semantics retained.
- Previous blue surfaces and historical chart columns changed to neutral grays, reducing the pervasive blue tint.
- All three screenshots reviewed. Layout, text and interaction destinations compared unchanged; the original second board remains untouched. No new boards created.
- Saved version: V3 · 配色试验 A / 鲜橙、明黄、白. Blue version backed up before editing.

## Prototype boundaries

Home / Time Pool navigation and latest credit → completion are linked without animation. App selection, duration chips, rule switches, management, full ledger and More remain static design controls. Long boards present full scroll-length content; nested scrolling, sticky running bars and real interactions were not implemented or tested. Home depicts an idle state, so it does not simultaneously show an active running bar.

Static data: today two sessions totaling 90 minutes; lifetime credits 270 minus debits 180 equals available balance 90. The seven displayed daily amounts sum to 270. The recent ledger is a partial history. Viewing completion does not represent a new credit.

## Penpot

- File: f3fd0af9-0404-8150-8008-9e2ae16d5720
- Page: 6420ea78-4e1c-80cb-8008-a2af97708cc4 — V3 · 静态 UI / Home · Time Pool
- Home: 6420ea78-4e1c-80cb-8008-a2b046f8d259
- Time Pool: 6420ea78-4e1c-80cb-8008-a324ea50c556
- Completion: 6420ea78-4e1c-80cb-8008-a2b1830acc1d
- Preserved second board: 6420ea78-4e1c-80cb-8008-a2b0c27d0454
- Review boards arranged together to the right of the preserved second board.
- Flow: V3 · 首页与时间池
- Saved version: V3 · 静态 Home、Time Pool 与成功结算
- Pre-edit version saved: V2 · 修改前备份 / 保留角色版

## Verification

All three screenshots visually reviewed. No file integrity errors or text overflowing board bounds. All seven navigation hotspots read back with the correct destinations. Second board signature unchanged. Browser playback was not independently clicked through.
