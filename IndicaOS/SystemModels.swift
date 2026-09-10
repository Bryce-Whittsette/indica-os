import SwiftUI

enum SystemPhase: Equatable {
    case booting
    case locked
    case home
    case app(BuiltInApp)
    case switcher
}

enum SystemOverlay: Equatable {
    case controlCenter
    case notifications
    case wallpaper
    case lockCustomization
}

enum IndicaAppearance: String, CaseIterable, Identifiable {
    case automatic = "Automatic"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .automatic: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum IndicaAccent: String, CaseIterable, Identifiable {
    case champagne = "Champagne"
    case violet = "Violet"
    case blue = "Blue"
    case aqua = "Aqua"
    case green = "Green"
    case coral = "Coral"
    case rose = "Rose"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .champagne: Color(hex: 0xB88C68)
        case .violet: Color(hex: 0x8B7CFF)
        case .blue: Color(hex: 0x3185FF)
        case .aqua: Color(hex: 0x1BC7C2)
        case .green: Color(hex: 0x35C66B)
        case .coral: Color(hex: 0xFF765F)
        case .rose: Color(hex: 0xF05F9E)
        }
    }
}

enum AppIconAppearance: String, CaseIterable, Identifiable {
    case automatic = "Automatic"
    case light = "Light"
    case dark = "Dark"
    case clear = "Clear"
    case tinted = "Tinted"

    var id: String { rawValue }
}

enum HomeLayoutDensity: String, CaseIterable, Identifiable {
    case comfortable = "Comfortable"
    case compact = "Compact"

    var id: String { rawValue }
}

enum LockClockStyle: String, CaseIterable, Identifiable {
    case rounded = "Rounded"
    case classic = "Classic"
    case mono = "Mono"
    case soft = "Soft"

    var id: String { rawValue }

    var design: Font.Design {
        switch self {
        case .rounded, .soft: .rounded
        case .classic: .default
        case .mono: .monospaced
        }
    }

    var weight: Font.Weight {
        switch self {
        case .rounded: .medium
        case .classic: .light
        case .mono: .regular
        case .soft: .thin
        }
    }
}

enum NotificationPreviewStyle: String, CaseIterable, Identifiable {
    case always = "Always"
    case unlocked = "When Unlocked"
    case never = "Never"

    var id: String { rawValue }
}

enum WallpaperStyle: String, CaseIterable, Identifiable {
    case aura = "Aura"
    case tide = "Tide"
    case bloom = "Bloom"
    case dusk = "Dusk"
    case graphite = "Graphite"
    case daylight = "Daylight"

    var id: String { rawValue }

    var colors: [Color] {
        switch self {
        case .aura:
            [Color(hex: 0x05070C), Color(hex: 0x111722), Color(hex: 0x746052)]
        case .tide:
            [Color(hex: 0x041113), Color(hex: 0x123B3D), Color(hex: 0x69A39B)]
        case .bloom:
            [Color(hex: 0x16090F), Color(hex: 0x522638), Color(hex: 0xC38D7A)]
        case .dusk:
            [Color(hex: 0x080C19), Color(hex: 0x272B4B), Color(hex: 0xA16F5E)]
        case .graphite:
            [Color(hex: 0x030405), Color(hex: 0x17191E), Color(hex: 0x666B72)]
        case .daylight:
            [Color(hex: 0xF3F1EC), Color(hex: 0xC9D4DA), Color(hex: 0xD5BFB0)]
        }
    }

    var foreground: Color {
        self == .daylight ? Color.black.opacity(0.88) : .white
    }
}

enum BuiltInApp: String, CaseIterable, Identifiable, Codable {
    case phone
    case messages
    case camera
    case photos
    case browser
    case mail
    case maps
    case weather
    case calendar
    case clock
    case notes
    case reminders
    case files
    case music
    case video
    case podcasts
    case news
    case books
    case wallet
    case health
    case home
    case find
    case contacts
    case calculator
    case voiceMemos
    case translate
    case shortcuts
    case store
    case settings
    case compass
    case measure
    case magnifier
    case tips
    case canvas
    case journal
    case passwords
    case stocks
    case fitness
    case watch
    case videoCall
    case accounts
    case spotify
    case youtube
    case notion
    case discord
    case telegram
    case gmail
    case outlook
    case chatGPT
    case claude

