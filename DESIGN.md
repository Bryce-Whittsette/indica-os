# Design system: Instrument

The owner selected direction A, **Instrument**, on 2026-11-03 from three explored directions (`docs/brief/master-brief.md` §6). The selected direction's tokens and rules are recorded below.

**Status: built for the shell, simulator-checked.** Tokens, icons, Home, Lock Screen, switcher, overlays, app bar and Calendar use it. It has not been seen on a physical iPhone. See "Not done yet" below. Keep this file describing what's really in the code.

## Thesis

A phone as a precise tool. Quiet surfaces, ruled lines and one signal color. Nothing moves or glows unless it's telling you something.

## Scope

Instrument applies to Swift UI's own surfaces: the shell, launcher, Lock Screen, switcher, overlays, app bar and original apps. An app that reproduces an existing iOS app keeps that app's layout, density, navigation and controls (§6, §20). Don't reskin those into Instrument.

**Calendar is treated as an original surface.** It's Swift UI's own local calendar and doesn't reach the iOS Calendar's data, and the selected direction's comps include a ruled Calendar. This is a reading of the brief, recorded here so the owner can overrule it. Clock, Files and Voice Memos haven't had this decision made and keep system styling.

## Where it lives

- `IndicaOS/InstrumentTokens.swift`: the palette and contrast formula, with no SwiftUI, so `Tests/InstrumentTokenTests.swift` can measure it.
- `IndicaOS/DesignSystem.swift`: `Instrument.*` colors, `mono()`, `motion`, `press`, `InstrumentRule`, `instrumentPanel()`.
- `IndicaOS/InstrumentIcons.swift`: `AppMark`, the live Calendar and Clock tiles, and monograms.
- `IndicaOS/Assets.xcassets/Glyphs`: the SVG masters. Edit these directly.

## Color

Semantic tokens for both appearances. Every pair below is measured in CI: 4.5:1 for text, 3:1 for marks and outlines.

| Token | Light | Dark | Use |
| --- | --- | --- | --- |
| `ground` | `#E9EBE8` | `#121416` | Shell background |
| `surface` | `#FFFFFF` | `#1E2124` | Tiles, panels, app content |
| `ink` | `#16181A` | `#ECEEEB` | Text, glyphs, rules |
| `inkSecondary` | `#4C5157` | `#A3A8A5` | Labels, captions |
| `rule` | `#C9CCC8` | `#3B3F42` | Lighter hairlines between rows. Decorative, so not held to 3:1 |
| `edge` | `#16181A` | `#6B7074` | Outlines of tiles and panels. Softer than `ink` in dark, so outlines don't out-shout the glyphs |
| `signal` | `#E8430C` | `#FF6A36` | The one accent, for marks and shapes |
| `signalText` | `#B8330A` | `#FF6A36` | The accent as small text |
| `success` | `#1B7F4B` | `#45C486` | Success only |

Signal means "this is current or needs you." It isn't decoration, and it isn't error: errors keep the system red. A selected or on control that the shell draws is a solid `ink` block, not signal. iOS controls such as Toggle take the accent, since an ink Toggle loses its white knob in dark.

The default accent, which tints controls across the app, is Signal in its text form. Calendar and Search override it with `ink` where a whole screen of controls would otherwise turn orange. Signal as text reaches 4.5:1 only on Instrument's own ground, so on gradient wallpapers the ledger uses the plain foreground. The earlier accents stay in Settings.

## Type

- The system font carries all UI, through Dynamic Type text styles.
- **Numerals and small labels use the system monospaced face, standing in for IBM Plex Mono**, which isn't bundled. `Instrument.mono()` is the only place that would change.
- Headings: semibold, with tracking tightened at large sizes.
- Home and the Lock Screen have fixed layouts and cap Dynamic Type at the largest non-accessibility size. Calendar day numbers cap at the first accessibility size, because seven columns can't hold larger two-digit days. Everything else on the Calendar scales fully.

## Icons

- Original line glyphs in `ink` on flat `surface` tiles, one line weight (1.5 on a 24 grid), rounded ends and joins, no gradients.
- Apps are told apart by shape, not color. Calendar and Clock show live values.
- Dock tiles invert: solid tile, pale glyph.
- SF Symbols stay for functional controls inside screens.
- Third-party apps (Spotify, YouTube, Notion, Discord, Telegram, Gmail, Outlook, ChatGPT) don't get imitated logos. They use a neutral monogram tile unless official assets and their usage terms are confirmed.
- All five Settings icon appearances still work: Automatic, Light, Dark, Clear and Tinted.

## Material and depth

Matte and opaque. Hairlines replace shadows. Blur only where iOS supplies it, such as sheets and system bars. `liquidGlass` is gone, and so are the Settings controls that only drove it (see the changelog). Weather reproduces the iOS app and sits on its own gradient, so it keeps an iOS material.

The earlier gradient wallpapers stay as a choice, and a saved choice is respected. Instrument's flat ground is the default for anyone who hasn't picked one.

## Motion

- Default: critically damped, damping 1.0, `Instrument.motion` at response 0.32. No overshoot, including after a flick.
- The pager in `HomePager.swift` already behaves this way.
- Press feedback is immediate on touch-down (`Instrument.press`), and cancels when a touch becomes a drag.
- Reduce Motion: changes happen in place or crossfade. Gradient wallpapers hold still.

## Signature details

- **Search pill as a ruler:** one tick per page. The tick nearest the position grows and takes the signal color, continuously, so it tracks the finger during a scrub.
- **Ledger:** the top of Home and the Lock Screen is a ruled two-cell strip with Up Next and the labeled sample weather.
- **Ruled Calendar:** a hairline grid, with the selected day as an `ink` block with a signal underline.

## Voice

Direct and exact. "Saved on this iPhone. Not synced with the iOS Calendar." "Nothing on this day."

## Not done yet

- The logo and wordmark come next, as concepts for the owner to choose from (§6). Until then the old boot mark stays, and the shipped app icon is unchanged.
- IBM Plex Mono isn't bundled.
- Connections keeps its colored service tiles inside the screen, which aren't restyled. Clock, Files and Voice Memos are real but still use system styling.
- The README screenshots still show v0.2.0.
