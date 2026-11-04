import SwiftUI
import UserNotifications

/// Shows Swift UI's own notifications while the app is open, since iOS hides them
/// by default for the foreground app.
final class ForegroundNotificationPresenter: NSObject, UNUserNotificationCenterDelegate {
    static let shared = ForegroundNotificationPresenter()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // A one-time alarm that fires while the app is open turns its switch off now,
        // rather than the next time the app comes back. Not awaited: the banner shouldn't wait.
        Task { @MainActor in await ClockStore.shared.refresh() }
        return [.banner, .sound]
    }
}

/// Clock state lives outside the views, so it survives switching apps and relaunching.
@MainActor
final class ClockStore: ObservableObject {
    static let shared = ClockStore()

    @Published var cityIdentifiers: [String] {
        didSet { save(cityIdentifiers, key: "clockCities") }
    }
    @Published var alarms: [ClockAlarm] {
        didSet { save(alarms, key: "clockAlarms") }
    }
    @Published private(set) var timer: CountdownTimer {
        didSet { save(timer, key: "clockTimer") }
    }
    @Published private(set) var stopwatch: Stopwatch {
        didSet { save(stopwatch, key: "clockStopwatch") }
    }
    @Published var timerMinutes: Double {
        didSet { UserDefaults.standard.set(timerMinutes, forKey: "clockTimerMinutes") }
    }
    @Published private(set) var notifications = UNAuthorizationStatus.notDetermined
    @Published var timerJustFinished = false

    private static let timerNotificationID = "clock-timer"
    private let center = UNUserNotificationCenter.current()

    private init() {
        cityIdentifiers = Self.load(key: "clockCities") ?? ["America/New_York", "Europe/London", "Asia/Tokyo"]
        alarms = Self.load(key: "clockAlarms") ?? []
        timer = Self.load(key: "clockTimer") ?? CountdownTimer()
        stopwatch = Self.load(key: "clockStopwatch") ?? Stopwatch()
        let minutes = UserDefaults.standard.double(forKey: "clockTimerMinutes")
        timerMinutes = minutes > 0 ? minutes : 5
    }

    private static func load<T: Decodable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    // MARK: Notifications

    /// Reads the current permission, which can change in Settings at any time.
    /// Runs on opening Clock and returning to the app. With permission, it also
    /// schedules anything that couldn't be scheduled while permission was off.
    func refresh() async {
        notifications = await center.notificationSettings().authorizationStatus
        guard notifications == .authorized || notifications == .provisional else { return }
        let pending = Set(await center.pendingNotificationRequests().map(\.identifier))

        if case .running = timer.state, !pending.contains(Self.timerNotificationID) {
            scheduleTimerNotification()
        }
        for alarm in alarms where alarm.isOn {
            if let fires = alarm.oneTimeFireDate, fires <= .now {
                // A one-time alarm that has gone off turns its switch off.
                setAlarm(alarm.id, isOn: false)
            } else if !expectedIDs(for: alarm).allSatisfy(pending.contains) {
                schedule(alarm)
            }
        }
    }

