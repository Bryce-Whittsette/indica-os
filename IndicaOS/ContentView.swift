import SwiftUI

struct ContentView: View {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.dynamicTypeSize) private var preferredTextSize
    @StateObject private var system = IndicaSystem()
    @StateObject private var connections = ConnectionStore()

    var body: some View {
        SystemShell()
            .environmentObject(system)
            .environmentObject(connections)
            .preferredColorScheme(system.appearance.colorScheme)
            .environment(\.dynamicTypeSize, max(system.dynamicTypeSize, preferredTextSize))
            .fontWeight(system.boldText ? .semibold : nil)
            .tint(system.accent)
            .transaction { transaction in
                if system.reduceMotion || systemReduceMotion {
                    transaction.animation = nil
                }
            }
    }
}

#Preview {
    ContentView()
}
