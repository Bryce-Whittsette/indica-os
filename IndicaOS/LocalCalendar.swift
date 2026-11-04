import SwiftUI

/// A month view with events saved on this device. It doesn't read or write the
/// iOS Calendar, and it says so.
struct CalendarApp: View {
    @EnvironmentObject private var system: IndicaSystem
    private let calendar = Calendar.current
    @State private var selectedDate = Calendar.current.startOfDay(for: .now)
    @State private var displayedMonth = Calendar.current.dateInterval(of: .month, for: .now)?.start ?? .now
    @State private var editing: EventDraft?

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
                VStack(spacing: 18) {
                    HStack {
                        ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, day in
                            Text(day)
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                        ForEach(Array(monthCells.enumerated()), id: \.offset) { _, cell in
                            if let date = cell {
                                dayCell(date)
                            } else {
                                Color.clear.frame(height: 42)
                            }
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text(selectedDate.formatted(.dateTime.month(.wide).day()))
                            .font(.title2.bold())

                        let dayEvents = eventsOnSelectedDate
                        if dayEvents.isEmpty {
                            ContentUnavailableView(
                                "No Events",
                                systemImage: "calendar.badge.plus",
                                description: Text("Tap + to add one.")
                            )
                            .frame(height: 180)
                        } else {
                            ForEach(dayEvents) { event in
                                eventRow(event)
                            }
                        }

                        Text("Events are saved on this iPhone. They aren't synced with the iOS Calendar.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
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
            .sheet(item: $editing) { draft in
                EventEditor(draft: draft, calendar: calendar)
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let hasEvent = hasEvents(on: date)
        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.callout.weight(isSelected || isToday ? .bold : .medium))
                    .frame(width: 34, height: 34)
                    .background(isSelected ? .red : .clear, in: Circle())
                    .foregroundStyle(isSelected ? .white : (isToday ? .red : .primary))
                Circle()
                    .fill(hasEvent ? Color.red : .clear)
                    .frame(width: 4, height: 4)
            }
            .frame(minWidth: 44, minHeight: 44)
        }
        .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
        .accessibilityValue(hasEvent ? "Has events" : "")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func eventRow(_ event: CalendarEvent) -> some View {
        Button {
            editing = EventDraft(event: event, calendar: calendar)
        } label: {
            HStack(spacing: 12) {
                Capsule()
                    .fill(.red)
                    .frame(width: 4, height: 45)
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.subheadline.weight(.semibold))
                        .multilineTextAlignment(.leading)
                    Text(timeText(for: event))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(12)
            .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func timeText(for event: CalendarEvent) -> String {
        guard !event.isAllDay else { return "All day" }
        let start = event.start.formatted(date: .omitted, time: .shortened)
        let end = event.end.formatted(date: .omitted, time: .shortened)
        if calendar.isDate(event.start, inSameDayAs: event.end) {
            return "\(start) – \(end)"
        }
        return "\(event.start.formatted(date: .abbreviated, time: .shortened)) – \(event.end.formatted(date: .abbreviated, time: .shortened))"
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
