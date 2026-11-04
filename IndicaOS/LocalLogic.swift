import Foundation

/// Rules for the local Calendar and Clock apps, with no UI dependencies so
/// `Tests/LocalLogicTests.swift` can run them directly.

/// A calendar event saved on this device. A timed event is a moment in time, so it
/// moves with the time zone. An all-day event is a calendar date, so it stays on
/// that date wherever the device is: its dates are stored as UTC midnights and only
/// their year, month and day are ever read.
struct CalendarEvent: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var start: Date
    var end: Date
    var isAllDay: Bool

    init(id: UUID = UUID(), title: String, start: Date, end: Date, isAllDay: Bool = false) {
        self.id = id
        self.title = title
        self.start = start
        self.end = end
        self.isAllDay = isAllDay
    }

    private static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    /// The stored form of a date picked for an all-day event.
    static func allDayValue(for localDate: Date, in calendar: Calendar) -> Date {
        let parts = calendar.dateComponents([.year, .month, .day], from: localDate)
        return utc.date(from: DateComponents(year: parts.year, month: parts.month, day: parts.day)) ?? localDate
    }

    /// Midnight in `calendar` on the date an all-day value stands for.
    static func localDate(forAllDayValue value: Date, in calendar: Calendar) -> Date {
        let parts = utc.dateComponents([.year, .month, .day], from: value)
        return calendar.date(from: DateComponents(year: parts.year, month: parts.month, day: parts.day)) ?? value
    }

    /// When the event starts and ends, in `calendar`'s time zone. An all-day event
    /// ends at the midnight after its last date.
    func localInterval(in calendar: Calendar) -> (start: Date, end: Date) {
        guard isAllDay else { return (start, end) }
        let first = Self.localDate(forAllDayValue: start, in: calendar)
        let last = Self.localDate(forAllDayValue: end, in: calendar)
        return (first, calendar.date(byAdding: .day, value: 1, to: last) ?? last)
    }

    func occurs(on day: Date, in calendar: Calendar) -> Bool {
        let dayStart = calendar.startOfDay(for: day)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return false }
        let interval = localInterval(in: calendar)
        // A zero-length event still falls on the day it's at.
        if interval.start == interval.end { return interval.start >= dayStart && interval.start < dayEnd }
        return interval.start < dayEnd && interval.end > dayStart
    }

    /// All-day events first, then by start time.
    static func ordered(_ events: [CalendarEvent], in calendar: Calendar) -> [CalendarEvent] {
        events.sorted { first, second in
            if first.isAllDay != second.isAllDay { return first.isAllDay }
            return first.localInterval(in: calendar).start < second.localInterval(in: calendar).start
        }
    }

    /// The event happening now or starting soonest.
    static func next(in events: [CalendarEvent], after now: Date, calendar: Calendar) -> CalendarEvent? {
        events
            .filter { $0.localInterval(in: calendar).end > now }
            .min { $0.localInterval(in: calendar).start < $1.localInterval(in: calendar).start }
    }
}

/// A countdown built on a deadline rather than ticks, so it stays right across
/// switching apps, backgrounding and relaunching.
struct CountdownTimer: Codable, Equatable {
    enum State: Codable, Equatable {
        case idle
        case running(end: Date)
        case paused(remaining: TimeInterval)
    }

    var state = State.idle

    mutating func start(duration: TimeInterval, at now: Date) {
        state = .running(end: now.addingTimeInterval(duration))
    }

    mutating func pause(at now: Date) {
        guard case .running(let end) = state else { return }
        state = .paused(remaining: max(0, end.timeIntervalSince(now)))
    }

    mutating func resume(at now: Date) {
        guard case .paused(let remaining) = state else { return }
        state = .running(end: now.addingTimeInterval(remaining))
    }

    mutating func cancel() {
        state = .idle
    }

    func remaining(at now: Date) -> TimeInterval {
        switch state {
        case .idle: 0
        case .running(let end): max(0, end.timeIntervalSince(now))
        case .paused(let remaining): remaining
        }
    }

    func hasFinished(at now: Date) -> Bool {
        if case .running(let end) = state { return end <= now }
        return false
    }
}

/// Elapsed time from timestamps, for the same reason.
struct Stopwatch: Codable, Equatable {
    var accumulated: TimeInterval = 0
    var runningSince: Date?
    /// Each lap's own length, newest first.
    var laps: [TimeInterval] = []
    private var elapsedAtLastLap: TimeInterval = 0

    var isRunning: Bool { runningSince != nil }
    var hasStarted: Bool { isRunning || accumulated > 0 }

    func elapsed(at now: Date) -> TimeInterval {
        accumulated + (runningSince.map { max(0, now.timeIntervalSince($0)) } ?? 0)
    }

    func currentLap(at now: Date) -> TimeInterval {
        elapsed(at: now) - elapsedAtLastLap
    }

    mutating func start(at now: Date) {
        guard runningSince == nil else { return }
        runningSince = now
    }

