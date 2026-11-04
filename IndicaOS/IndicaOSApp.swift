import SwiftUI
import UserNotifications

@main
struct IndicaOSApp: App {
    init() {
        UNUserNotificationCenter.current().delegate = ForegroundNotificationPresenter.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