    var id: String { rawValue }

    var name: String {
        switch self {
        case .phone: "Phone"
        case .messages: "Messages"
        case .camera: "Camera"
        case .photos: "Photos"
        case .browser: "Browser"
        case .mail: "Mail"
        case .maps: "Maps"
        case .weather: "Weather"
        case .calendar: "Calendar"
        case .clock: "Clock"
        case .notes: "Notes"
        case .reminders: "Reminders"
        case .files: "Files"
        case .music: "Music"
        case .video: "TV"
        case .podcasts: "Podcasts"
        case .news: "News"
        case .books: "Books"
        case .wallet: "Wallet"
        case .health: "Health"
        case .home: "Home"
        case .find: "Find"
        case .contacts: "Contacts"
        case .calculator: "Calculator"
        case .voiceMemos: "Voice Memos"
        case .translate: "Translate"
        case .shortcuts: "Shortcuts"
        case .store: "Store"
        case .settings: "Settings"
        case .compass: "Compass"
        case .measure: "Measure"
        case .magnifier: "Magnifier"
        case .tips: "Tips"
        case .canvas: "Canvas"
        case .journal: "Journal"
        case .passwords: "Passwords"
        case .stocks: "Stocks"
        case .fitness: "Fitness"
        case .watch: "Watch"
        case .videoCall: "Video"
        case .accounts: "Connections"
        case .spotify: "Spotify"
        case .youtube: "YouTube"
        case .notion: "Notion"
        case .discord: "Discord"
        case .telegram: "Telegram"
        case .gmail: "Gmail"
        case .outlook: "Outlook"
        case .chatGPT: "ChatGPT"
        case .claude: "Claude"
        }
    }

    var symbol: String {
        switch self {
        case .phone: "phone.fill"
        case .messages: "message.fill"
        case .camera: "camera.fill"
        case .photos: "photo.on.rectangle.angled"
        case .browser: "safari.fill"
        case .mail: "envelope.fill"
        case .maps: "map.fill"
        case .weather: "cloud.sun.fill"
        case .calendar: "calendar"
        case .clock: "clock.fill"
        case .notes: "note.text"
        case .reminders: "checklist"
        case .files: "folder.fill"
        case .music: "music.note"
        case .video: "play.rectangle.fill"
        case .podcasts: "dot.radiowaves.left.and.right"
        case .news: "newspaper.fill"
        case .books: "books.vertical.fill"
        case .wallet: "wallet.bifold.fill"
        case .health: "heart.fill"
        case .home: "house.fill"
        case .find: "location.fill"
        case .contacts: "person.crop.circle.fill"
        case .calculator: "plus.forwardslash.minus"
        case .voiceMemos: "waveform"
        case .translate: "character.bubble.fill"
        case .shortcuts: "square.stack.3d.up.fill"
        case .store: "bag.fill"
        case .settings: "gearshape.fill"
        case .compass: "safari"
        case .measure: "ruler.fill"
        case .magnifier: "magnifyingglass"
        case .tips: "lightbulb.fill"
        case .canvas: "scribble.variable"
        case .journal: "book.closed.fill"
        case .passwords: "key.fill"
        case .stocks: "chart.line.uptrend.xyaxis"
        case .fitness: "figure.run"
        case .watch: "applewatch"
        case .videoCall: "video.fill"
        case .accounts: "person.crop.circle.badge.checkmark"
        case .spotify: "waveform.circle.fill"
        case .youtube: "play.rectangle.fill"
        case .notion: "doc.richtext.fill"
        case .discord: "bubble.left.and.bubble.right.fill"
        case .telegram: "paperplane.fill"
        case .gmail: "envelope.badge.fill"
        case .outlook: "tray.full.fill"
        case .chatGPT: "sparkles"
        case .claude: "sun.max.fill"
        }
    }