    /// Asks only when the person starts something that needs it.
    private func ensureNotificationPermission() async {
        if notifications == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .sound])
        }
        notifications = await center.notificationSettings().authorizationStatus
    }

    // MARK: Timer

    func startTimer() {
        timer.start(duration: timerMinutes * 60, at: .now)
        timerJustFinished = false
        scheduleTimerNotification()
    }

    func pauseTimer() {
        timer.pause(at: .now)
        center.removePendingNotificationRequests(withIdentifiers: [Self.timerNotificationID])
    }

    func resumeTimer() {
        timer.resume(at: .now)
        scheduleTimerNotification()
    }

    func cancelTimer() {
        timer.cancel()
        timerJustFinished = false
        center.removePendingNotificationRequests(withIdentifiers: [Self.timerNotificationID])
    }

    /// Called on each tick. The notification has already been scheduled, so this
    /// only updates the screen.
    func checkTimer(at now: Date) {
        guard timer.hasFinished(at: now) else { return }
        timer.cancel()
        timerJustFinished = true
    }

    private func scheduleTimerNotification() {
        let seconds = timer.remaining(at: .now)
        guard seconds > 0 else { return }
        Task {
            await ensureNotificationPermission()
            let content = UNMutableNotificationContent()
            content.title = "Timer"
            content.body = "Your timer is done."
            content.sound = .default
            // The person may have paused or cancelled while permission was being asked for.
            guard case .running = timer.state else { return }
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, timer.remaining(at: .now)), repeats: false)
            try? await center.add(UNNotificationRequest(identifier: Self.timerNotificationID, content: content, trigger: trigger))
            if case .running = timer.state { return }
            center.removePendingNotificationRequests(withIdentifiers: [Self.timerNotificationID])
        }
    }

    // MARK: Stopwatch

    func startStopwatch() { stopwatch.start(at: .now) }
    func stopStopwatch() { stopwatch.stop(at: .now) }
    func lapStopwatch() { stopwatch.lap(at: .now) }
    func resetStopwatch() { stopwatch.reset() }

    // MARK: Alarms

    func save(alarm: ClockAlarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
        } else {
            alarms.append(alarm)
        }
        schedule(alarm)
    }

    func setAlarm(_ id: UUID, isOn: Bool) {
        guard let index = alarms.firstIndex(where: { $0.id == id }) else { return }
        alarms[index].isOn = isOn
        schedule(alarms[index])
    }

    func delete(alarmID: UUID) {
        alarms.removeAll { $0.id == alarmID }
        center.removePendingNotificationRequests(withIdentifiers: notificationIDs(for: alarmID))
    }

    private func notificationIDs(for alarmID: UUID) -> [String] {
        (0...7).map { "alarm-\(alarmID.uuidString)-\($0)" }
    }

    private func expectedIDs(for alarm: ClockAlarm) -> [String] {
        let days = alarm.weekdays.isEmpty ? [0] : alarm.weekdays.sorted()
        return days.map { "alarm-\(alarm.id.uuidString)-\($0)" }
    }

    private func isStillOn(_ id: UUID) -> Bool {
        alarms.first { $0.id == id }?.isOn == true
    }

    private func schedule(_ alarm: ClockAlarm) {
        center.removePendingNotificationRequests(withIdentifiers: notificationIDs(for: alarm.id))
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index].oneTimeFireDate = nil
        }
        guard alarm.isOn else { return }
        Task {
            await ensureNotificationPermission()
            // It may have been turned off or deleted while permission was being asked for.
            guard isStillOn(alarm.id) else { return }
            let content = UNMutableNotificationContent()
            content.title = alarm.label.isEmpty ? "Alarm" : alarm.label
            let fireTime = Calendar.current.date(from: DateComponents(hour: alarm.hour, minute: alarm.minute))
            content.body = fireTime?.formatted(date: .omitted, time: .shortened) ?? ""
            content.sound = .default
            // 0 is the one-time alarm; 1 to 7 are weekly repeats.
            let days: [Int] = alarm.weekdays.isEmpty ? [0] : alarm.weekdays.sorted()
            for day in days {
                var parts = DateComponents(hour: alarm.hour, minute: alarm.minute)
                if day > 0 { parts.weekday = day }
                let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: day > 0)
                let request = UNNotificationRequest(
                    identifier: "alarm-\(alarm.id.uuidString)-\(day)",
                    content: content,
                    trigger: trigger
                )
                try? await center.add(request)
            }
            guard isStillOn(alarm.id) else {
                center.removePendingNotificationRequests(withIdentifiers: notificationIDs(for: alarm.id))
                return
            }
            let pending = Set(await center.pendingNotificationRequests().map(\.identifier))
            if alarm.weekdays.isEmpty, pending.contains("alarm-\(alarm.id.uuidString)-0"),
               let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
                alarms[index].oneTimeFireDate = alarm.nextFire(after: .now, calendar: .current)
            }
        }
    }
}

