import Foundation

// Measures the Instrument palette in both appearances: 4.5:1 for text, and 3:1 for
// marks and outlines. Run with:
// swiftc IndicaOS/InstrumentTokens.swift Tests/InstrumentTokenTests.swift -o /tmp/token-tests && /tmp/token-tests

@main
struct InstrumentTokenTests {
    static func main() {
        typealias T = InstrumentTokens
        let text = 4.5
        let mark = 3.0
        // Foreground, background, required ratio, and what the pair is used for.
        let pairs: [(String, InstrumentColor, InstrumentColor, Double)] = [
            ("ink on ground", T.ink, T.ground, text),
            ("ink on surface", T.ink, T.surface, text),
            ("inkSecondary on ground", T.inkSecondary, T.ground, text),
            ("inkSecondary on surface", T.inkSecondary, T.surface, text),
            ("signalText on ground", T.signalText, T.ground, text),
            ("signalText on surface", T.signalText, T.surface, text),
            ("surface on ink (selected day)", T.surface, T.ink, text),
            ("ground on ink (dock glyph)", T.ground, T.ink, mark),
            ("signal on ground", T.signal, T.ground, mark),
            ("signal on surface", T.signal, T.surface, mark),
            ("success on ground", T.success, T.ground, mark),
            ("success on surface", T.success, T.surface, mark),
            ("edge on ground", T.edge, T.ground, mark),
            ("edge on surface", T.edge, T.surface, mark)
        ]

        var failures = 0
        func check(_ name: String, _ foreground: UInt, _ background: UInt, _ required: Double) {
            let ratio = T.contrast(foreground, background)
            let passed = ratio >= required
            if !passed { failures += 1 }
            print("\(passed ? "ok  " : "FAIL") \(name): \(String(format: "%.2f", ratio)) (needs \(required))")
        }

        for (name, foreground, background, required) in pairs {
            check("\(name), light", foreground.light, background.light, required)
            check("\(name), dark", foreground.dark, background.dark, required)
        }

        // The formula itself, against known values.
        check("black on white is 21:1", 0x000000, 0xFFFFFF, 21)
        if abs(T.contrast(0x777777, 0xFFFFFF) - 4.48) > 0.01 {
            failures += 1
            print("FAIL #777 on white should be 4.48")
        }

        print(failures == 0 ? "All token checks passed" : "\(failures) token checks failed")
        exit(failures == 0 ? 0 : 1)
    }
}
