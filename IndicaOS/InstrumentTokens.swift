import Foundation

/// One Instrument color: an sRGB value for each appearance.
struct InstrumentColor {
    let light: UInt
    let dark: UInt
}

/// The Instrument palette, free of SwiftUI so `Tests/InstrumentTokenTests.swift`
/// can measure its contrast. `DESIGN.md` records what each token is for.
enum InstrumentTokens {
    static let ground = InstrumentColor(light: 0xE9EBE8, dark: 0x121416)
    static let surface = InstrumentColor(light: 0xFFFFFF, dark: 0x1E2124)
    static let ink = InstrumentColor(light: 0x16181A, dark: 0xECEEEB)
    static let inkSecondary = InstrumentColor(light: 0x4C5157, dark: 0xA3A8A5)
    /// Lighter hairlines between rows.
    static let rule = InstrumentColor(light: 0xC9CCC8, dark: 0x3B3F42)
    /// The outline of a tile or panel. Softer than `ink` in dark, where a full-strength
    /// line around every tile would out-shout the glyph inside it.
    static let edge = InstrumentColor(light: 0x16181A, dark: 0x6B7074)
    static let signal = InstrumentColor(light: 0xE8430C, dark: 0xFF6A36)
    static let signalText = InstrumentColor(light: 0xB8330A, dark: 0xFF6A36)
    static let success = InstrumentColor(light: 0x1B7F4B, dark: 0x45C486)

    /// WCAG relative luminance of an sRGB value.
    static func luminance(_ hex: UInt) -> Double {
        func linear(_ channel: UInt) -> Double {
            let value = Double(channel & 0xFF) / 255
            return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(hex >> 16) + 0.7152 * linear(hex >> 8) + 0.0722 * linear(hex)
    }

    /// WCAG contrast ratio between two sRGB values, from 1 to 21.
    static func contrast(_ first: UInt, _ second: UInt) -> Double {
        let lighter = max(luminance(first), luminance(second))
        let darker = min(luminance(first), luminance(second))
        return (lighter + 0.05) / (darker + 0.05)
    }
}