struct ClockApp: View {
    @ObservedObject private var store = ClockStore.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var tab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Clock mode", selection: $tab) {
                    Text("World").tag(0)
                    Text("Alarms").tag(1)
                    Text("Stopwatch").tag(2)
                    Text("Timer").tag(3)
                }
                .pickerStyle(.segmented)
                .padding()

                switch tab {
                case 0: WorldClockTab(store: store)
                case 1: AlarmsTab(store: store)
                case 2: StopwatchTab(store: store)
                default: TimerTab(store: store)
                }
            }
            .navigationTitle("Clock")
            .navigationBarTitleDisplayMode(.inline)
            .task { await store.refresh() }
            // Permission may have changed in Settings, and an alarm may have gone off.
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { Task { await store.refresh() } }
            }
        }
    }
}

// MARK: World

private struct WorldClockTab: View {
    @ObservedObject var store: ClockStore
    @State private var addingCity = false

    var body: some View {
        // Updates on the minute, not every frame.
        TimelineView(.everyMinute) { context in
            List {
                ForEach(store.cityIdentifiers, id: \.self) { identifier in
                    if let zone = TimeZone(identifier: identifier) {
                        row(identifier: identifier, zone: zone, now: context.date)
                    }
                }
                .onDelete { store.cityIdentifiers.remove(atOffsets: $0) }
            }
            .listStyle(.plain)
            .overlay {
                if store.cityIdentifiers.isEmpty {
                    ContentUnavailableView("No Cities", systemImage: "globe", description: Text("Tap + to add one."))
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { addingCity = true } label: { Image(systemName: "plus") }
                    .accessibilityLabel("Add city")
            }
        }
        .sheet(isPresented: $addingCity) {
            CityPicker(store: store)
        }
    }

    private func row(identifier: String, zone: TimeZone, now: Date) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(ClockFormat.cityName(for: identifier))
                    .font(.title2)
                Text(ClockFormat.worldClockOffset(zone: zone, reference: .current, at: now))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(ClockFormat.time(now, in: zone))
                .font(.largeTitle.weight(.light))
                .monospacedDigit()
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}

private struct CityPicker: View {
    @ObservedObject var store: ClockStore
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var matches: [String] {
        TimeZone.knownTimeZoneIdentifiers
            .filter { $0.contains("/") && !store.cityIdentifiers.contains($0) }
            .filter { query.isEmpty || $0.localizedCaseInsensitiveContains(query.replacingOccurrences(of: " ", with: "_")) }
            .sorted { ClockFormat.cityName(for: $0) < ClockFormat.cityName(for: $1) }
    }

