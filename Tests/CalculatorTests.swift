import Foundation

@main
enum CalculatorTests {
    static func main() {
        let cases: [([String], String)] = [
            (["2", "+", "3", "="], "5"),
            (["9", "÷", "0", "="], "Error"),
            (["9", "÷", "0", "=", "4"], "4"),
            (["2", "+", "×", "3", "="], "6"),
            (["2", "+", "3", "+", "4", "="], "9"),
            ([".", "5", "+", ".", "5", "="], "1"),
            (["8", "±", "⌫"], "0"),
            (["5", "0", "%"], "0.5"),
            (["5", "+", "3", "=", "=", "="], "8"),
            (["1", "0", "×", "1", "0", "×", "1", "0", "="], "1000"),
            (["7", "AC"], "0"),
            (["1", ".", ".", "2"], "1.2")
        ]
        for (keys, expected) in cases {
            var calculator = CalculatorEngine()
            for key in keys { calculator.tap(key) }
            precondition(calculator.display == expected, "\(keys): \(calculator.display), expected \(expected)")
        }
        var large = CalculatorEngine()
        large.tap("9")
        for _ in 0..<400 { large.tap("×"); large.tap("9"); large.tap("=") }
        // Very large arithmetic must never attempt a trapping Double-to-Int cast.
        precondition(!large.display.isEmpty)
        print("13 calculator checks passed")
    }
}
