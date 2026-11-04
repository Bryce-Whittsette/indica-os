import SwiftUI

/// The Trace mark. Its masters and rules are in `docs/brand`. The line and dot are
/// separate template layers, so each takes its own color.
struct BrandMark: View {
    var size: CGFloat = 48
    var line: Color = Instrument.ink
    var dot: Color = Instrument.signal

    var body: some View {
        ZStack {
            Image("brand-mark-line").renderingMode(.template).resizable().foregroundStyle(line)
            Image("brand-mark-dot").renderingMode(.template).resizable().foregroundStyle(dot)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// The Swift UI wordmark, with the space measured by a bracket. Below 28 pt tall the
/// bracket reads as an underscore, so it's dropped and the plain space remains.
struct BrandWordmark: View {
    var height: CGFloat = 40
    var letters: Color = Instrument.ink
    var space: Color = Instrument.signal

    var body: some View {
        ZStack {
            Image("brand-wordmark-letters").renderingMode(.template).resizable().foregroundStyle(letters)
            if height >= 28 {
                Image("brand-wordmark-space").renderingMode(.template).resizable().foregroundStyle(space)
            }
        }
        .frame(width: height * 256 / 62, height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Swift UI")
    }
}

extension BuiltInApp {
    /// A neutral letter for a third-party service, in place of an imitated logo.
    /// Replace one only with official assets whose usage terms have been confirmed.
    var monogram: String? {
        switch self {
        case .spotify: "S"
        case .youtube: "Y"
        case .notion: "N"
        case .discord: "D"
        case .telegram: "T"
        case .gmail: "G"
        case .outlook: "O"
        case .chatGPT: "C"
        default: nil
        }
    }

    /// The vector master in `Assets.xcassets/Glyphs`, as a template image.
    var glyphAssetName: String { "glyph-\(rawValue)" }
}

/// An app's flat tile. Apps are told apart by the glyph's shape, not by color.
/// The look follows the Settings icon appearance, unless a caller overrides it.
struct AppMark: View {
    @EnvironmentObject private var system: IndicaSystem
    let app: BuiltInApp
    var size: CGFloat = 62
    /// A dock tile: a solid tile with a pale glyph, when the appearance is Automatic.
    var isInverted = false
    /// Sits directly on the wallpaper, so Clear takes the wallpaper's foreground.
    var isOnWallpaper = false
    /// Draws a specific appearance, for the Settings previews.
    var appearance: AppIconAppearance?

    private struct Style {
        let tile: Color
        let glyph: Color
        let edge: Color?
        /// The accent on a live value. Off where it wouldn't read against the tile.
        let liveAccent: Color
    }

    private var style: Style {
        switch appearance ?? system.iconAppearance {
        case .automatic where isInverted:
            let tile = system.wallpaper.foreground
            let glyph = system.wallpaper.invertedForeground
            return Style(tile: tile, glyph: glyph, edge: nil, liveAccent: glyph)
        case .automatic:
            return Style(
                tile: Instrument.surface,
                glyph: Instrument.ink,
                edge: Instrument.edge,
                liveAccent: Instrument.signalText
            )
        case .light:
            let ink = Color(hex: InstrumentTokens.ink.light)
            return Style(
                tile: Color(hex: InstrumentTokens.surface.light),
                glyph: ink,
                edge: ink,
                liveAccent: Color(hex: InstrumentTokens.signalText.light)
            )
        case .dark:
            return Style(
                tile: Color(hex: InstrumentTokens.surface.dark),
                glyph: Color(hex: InstrumentTokens.ink.dark),
                edge: Color(hex: InstrumentTokens.edge.dark),
                liveAccent: Color(hex: InstrumentTokens.signalText.dark)
            )
        case .clear:
            let ink = isOnWallpaper ? system.wallpaper.foreground : Instrument.ink
            return Style(tile: .clear, glyph: ink, edge: ink, liveAccent: ink)
        case .tinted:
            let glyph = system.accentStyle.onColor
            return Style(tile: system.accent, glyph: glyph, edge: nil, liveAccent: glyph)
        }
    }

    var body: some View {
        let style = style
        let shape = RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
        ZStack {
            shape.fill(style.tile)
            if let edge = style.edge {
                shape.strokeBorder(edge, lineWidth: Instrument.hairline)
            }
            AppGlyph(app: app, size: size, color: style.glyph, liveAccent: style.liveAccent)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// A flat tile for a connected service that isn't an app on Home, using its SF Symbol.
struct ServiceMark: View {
    let symbol: String
    var size: CGFloat = 38

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
        Image(systemName: symbol)
            .font(.system(size: size * 0.45))
            .foregroundStyle(Instrument.ink)
            .frame(width: size, height: size)
            .background(Instrument.surface, in: shape)
            .overlay { shape.strokeBorder(Instrument.edge, lineWidth: Instrument.hairline) }
            .accessibilityHidden(true)
    }
}

/// What's inside a tile: a live value, a monogram, or a line glyph.
private struct AppGlyph: View {
    let app: BuiltInApp
    let size: CGFloat
    let color: Color
    let liveAccent: Color

    var body: some View {
        switch app {
        case .calendar:
            TimelineView(.everyMinute) { context in
                VStack(spacing: size * 0.01) {
                    Text(context.date.formatted(.dateTime.weekday(.abbreviated)).uppercased())
                        .font(.system(size: size * 0.16, weight: .medium, design: .monospaced))
                        .foregroundStyle(liveAccent)
                    Text(context.date.formatted(.dateTime.day()))
                        .font(.system(size: size * 0.38, weight: .regular, design: .monospaced))
                        .foregroundStyle(color)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            }
        case .clock:
            TimelineView(.everyMinute) { context in
                ClockFace(date: context.date, size: size * 0.4, line: size * 0.5 * 1.5 / 24, color: color)
            }
        default:
            if let monogram = app.monogram {
                Text(monogram)
                    .font(.system(size: size * 0.42, weight: .regular, design: .monospaced))
                    .foregroundStyle(color)
            } else {
                Image(app.glyphAssetName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.5, height: size * 0.5)
                    .foregroundStyle(color)
            }
        }
    }
}

/// The Clock tile's face, showing the real time.
private struct ClockFace: View {
    let date: Date
    let size: CGFloat
    /// The same line weight as a glyph.
    let line: CGFloat
    let color: Color

    var body: some View {
        let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
        let minute = Double(parts.minute ?? 0)
        let hour = Double((parts.hour ?? 0) % 12) + minute / 60
        let radius = size / 2

        Path { path in
            let center = CGPoint(x: radius, y: radius)
            func hand(_ turns: Double, _ length: CGFloat) {
                let angle = turns * 2 * .pi
                path.move(to: center)
                path.addLine(to: CGPoint(
                    x: center.x + sin(angle) * length,
                    y: center.y - cos(angle) * length
                ))
            }
            path.addEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
            hand(hour / 12, radius * 0.5)
            hand(minute / 60, radius * 0.72)
        }
        .stroke(color, style: StrokeStyle(lineWidth: line, lineCap: .round, lineJoin: .round))
        .frame(width: size, height: size)
    }
}