    var body: some View {
        NavigationStack {
            List(matches, id: \.self) { identifier in
                Button {
                    store.cityIdentifiers.append(identifier)
                    dismiss()
                } label: {
                    VStack(alignment: .leading) {
                        Text(ClockFormat.cityName(for: identifier))
                        Text(identifier.split(separator: "/").first.map(String.init) ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.primary)
            }
            .overlay {
                if matches.isEmpty { ContentUnavailableView.search(text: query) }
            }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search cities")
            .navigationTitle("Add City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: Alarms

private struct NotificationPermissionNote: View {
    let status: UNAuthorizationStatus
    let message: String

    var body: some View {
        if status == .denied {
            VStack(alignment: .leading, spacing: 6) {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.footnote.weight(.semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

private struct AlarmsTab: View {
    @ObservedObject var store: ClockStore
    @State private var editing: ClockAlarm?
    private let calendar = Calendar.current

    private var sortedAlarms: [ClockAlarm] {
        store.alarms.sorted { ($0.hour, $0.minute) < ($1.hour, $1.minute) }
    }

    var body: some View {
        VStack(spacing: 0) {
            NotificationPermissionNote(
                status: store.notifications,
                message: "Notifications are off for Swift UI, so alarms can't go off."
            )
            List {
                ForEach(sortedAlarms) { alarm in
                    row(alarm)
                }
                .onDelete { offsets in
                    let sorted = sortedAlarms
                    offsets.forEach { store.delete(alarmID: sorted[$0].id) }
                }

                Section {
                } footer: {
                    Text("Alarms arrive as notifications. Silent mode and Focus can silence them, and they don't ring like the iOS Clock.")
                }
            }
            .listStyle(.plain)
            .overlay {
                if store.alarms.isEmpty {
                    ContentUnavailableView("No Alarms", systemImage: "alarm", description: Text("Tap + to add one."))
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let next = calendar.date(byAdding: .hour, value: 1, to: .now) ?? .now
                    editing = ClockAlarm(
                        hour: calendar.component(.hour, from: next),
                        minute: 0
                    )
                } label: { Image(systemName: "plus") }
                    .accessibilityLabel("Add alarm")
            }
        }
        .sheet(item: $editing) { alarm in
            AlarmEditor(store: store, alarm: alarm, isNew: !store.alarms.contains { $0.id == alarm.id })
        }
    }

    private func timeText(_ alarm: ClockAlarm) -> String {
        let date = calendar.date(from: DateComponents(hour: alarm.hour, minute: alarm.minute)) ?? .now
        return date.formatted(date: .omitted, time: .shortened)
    }

    private func row(_ alarm: ClockAlarm) -> some View {
        HStack {
            Button {
                editing = alarm
            } label: {
                VStack(alignment: .leading) {
                    Text(timeText(alarm))
                        .font(.largeTitle.weight(.light))
                    Text([alarm.label, alarm.repeatSummary(in: calendar)].filter { !$0.isEmpty }.joined(separator: " · "))
                        .font(.caption)
                }
                .foregroundStyle(alarm.isOn ? .primary : .secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Toggle(timeText(alarm), isOn: Binding(
                get: { alarm.isOn },
                set: { store.setAlarm(alarm.id, isOn: $0) }
            ))
            .labelsHidden()
        }
    }
}

private struct AlarmEditor: View {
    @ObservedObject var store: ClockStore
    @Environment(\.dismiss) private var dismiss
    @State private var alarm: ClockAlarm
    @State private var time: Date
    let isNew: Bool
    private let calendar = Calendar.current

    init(store: ClockStore, alarm: ClockAlarm, isNew: Bool) {
        self.store = store
        self.isNew = isNew
        _alarm = State(initialValue: alarm)
        _time = State(initialValue: Calendar.current.date(from: DateComponents(hour: alarm.hour, minute: alarm.minute)) ?? .now)
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)

                Section("Repeat") {
                    ForEach(orderedWeekdays, id: \.self) { weekday in
                        Button {
                            if alarm.weekdays.contains(weekday) {
                                alarm.weekdays.remove(weekday)
                            } else {
                                alarm.weekdays.insert(weekday)
                            }
                        } label: {
                            HStack {
                                Text(calendar.weekdaySymbols[weekday - 1])
                                Spacer()
                                if alarm.weekdays.contains(weekday) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                        .accessibilityAddTraits(alarm.weekdays.contains(weekday) ? .isSelected : [])
                    }
                }

                Section("Label") {
                    TextField("Alarm", text: $alarm.label)
                }

                if !isNew {
                    Section {
                        Button("Delete Alarm", role: .destructive) {
                            store.delete(alarmID: alarm.id)
                            dismiss()
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(isNew ? "Add Alarm" : "Edit Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        alarm.hour = calendar.component(.hour, from: time)
                        alarm.minute = calendar.component(.minute, from: time)
                        alarm.isOn = true
                        store.save(alarm: alarm)
                        dismiss()
                    }
                }
            }
        }
    }

    private var orderedWeekdays: [Int] {
        (0..<7).map { (calendar.firstWeekday - 1 + $0) % 7 + 1 }
    }
}

// MARK: Stopwatch

private struct StopwatchTab: View {
    @ObservedObject var store: ClockStore

    var body: some View {
        VStack(spacing: 20) {
            TimelineView(.animation(minimumInterval: 1.0 / 30, paused: !store.stopwatch.isRunning)) { context in
                Text(ClockFormat.stopwatch(store.stopwatch.elapsed(at: context.date)))
                    .font(.system(size: 64, weight: .thin))
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .accessibilityLabel("Elapsed time")
            }

            HStack {
                Button {
                    if store.stopwatch.isRunning {
                        store.lapStopwatch()
                    } else {
                        store.resetStopwatch()
                    }
                } label: {
                    roundLabel(store.stopwatch.isRunning || !store.stopwatch.hasStarted ? "Lap" : "Reset", color: .gray)
                }
                .disabled(!store.stopwatch.hasStarted)

                Spacer()

                Button {
                    if store.stopwatch.isRunning {
                        store.stopStopwatch()
                    } else {
                        store.startStopwatch()
                    }
                } label: {
                    roundLabel(store.stopwatch.isRunning ? "Stop" : "Start", color: store.stopwatch.isRunning ? .red : .green)
                }
            }
            .padding(.horizontal, 28)

            List {
                ForEach(Array(store.stopwatch.laps.enumerated()), id: \.offset) { index, lap in
                    HStack {
                        Text("Lap \(store.stopwatch.laps.count - index)")
                        Spacer()
                        Text(ClockFormat.stopwatch(lap))
                            .monospacedDigit()
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    private func roundLabel(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.headline)
            .frame(width: 86, height: 86)
            .background(color.opacity(0.2), in: Circle())
            .foregroundStyle(color)
    }
}

// MARK: Timer

private struct TimerTab: View {
    @ObservedObject var store: ClockStore
    @EnvironmentObject private var system: IndicaSystem

    private var isIdle: Bool { store.timer.state == .idle }
    private var isRunning: Bool {
        if case .running = store.timer.state { return true }
        return false
    }

    var body: some View {
        VStack(spacing: 24) {
            NotificationPermissionNote(
                status: store.notifications,
                message: "Notifications are off for Swift UI, so the timer can only tell you it's done while it's on screen."
            )

            Spacer()

            TimelineView(.periodic(from: .now, by: 0.25)) { context in
                Text(displayText(at: context.date))
                    .font(.system(size: 78, weight: .thin))
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .onChange(of: context.date) { _, now in store.checkTimer(at: now) }
            }
            .accessibilityLabel("Time remaining")

            if store.timerJustFinished {
                Label("Timer done", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
            }

            if isIdle {
                Slider(value: $store.timerMinutes, in: 1...120, step: 1) {
                    Text("Minutes")
                } onEditingChanged: { _ in
                    store.timerJustFinished = false
                }
                .padding(.horizontal, 32)
                Text("\(Int(store.timerMinutes)) minute\(Int(store.timerMinutes) == 1 ? "" : "s")")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Button {
                    store.cancelTimer()
                } label: {
                    roundLabel("Cancel", color: .gray)
                }
                .disabled(isIdle)

                Spacer()

                Button {
                    switch store.timer.state {
                    case .idle: store.startTimer()
                    case .running: store.pauseTimer()
                    case .paused: store.resumeTimer()
                    }
                } label: {
                    roundLabel(
                        isIdle ? "Start" : (isRunning ? "Pause" : "Resume"),
                        color: isRunning ? .orange : .green
                    )
                }
            }
            .padding(.horizontal, 28)

            Spacer()
        }
        .onChange(of: store.timerJustFinished) { _, finished in
            if finished { HapticEngine.play(.success, enabled: system.hapticsEnabled) }
        }
    }

    private func displayText(at now: Date) -> String {
        if isIdle { return ClockFormat.countdown(store.timerMinutes * 60) }
        return ClockFormat.countdown(store.timer.remaining(at: now))
    }

    private func roundLabel(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.headline)
            .frame(width: 86, height: 86)
            .background(color.opacity(0.2), in: Circle())
            .foregroundStyle(color)
    }
}
