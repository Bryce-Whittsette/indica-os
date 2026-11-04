# Design system: Instrument

The owner selected direction A, **Instrument**, on 2026-11-03 from three explored directions (`docs/brief/master-brief.md` §6). Comps: [Swift UI Brand Directions](https://claude.ai/artifact/DkZwBFrE2CY3hW7DQFr44h), which is private to the owner.

**Status: selected, not built.** The app still has the earlier prototype's look. Update this file as tokens ship, and keep it describing what's really in the code.

## Thesis

A phone as a precise tool. Quiet surfaces, ruled lines and one signal color. Nothing moves or glows unless it's telling you something.

## Scope

Instrument applies to Swift UI's own surfaces: the shell, launcher, Lock Screen, switcher, overlays, app bar and original apps. An app that reproduces an existing iOS app keeps that app's layout, density, navigation and controls (§6, §20). Don't reskin those into Instrument.

## Color

Semantic tokens, defined for both appearances:

| Token | Light | Dark | Use |
| --- | --- | --- | --- |
| `ground` | `#E9EBE8` | `#121416` | Shell background |
| `surface` | `#FFFFFF` | `#1E2124` | Tiles, sheets, app content |
| `ink` | `#16181A` | `#ECEEEB` | Text, glyphs, rules |
| `inkSecondary` | `#4C5157` | check contrast when built | Labels, captions |
| `rule` | `#C9CCC8` | check contrast when built | Lighter hairlines |
| `signal` | `#E8430C` | `#FF6A36` | The one accent, for marks and shapes |
| `signalText` | `#B8330A` | `#FF6A36` | The accent as small text |
| `success` | `#1B7F4B` | `#45C486` | Success only |

Signal means "this is current or needs you." It isn't decoration, and it isn't error: errors keep the system red. Contrast needs measuring in both appearances when built, with 4.5:1 for text.

## Type

- The system font carries all UI, through Dynamic Type text styles.
- IBM Plex Mono is the brand face, for numerals and small labels only. It's under the Open Font License and would need bundling. Numerals must still scale with Dynamic Type.
- Headings: semibold, with tracking tightened at large sizes.

## Icons

- Original line glyphs in `ink` on flat `surface` tiles, one line weight (1.5 on a 24 grid), rounded ends and joins, no gradients.
- Apps are told apart by shape, not color. Calendar and Clock show live values.
- Dock tiles invert: `ink` tile, pale glyph.
- Keep editable vector masters in the repo. Xcode asset catalogs can hold SVG as template images, which avoids a custom path parser.
- SF Symbols stay for functional controls inside screens.
- Third-party apps (Spotify, YouTube, Notion, Discord, Telegram, Gmail, Outlook, ChatGPT, Claude) don't get imitated logos. Use a neutral monogram tile unless official assets and their usage terms are confirmed.
- The Settings icon appearance options must keep working or be removed deliberately, with the change recorded.

## Material and depth

Matte and opaque. Hairlines replace shadows. Blur only where iOS supplies it, such as sheets and system bars. The shell's `liquidGlass` and the icons' gradients and shadows go away. Reduce Transparency should change almost nothing.

## Motion

- Default: critically damped, damping 1.0, response 0.30 to 0.34. No overshoot, including after a flick.
- The pager in `HomePager.swift` already behaves this way.
- Press feedback is immediate on touch-down, and cancels when a touch becomes a drag.
- Reduce Motion: changes happen in place or crossfade.

## Signature details

- **Search pill as a ruler:** one tick per page. The current tick is taller and in signal, and it tracks the finger continuously during a scrub.
- **Ledger:** the top of Home is a ruled two-cell strip with Up Next and the (labeled sample) weather, replacing the widget cards.
- **Ruled Calendar:** a hairline grid, with the selected day as an `ink` block with a signal underline.

## Voice

Direct and exact. "Saved on this iPhone." "Not synced with the iOS Calendar." "Microphone access is off."

## Still to do

The logo and wordmark come next, as concepts for the owner to choose from (§6). Until then the old boot mark stays, and the shipped app icon is unchanged.
