import SwiftUI

private enum SettingsRoute: String, CaseIterable, Hashable, Identifiable {
    case connections
    case wifi
    case bluetooth
    case cellular
    case vpn
    case notifications
    case sounds
    case focus
    case display
    case homeScreen
    case wallpaper
    case lockScreen
    case colorMotion
    case accessibility
    case privacy
    case battery
    case general
    case apps
    case developer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .connections: "Accounts & Connections"
        case .wifi: "Wi-Fi"
        case .bluetooth: "Bluetooth"
        case .cellular: "Mobile Service"
        case .vpn: "VPN"
        case .notifications: "Notifications"
        case .sounds: "Sounds & Haptics"
        case .focus: "Focus"
        case .display: "Display & Brightness"
        case .homeScreen: "Home Screen & App Library"
        case .wallpaper: "Wallpaper"
        case .lockScreen: "Lock Screen"
        case .colorMotion: "Color & Motion"
        case .accessibility: "Accessibility"
        case .privacy: "Privacy & Security"
        case .battery: "Battery"
        case .general: "General"
        case .apps: "Apps"
        case .developer: "Developer Integrations"
        }
    }

    var detail: String? {
        switch self {
        case .connections: "OAuth, APIs, device permissions"
        case .colorMotion: "Accent and motion"
        case .developer: "Credentials & redirect URIs"
        default: nil
        }
    }

    var symbol: String {
        switch self {
        case .connections: "person.crop.circle.badge.checkmark"
        case .wifi: "wifi"
        case .bluetooth: "bolt.horizontal.fill"
        case .cellular: "antenna.radiowaves.left.and.right"
        case .vpn: "network.badge.shield.half.filled"
        case .notifications: "bell.badge.fill"
        case .sounds: "speaker.wave.3.fill"
        case .focus: "moon.fill"
        case .display: "textformat.size"
        case .homeScreen: "square.grid.3x3.fill"
        case .wallpaper: "photo.fill"
        case .lockScreen: "lock.rectangle.fill"
        case .colorMotion: "paintpalette.fill"
        case .accessibility: "accessibility"
        case .privacy: "hand.raised.fill"
        case .battery: "battery.100percent"
        case .general: "gear"
        case .apps: "square.grid.3x3.fill"
        case .developer: "wrench.and.screwdriver.fill"
        }
    }

    var tint: Color {
        switch self {
        case .connections: .indigo
        case .wifi, .bluetooth: .blue
        case .cellular: .green
        case .vpn: .teal
        case .notifications: .red
        case .sounds: .pink
        case .focus: .indigo
        case .display: .blue
        case .homeScreen: .cyan
        case .wallpaper: .cyan
        case .lockScreen: .indigo
        case .colorMotion: .purple
        case .accessibility: .blue
        case .privacy: .blue
        case .battery: .green
        case .general: .gray
        case .apps: .blue
        case .developer: .orange
        }
    }
}

struct IndicaSettingsApp: View {
    @EnvironmentObject private var system: IndicaSystem
    @EnvironmentObject private var connections: ConnectionStore
    @ObservedObject private var device = DeviceStatus.shared
    @State private var query = ""

    private let connectionRoutes: [SettingsRoute] = [.wifi, .bluetooth, .cellular, .vpn]
    private let behaviorRoutes: [SettingsRoute] = [.notifications, .sounds, .focus]
    private let personalizationRoutes: [SettingsRoute] = [.display, .homeScreen, .wallpaper, .lockScreen, .colorMotion]
    private let systemRoutes: [SettingsRoute] = [.accessibility, .privacy, .battery, .general, .apps, .developer]