    var palette: [Color] {
        switch self {
        case .phone: [.green, Color(hex: 0x14B85A)]
        case .messages: [Color(hex: 0x52D769), Color(hex: 0x14A83B)]
        case .camera: [Color(hex: 0x4F5560), .black]
        case .photos: [Color(hex: 0xFF6B77), Color(hex: 0x7D62FF)]
        case .browser: [Color(hex: 0x65C7FF), Color(hex: 0x1479E7)]
        case .mail: [Color(hex: 0x4CB7FF), Color(hex: 0x1168DA)]
        case .maps: [Color(hex: 0xA6DC75), Color(hex: 0x3AA7E8)]
        case .weather: [Color(hex: 0x63BEFF), Color(hex: 0x3067CB)]
        case .calendar: [.white, Color(hex: 0xFF4B45)]
        case .clock: [Color(hex: 0x27292D), .black]
        case .notes: [Color(hex: 0xFFD84D), Color(hex: 0xF0AA2A)]
        case .reminders: [Color(hex: 0x7E74FF), Color(hex: 0x4A9CFF)]
        case .files: [Color(hex: 0x65B7FF), Color(hex: 0x246BD8)]
        case .music: [Color(hex: 0xFF497A), Color(hex: 0xD81F58)]
        case .video: [Color(hex: 0x5144D8), Color(hex: 0x1E173E)]
        case .podcasts: [Color(hex: 0x9B5BFF), Color(hex: 0x6330BD)]
        case .news: [Color(hex: 0xFF5A55), Color(hex: 0xC82328)]
        case .books: [Color(hex: 0xFF9B42), Color(hex: 0xF0602A)]
        case .wallet: [Color(hex: 0x383B42), Color(hex: 0x121318)]
        case .health: [.white, Color(hex: 0xFF436B)]
        case .home: [Color(hex: 0xFFB247), Color(hex: 0xF57934)]
        case .find: [Color(hex: 0x5ED77B), Color(hex: 0x2B9F65)]
        case .contacts: [Color(hex: 0xA7ADB8), Color(hex: 0x636978)]
        case .calculator: [Color(hex: 0xF6A526), Color(hex: 0x202124)]
        case .voiceMemos: [Color(hex: 0xFF4A4F), Color(hex: 0xB71827)]
        case .translate: [Color(hex: 0x67A9FF), Color(hex: 0x2859C8)]
        case .shortcuts: [Color(hex: 0x8267FF), Color(hex: 0xF05BC7)]
        case .store: [Color(hex: 0x45B6FF), Color(hex: 0x1674D4)]
        case .settings: [Color(hex: 0x9FA4AE), Color(hex: 0x555B65)]
        case .compass: [Color(hex: 0x282B30), Color(hex: 0x111214)]
        case .measure: [Color(hex: 0x17181B), Color(hex: 0xD4A72C)]
        case .magnifier: [Color(hex: 0x4A8CFF), Color(hex: 0x6F55D9)]
        case .tips: [Color(hex: 0xFFD94E), Color(hex: 0xF0A321)]
        case .canvas: [Color(hex: 0xF5F0E7), Color(hex: 0xEF8354)]
        case .journal: [Color(hex: 0x6A70E8), Color(hex: 0x3942A3)]
        case .passwords: [Color(hex: 0x5E9CFF), Color(hex: 0x6D5AE6)]
        case .stocks: [Color(hex: 0x272A2F), Color(hex: 0x111214)]
        case .fitness: [Color(hex: 0xF34B88), Color(hex: 0x7F48FF)]
        case .watch: [Color(hex: 0x303236), Color(hex: 0x101114)]
        case .videoCall: [Color(hex: 0x5BD578), Color(hex: 0x25A548)]
        case .accounts: [Color(hex: 0x8B7CFF), Color(hex: 0x3E64E8)]
        case .spotify: [Color(hex: 0x29D86C), Color(hex: 0x0C7F41)]
        case .youtube: [Color(hex: 0xFF4E55), Color(hex: 0xB61523)]
        case .notion: [Color(hex: 0x4A4A4C), Color(hex: 0x111214)]
        case .discord: [Color(hex: 0x7587F4), Color(hex: 0x4D5FD2)]
        case .telegram: [Color(hex: 0x55B8F4), Color(hex: 0x197AC2)]
        case .gmail: [Color(hex: 0xEA5A52), Color(hex: 0xC83238)]
        case .outlook: [Color(hex: 0x4B9BFF), Color(hex: 0x1758B8)]
        case .chatGPT: [Color(hex: 0x5AC7AF), Color(hex: 0x177966)]
        case .claude: [Color(hex: 0xE8A979), Color(hex: 0xA65C38)]
        }
    }

