import Foundation

/// Immediate-execution arithmetic for the calculator keypad.
/// Repeated equals does not repeat the previous operation.
struct CalculatorEngine {
    private(set) var display = "0"
    private var accumulator: Double?
    private var operation: String?
    private var startsNewNumber = true

    mutating func tap(_ key: String) {
        if key.count == 1 && (Int(key) != nil || key == ".") {
            if startsNewNumber {
                display = key == "." ? "0." : key
                startsNewNumber = false
            } else if key == "." {
                if !display.contains(".") { display += "." }
            } else if display.count < 12 {
                display = display == "0" ? key : display + key
            }
            return
        }
        if key == "AC" { self = CalculatorEngine(); return }
        guard display != "Error" else { return }
        switch key {
        case "⌫":
            if startsNewNumber { return }
            display.removeLast()
            if display.isEmpty || display == "-" { display = "0" }
        case "±":
            if display.hasPrefix("-") { display.removeFirst() }
            else if display != "0" { display = "-" + display }
        case "%":
            display = Self.format((Double(display) ?? 0) / 100)
        case "=", "+", "−", "×", "÷":
            if !startsNewNumber, let lhs = accumulator, let operation {
                let rhs = Double(display) ?? 0
                let result: Double
                switch operation {
                case "+": result = lhs + rhs
                case "−": result = lhs - rhs
                case "×": result = lhs * rhs
                default: result = rhs == 0 ? .nan : lhs / rhs
                }
                display = Self.format(result)
                if display == "Error" {
                    accumulator = nil; self.operation = nil; startsNewNumber = true
                    return
                }
            }
            if key == "=" { accumulator = nil; operation = nil }
            else { accumulator = Double(display); operation = key }
            startsNewNumber = true
        default: break
        }
    }

    private static func format(_ value: Double) -> String {
        guard value.isFinite else { return "Error" }
        return value == 0 ? "0" : String(format: "%.10g", locale: Locale(identifier: "en_US_POSIX"), value)
    }
}