    mutating func stop(at now: Date) {
        accumulated = elapsed(at: now)
        runningSince = nil
    }

    mutating func lap(at now: Date) {
        guard isRunning else { return }
        laps.insert(currentLap(at: now), at: 0)
        elapsedAtLastLap = elapsed(at: now)
    }

    mutating func reset() {
        self = Stopwatch()
    }
}

/// An alarm. `weekdays` uses `Calendar`'s numbering, 1 for Sunday; empty means once.
struct ClockAlarm: Identifiable, Codable, Equatable {
    let id: UUID
    var hour: Int
    var minute: Int
    var weekdays: Set<Int>
    var label: String
    var isOn: Bool
    /// When a scheduled one-time alarm goes off, so it can be told apart from one whose
    /// notification couldn't be scheduled. Nil if it's repeating or not scheduled.
    var oneTimeFireDate: Date?

    init(id: UUID = UUID(), hour: Int, minute: Int, weekdays: Set<Int> = [], label: String = "", isOn: Bool = true) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.weekdays = weekdays
        self.label = label
        self.isOn = isOn
    }

    func nextFire(after now: Date, calendar: Calendar) -> Date? {
        let matches: [DateComponents] = weekdays.isEmpty
            ? [DateComponents(hour: hour, minute: minute)]
            : weekdays.map { DateComponents(hour: hour, minute: minute, weekday: $0) }
        return matches
            .compactMap { calendar.nextDate(after: now, matching: $0, matchingPolicy: .nextTime) }
            .min()
    }

    func repeatSummary(in calendar: Calendar) -> String {
        if weekdays.isEmpty { return "Once" }
        if weekdays.count == 7 { return "Every day" }
        if weekdays == [2, 3, 4, 5, 6] { return "Weekdays" }
        if weekdays == [1, 7] { return "Weekends" }
        let first = calendar.firstWeekday
        return weekdays
            .sorted { ($0 - first + 7) % 7 < ($1 - first + 7) % 7 }
            .map { calendar.shortWeekdaySymbols[$0 - 1] }
            .joined(separator: " ")
    }
}

enum ClockFormat {
    /// `05:00`, or `1:05:00` past an hour.
    static func countdown(_ seconds: TimeInterval) -> String {
        // Rounds up, so a timer shows 00:01 until it's really done rather than 00:00 early.
        let total = Int(seconds.rounded(.up))
        let hours = total / 3600
        let minutes = total / 60 % 60
        let remainder = total % 60
        return hours > 0
            ? String(format: "%d:%02d:%02d", hours, minutes, remainder)
            : String(format: "%02d:%02d", minutes, remainder)
    }

    /// `01:05.32`.
    static func stopwatch(_ seconds: TimeInterval) -> String {
        let hundredths = Int((seconds * 100).rounded(.down))
        return String(format: "%02d:%02d.%02d", hundredths / 6000, hundredths / 100 % 60, hundredths % 100)
    }

    /// "Today, +5HRS", or "Today, same time" when the zones agree right now.
    static func worldClockOffset(zone: TimeZone, reference: TimeZone, at now: Date) -> String {
        var here = Calendar(identifier: .gregorian)
        here.timeZone = reference
        var there = Calendar(identifier: .gregorian)
        there.timeZone = zone

        let hereDay = here.dateComponents([.year, .month, .day], from: now)
        let thereDay = there.dateComponents([.year, .month, .day], from: now)
        let hereDate = here.date(from: hereDay) ?? now
        let thereDate = here.date(from: thereDay) ?? now
        let days = here.dateComponents([.day], from: hereDate, to: thereDate).day ?? 0
        let day = days == 0 ? "Today" : (days > 0 ? "Tomorrow" : "Yesterday")

        let seconds = zone.secondsFromGMT(for: now) - reference.secondsFromGMT(for: now)
        guard seconds != 0 else { return "\(day), same time" }
        let sign = seconds > 0 ? "+" : "-"
        let hours = abs(seconds) / 3600
        let minutes = abs(seconds) / 60 % 60
        if minutes > 0 { return "\(day), \(sign)\(hours):\(String(format: "%02d", minutes))HRS" }
        return "\(day), \(sign)\(hours)HR\(hours == 1 ? "" : "S")"
    }

    /// The time in `zone`, as text. Passing a format to `Text(_:format:)` instead would
    /// show the device's time, because SwiftUI applies its own time zone to the format.
    static func time(_ date: Date, in zone: TimeZone, locale: Locale = .autoupdatingCurrent) -> String {
        date.formatted(Date.FormatStyle(date: .omitted, time: .shortened, locale: locale, timeZone: zone))
    }

    /// "America/New_York" becomes "New York".
    static func cityName(for identifier: String) -> String {
        (identifier.split(separator: "/").last.map(String.init) ?? identifier)
            .replacingOccurrences(of: "_", with: " ")
    }
}