    var category: AppCategory {
        switch self {
        case .phone, .messages, .mail, .contacts, .videoCall, .gmail, .outlook, .discord, .telegram:
            .communication
        case .camera, .photos, .music, .video, .podcasts, .books, .news, .voiceMemos, .spotify, .youtube:
            .media
        case .calendar, .clock, .notes, .reminders, .files, .calculator, .translate, .shortcuts, .canvas, .journal, .notion, .chatGPT, .claude:
            .productivity
        case .maps, .weather, .find, .compass, .measure, .magnifier:
            .utilities
        case .wallet, .health, .home, .store, .passwords, .stocks, .fitness, .watch, .tips, .settings, .browser, .accounts:
            .system
        }
    }
}

enum AppCategory: String {
    case communication
    case media
    case productivity
    case utilities
    case system
}

struct NoteItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var body: String
    var modified: Date

    init(id: UUID = UUID(), title: String, body: String, modified: Date = .now) {
        self.id = id
        self.title = title
        self.body = body
        self.modified = modified
    }
}

struct ReminderItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isComplete: Bool

    init(id: UUID = UUID(), title: String, isComplete: Bool = false) {
        self.id = id
        self.title = title
        self.isComplete = isComplete
    }
}

struct MessageItem: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let isMine: Bool
    let sentAt: Date

    init(id: UUID = UUID(), text: String, isMine: Bool, sentAt: Date = .now) {
        self.id = id
        self.text = text
        self.isMine = isMine
        self.sentAt = sentAt
    }
}

struct SystemNotification: Identifiable, Equatable {
    let id = UUID()
    let app: BuiltInApp
    let title: String
    let body: String
    let date: Date
}

