# Duolingo-inspired UI handoff

This is a style reference, not a brand copy. The visual language borrows the reference app's energy: a white canvas, vivid semantic colors, strong progress signals, and long stacked action buttons.

## Tokens

| Token | Flutter value | Use |
|---|---|---|
| `color.action.primary` | `#58CC02` | Main action and positive progress |
| `color.action.depth` | `#46A302` | Button bottom depth |
| `color.info` | `#1CB0F6` | Active or informational emphasis |
| `color.reward` | `#FFC800` | Time-pool and reward emphasis |
| `color.canvas` | `#FFFFFF` | Page background |
| `color.text.primary` | `#4B4B4B` | Main text |
| `radius.control` | `14` | Buttons and compact controls |
| `space.page` | `24` | Mobile page inset |

## Reusable widgets

- `FocusPrimaryButton`: long rectangular action with face, darker bottom depth, pressed travel, disabled, loading, and semantics states.
- `SurfaceCard`: white surface with a thin boundary and restrained elevation.
- `StatusPill`: explicit text status; color never carries state by itself.
- `_TodayStats` / `_StatTile`: compact Home summary row for today's focus, completion count, and pool balance.

## Handoff rule

Penpot defines the visual contract and component states. Flutter owns scrolling, input, navigation, animation, and business truth. A Penpot prototype does not create the Flutter widget automatically.