    var body: some View {
        NavigationStack {
            List {
                if matches("Demo User accounts connections cloud media") {
                    Section {
                        NavigationLink(value: SettingsRoute.connections) {
                            AccountSettingsCard()
                        }
                    }
                }

                if query.isEmpty || connectionRoutes.contains(where: routeMatches) {
                    Section {
                        if query.isEmpty || matches("airplane mode") {
                            SettingsSwitchRow(
                                title: "Airplane Mode",
                                symbol: "airplane",
                                tint: .orange,
                                isOn: $system.airplaneMode
                            )
                        }
                        settingsLinks(connectionRoutes)
                    }
                }

                if query.isEmpty || behaviorRoutes.contains(where: routeMatches) {
                    Section {
                        settingsLinks(behaviorRoutes)
                    }
                }

                if query.isEmpty || personalizationRoutes.contains(where: routeMatches) {
                    Section("Personalize") {
                        settingsLinks(personalizationRoutes)
                    }
                }

                if query.isEmpty || systemRoutes.contains(where: routeMatches) {
                    Section {
                        settingsLinks(systemRoutes)
                    }
                }

                if query.isEmpty {
                    Section {
                        Button {
                            system.lock()
                        } label: {
                            Label("Lock Swift UI", systemImage: "lock.fill")
                        }
                    }

                    Section {
                        VStack(alignment: .leading, spacing: 7) {
                            Text("Swift UI \(AppInfo.version)")
                                .font(.headline)
                            Text("An original interactive iPhone-style simulator. It does not replace iOS and is not affiliated with Apple.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .searchable(text: $query, prompt: "Search Settings")
            .navigationDestination(for: SettingsRoute.self, destination: destination)
        }
    }

    @ViewBuilder
    private func settingsLinks(_ routes: [SettingsRoute]) -> some View {
        ForEach(routes.filter { query.isEmpty || routeMatches($0) }) { route in
            NavigationLink(value: route) {
                SettingsLinkLabel(
                    title: route.title,
                    detail: routeDetail(route),
                    symbol: route.symbol,
                    tint: route.tint
                )
            }
        }
    }

    private func routeDetail(_ route: SettingsRoute) -> String? {
        switch route {
        case .wifi: device.network == .wifi ? "Connected" : "Not connected"
        case .bluetooth: system.bluetoothEnabled ? "On" : "Off"
        case .vpn: "Not Connected"
        case .notifications: system.notificationCountText
        case .focus: system.isFocusEnabled ? "On" : "Off"
        case .display: system.appearance.rawValue
        case .wallpaper: system.wallpaper.rawValue
        case .colorMotion: system.accentStyle.rawValue
        case .battery: device.batteryPercentText ?? "Unavailable"
        case .connections: "\(connections.connectedCount) ready"
        default: route.detail
        }
    }

    private func routeMatches(_ route: SettingsRoute) -> Bool {
        matches("\(route.title) \(route.detail ?? "")")
    }

    private func matches(_ text: String) -> Bool {
        query.isEmpty || text.localizedCaseInsensitiveContains(query)
    }

    @ViewBuilder
    private func destination(_ route: SettingsRoute) -> some View {
        switch route {
        case .connections: SettingsConnectionsView()
        case .wifi: WiFiSettingsView()
        case .bluetooth: BluetoothSettingsView()
        case .cellular: CellularSettingsView()
        case .vpn: VPNSettingsView()
        case .notifications: NotificationsSettingsView()
        case .sounds: SoundsSettingsView()
        case .focus: FocusSettingsView()
        case .display: DisplaySettingsView()
        case .homeScreen: HomeScreenSettingsView()
        case .wallpaper: WallpaperSettingsView()
        case .lockScreen: LockScreenSettingsView()
        case .colorMotion: ColorMotionSettingsView()
        case .accessibility: AccessibilitySettingsView()
        case .privacy: PrivacySettingsView()
        case .battery: BatterySettingsView()
        case .general: GeneralSettingsView()
        case .apps: AppsSettingsView()
        case .developer: DeveloperIntegrationView()
        }
    }
}

private struct AccountSettingsCard: View {
    @EnvironmentObject private var connections: ConnectionStore

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x9C82FF), Color(hex: 0xF06BA8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(Text("B").font(.title.bold()).foregroundStyle(.white))

            VStack(alignment: .leading, spacing: 3) {
                Text("Demo User")
                    .font(.title3.bold())
                Text("\(connections.connectedCount) services · Keychain protected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Accounts, APIs & device access")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 3)
    }
}

private struct SettingsConnectionsView: View {
    @EnvironmentObject private var connections: ConnectionStore

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Connect what you use")
                        .font(.title2.bold())
                    Text("Every service gets its own permission and can be disconnected independently.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }

            Section("Device") {
                serviceLink(.apple)
            }

            Section("Accounts") {
                ForEach([
                    ConnectedService.spotify,
                    .google,
                    .microsoft,
                    .notion,
                    .discord,
                    .telegram,
                    .openAI
                ]) { service in
                    serviceLink(service)
                }
            }

            Section("Privacy") {
                Label("OAuth opens the provider’s real consent page", systemImage: "checkmark.shield.fill")
                Label("Tokens and keys are kept in Keychain", systemImage: "key.fill")
                Label("Mac passwords and sessions are never imported", systemImage: "hand.raised.fill")
            }
            .font(.subheadline)
        }
        .navigationTitle("Connections")
    }

    private func serviceLink(_ service: ConnectedService) -> some View {
        NavigationLink {
            ServiceConnectionDetail(service: service)
        } label: {
            HStack(spacing: 12) {
                SettingsGlyph(symbol: service.symbol, tint: service.tint)
                VStack(alignment: .leading, spacing: 2) {
                    Text(service.name)
                    Text(
                        connections.isConnected(service)
                            ? (connections.account(for: service)?.displayName ?? "Connected")
                            : service.connectionKind
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                Spacer()
                if connections.isConnected(service) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
    }
}

private struct WiFiSettingsView: View {
    @EnvironmentObject private var system: IndicaSystem
    @AppStorage("askToJoinNetworks") private var askToJoin = true
    @AppStorage("autoJoinHotspot") private var autoJoinHotspot = true
    @ObservedObject private var device = DeviceStatus.shared

    var body: some View {
        Form {
            Section {
                LabeledContent("Active Connection", value: device.network.description)
            } header: {
                Text("This iPhone")
            } footer: {
                Text("iOS doesn’t share the Wi-Fi network name with this app. Choose a network in the Settings app under Wi-Fi.")
            }

            Section {
                Toggle("Wi-Fi", isOn: $system.wifiEnabled)
            } header: {
                Text("Simulated")
            } footer: {
                Text("These switches are simulated. They change only Swift UI’s own state, not this iPhone’s Wi-Fi.")
            }

            if system.wifiEnabled {
                Section {
                    Toggle("Ask to Join Networks", isOn: $askToJoin)
                    Toggle("Auto-Join Hotspot", isOn: $autoJoinHotspot)
                    Toggle("Private Wi-Fi Address", isOn: $system.privateWiFiAddress)
                }
            }
        }
        .navigationTitle("Wi-Fi")
    }
}

private struct BluetoothSettingsView: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var connectedHeadphones = true

    var body: some View {
        Form {
            Section {
                Toggle("Bluetooth", isOn: $system.bluetoothEnabled)
            }

            if system.bluetoothEnabled {
                Section("My Devices") {
                    Toggle(isOn: $connectedHeadphones) {
                        VStack(alignment: .leading) {
                            Text("Demo Headphones")
                            Text(connectedHeadphones ? "Connected" : "Not Connected")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    LabeledContent("Controller", value: "Not Connected")
                    LabeledContent("Studio Speaker", value: "Not Connected")
                }

                Section {
                    Label("Discoverable as “\(system.deviceName)”", systemImage: "antenna.radiowaves.left.and.right")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Bluetooth")
    }
}

private struct CellularSettingsView: View {
    @AppStorage("cellularDataEnabled") private var cellularData = true
    @AppStorage("dataRoaming") private var dataRoaming = false
    @AppStorage("lowDataMode") private var lowDataMode = false
    @ObservedObject private var device = DeviceStatus.shared

    var body: some View {
        Form {
            Section {
                Toggle("Mobile Data", isOn: $cellularData)
                Toggle("Data Roaming", isOn: $dataRoaming)
                Toggle("Low Data Mode", isOn: $lowDataMode)
            } header: {
                Text("Simulated")
            } footer: {
                Text("These switches are simulated. They change only Swift UI’s own state, not this iPhone’s cellular settings.")
            }

            Section {
                LabeledContent("Active Connection", value: device.network.description)
            } header: {
                Text("Plan")
            } footer: {
                Text("iOS doesn’t share your carrier or data usage with apps. See the Settings app under Cellular.")
            }
        }
        .navigationTitle("Mobile Service")
    }
}

private struct VPNSettingsView: View {
    @State private var enabled = false
    @State private var connectOnDemand = false

    var body: some View {
        Form {
            Section {
                Toggle("VPN Status", isOn: $enabled)
                Toggle("Connect On Demand", isOn: $connectOnDemand)
            }

            Section("Configuration") {
                LabeledContent("Name", value: "Swift UI Private")
                LabeledContent("Type", value: "WireGuard")
                LabeledContent("Status", value: enabled ? "Connected" : "Not Connected")
            }
        }
        .navigationTitle("VPN")
    }
}

private struct NotificationsSettingsView: View {
    @EnvironmentObject private var system: IndicaSystem

    private var notificationApps: [BuiltInApp] {
        BuiltInApp.allCases
            .filter { [.communication, .media, .productivity].contains($0.category) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        List {
            Section {
                Picker("Show Previews", selection: $system.notificationPreviews) {
                    ForEach(NotificationPreviewStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                NavigationLink("Notification Center") {
                    NotificationHistorySettingsView()
                }
            }

            Section("Notification Style") {
                ForEach(notificationApps) { app in
                    NavigationLink {
                        AppNotificationSettingsView(app: app)
                    } label: {
                        HStack(spacing: 12) {
                            AppSettingsMark(app: app)
                            Text(app.name)
                            Spacer()
                            Text(system.notificationsEnabled(for: app) ? "On" : "Off")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Notifications")
    }
}

private struct NotificationHistorySettingsView: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        List {
            ForEach(system.notifications) { notification in
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.headline)
                    Text(notification.body)
                        .font(.subheadline)
                    Text(notification.app.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .onDelete { offsets in
                system.notifications.remove(atOffsets: offsets)
            }
        }
        .navigationTitle("Notification Center")
    }
}

private struct AppNotificationSettingsView: View {
    @EnvironmentObject private var system: IndicaSystem
    let app: BuiltInApp
    @State private var sounds = true
    @State private var badges = true
    @State private var timeSensitive = true

    private var enabled: Binding<Bool> {
        Binding(
            get: { system.notificationsEnabled(for: app) },
            set: { system.setNotifications($0, for: app) }
        )
    }

    var body: some View {
        Form {
            Section {
                Toggle("Allow Notifications", isOn: enabled)
            }

            if enabled.wrappedValue {
                Section("Alerts") {
                    Toggle("Lock Screen", isOn: .constant(true))
                    Toggle("Notification Center", isOn: .constant(true))
                    Toggle("Banners", isOn: .constant(true))
                }
                Section {
                    Toggle("Sounds", isOn: $sounds)
                    Toggle("Badges", isOn: $badges)
                    Toggle("Time Sensitive Notifications", isOn: $timeSensitive)
                }
            }
        }
        .navigationTitle(app.name)
    }
}

private struct SoundsSettingsView: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var lockSound = true

    var body: some View {
        Form {
            Section("Ringtone and Alerts") {
                HStack {
                    Image(systemName: "speaker.fill")
                    Slider(value: $system.volume)
                    Image(systemName: "speaker.wave.3.fill")
                }
                Toggle("Sound Effects", isOn: $system.soundsEnabled)
                Toggle("Haptics", isOn: $system.hapticsEnabled)
            }

            Section("System Sounds") {
                Toggle("Keyboard Feedback", isOn: $system.keyboardClicks)
                Toggle("Lock Sound", isOn: $lockSound)
            }

            Section {
                Button("Play Test Sound") {}
                    .disabled(!system.soundsEnabled)
            }
        }
        .navigationTitle("Sounds & Haptics")
    }
}

private struct FocusSettingsView: View {
    @EnvironmentObject private var system: IndicaSystem
    @AppStorage("focusShareAcrossDevices") private var shareAcrossDevices = true
    @AppStorage("focusScheduleEnabled") private var scheduleEnabled = false

    var body: some View {
        Form {
            Section {
                Toggle("Focus Status", isOn: $system.isFocusEnabled)
                Toggle("Share Across Devices", isOn: $shareAcrossDevices)
            }

            Section("Schedules") {
                Toggle("Quiet Hours · 10 PM to 7 AM", isOn: $scheduleEnabled)
                NavigationLink("Add Schedule") {
                    Text("Choose a time, location, or app trigger.")
                        .padding()
                        .navigationTitle("New Schedule")
                }
            }

            Section("Focus Modes") {
                Label("Do Not Disturb", systemImage: "moon.fill")
                Label("Personal", systemImage: "person.fill")
                Label("Work", systemImage: "briefcase.fill")
                Label("Driving", systemImage: "car.fill")
            }
        }
        .navigationTitle("Focus")
    }
}

private struct DisplaySettingsView: View {
    @EnvironmentObject private var system: IndicaSystem
    @AppStorage("trueTone") private var trueTone = true
    @AppStorage("autoLockMinutes") private var autoLockMinutes = 2

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Appearance", selection: $system.appearance) {
                    ForEach(IndicaAppearance.allCases) { appearance in
                        Text(appearance.rawValue).tag(appearance)
                    }
                }
                .pickerStyle(.segmented)

                HStack(spacing: 12) {
                    appearancePreview(.light)
                    appearancePreview(.dark)
                }
                .padding(.vertical, 4)
            }

            Section("Brightness") {
                HStack {
                    Image(systemName: "sun.min.fill")
                    Slider(value: $system.brightness)
                    Image(systemName: "sun.max.fill")
                }
                Toggle("True Tone", isOn: $trueTone)
            }

            Section("Text") {
                Toggle("Bold Text", isOn: $system.boldText)
                VStack(alignment: .leading) {
                    Text("Text Size")
                    Slider(value: $system.textScale, in: 0.82...1.25)
                }
            }

            Section {
                Picker("Auto-Lock", selection: $autoLockMinutes) {
                    Text("30 Seconds").tag(0)
                    Text("1 Minute").tag(1)
                    Text("2 Minutes").tag(2)
                    Text("5 Minutes").tag(5)
                    Text("Never").tag(-1)
                }
            }
        }
        .navigationTitle("Display & Brightness")
    }

    private func appearancePreview(_ appearance: IndicaAppearance) -> some View {
        Button {
            system.appearance = appearance
        } label: {
            VStack(spacing: 7) {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(appearance == .dark ? Color(hex: 0x16171A) : .white)
                    .frame(height: 94)
                    .overlay {
                        VStack(spacing: 7) {
                            Capsule()
                                .fill(appearance == .dark ? .white.opacity(0.85) : .black.opacity(0.75))
                                .frame(width: 55, height: 8)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(appearance == .dark ? .white.opacity(0.12) : .black.opacity(0.08))
                                .frame(width: 78, height: 42)
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(system.appearance == appearance ? system.accent : .secondary.opacity(0.25), lineWidth: 3)
                    }
                Text(appearance.rawValue)
                    .font(.caption.bold())
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

private struct HomeScreenSettingsView: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        Form {
            Section("App Icons") {
                Picker("Appearance", selection: $system.iconAppearance) {
                    ForEach(AppIconAppearance.allCases) { appearance in
                        Text(appearance.rawValue).tag(appearance)
                    }
                }

                HStack {
                    ForEach([AppIconAppearance.light, .dark, .clear, .tinted]) { appearance in
                        iconPreview(appearance)
                    }
                }
                .padding(.vertical, 5)
            }

            Section("Layout") {
                Picker("Density", selection: $system.homeLayoutDensity) {
                    ForEach(HomeLayoutDensity.allCases) { density in
                        Text(density.rawValue).tag(density)
                    }
                }
                .pickerStyle(.segmented)
                Toggle("Show App Labels", isOn: $system.showAppLabels)
            }

            Section {
                Text("Press and hold the Home Screen to enter edit mode. Swipe between pages for built-in apps, connected daily apps, and utilities.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Home Screen")
    }

    private func iconPreview(_ appearance: AppIconAppearance) -> some View {
        Button {
            system.iconAppearance = appearance
        } label: {
            VStack(spacing: 5) {
                AppMark(app: .notes, size: 52, appearance: appearance)
                    .overlay {
                        if system.iconAppearance == appearance {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Instrument.signal, lineWidth: 2)
                                .padding(-3)
                        }
                    }
                Text(appearance.rawValue)
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .accessibilityLabel(appearance.rawValue)
        .accessibilityAddTraits(system.iconAppearance == appearance ? .isSelected : [])
    }
}

private struct WallpaperSettingsView: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 18) {
                ForEach(WallpaperStyle.allCases) { wallpaper in
                    Button {
                        withAnimation(Instrument.motion) {
                            system.wallpaper = wallpaper
                        }
                    } label: {
                        VStack(spacing: 8) {
                            IndicaWallpaper(style: wallpaper)
                                .frame(height: 245)
                                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 26)
                                        .stroke(system.wallpaper == wallpaper ? system.accent : .white.opacity(0.2), lineWidth: system.wallpaper == wallpaper ? 4 : 1)
                                }
                            HStack {
                                Text(wallpaper.rawValue)
                                    .font(.subheadline.bold())
                                if system.wallpaper == wallpaper {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(system.accent)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("Wallpaper")
    }
}

private struct LockScreenSettingsView: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                IndicaWallpaper(style: system.wallpaper)
                    .overlay {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(Date.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)).uppercased())
                                .font(Instrument.mono(.caption, weight: .medium))
                            Text(Date.now.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)).minute(.twoDigits)))
                                .font(.system(size: 57, weight: system.lockClockStyle.weight, design: system.lockClockStyle.design))
                            if system.showLockWidgets {
                                LedgerStrip(verticalPadding: 8)
                                    .padding(.top, 8)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .padding(.top, 19)
                        .foregroundStyle(system.wallpaper.foreground)
                    }
                    .frame(height: 420)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Instrument.edge, lineWidth: Instrument.hairline)
                    }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Clock Style")
                        .font(.headline)
                    Picker("Clock Style", selection: $system.lockClockStyle) {
                        ForEach(LockClockStyle.allCases) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                    Toggle("Show Lock Screen Widgets", isOn: $system.showLockWidgets)
                }
                .padding(17)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24))

                Button {
                    system.overlay = .wallpaper
                } label: {
                    Label("Choose Wallpaper", systemImage: "photo.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Lock Screen")
    }
}

private struct ColorMotionSettingsView: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        Form {
            Section("Motion") {
                Toggle("Reduce Motion", isOn: $system.reduceMotion)
            }

            Section("Accent Color") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
                    ForEach(IndicaAccent.allCases) { accent in
                        Button {
                            system.accentStyle = accent
                        } label: {
                            Circle()
                                .fill(accent.color)
                                .frame(width: 34, height: 34)
                                .overlay {
                                    if system.accentStyle == accent {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(accent.onColor)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(accent.rawValue)
                        .accessibilityAddTraits(system.accentStyle == accent ? .isSelected : [])
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Color & Motion")
    }
}

private struct AccessibilitySettingsView: View {
    @EnvironmentObject private var system: IndicaSystem
    @AppStorage("increaseContrast") private var increaseContrast = false
    @AppStorage("buttonShapes") private var buttonShapes = false

    var body: some View {
        Form {
            Section("Vision") {
                Toggle("Bold Text", isOn: $system.boldText)
                Toggle("Increase Contrast", isOn: $increaseContrast)
                Toggle("Button Shapes", isOn: $buttonShapes)
                VStack(alignment: .leading) {
                    Text("Text Size")
                    Slider(value: $system.textScale, in: 0.82...1.25)
                }
            }

            Section("Motion") {
                Toggle("Reduce Motion", isOn: $system.reduceMotion)
            }

            Section("Preview") {
                Text("Swift UI adapts its text and animations to these preferences.")
                    .font(.body)
            }
        }
        .navigationTitle("Accessibility")
    }
}

private struct PrivacySettingsView: View {
    @EnvironmentObject private var system: IndicaSystem
    @AppStorage("lockdownMode") private var lockdownMode = false
    @AppStorage("privateRelay") private var privateRelay = true

    var body: some View {
        Form {
            Section {
                Toggle("Location Services", isOn: $system.locationServices)
                Toggle("Allow Apps to Request to Track", isOn: $system.allowTrackingRequests)
                Toggle("Share Swift UI Analytics", isOn: $system.analyticsSharing)
            }

            Section("Network Privacy") {
                Toggle("Private Relay", isOn: $privateRelay)
                Toggle("Lockdown Mode", isOn: $lockdownMode)
            }

            Section("App Privacy") {
                NavigationLink("Photos") { PermissionExplanationView(name: "Photos", symbol: "photo.fill") }
                NavigationLink("Contacts") { PermissionExplanationView(name: "Contacts", symbol: "person.crop.circle.fill") }
                NavigationLink("Calendars & Reminders") { PermissionExplanationView(name: "Calendars & Reminders", symbol: "calendar") }
                NavigationLink("Microphone & Camera") { PermissionExplanationView(name: "Microphone & Camera", symbol: "camera.fill") }
            }

            Section {
                Text("Swift UI never extracts passwords, browser cookies, Keychain entries, or active Mac app sessions. Account access uses provider consent screens or device permission dialogs.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Privacy & Security")
    }
}

private struct PermissionExplanationView: View {
    let name: String
    let symbol: String
    @State private var allowed = false

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $allowed) {
                    Label(name, systemImage: symbol)
                }
            } footer: {
                Text("This prototype records the preference here. The real iOS permission prompt appears when the matching native framework is enabled and used on a device.")
            }
        }
        .navigationTitle(name)
    }
}

private struct BatterySettingsView: View {
    @ObservedObject private var device = DeviceStatus.shared
    @State private var isLowPowerOn = ProcessInfo.processInfo.isLowPowerModeEnabled

    private var stateText: String {
        switch device.batteryState {
        case .charging: "Charging"
        case .full: "Full"
        case .unplugged: "Not charging"
        case .unknown: "Unavailable"
        @unknown default: "Unavailable"
        }
    }

    var body: some View {
        Form {
            Section {
                LabeledContent("Current Level", value: device.batteryPercentText ?? "Unavailable")
                LabeledContent("Status", value: stateText)
                LabeledContent("Low Power Mode", value: isLowPowerOn ? "On" : "Off")
            } footer: {
                Text("iOS doesn’t share battery history, maximum capacity, or cycle count with apps, and only you can change Low Power Mode. See the Settings app under Battery.")
            }
        }
        .navigationTitle("Battery")
        .onReceive(NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)) { _ in
            isLowPowerOn = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
    }
}

private struct GeneralSettingsView: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        List {
            Section {
                NavigationLink("About") { AboutSettingsView() }
                NavigationLink("Software Update") { SoftwareUpdateSettingsView() }
                NavigationLink("Swift UI Storage") { StorageSettingsView() }
            }

            Section {
                NavigationLink("Background App Refresh") { BackgroundRefreshSettingsView() }
                NavigationLink("Date & Time") { DateTimeSettingsView() }
                NavigationLink("Language & Region") { LanguageSettingsView() }
            }

            Section {
                NavigationLink("Transfer or Reset Swift UI") { ResetSettingsView() }
            }
        }
        .navigationTitle("General")
    }
}

private struct AboutSettingsView: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $system.deviceName)
            }
            Section {
                LabeledContent("Swift UI Version", value: AppInfo.version)
                LabeledContent("Device", value: UIDevice.current.model)
                LabeledContent("System", value: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
            }
            Section {
                LabeledContent("Apps", value: "\(BuiltInApp.allCases.count)")
                LabeledContent("Capacity", value: DeviceStorage.read()?.totalText ?? "Unavailable")
                LabeledContent("Available", value: DeviceStorage.read()?.availableText ?? "Unavailable")
            } footer: {
                Text("iOS doesn’t share the serial number or exact model with apps. Find them in the Settings app under General › About.")
            }
        }
        .navigationTitle("About")
    }
}

/// The app's own version from its bundle.
enum AppInfo {
    static var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(short) (\(build))"
    }
}

/// Device storage from the file system's volume attributes.
struct DeviceStorage {
    let total: Int64
    let available: Int64

    var used: Int64 { max(total - available, 0) }
    var totalText: String { total.formatted(.byteCount(style: .file)) }
    var availableText: String { available.formatted(.byteCount(style: .file)) }
    var usedText: String { used.formatted(.byteCount(style: .file)) }

    static func read() -> DeviceStorage? {
        let values = try? URL(fileURLWithPath: NSHomeDirectory()).resourceValues(forKeys: [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey
        ])
        guard let total = values?.volumeTotalCapacity,
              let available = values?.volumeAvailableCapacityForImportantUsage else { return nil }
        return DeviceStorage(total: Int64(total), available: available)
    }

    /// Bytes used by this app's own documents, caches and settings.
    static func appDataSize() -> Int64 {
        let home = URL(fileURLWithPath: NSHomeDirectory())
        var total: Int64 = 0
        for folder in ["Documents", "Library"] {
            let enumerator = FileManager.default.enumerator(
                at: home.appending(path: folder),
                includingPropertiesForKeys: [.fileSizeKey]
            )
            while let url = enumerator?.nextObject() as? URL {
                total += Int64((try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
            }
        }
        return total
    }
}

private struct SoftwareUpdateSettingsView: View {
    var body: some View {
        Form {
            Section {
                VStack(spacing: 13) {
                    Image(systemName: "shippingbox")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Swift UI \(AppInfo.version)")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } footer: {
                Text("Swift UI can’t check for updates by itself. New versions are published on GitHub. Updates to iOS are in the Settings app under General › Software Update.")
            }
            Section {
                Link("View Releases on GitHub", destination: URL(string: "https://github.com/Bryce-Whittsette/indica-os/releases")!)
            }
        }
        .navigationTitle("Software Update")
    }
}

private struct StorageSettingsView: View {
    @State private var storage = DeviceStorage.read()
    @State private var appDataSize: Int64?

    var body: some View {
        List {
            Section {
                if let storage {
                    VStack(alignment: .leading, spacing: 12) {
                        ProgressView(value: Double(storage.used), total: Double(max(storage.total, 1)))
                        Text("\(storage.usedText) of \(storage.totalText) used")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                } else {
                    Text("Device storage is unavailable.")
                        .foregroundStyle(.secondary)
                }
            } footer: {
                Text("iOS doesn’t share how much space other apps use. See the Settings app under General › iPhone Storage.")
            }

            Section("This App") {
                LabeledContent("Swift UI data", value: appDataSize.map { $0.formatted(.byteCount(style: .file)) } ?? "Calculating…")
            }
        }
        .navigationTitle("Swift UI Storage")
        .task {
            appDataSize = await Task.detached(priority: .utility) { DeviceStorage.appDataSize() }.value
        }
    }
}

private struct BackgroundRefreshSettingsView: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        List {
            Section {
                Toggle("Background App Refresh", isOn: $system.backgroundRefresh)
            }

            if system.backgroundRefresh {
                Section("Apps") {
                    ForEach(BuiltInApp.allCases.sorted { $0.name < $1.name }) { app in
                        Toggle(
                            app.name,
                            isOn: Binding(
                                get: { system.backgroundRefreshEnabled(for: app) },
                                set: { system.setBackgroundRefresh($0, for: app) }
                            )
                        )
                    }
                }
            }
        }
        .navigationTitle("Background Refresh")
    }
}

private struct DateTimeSettingsView: View {
    @AppStorage("setTimeAutomatically") private var automatically = true
    @AppStorage("use24HourTime") private var use24Hour = false

    var body: some View {
        Form {
            Section {
                Toggle("Set Automatically", isOn: $automatically)
                Toggle("24-Hour Time", isOn: $use24Hour)
            }
            Section {
                LabeledContent("Time Zone", value: "New York")
                LabeledContent("Region", value: "United States")
            }
        }
        .navigationTitle("Date & Time")
    }
}

private struct LanguageSettingsView: View {
    @AppStorage("indicaLanguage") private var language = "English"
    @AppStorage("indicaRegion") private var region = "United States"

    var body: some View {
        Form {
            Picker("Language", selection: $language) {
                Text("English").tag("English")
                Text("Spanish").tag("Spanish")
                Text("French").tag("French")
            }
            Picker("Region", selection: $region) {
                Text("United States").tag("United States")
                Text("Canada").tag("Canada")
                Text("United Kingdom").tag("United Kingdom")
            }
            LabeledContent("Temperature", value: "Fahrenheit")
            LabeledContent("Measurement System", value: "US")
        }
        .navigationTitle("Language & Region")
    }
}

private struct ResetSettingsView: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var showingResetSettings = false
    @State private var showingEraseContent = false

    var body: some View {
        List {
            Section {
                Button("Reset All Settings") {
                    showingResetSettings = true
                }
                Button("Remove Sample Content", role: .destructive) {
                    showingEraseContent = true
                }
            } footer: {
                Text("Reset All Settings keeps notes, messages, reminders, journal entries, drawings, and account credentials. Remove Sample Content deletes the example notes, reminders, messages, and journal entry included with the app, even if you checked one off, and clears the simulated camera captures. Notes you edited and anything you added yourself are kept.")
            }
        }
        .navigationTitle("Transfer or Reset")
        .confirmationDialog("Reset every Swift UI setting?", isPresented: $showingResetSettings, titleVisibility: .visible) {
            Button("Reset All Settings", role: .destructive) {
                system.resetSystemSettings()
            }
        }
        .confirmationDialog(
            "Remove sample content?",
            isPresented: $showingEraseContent,
            titleVisibility: .visible
        ) {
            Button("Remove Sample Content", role: .destructive) {
                system.removeSampleContent()
            }
        } message: {
            Text("Simulated camera captures are cleared too. Notes, reminders, messages, and journal entries you added, notes you edited, and your drawings are not affected.")
        }
    }
}

private struct AppsSettingsView: View {
    @State private var query = ""

    private var filteredApps: [BuiltInApp] {
        BuiltInApp.allCases
            .filter { query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        List(filteredApps) { app in
            NavigationLink {
                IndividualAppSettingsView(app: app)
            } label: {
                HStack(spacing: 12) {
                    AppSettingsMark(app: app)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(app.name)
                        Text(app.category.rawValue.capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Apps")
        .searchable(text: $query, prompt: "Search Apps")
    }
}

private struct IndividualAppSettingsView: View {
    @EnvironmentObject private var system: IndicaSystem
    let app: BuiltInApp
    @AppStorage("appCellularDefault") private var cellular = true

    private var notifications: Binding<Bool> {
        Binding(
            get: { system.notificationsEnabled(for: app) },
            set: { system.setNotifications($0, for: app) }
        )
    }

    private var refresh: Binding<Bool> {
        Binding(
            get: { system.backgroundRefreshEnabled(for: app) },
            set: { system.setBackgroundRefresh($0, for: app) }
        )
    }

    var body: some View {
        Form {
            Section {
                HStack(spacing: 13) {
                    AppSettingsMark(app: app, size: 52)
                    VStack(alignment: .leading) {
                        Text(app.name)
                            .font(.headline)
                        Text("Swift UI system app")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Toggle("Notifications", isOn: notifications)
                Toggle("Background App Refresh", isOn: refresh)
                Toggle("Mobile Data", isOn: $cellular)
            }

            if let service = ConnectedService.service(for: app) {
                Section("Account") {
                    NavigationLink("Manage \(service.shortName) Connection") {
                        ServiceConnectionDetail(service: service)
                    }
                }
            }
        }
        .navigationTitle(app.name)
    }
}

private struct DeveloperIntegrationView: View {
    @EnvironmentObject private var connections: ConnectionStore

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Integration Console")
                        .font(.title2.bold())
                    Text("Register provider apps, add public client identifiers, and test secure account connections.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 5)
            }

            Section("Providers") {
                ForEach(ConnectedService.allCases) { service in
                    NavigationLink {
                        ServiceConnectionDetail(service: service)
                    } label: {
                        HStack {
                            SettingsGlyph(symbol: service.symbol, tint: service.tint)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(service.name)
                                Text(service.connectionKind)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: connections.isConnected(service) ? "checkmark.circle.fill" : "circle.dashed")
                                .foregroundStyle(connections.isConnected(service) ? .green : .secondary)
                        }
                    }
                }
            }

            Section("Redirects") {
                LabeledContent("Swift UI", value: "indicaos://oauth")
                LabeledContent("Spotify", value: "indicaos://oauth/spotify")
                Text("Client secrets belong on a secure backend, never in this Xcode project.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Developer")
    }
}

private struct SettingsLinkLabel: View {
    let title: String
    let detail: String?
    let symbol: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            SettingsGlyph(symbol: symbol, tint: tint)
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            if let detail {
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

private struct SettingsSwitchRow: View {
    let title: String
    let symbol: String
    let tint: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            SettingsGlyph(symbol: symbol, tint: tint)
            Toggle(title, isOn: $isOn)
        }
    }
}

private struct SettingsGlyph: View {
    let symbol: String
    let tint: Color

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 29, height: 29)
            .background(tint, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct AppSettingsMark: View {
    let app: BuiltInApp
    var size: CGFloat = 34

    var body: some View {
        AppMark(app: app, size: size)
    }
}