@MainActor
final class IndicaSystem: ObservableObject {
    @Published var phase: SystemPhase = .booting
    @Published var overlay: SystemOverlay?
    @Published var appearance: IndicaAppearance {
        didSet {
            UserDefaults.standard.set(appearance.rawValue, forKey: "appearance")
        }
    }
    @Published var wallpaper: WallpaperStyle {
        didSet {
            UserDefaults.standard.set(wallpaper.rawValue, forKey: "wallpaper")
        }
    }
    @Published var accentStyle: IndicaAccent = IndicaAccent(
        rawValue: UserDefaults.standard.string(forKey: "accentStyle") ?? ""
    ) ?? .champagne {
        didSet { UserDefaults.standard.set(accentStyle.rawValue, forKey: "accentStyle") }
    }
    @Published var iconAppearance: AppIconAppearance = AppIconAppearance(
        rawValue: UserDefaults.standard.string(forKey: "iconAppearance") ?? ""
    ) ?? .automatic {
        didSet { UserDefaults.standard.set(iconAppearance.rawValue, forKey: "iconAppearance") }
    }
    @Published var homeLayoutDensity: HomeLayoutDensity = HomeLayoutDensity(
        rawValue: UserDefaults.standard.string(forKey: "homeLayoutDensity") ?? ""
    ) ?? .comfortable {
        didSet { UserDefaults.standard.set(homeLayoutDensity.rawValue, forKey: "homeLayoutDensity") }
    }
    @Published var lockClockStyle: LockClockStyle = LockClockStyle(
        rawValue: UserDefaults.standard.string(forKey: "lockClockStyle") ?? ""
    ) ?? .classic {
        didSet { UserDefaults.standard.set(lockClockStyle.rawValue, forKey: "lockClockStyle") }
    }
    @Published var notificationPreviews: NotificationPreviewStyle = NotificationPreviewStyle(
        rawValue: UserDefaults.standard.string(forKey: "notificationPreviews") ?? ""
    ) ?? .unlocked {
        didSet { UserDefaults.standard.set(notificationPreviews.rawValue, forKey: "notificationPreviews") }
    }
    @Published var glassIntensity: Double = UserDefaults.standard.object(forKey: "glassIntensity") as? Double ?? 0.72 {
        didSet { UserDefaults.standard.set(glassIntensity, forKey: "glassIntensity") }
    }
    @Published var reduceTransparency = UserDefaults.standard.bool(forKey: "reduceTransparency") {
        didSet { UserDefaults.standard.set(reduceTransparency, forKey: "reduceTransparency") }
    }
    @Published var reduceMotion = UserDefaults.standard.bool(forKey: "reduceMotion") {
        didSet { UserDefaults.standard.set(reduceMotion, forKey: "reduceMotion") }
    }
    @Published var boldText = UserDefaults.standard.bool(forKey: "boldText") {
        didSet { UserDefaults.standard.set(boldText, forKey: "boldText") }
    }
    @Published var textScale: Double = UserDefaults.standard.object(forKey: "textScale") as? Double ?? 1 {
        didSet { UserDefaults.standard.set(textScale, forKey: "textScale") }
    }
    @Published var showAppLabels = UserDefaults.standard.object(forKey: "showAppLabels") as? Bool ?? true {
        didSet { UserDefaults.standard.set(showAppLabels, forKey: "showAppLabels") }
    }
    @Published var showLockWidgets = UserDefaults.standard.object(forKey: "showLockWidgets") as? Bool ?? true {
        didSet { UserDefaults.standard.set(showLockWidgets, forKey: "showLockWidgets") }
    }
    @Published var soundsEnabled = UserDefaults.standard.object(forKey: "soundsEnabled") as? Bool ?? true {
        didSet { UserDefaults.standard.set(soundsEnabled, forKey: "soundsEnabled") }
    }
    @Published var hapticsEnabled = UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true {
        didSet { UserDefaults.standard.set(hapticsEnabled, forKey: "hapticsEnabled") }
    }
    @Published var keyboardClicks = UserDefaults.standard.object(forKey: "keyboardClicks") as? Bool ?? true {
        didSet { UserDefaults.standard.set(keyboardClicks, forKey: "keyboardClicks") }
    }
    @Published var lowPowerMode = UserDefaults.standard.bool(forKey: "lowPowerMode") {
        didSet { UserDefaults.standard.set(lowPowerMode, forKey: "lowPowerMode") }
    }
    @Published var batteryPercentage = UserDefaults.standard.object(forKey: "batteryPercentage") as? Bool ?? true {
        didSet { UserDefaults.standard.set(batteryPercentage, forKey: "batteryPercentage") }
    }
    @Published var locationServices = UserDefaults.standard.object(forKey: "locationServices") as? Bool ?? true {
        didSet { UserDefaults.standard.set(locationServices, forKey: "locationServices") }
    }
    @Published var analyticsSharing = UserDefaults.standard.bool(forKey: "analyticsSharing") {
        didSet { UserDefaults.standard.set(analyticsSharing, forKey: "analyticsSharing") }
    }
    @Published var allowTrackingRequests = UserDefaults.standard.bool(forKey: "allowTrackingRequests") {
        didSet { UserDefaults.standard.set(allowTrackingRequests, forKey: "allowTrackingRequests") }
    }
    @Published var automaticUpdates = UserDefaults.standard.object(forKey: "automaticUpdates") as? Bool ?? true {
        didSet { UserDefaults.standard.set(automaticUpdates, forKey: "automaticUpdates") }
    }
    @Published var backgroundRefresh = UserDefaults.standard.object(forKey: "backgroundRefresh") as? Bool ?? true {
        didSet { UserDefaults.standard.set(backgroundRefresh, forKey: "backgroundRefresh") }
    }
    @Published var privateWiFiAddress = UserDefaults.standard.object(forKey: "privateWiFiAddress") as? Bool ?? true {
        didSet { UserDefaults.standard.set(privateWiFiAddress, forKey: "privateWiFiAddress") }
    }
    @Published var deviceName = UserDefaults.standard.string(forKey: "deviceName") ?? "My Indica" {
        didSet { UserDefaults.standard.set(deviceName, forKey: "deviceName") }
    }
    @Published var disabledNotificationApps = Set(
        UserDefaults.standard.stringArray(forKey: "disabledNotificationApps") ?? []
    ) {
        didSet {
            UserDefaults.standard.set(Array(disabledNotificationApps).sorted(), forKey: "disabledNotificationApps")
        }
    }
    @Published var disabledBackgroundApps = Set(
        UserDefaults.standard.stringArray(forKey: "disabledBackgroundApps") ?? []
    ) {
        didSet {
            UserDefaults.standard.set(Array(disabledBackgroundApps).sorted(), forKey: "disabledBackgroundApps")
        }
    }
    @Published var isEditingHome = false
    @Published var isFocusEnabled = false
    @Published var wifiEnabled = true
    @Published var bluetoothEnabled = true
    @Published var airplaneMode = false
    @Published var brightness = 0.78
    @Published var volume = 0.46
    @Published var appHistory: [BuiltInApp] = []
    @Published var notifications: [SystemNotification] = [
        SystemNotification(app: .messages, title: "Maya", body: "The concept finally feels like a real phone.", date: .now),
        SystemNotification(app: .calendar, title: "Design review", body: "Today at 2:30 PM", date: .now.addingTimeInterval(-900)),
        SystemNotification(app: .weather, title: "Rain later", body: "Showers are expected around 7 PM.", date: .now.addingTimeInterval(-1800))
    ]
    @Published var notes: [NoteItem] {
        didSet { Self.save(notes, key: "notes") }
    }
    @Published var reminders: [ReminderItem] {
        didSet { Self.save(reminders, key: "reminders") }
    }
    @Published var messages: [MessageItem] {
        didSet { Self.save(messages, key: "messages") }
    }
    @Published var homeAccessories: [String: Bool] = [
        "Living Room": true,
        "Desk Lamp": false,
        "Studio": true,
        "Front Door": true
    ]
    @Published var capturedMoments: Int {
        didSet { UserDefaults.standard.set(capturedMoments, forKey: "capturedMoments") }
    }

