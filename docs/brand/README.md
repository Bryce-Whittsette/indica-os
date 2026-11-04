# Swift UI identity

The owner selected the Trace mark with The Space wordmark on 2026-11-03. No trademark search has been run on the marks or the name.

The mark, wordmark and app icon are three separate things with separate jobs:

| Part | Job | Files |
| --- | --- | --- |
| Mark | Stands alone where the name is already nearby or space is tight | `mark.svg`, `mark-dark.svg`, `mark-mono.svg` |
| Wordmark | Says the full product name | `wordmark.svg`, `wordmark-small.svg` and their `-dark` and `-mono` versions |
| Lockup | Mark and name together, for first impressions and headers | `lockup.svg`, `lockup-dark.svg`, `lockup-mono.svg` |
| App icon | The mark inside a tile, for iOS | `IndicaOS/Assets.xcassets/AppIcon.appiconset` |

The SVGs are the editable masters. Raster files come from them: run `swiftc docs/brand/export.swift -o /tmp/brand-export && /tmp/brand-export` from the repository root. It writes the app icons and `docs/brand/png`.

## Construction

**Mark.** A 48-unit grid. One line, 4 units wide with round ends, drawn as a single drag: 14 units between bars, with bends of radius 7. It ends in a dot of radius 4, which is where the finger is now. The whole mark is centered in the grid.

**Wordmark.** Original lettering, not a font, so it needs no font license and nothing to bundle. Eight monospaced cells, each 32 units wide, with a 5-unit line and round ends: cap height at 12.5, x-height at 24.5, baseline at 47.5. The S uses the mark's construction. The space takes exactly one cell, and a square-cornered bracket measures it.

**Lockup.** The mark at 1.25 scale, so its line matches the wordmark's at 5 units, centered on the capitals, then a 14-unit gap.

## Color

| Part | On light | On dark |
| --- | --- | --- |
| Line and letters | `ink` `#16181A` | `#ECEEEB` |
| Dot and bracket | `signal` `#E8430C` | `#FF6A36` |

Use the `-mono` versions, recolored to one solid color, where color isn't available. The dot still shows as a bulb, and the bracket still has its shape.

## Size

- **Mark:** 16 px at the smallest.
- **Wordmark with its bracket:** 28 pt tall at the smallest. Below that the bracket reads as an underscore, which makes the name look like "Swift_UI". Use `wordmark-small.svg`, which has a plain space.
- **Clear space:** at least the height of the wordmark's x-height on all sides. For the mark, 8 of its grid units.

## App icon

The mark at 75% of a full-bleed square tile. iOS applies the corners, so the file has none.

| Variant | Tile | Line | Dot |
| --- | --- | --- | --- |
| Default | `#16181A` | `#ECEEEB` | `#FF6A36` |
| Dark | `#000000` | `#ECEEEB` | `#FF6A36` |
| Tinted | `#000000` | `#FFFFFF` | `#A0A0A0`, since iOS supplies the color |

## Keep it right

- Write the name as **Swift UI**, with the space. "SwiftUI" without one is Apple's framework.
- Don't add a bird, a wing or a chevron, or anything else that recalls Apple's Swift logo.
- Don't redraw the wordmark in a font, close the space, or put the bracket under anything else.
- Don't add gradients, shadows or glass, or use the dot and bracket in any color other than the one accent.
- Don't rotate, stretch or outline the mark, or use it inside a sentence in place of the name.

## Using it

- **In the app:** `BrandMark` and `BrandWordmark`, from the template layers in `Assets.xcassets/Brand`.
- **GitHub avatar:** `png/avatar-1024.png`.
- **Social preview:** `png/social-1200x630.png`. GitHub sets this in the repository's Settings, under Social preview.
- **README and documentation:** the lockup, with `lockup-dark.svg` for dark mode.
