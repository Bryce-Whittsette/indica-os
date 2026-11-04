import SwiftUI

/// A month view with events saved on this device. It doesn't read or write the
/// iOS Calendar, and it says so.
struct CalendarApp: View {
    @EnvironmentObject private var system: IndicaSystem
    private let calendar = Calendar.current
    @State private var selectedDate = Calendar.current.startOfDay(for: .now)
    @State private var displayedMonth = Calendar.current.dateInterval(of: .month, for: .now)?.start ?? .now
    @State private var editing: EventDraft?
    @ScaledMetric(relativeTo: .subheadline) private var dayCellHeight: CGFloat = 48
    @ScaledMetric(relativeTo: .footnote) private var timeColumnWidth: CGFloat = 76

    /// Scales with text, but stays a comfortable target and doesn't dwarf the capped numerals.
    private var cellHeight: CGFloat { min(max(dayCellHeight, 44), 72) }

    /// Weekday symbols ordered from the locale's first weekday.
    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let first = calendar.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }

    /// Leading blanks (nil) followed by each day of the displayed month.
    private var monthCells: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        let weekday = calendar.component(.weekday, from: displayedMonth)
        let leading = (weekday - calendar.firstWeekday + 7) % 7
        let days = range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: displayedMonth) }
        return Array(repeating: nil, count: leading) + days
    }

    private var eventsOnSelectedDate: [CalendarEvent] {
        CalendarEvent.ordered(
            system.calendarEvents.filter { $0.occurs(on: selectedDate, in: calendar) },
            in: calendar
        )
    }

    private func hasEvents(on date: Date) -> Bool {
        system.calendarEvents.contains { $0.occurs(on: date, in: calendar) }
    }

    private func moveMonth(by value: Int) {
        if let month = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = month
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    InstrumentRule()

                    HStack(spacing: 0) {
                        ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, day in
                            Text(day)
                                .font(Instrument.mono(.caption2))
                                .foregroundStyle(Instrument.inkSecondary)
                                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                        ForEach(Array(monthCells.enumerated()), id: \.offset) { _, cell in
                            if let date = cell {
                                dayCell(date)
                            } else {
                                // Blank cells keep the rule running to the start of the row.
                                VStack(spacing: 0) {
                                    InstrumentRule(color: Instrument.rule)
                                    Spacer(minLength: 0)
                                }
                                .frame(minHeight: cellHeight)
                                .accessibilityHidden(true)
                            }
                        }
                    }

                    selectedDaySection
                        .padding(.top, 24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Instrument.surface)
            .navigationTitle(displayedMonth.formatted(.dateTime.month(.wide).year()))
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button { moveMonth(by: -1) } label: { Image(systemName: "chevron.left") }
                        .accessibilityLabel("Previous month")
                    Button { moveMonth(by: 1) } label: { Image(systemName: "chevron.right") }
                        .accessibilityLabel("Next month")
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Today") {
                        selectedDate = calendar.startOfDay(for: .now)
                        displayedMonth = calendar.dateInterval(of: .month, for: .now)?.start ?? .now
                    }
                    Button {
                        editing = EventDraft(day: selectedDate, calendar: calendar)
                    } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Add event")
                }
            }
            // Signal marks what's current, so plain controls here stay ink. The editor
            // sheet keeps the accent: an ink Toggle loses its white knob in dark.
            .tint(Instrument.ink)
            .sheet(item: $editing) { draft in
                EventEditor(draft: draft, calendar: calendar)
                    .tint(Instrument.signalText)
            }
        }
    }

    private var selectedDaySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(selectedDate.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)).uppercased())
                .font(Instrument.mono(.caption2))
                .foregroundStyle(Instrument.inkSecondary)
                .padding(.bottom, 8)
                .accessibilityAddTraits(.isHeader)

            InstrumentRule()

            let dayEvents = eventsOnSelectedDate
            if dayEvents.isEmpty {
                Text("Nothing on this day. Tap + to add an event.")
                    .font(.subheadline)
                    .foregroundStyle(Instrument.inkSecondary)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .padding(.vertical, 8)
                InstrumentRule(color: Instrument.rule)
            } else {
                ForEach(dayEvents) { event in
                    eventRow(event)
                    InstrumentRule(color: Instrument.rule)
                }
            }

            Text("Saved on this iPhone. Not synced with the iOS Calendar.")
                .font(.footnote)
                .foregroundStyle(Instrument.inkSecondary)
                .padding(.top, 14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func dayCell(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let hasEvent = hasEvents(on: date)
        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 3) {
                Text("\(calendar.component(.day, from: date))")
                    .font(Instrument.mono(.subheadline, weight: isToday ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Instrument.surface : (isToday ? Instrument.signalText : Instrument.ink))
                    // Seven columns can't hold larger two-digit days without running together.
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                // A short mark under a day with events.
                (isSelected ? Instrument.surface : Instrument.ink)
                    .frame(width: 10, height: 2)
                    .opacity(hasEvent ? 1 : 0)
            }
            .frame(maxWidth: .infinity, minHeight: cellHeight)
            .background(isSelected ? Instrument.ink : .clear)
            // The selected day is a solid block with a signal underline.
            .overlay(alignment: .bottom) {
                if isSelected {
                    Instrument.signal.frame(height: 3)
                }
            }
            .overlay(alignment: .top) {
                InstrumentRule(color: isSelected ? Instrument.ink : Instrument.rule)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
        .accessibilityValue([isToday ? "Today" : nil, hasEvent ? "Has events" : nil].compactMap { $0 }.joined(separator: ", "))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func eventRow(_ event: CalendarEvent) -> some View {
        Button {
            editing = EventDraft(event: event, calendar: calendar)
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(leadingTime(for: event))
                    .font(Instrument.mono(.footnote))
                    .foregroundStyle(Instrument.signalText)
                    .frame(width: timeColumnWidth, alignment: .leading)
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundStyle(Instrument.ink)
                        .multilineTextAlignment(.leading)
                    if let detail = untilText(for: event) {
                        Text(detail)
                            .font(.footnote)
                            .foregroundStyle(Instrument.inkSecondary)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 14)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func leadingTime(for event: CalendarEvent) -> String {
        if event.isAllDay { return "All day" }
        // On a later day of a multi-day event, a bare time would read as today's.
        if !calendar.isDate(event.start, inSameDayAs: selectedDate) {
            return event.start.formatted(.dateTime.month(.abbreviated).day())
        }
        return event.start.formatted(date: .omitted, time: .shortened)
    }

    /// When it ends, for an event with a time. All-day events only need this across days.
    private func untilText(for event: CalendarEvent) -> String? {
        if event.isAllDay {
            let interval = event.localInterval(in: calendar)
            let last = calendar.date(byAdding: .day, value: -1, to: interval.end) ?? interval.start
            guard !calendar.isDate(interval.start, inSameDayAs: last) else { return nil }
            return "Until \(last.formatted(.dateTime.month(.abbreviated).day()))"
        }
        if calendar.isDate(event.start, inSameDayAs: event.end) {
            return "Until \(event.end.formatted(date: .omitted, time: .shortened))"
        }
        return "Until \(event.end.formatted(date: .abbreviated, time: .shortened))"
    }
}

/// An event being created or edited. Dates here are always local ones, for the
/// pickers; all-day dates convert to their stored form on save.
private struct EventDraft: Identifiable {
    let id = UUID()
    let existingID: UUID?
    var title: String
    var start: Date
    var end: Date
    var isAllDay: Bool

    init(day: Date, calendar: Calendar) {
        existingID = nil
        title = ""
        isAllDay = false
        // The next whole hour, on the selected day.
        let hour = calendar.component(.hour, from: .now) + 1
        start = calendar.date(bySettingHour: min(hour, 23), minute: 0, second: 0, of: day) ?? day
        end = calendar.date(byAdding: .hour, value: 1, to: start) ?? start
    }

    init(event: CalendarEvent, calendar: Calendar) {
        existingID = event.id
        title = event.title
        isAllDay = event.isAllDay
        if event.isAllDay {
            start = CalendarEvent.localDate(forAllDayValue: event.start, in: calendar)
            end = CalendarEvent.localDate(forAllDayValue: event.end, in: calendar)
        } else {
            start = event.start
            end = event.end
        }
    }

    func event(in calendar: Calendar) -> CalendarEvent {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if isAllDay {
            return CalendarEvent(
                id: existingID ?? UUID(),
                title: trimmed,
                start: CalendarEvent.allDayValue(for: start, in: calendar),
                end: CalendarEvent.allDayValue(for: end, in: calendar),
                isAllDay: true
            )
        }
        return CalendarEvent(id: existingID ?? UUID(), title: trimmed, start: start, end: end)
    }
}

private struct EventEditor: View {
    @EnvironmentObject private var system: IndicaSystem
    @Environment(\.dismiss) private var dismiss
    @State private var draft: EventDraft
    @State private var confirmingDelete = false
    @FocusState private var isTitleFocused: Bool
    let calendar: Calendar

    init(draft: EventDraft, calendar: Calendar) {
        _draft = State(initialValue: draft)
        self.calendar = calendar
    }

    private var canSave: Bool {
        !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !endsBeforeStart
    }

    private var endsBeforeStart: Bool {
        draft.isAllDay
            ? calendar.startOfDay(for: draft.end) < calendar.startOfDay(for: draft.start)
            : draft.end < draft.start
    }

    private var components: DatePickerComponents {
        draft.isAllDay ? .date : [.date, .hourAndMinute]
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $draft.title)
                        .focused($isTitleFocused)
                }
                Section {
                    Toggle("All-day", isOn: $draft.isAllDay)
                    DatePicker("Starts", selection: $draft.start, displayedComponents: components)
                    DatePicker("Ends", selection: $draft.end, displayedComponents: components)
                } footer: {
                    if endsBeforeStart {
                        Text("The end can't be before the start.")
                            .foregroundStyle(.red)
                    }
                }
                if draft.existingID != nil {
                    Section {
                        Button("Delete Event", role: .destructive) { confirmingDelete = true }
                        .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(draft.existingID == nil ? "New Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(draft.existingID == nil ? "Add" : "Done") { save() }
                        .disabled(!canSave)
                }
            }
            .onChange(of: draft.start) { oldStart, newStart in
                // Moving the start keeps the event's length, as iOS does.
                guard draft.end >= oldStart else { return }
                if draft.isAllDay {
                    // By calendar days: a day isn't always 24 hours long.
                    let days = calendar.dateComponents(
                        [.day],
                        from: calendar.startOfDay(for: oldStart),
                        to: calendar.startOfDay(for: draft.end)
                    ).day ?? 0
                    draft.end = calendar.date(byAdding: .day, value: days, to: newStart) ?? newStart
                    return
                }
                draft.end = newStart.addingTimeInterval(draft.end.timeIntervalSince(oldStart))
            }
            .confirmationDialog("Delete this event?", isPresented: $confirmingDelete, titleVisibility: .visible) {
                Button("Delete Event", role: .destructive) {
                    system.calendarEvents.removeAll { $0.id == draft.existingID }
                    dismiss()
                }
            }
            .onAppear {
                if draft.existingID == nil { isTitleFocused = true }
            }
        }
    }

    private func save() {
        let event = draft.event(in: calendar)
        if let index = system.calendarEvents.firstIndex(where: { $0.id == event.id }) {
            system.calendarEvents[index] = event
        } else {
            system.calendarEvents.append(event)
        }
        dismiss()
    }
}