    var accent: Color { accentStyle.color }
    var dynamicTypeSize: DynamicTypeSize {
        switch textScale {
        case ..<0.9: .small
        case ..<0.98: .medium
        case ..<1.08: .large
        case ..<1.18: .xLarge
        default: .xxLarge
        }
    }

    let homePages: [[BuiltInApp]] = [
        [.weather, .calendar, .photos, .camera, .mail, .maps, .clock, .notes,
         .reminders, .store, .health, .wallet, .home, .find, .music, .settings],
        [.browser, .contacts, .files, .calculator, .podcasts, .news, .books, .voiceMemos,
         .translate, .shortcuts, .video, .videoCall, .fitness, .journal, .passwords, .stocks],
        [.accounts, .spotify, .youtube, .gmail, .outlook, .notion, .discord, .telegram,
         .chatGPT, .claude],
        [.compass, .measure, .magnifier, .tips, .canvas, .watch]
    ]

    let dockApps: [BuiltInApp] = [.phone, .messages, .browser, .spotify]

    init() {
        appearance = IndicaAppearance(rawValue: UserDefaults.standard.string(forKey: "appearance") ?? "") ?? .automatic
        wallpaper = WallpaperStyle(rawValue: UserDefaults.standard.string(forKey: "wallpaper") ?? "") ?? .aura
        notes = Self.load(
            [NoteItem(title: "Welcome to Indica", body: "This note is saved locally. Edit it, create another, then relaunch the simulator.")],
            key: "notes"
        )
        reminders = Self.load(
            [ReminderItem(title: "Customize the Lock Screen"), ReminderItem(title: "Try Control Center")],
            key: "reminders"
        )
        messages = Self.load(
            [
                MessageItem(text: "You made it home?", isMine: false, sentAt: .now.addingTimeInterval(-500)),
                MessageItem(text: "Yep, testing Indica OS now.", isMine: true, sentAt: .now.addingTimeInterval(-420))
            ],
            key: "messages"
        )
        capturedMoments = UserDefaults.standard.integer(forKey: "capturedMoments")

        if ProcessInfo.processInfo.arguments.contains("--control") {
            phase = .home
            overlay = .controlCenter
        } else if ProcessInfo.processInfo.arguments.contains("--notifications") {
            phase = .home
            overlay = .notifications
        } else if ProcessInfo.processInfo.arguments.contains("--home") {
            phase = .home
        } else if let appArgument = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--app=") }) {
            let appName = String(appArgument.dropFirst("--app=".count))
            if let app = BuiltInApp(rawValue: appName) {
                appHistory = [app]
                phase = .app(app)
            }
        }
    }

    func finishBoot() {
        withAnimation(.spring(response: 0.65, dampingFraction: 0.86)) {
            phase = .locked
        }
    }

    func unlock() {
        HapticEngine.play(.success, enabled: hapticsEnabled)
        withAnimation(.spring(response: 0.58, dampingFraction: 0.84)) {
            overlay = nil
            phase = .home
        }
    }

    func lock() {
        HapticEngine.play(.rigid, enabled: hapticsEnabled)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
            overlay = nil
            isEditingHome = false
            phase = .locked
        }
    }

    func open(_ app: BuiltInApp) {
        HapticEngine.play(.light, enabled: hapticsEnabled)
        appHistory.removeAll { $0 == app }
        appHistory.insert(app, at: 0)
        appHistory = Array(appHistory.prefix(6))
        withAnimation(.spring(response: 0.48, dampingFraction: 0.86)) {
            overlay = nil
            phase = .app(app)
        }
    }

    func goHome() {
        HapticEngine.play(.selection, enabled: hapticsEnabled)
        withAnimation(.spring(response: 0.48, dampingFraction: 0.88)) {
            overlay = nil
            phase = .home
        }
    }

    func showSwitcher() {
        guard !appHistory.isEmpty else {
            goHome()
            return
        }
        HapticEngine.play(.medium, enabled: hapticsEnabled)
        withAnimation(.spring(response: 0.44, dampingFraction: 0.84)) {
            overlay = nil
            phase = .switcher
        }
    }

    func dismissNotification(_ notification: SystemNotification) {
        HapticEngine.play(.selection, enabled: hapticsEnabled)
        notifications.removeAll { $0.id == notification.id }
    }

    func notificationsEnabled(for app: BuiltInApp) -> Bool {
        !disabledNotificationApps.contains(app.rawValue)
    }

    func setNotifications(_ enabled: Bool, for app: BuiltInApp) {
        HapticEngine.play(.selection, enabled: hapticsEnabled)
        if enabled {
            disabledNotificationApps.remove(app.rawValue)
        } else {
            disabledNotificationApps.insert(app.rawValue)
        }
    }

    func backgroundRefreshEnabled(for app: BuiltInApp) -> Bool {
        !disabledBackgroundApps.contains(app.rawValue)
    }

    func setBackgroundRefresh(_ enabled: Bool, for app: BuiltInApp) {
        HapticEngine.play(.selection, enabled: hapticsEnabled)
        if enabled {
            disabledBackgroundApps.remove(app.rawValue)
        } else {
            disabledBackgroundApps.insert(app.rawValue)
        }
    }

    func resetSystemSettings() {
        appearance = .automatic
        wallpaper = .aura
        accentStyle = .champagne
        iconAppearance = .automatic
        homeLayoutDensity = .comfortable
        lockClockStyle = .classic
        notificationPreviews = .unlocked
        glassIntensity = 0.72
        reduceTransparency = false
        reduceMotion = false
        boldText = false
        textScale = 1
        showAppLabels = true
        showLockWidgets = true
        soundsEnabled = true
        hapticsEnabled = true
        keyboardClicks = true
        lowPowerMode = false
        batteryPercentage = true
        locationServices = true
        analyticsSharing = false
        allowTrackingRequests = false
        automaticUpdates = true
        backgroundRefresh = true
        privateWiFiAddress = true
        wifiEnabled = true
        bluetoothEnabled = true
        airplaneMode = false
        isFocusEnabled = false
        brightness = 0.78
        volume = 0.46
        disabledNotificationApps = []
        disabledBackgroundApps = []
    }

    func resetDemoData() {
        notes = [NoteItem(title: "Welcome to Indica", body: "A clean start.")]
        reminders = [ReminderItem(title: "Explore the Home Screen")]
        messages = [MessageItem(text: "Fresh start ✨", isMine: false)]
        capturedMoments = 0
    }

    private static func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private static func load<T: Decodable>(_ fallback: T, key: String) -> T {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode(T.self, from: data)
        else {
            return fallback
        }
        return decoded
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}
