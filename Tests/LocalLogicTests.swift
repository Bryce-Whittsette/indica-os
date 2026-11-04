import Foundation

@main
enum LocalLogicTests {
    static func calendar(_ zone: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: zone)!
        return calendar
    }

    static func date(_ calendar: Calendar, _ y: Int, _ m: Int, _ d: Int, _ h: Int = 0, _ min: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: y, month: m, day: d, hour: h, minute: min))!
    }

    static func main() {
        let ny = calendar("America/New_York")
        let tokyo = calendar("Asia/Tokyo")

        // A timed event moves with the zone: 10 PM Nov 3 in New York is Nov 4 in Tokyo.
        let late = CalendarEvent(title: "Late", start: date(ny, 2026, 11, 3, 22), end: date(ny, 2026, 11, 3, 23))
        precondition(late.occurs(on: date(ny, 2026, 11, 3), in: ny))
        precondition(!late.occurs(on: date(ny, 2026, 11, 4), in: ny))
        precondition(late.occurs(on: date(tokyo, 2026, 11, 4), in: tokyo))
        precondition(!late.occurs(on: date(tokyo, 2026, 11, 3), in: tokyo))

        // An all-day event stays on its date in every zone.
        let value = CalendarEvent.allDayValue(for: date(ny, 2026, 11, 3, 15), in: ny)
        let holiday = CalendarEvent(title: "Day", start: value, end: value, isAllDay: true)
        for zone in [ny, tokyo, calendar("Pacific/Kiritimati"), calendar("Pacific/Pago_Pago")] {
            precondition(holiday.occurs(on: date(zone, 2026, 11, 3, 12), in: zone), "\(zone.timeZone)")
            precondition(!holiday.occurs(on: date(zone, 2026, 11, 2, 12), in: zone), "\(zone.timeZone)")
            precondition(!holiday.occurs(on: date(zone, 2026, 11, 4, 12), in: zone), "\(zone.timeZone)")
        }

        // Multi-day events cover each day and end cleanly; an event ending at midnight
        // doesn't spill into the next day.
        let trip = CalendarEvent(title: "Trip", start: date(ny, 2026, 11, 3, 20), end: date(ny, 2026, 11, 5, 8))
        precondition(trip.occurs(on: date(ny, 2026, 11, 4), in: ny))
        precondition(trip.occurs(on: date(ny, 2026, 11, 5), in: ny))
        precondition(!trip.occurs(on: date(ny, 2026, 11, 6), in: ny))
        let toMidnight = CalendarEvent(title: "M", start: date(ny, 2026, 11, 3, 22), end: date(ny, 2026, 11, 4))
        precondition(!toMidnight.occurs(on: date(ny, 2026, 11, 4), in: ny))
        let instant = CalendarEvent(title: "I", start: date(ny, 2026, 11, 3, 9), end: date(ny, 2026, 11, 3, 9))
        precondition(instant.occurs(on: date(ny, 2026, 11, 3), in: ny))

        // A day that isn't 24 hours long: US clocks change on Nov 1, 2026.
        let dstLate = CalendarEvent(title: "DST", start: date(ny, 2026, 11, 1, 23), end: date(ny, 2026, 11, 1, 23, 30))
        precondition(dstLate.occurs(on: date(ny, 2026, 11, 1), in: ny))
        precondition(!dstLate.occurs(on: date(ny, 2026, 11, 2), in: ny))

        // All-day first, then by time. Next skips what's over and includes what's happening.
        let morning = CalendarEvent(title: "Morning", start: date(ny, 2026, 11, 3, 9), end: date(ny, 2026, 11, 3, 10))
        let ordered = CalendarEvent.ordered([late, morning, holiday], in: ny)
        precondition(ordered.map(\.title) == ["Day", "Morning", "Late"])
        let now = date(ny, 2026, 11, 3, 9, 30)
        precondition(CalendarEvent.next(in: [late, morning], after: now, calendar: ny)?.title == "Morning")
        precondition(CalendarEvent.next(in: [late, morning], after: date(ny, 2026, 11, 3, 11), calendar: ny)?.title == "Late")
        precondition(CalendarEvent.next(in: [morning], after: date(ny, 2026, 11, 3, 11), calendar: ny) == nil)

        // The timer runs from a deadline, including time spent away from the app.
        let t0 = date(ny, 2026, 11, 3, 12)
        var timer = CountdownTimer()
        timer.start(duration: 300, at: t0)
        precondition(timer.remaining(at: t0.addingTimeInterval(100)) == 200)
        timer.pause(at: t0.addingTimeInterval(100))
        precondition(timer.remaining(at: t0.addingTimeInterval(5000)) == 200)
        timer.resume(at: t0.addingTimeInterval(5000))
        precondition(timer.remaining(at: t0.addingTimeInterval(5050)) == 150)
        precondition(!timer.hasFinished(at: t0.addingTimeInterval(5199)))
        precondition(timer.hasFinished(at: t0.addingTimeInterval(5200)))
        precondition(timer.remaining(at: t0.addingTimeInterval(9000)) == 0)
        timer.cancel()
        precondition(timer.state == .idle && !timer.hasFinished(at: t0))

        // It survives a relaunch: state round-trips through storage.
        var saved = CountdownTimer()
        saved.start(duration: 60, at: t0)
        let restored = try! JSONDecoder().decode(CountdownTimer.self, from: JSONEncoder().encode(saved))
        precondition(restored == saved)

        // Stopwatch elapsed and laps.
        var watch = Stopwatch()
        watch.start(at: t0)
        precondition(watch.elapsed(at: t0.addingTimeInterval(10)) == 10)
        watch.lap(at: t0.addingTimeInterval(10))
        watch.lap(at: t0.addingTimeInterval(25))
        precondition(watch.laps == [15, 10])
        watch.stop(at: t0.addingTimeInterval(30))
        precondition(watch.elapsed(at: t0.addingTimeInterval(999)) == 30)
        precondition(watch.currentLap(at: t0.addingTimeInterval(999)) == 5)
        watch.lap(at: t0.addingTimeInterval(999))
        precondition(watch.laps.count == 2, "a stopped watch doesn't lap")
        watch.start(at: t0.addingTimeInterval(100))
        precondition(watch.elapsed(at: t0.addingTimeInterval(110)) == 40)
        let restoredWatch = try! JSONDecoder().decode(Stopwatch.self, from: JSONEncoder().encode(watch))
        precondition(restoredWatch == watch)
        watch.reset()
        precondition(watch == Stopwatch() && !watch.hasStarted)

        // Alarms find their next time.
        let wednesday = date(ny, 2026, 11, 4, 8)
        let once = ClockAlarm(hour: 7, minute: 30)
        precondition(once.nextFire(after: wednesday, calendar: ny) == date(ny, 2026, 11, 5, 7, 30))
        let later = ClockAlarm(hour: 9, minute: 0)
        precondition(later.nextFire(after: wednesday, calendar: ny) == date(ny, 2026, 11, 4, 9))
        let weekdays = ClockAlarm(hour: 7, minute: 0, weekdays: [2, 3, 4, 5, 6])
        let friday = date(ny, 2026, 11, 6, 8)
        precondition(weekdays.nextFire(after: friday, calendar: ny) == date(ny, 2026, 11, 9, 7), "skips the weekend")
        precondition(weekdays.repeatSummary(in: ny) == "Weekdays")
        precondition(ClockAlarm(hour: 1, minute: 0, weekdays: [1, 7]).repeatSummary(in: ny) == "Weekends")
        precondition(ClockAlarm(hour: 1, minute: 0).repeatSummary(in: ny) == "Once")

        // Formats.
        precondition(ClockFormat.countdown(300) == "05:00")
        precondition(ClockFormat.countdown(0.2) == "00:01")
        precondition(ClockFormat.countdown(3725) == "1:02:05")
        precondition(ClockFormat.stopwatch(65.325) == "01:05.32")

        // World clock offsets, including half-hour zones, date changes and daylight saving.
        let reference = TimeZone(identifier: "America/New_York")!
        let noon = date(ny, 2026, 11, 3, 12)
        let offset = { (zone: String, at: Date) in
            ClockFormat.worldClockOffset(zone: TimeZone(identifier: zone)!, reference: reference, at: at)
        }
        precondition(offset("America/New_York", noon) == "Today, same time")
        precondition(offset("Europe/London", noon) == "Today, +5HRS")
        precondition(offset("Asia/Tokyo", noon) == "Tomorrow, +14HRS", offset("Asia/Tokyo", noon))
        precondition(offset("America/Chicago", noon) == "Today, -1HR")
        precondition(offset("Asia/Kolkata", noon) == "Today, +10:30HRS")
        precondition(offset("Pacific/Pago_Pago", date(ny, 2026, 11, 3, 1)) == "Yesterday, -6HRS")
        precondition(offset("Asia/Tokyo", date(ny, 2026, 7, 3, 12)) == "Tomorrow, +13HRS", "summer time changes the gap")
        precondition(ClockFormat.cityName(for: "America/New_York") == "New York")

        // Each city shows its own time, not the device's.
        let enGB = Locale(identifier: "en_GB")
        precondition(ClockFormat.time(noon, in: reference, locale: enGB) == "12:00")
        precondition(ClockFormat.time(noon, in: TimeZone(identifier: "Europe/London")!, locale: enGB) == "17:00")
        precondition(ClockFormat.time(noon, in: TimeZone(identifier: "Asia/Tokyo")!, locale: enGB) == "2:00")

        print("Local logic checks passed")
    }
}
