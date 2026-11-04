import SwiftUI

/// Instrument, the selected design system. See `DESIGN.md`.
///
/// It applies to Swift UI's own surfaces. An app that reproduces an existing iOS
/// app keeps that app's look, so don't reach for these tokens there.
enum Instrument {
    static let ground = Color(InstrumentTokens.ground)
    static let surface = Color(InstrumentTokens.surface)
    static let ink = Color(InstrumentTokens.ink)
    static let inkSecondary = Color(InstrumentTokens.inkSecondary)
    static let rule = Color(InstrumentTokens.rule)
    static let edge = Color(InstrumentTokens.edge)
    static let signal = Color(InstrumentTokens.signal)
    static let signalText = Color(InstrumentTokens.signalText)
    static let success = Color(InstrumentTokens.success)

    static let hairline: CGFloat = 1

    /// The default for anything that moves: critically damped, so nothing overshoots.
    static let motion = Animation.spring(response: 0.32, dampingFraction: 1)
    /// Press feedback, quick enough to read as immediate.
    static let press = Animation.spring(response: 0.2, dampingFraction: 1)

    /// The brand face for numerals and small labels. It uses a text style, so it
    /// follows Dynamic Type. The system monospaced face stands in for IBM Plex Mono,
    /// which isn't bundled; this is the only place that would change.
    static func mono(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .monospaced, weight: weight)
    }
}

extension Color {
    /// A color that follows the current appearance.
    init(_ token: InstrumentColor) {
        self.init(uiColor: UIColor { traits in
            UIColor(rgb: traits.userInterfaceStyle == .dark ? token.dark : token.light)
        })
    }
}

private extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}

/// A one-point horizontal line.
struct InstrumentRule: View {
    var color: Color = Instrument.ink

    var body: some View {
        color
            .frame(height: Instrument.hairline)
            .accessibilityHidden(true)
    }
}

extension View {
    /// A matte panel: an opaque surface with a hairline instead of a shadow.
    func instrumentPanel(cornerRadius: CGFloat = 16) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return background(Instrument.surface, in: shape)
            .overlay {
                shape
                    .stroke(Instrument.edge, lineWidth: Instrument.hairline)
                    .allowsHitTesting(false)
            }
    }
}

/// The main action on a Swift UI screen: a solid ink block. White text on the accent
/// fails contrast in dark, so primary actions don't use it. Give the label its own padding.
struct InstrumentPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Instrument.surface)
            .background(Instrument.ink, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(Instrument.press, value: configuration.isPressed)
    }
}
