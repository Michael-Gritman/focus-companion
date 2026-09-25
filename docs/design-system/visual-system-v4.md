# V4 — Color-led Home and Time Pool

2026-09-14. User found earlier palette swaps too superficial and requested a more distinctive structure with substantial theme color. This is a visual proposal awaiting review.

## Updated in place

- Home: full-width orange #FF8A1F action region, compact daily statistics, large duration with minute ruler, app summary, and a white B-2 primary action. Recurring rules are plain rows rather than repeated cards; recent records remain below.
- Time Pool: full-width yellow #FFD43B balance region with large available minutes and credit/debit totals. Seven-day accumulation and ledger continue on white below.
- Both top regions end with rounded lower corners. Both retain 48 × 48 blank character slots and 390 × 1080 board dimensions.
- Existing completion and restriction screens were left unchanged. No new boards created.
- Retains the orange/white/yellow direction, dark #302E2A text, green credit semantics and red debit semantics.

## Prototype boundaries

### Home refinement (V4.1)

User rejected the edge-to-edge colored functional area and requested only Home to be refined first. Home now separates its white title/statistics area from an inset orange action panel at (12,202), sized 366 × 312 with radius22. A pale orange duration control contains a smaller 64px number, stepper controls and 15/30/45/60 presets. App selection gets its own row. White primary button uses radius13 and a reduced 3px depth. The blank companion slot is44px. Orange theme remains #FF8A1F.

The lower Home sections and all other boards were verified unchanged. Home screenshot reviewed, no out-of-bounds text or file integrity errors. Saved as V4.1 · Home / 留边与精简启动面板. Selection/start controls remain static; existing navigation is unchanged. This is a review proposal, not final design approval.

Home and Time Pool navigation is wired without transitions; latest credit opens the existing completion screen. Start, app selection, minute ruler, rule controls, management, full ledger and More are static design controls. No real timer, blocking or ledger persistence. Home depicts idle state. The long boards show scroll-length compositions; sticky navigation or nested scroll behavior is not validated.

### Home single-action revision (V4.2, supersedes earlier Home controls)

User explicitly requested bright yellow instead of orange, removal of top branding/slogan for future animation and variable copy, and only a Start button inside the main functional frame. Applied to Home only. The frame now has a shaped/chamfered outline, lighter upper bevel, darker lower depth and a restrained shadow. Face #FFD43B; centered white button with #FFD43B text as requested. Removed duration, preset, stepper, app selection, disclosure and other text from the frame. Daily statistics remain outside it. Other Home orange accents changed to yellow; all other pages verified unchanged.

Reviewed exported Home screenshot, confirmed the frame contains only the Start label as text, validated the file, and saved version V4.2 · Home / 明黄立体框与单一开始按钮. No new boards or working start flow added.

Static values remain: 90 minutes available = 270 credited - 180 spent. Today 90 minutes completed in two sessions. Last seven daily focus amounts are 30,45,0,60,25,20,90.

## Penpot locations and verification

- File: f3fd0af9-0404-8150-8008-9e2ae16d5720
- Page: 6420ea78-4e1c-80cb-8008-a2af97708cc4 — V4 · 行动首页与时间积累
- Home: 6420ea78-4e1c-80cb-8008-a2b046f8d259
- Time Pool: 6420ea78-4e1c-80cb-8008-a324ea50c556
- Saved version: V4 · 鲜橙行动首页与明黄时间池
- Previous version backed up before edits.
- Both screenshots reviewed; no text outside board bounds or file integrity errors. All five new navigation hotspots read back with expected destinations. Completion and restriction board signatures match pre-edit state. Canvas focused on the two updated boards.
