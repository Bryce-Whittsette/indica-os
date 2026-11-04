import AVFoundation
import SwiftUI

/// The real flashlight, on hardware that has one.
@MainActor
enum DeviceTorch {
    /// Kept, since view bodies read this while they track a finger.
    static let isAvailable = AVCaptureDevice.default(for: .video)?.hasTorch == true

    static var isOn: Bool {
        isAvailable && AVCaptureDevice.default(for: .video)?.torchMode == .on
    }

    /// Returns whether the flashlight is on afterward.
    @discardableResult
    static func toggle() -> Bool {
        guard isAvailable, let device = AVCaptureDevice.default(for: .video) else { return false }
        guard (try? device.lockForConfiguration()) != nil else { return device.torchMode == .on }
        device.torchMode = device.torchMode == .on ? .off : .on
        device.unlockForConfiguration()
        return device.torchMode == .on
    }
}

struct SystemShell: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var didStart = false
    // Owned here because HomeScreen is destroyed while an app is open.
    @StateObject private var homePager = HomePager()

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                IndicaWallpaper(style: system.wallpaper)

                phaseContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if let overlay = system.overlay {
                    overlayView(overlay)
                        .accessibilityAction(.escape) {
                            withAnimation(Instrument.motion) { system.overlay = nil }
                        }
                        .zIndex(20)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .environment(\.shellSafeAreaInsets, proxy.safeAreaInsets)
            // Before ignoresSafeArea, so the touch area and the gesture's coordinates
            // are the whole screen. After it, the status bar region gets no touches.
            .contentShape(Rectangle())
            .simultaneousGesture(
                systemGesture(
                    screenSize: CGSize(
                        width: proxy.size.width,
                        height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
                    ),
                    topBand: proxy.safeAreaInsets.top + 20
                )
            )
            .ignoresSafeArea()
            .onAppear {
                guard !didStart else { return }
                didStart = true
                guard system.phase == .booting else { return }
                system.finishBoot()
            }
        }
        .statusBarHidden(true)
        // Every shell state owns top and bottom edge swipes, so the first swipe from
        // those edges reaches the shell. A second reaches iOS, so a deliberate exit
        // still works. See docs/interactions.md.
        .defersSystemGestures(on: .vertical)
        // Asks iOS to fade its home bar when idle, so it doesn't sit under the app bar.
        // iOS decides when; it can stay visible (docs/interactions.md).
        .persistentSystemOverlays(.hidden)
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch system.phase {
        case .booting:
            BootScreen()
                .transition(.opacity.combined(with: .scale(scale: 1.03)))
        case .locked:
            LockScreen()
                .transition(.opacity)
        case .home:
            HomeScreen(pager: homePager)
                .transition(.scale(scale: 0.94).combined(with: .opacity))
        case .app(let app):
            AppHost(app: app)
                .transition(.scale(scale: 0.9, anchor: .center).combined(with: .opacity))
        case .switcher:
            AppSwitcher()
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    @ViewBuilder
    private func overlayView(_ overlay: SystemOverlay) -> some View {
        switch overlay {
        case .controlCenter:
            ControlCenterOverlay()
        case .notifications:
            NotificationCenterOverlay()
        case .wallpaper:
            WallpaperPickerOverlay()
        case .lockCustomization:
            LockCustomizationOverlay()
        }
    }

    private func systemGesture(screenSize size: CGSize, topBand: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                // An open overlay owns its own drags, and a mostly sideways drag is a page swipe.
                guard system.overlay == nil,
                      abs(value.translation.height) > abs(value.translation.width) else { return }
                let startedAtTop = value.startLocation.y < topBand
                let startedAtBottom = value.startLocation.y > size.height - 172

                if startedAtTop, value.translation.height > 70 {
                    withAnimation(Instrument.motion) {
                        system.overlay = value.startLocation.x > size.width * 0.53 ? .controlCenter : .notifications
                    }
                } else if startedAtBottom, value.translation.height < -46 {
                    switch system.phase {
                    case .app, .switcher:
                        // These own upward drags themselves. In the switcher a swipe
                        // up closes a card, and must not leave the switcher too.
                        break
                    case .locked:
                        system.unlock()
                    default:
                        system.goHome()
                    }
                }
            }
    }
}

private struct BootScreen: View {
    var body: some View {
        ZStack {
            Instrument.ground

            VStack(spacing: 18) {
                BrandMark(size: 88)
                BrandWordmark(height: 32)
            }
        }
    }
}

struct IndicaWallpaper: View {
    let style: WallpaperStyle

    var body: some View {
        if style == .instrument {
            // Matte and still: the shell's own ground, in either appearance.
            Instrument.ground
        } else {
            GradientWallpaper(style: style)
        }
    }
}

/// The earlier wallpapers, still offered as a choice. They hold still under Reduce Motion,
/// including when it's turned on while one is showing.
private struct GradientWallpaper: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let style: WallpaperStyle
    @State private var drift = false

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                LinearGradient(
                    colors: style.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Ellipse()
                    .fill(style.colors.last?.opacity(style == .daylight ? 0.48 : 0.34) ?? .clear)
                    .frame(width: size.width * 1.28, height: size.width * 0.72)
                    .blur(radius: 82)
                    .rotationEffect(.degrees(drift ? 18 : -10))
                    .offset(x: drift ? size.width * 0.20 : -size.width * 0.12, y: -size.height * 0.36)

                Ellipse()
                    .fill(style.colors.dropFirst().first?.opacity(style == .daylight ? 0.44 : 0.52) ?? .clear)
                    .frame(width: size.width * 0.90, height: size.width * 1.35)
                    .blur(radius: 92)
                    .rotationEffect(.degrees(drift ? -14 : 13))
                    .offset(x: drift ? -size.width * 0.26 : size.width * 0.18, y: size.height * 0.34)
            }
            .onAppear { updateDrift() }
            .onChange(of: reduceMotion) { _, _ in updateDrift() }
        }
    }

    private func updateDrift() {
        if reduceMotion {
            withTransaction(Transaction(animation: nil)) { drift = false }
        } else {
            withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                drift = true
            }
        }
    }
}

private struct ShellSafeAreaInsetsKey: EnvironmentKey {
    static let defaultValue = EdgeInsets()
}

extension EnvironmentValues {
    /// The device's real safe-area insets, captured before the shell extends
    /// itself edge to edge. Use them to keep content clear of the camera
    /// housing and rounded corners instead of hard-coded offsets. `bottom`
    /// grows to the keyboard height while the keyboard is visible.
    var shellSafeAreaInsets: EdgeInsets {
        get { self[ShellSafeAreaInsetsKey.self] }
        set { self[ShellSafeAreaInsetsKey.self] = newValue }
    }
}

/// Occupies the device's top safe-area region. The camera housing (notch or
/// Dynamic Island) is physical, so the bar leaves its centre empty rather than
/// drawing a second one. Network and battery come from `DeviceStatus`; values
/// the system doesn't provide are left out rather than invented.
struct SystemStatusBar: View {
    @Environment(\.shellSafeAreaInsets) private var safeAreaInsets
    @ObservedObject private var device = DeviceStatus.shared
    var foreground: Color = Instrument.ink

    var body: some View {
        HStack {
            TimelineView(.periodic(from: .now, by: 30)) { context in
                Text(context.date.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)).minute(.twoDigits)))
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
            }

            Spacer()

            HStack(spacing: 5) {
                if let symbol = device.network.symbol {
                    Image(systemName: symbol)
                }
                if let symbol = device.batterySymbol {
                    Image(systemName: symbol)
                }
            }
            .font(.system(size: 12, weight: .semibold))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(device.accessibilitySummary)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 22)
        .frame(height: max(safeAreaInsets.top, 24))
    }
}

private struct LockScreen: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var dragOffset: CGFloat = 0
    @State private var torchOn = false

    var body: some View {
        VStack(spacing: 0) {
            SystemStatusBar(foreground: system.wallpaper.foreground)

            VStack(alignment: .leading, spacing: 2) {
                TimelineView(.periodic(from: .now, by: 60)) { context in
                    Text(context.date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)).uppercased())
                        .font(Instrument.mono(.footnote, weight: .medium))
                        .foregroundStyle(system.wallpaper.secondaryForeground)
                }

                TimelineView(.periodic(from: .now, by: 1)) { context in
                    Text(context.date.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)).minute(.twoDigits)))
                        .font(.system(size: 82, weight: system.lockClockStyle.weight, design: system.lockClockStyle.design))
                        .tracking(system.lockClockStyle == .classic ? -4 : -2)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .contentTransition(.numericText())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 12)

            if system.showLockWidgets {
                LedgerStrip()
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
            }

            Spacer()

            VStack(spacing: 8) {
                ForEach(system.notifications.prefix(2)) { notification in
                    NotificationCard(
                        notification: notification,
                        compact: true,
                        showsPreview: system.showsNotificationPreviews
                    )
                }
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 22)

            HStack {
                LockActionButton(symbol: "flashlight.on.fill", label: "Flashlight", isOn: torchOn) {
                    torchOn = DeviceTorch.toggle()
                }
                    .disabled(!DeviceTorch.isAvailable)
                    .opacity(DeviceTorch.isAvailable ? 1 : 0.4)
                Spacer()
                Text("Swipe up to open")
                    .font(.footnote)
                    .foregroundStyle(system.wallpaper.secondaryForeground)
                Spacer()
                LockActionButton(symbol: "camera", label: "Camera") {
                    system.unlock()
                    Task {
                        try? await Task.sleep(for: .milliseconds(320))
                        system.open(.camera)
                    }
                }
            }
            .padding(.horizontal, 20)
            // Room for the iOS home bar.
            .padding(.bottom, 34)
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .onAppear { torchOn = DeviceTorch.isOn }
        .offset(y: dragOffset)
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    dragOffset = min(0, value.translation.height)
                }
                .onEnded { value in
                    if value.translation.height < -70 {
                        system.unlock()
                    }
                    withAnimation(Instrument.motion) {
                        dragOffset = 0
                    }
                }
        )
        .onLongPressGesture(minimumDuration: 0.55) {
            withAnimation(Instrument.motion) {
                system.overlay = .lockCustomization
            }
        }
        .foregroundStyle(system.wallpaper.foreground)
    }
}

private struct LockActionButton: View {
    let symbol: String
    let label: String
    /// Nil for a button with no on or off state.
    var isOn: Bool?
    let action: () -> Void

    var body: some View {
        let on = isOn == true
        let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(on ? Instrument.surface : Instrument.ink)
                .frame(width: 48, height: 48)
                .background(on ? Instrument.ink : Instrument.surface, in: shape)
                .overlay { shape.strokeBorder(Instrument.edge, lineWidth: Instrument.hairline) }
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(label)
        .accessibilityValue(isOn.map { $0 ? "On" : "Off" } ?? "")
    }
}

private struct HomeScreen: View {
    @EnvironmentObject private var system: IndicaSystem
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @ObservedObject var pager: HomePager
    @State private var isSearching = false

    var body: some View {
        GeometryReader { proxy in
            let metrics = HomeLayoutMetrics(
                size: proxy.size,
                density: system.homeLayoutDensity
            )

            VStack(spacing: 0) {
                SystemStatusBar(foreground: system.wallpaper.foreground)

                HomePagerTrack(
                    motion: pager.motion,
                    pager: pager,
                    pageCount: system.homePages.count,
                    pageWidth: proxy.size.width,
                    onLongPress: toggleEditing
                ) {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(Array(system.homePages.enumerated()), id: \.offset) { pageIndex, apps in
                            VStack(spacing: metrics.sectionSpacing) {
                                if pageIndex == 0 {
                                    LedgerStrip(verticalPadding: metrics.ledgerVerticalPadding)
                                        .padding(.horizontal, metrics.horizontalPadding)
                                } else if pageIndex == 1 {
                                    SearchWidget { openSearchUnlessSwiped() }
                                        .padding(.horizontal, metrics.horizontalPadding)
                                } else {
                                    LibraryHeader(
                                        title: pageIndex == 2 ? "Connections" : "Utilities",
                                        detail: pageIndex == 2 ? "Services you can connect" : "Tools and extras",
                                        verticalPadding: metrics.ledgerVerticalPadding
                                    )
                                        .padding(.horizontal, metrics.horizontalPadding)
                                }

                                LazyVGrid(
                                    columns: Array(
                                        repeating: GridItem(.flexible(), spacing: metrics.columnSpacing),
                                        count: metrics.columnCount
                                    ),
                                    spacing: metrics.rowSpacing
                                ) {
                                    ForEach(apps) { app in
                                        AppIcon(
                                            app: app,
                                            isEditing: system.isEditingHome,
                                            size: metrics.iconSize,
                                            cancelsPress: pager.isSwiping,
                                            onRemove: {
                                                // The release of a swipe isn't a tap here either.
                                                guard !pager.suppressesTap else { return }
                                                removeFromHome(app)
                                            }
                                        ) {
                                            // The release of a swipe or long press isn't a tap.
                                            guard !system.isEditingHome, !pager.suppressesTap else { return }
                                            system.open(app)
                                        }
                                    }
                                }
                                .padding(.horizontal, metrics.horizontalPadding)

                                Spacer(minLength: 2)
                            }
                            .frame(width: proxy.size.width)
                            // Pages off screen stay out of the VoiceOver order.
                            .accessibilityHidden(pageIndex != pager.page)
                        }
                    }
                }

                SearchPagePill(
                    pager: pager,
                    motion: pager.motion,
                    pageCount: system.homePages.count,
                    onSearch: { isSearching = true }
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, metrics.pageIndicatorPadding)
                // Here, not at the top right, where it would cover the ledger.
                .overlay(alignment: .trailing) {
                    if system.isEditingHome {
                        Button {
                            HapticEngine.play(.selection, enabled: system.hapticsEnabled)
                            withAnimation(Instrument.motion) {
                                system.isEditingHome = false
                            }
                        } label: {
                            Text("Done")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Instrument.ink)
                                .padding(.horizontal, 16)
                                .frame(minHeight: 44)
                                .instrumentPanel(cornerRadius: 18)
                                .contentShape(Rectangle())
                        }
                        .padding(.trailing, metrics.horizontalPadding)
                    }
                }

                InstrumentRule(color: system.wallpaper.ruleForeground)
                    .padding(.horizontal, metrics.horizontalPadding)

                // The same columns as the grid, so the dock lines up with the rows above it.
                HStack(spacing: metrics.columnSpacing) {
                    ForEach(system.dockApps) { app in
                        AppIcon(
                            app: app,
                            isEditing: false,
                            size: metrics.iconSize,
                            showsLabel: false,
                            isInDock: true
                        ) {
                            guard !system.isEditingHome else { return }
                            system.open(app)
                        }
                    }
                }
                .padding(.horizontal, metrics.horizontalPadding)
                .padding(.top, metrics.dockVerticalPadding)

                // Room for the iOS home bar. The shell doesn't draw a second one.
                Color.clear
                    .frame(height: metrics.homeBarClearance)
            }
            .onChange(of: pager.page) { _, newPage in
                UIAccessibility.post(
                    notification: .announcement,
                    argument: "Page \(newPage + 1) of \(system.homePages.count)"
                )
            }
            .task(id: system.reduceMotion || systemReduceMotion) {
                pager.reducesMotion = system.reduceMotion || systemReduceMotion
            }
            .onAppear {
                pager.pageCount = system.homePages.count
                pager.homeDidAppear()
            }
            .foregroundStyle(system.wallpaper.foreground)
            // Home is a fixed layout with no scrolling, like the iOS Home Screen.
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
        // Presented outside the wallpaper text color so search uses system colors.
        .sheet(isPresented: $isSearching) {
            AppSearchView()
                .environmentObject(system)
        }
    }

    private func removeFromHome(_ app: BuiltInApp) {
        HapticEngine.play(.selection, enabled: system.hapticsEnabled)
        withAnimation(Instrument.motion) {
            _ = system.hiddenHomeApps.insert(app)
        }
    }

    private func toggleEditing() {
        HapticEngine.play(.rigid, enabled: system.hapticsEnabled)
        withAnimation(Instrument.motion) {
            system.isEditingHome.toggle()
        }
    }

    private func openSearchUnlessSwiped() {
        guard !pager.suppressesTap else { return }
        isSearching = true
    }
}

private struct HomeLayoutMetrics {
    let size: CGSize
    let density: HomeLayoutDensity

    private var compactHeight: Bool { size.height < 860 }

    var columnCount: Int { density == .compact ? 5 : 4 }
    var horizontalPadding: CGFloat { 20 }
    var sectionSpacing: CGFloat { compactHeight ? 12 : 20 }
    var columnSpacing: CGFloat { density == .compact ? 7 : 12 }
    var rowSpacing: CGFloat { density == .compact ? (compactHeight ? 8 : 11) : (compactHeight ? 10 : 16) }
    var iconSize: CGFloat {
        if density == .compact {
            return compactHeight ? 49 : 52
        }
        return compactHeight ? 58 : 62
    }
    var ledgerVerticalPadding: CGFloat { compactHeight ? 8 : 12 }
    var pageIndicatorPadding: CGFloat { compactHeight ? 6 : 10 }
    var dockVerticalPadding: CGFloat { compactHeight ? 8 : 12 }
    var homeBarClearance: CGFloat { compactHeight ? 26 : 30 }
}

/// The ruled strip at the top of Home and the Lock Screen: the real next event, and
/// the labeled sample weather.
struct LedgerStrip: View {
    @EnvironmentObject private var system: IndicaSystem
    var verticalPadding: CGFloat = 12

    /// The real next event, checked again each minute.
    private func upNext(at now: Date) -> (title: String, detail: String, hasEvent: Bool) {
        guard let event = CalendarEvent.next(in: system.calendarEvents, after: now, calendar: .current) else {
            return ("Nothing scheduled", "Calendar", false)
        }
        let start = event.localInterval(in: .current).start
        let detail: String
        if event.isAllDay {
            detail = Calendar.current.isDateInToday(start) ? "All day" : start.formatted(.dateTime.month(.abbreviated).day())
        } else if Calendar.current.isDateInToday(start) {
            detail = start.formatted(date: .omitted, time: .shortened)
        } else {
            detail = start.formatted(.dateTime.month(.abbreviated).day().hour().minute())
        }
        return (event.title, detail, true)
    }

    var body: some View {
        let wallpaper = system.wallpaper
        HStack(spacing: 0) {
            TimelineView(.everyMinute) { context in
                let next = upNext(at: context.date)
                cell(
                    label: "UP NEXT",
                    title: next.title,
                    value: next.detail,
                    valueColor: next.hasEvent ? wallpaper.signalForeground : wallpaper.secondaryForeground
                )
                .padding(.trailing, 12)
            }

            cell(
                label: "SAMPLE WEATHER",
                title: "Brooklyn",
                value: "72°",
                valueColor: wallpaper.foreground
            )
            .padding(.leading, 12)
        }
        .padding(.vertical, verticalPadding)
        .overlay { wallpaper.ruleForeground.frame(width: Instrument.hairline) }
        .overlay(alignment: .top) { InstrumentRule(color: wallpaper.ruleForeground) }
        .overlay(alignment: .bottom) { InstrumentRule(color: wallpaper.ruleForeground) }
        .foregroundStyle(wallpaper.foreground)
    }

    private func cell(label: String, title: String, value: String, valueColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(Instrument.mono(.caption2))
                .foregroundStyle(system.wallpaper.secondaryForeground)
            Text(title)
                .font(.headline)
            Text(value)
                .font(Instrument.mono(.footnote))
                .foregroundStyle(valueColor)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.75)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// The pill under the Home Screen grid. A tap opens search. Holding it, then
/// moving sideways, drives the shared page position: the pages follow the finger
/// continuously, resist past the first and last page, and settle on the nearest
/// page on release. Reversing direction just moves the position back, so nothing
/// queues.
private struct SearchPagePill: View {
    @EnvironmentObject private var system: IndicaSystem
    @ObservedObject var pager: HomePager
    @ObservedObject var motion: HomePagerMotion
    let pageCount: Int
    let onSearch: () -> Void

    private enum Phase {
        case idle, pressing, scrubbing, cancelled
    }

    @State private var phase: Phase = .idle
    @State private var holdTask: Task<Void, Never>?
    @State private var latestTranslation: CGFloat = 0
    /// Resets by itself if the system cancels the touch, when `onEnded` doesn't run.
    @GestureState private var isTouching = false

    private let holdDuration: Duration = .milliseconds(280)
    private let moveTolerance: CGFloat = 10

    var body: some View {
        HStack(spacing: 10) {
            if phase != .scrubbing {
                Image(systemName: "magnifyingglass")
                    .font(.caption)

                Text("Search")
                    .font(.footnote)
            }

            // The ruler: one tick per page. The tick nearest the position grows and
            // takes the signal color, continuously, so it tracks the finger in a scrub.
            HStack(spacing: phase == .scrubbing ? 14 : 7) {
                ForEach(0..<pageCount, id: \.self) { index in
                    let nearness = max(0, 1 - abs(motion.position - CGFloat(index)))
                    ZStack(alignment: .bottom) {
                        Instrument.ink
                            .frame(width: 1, height: 7)
                        Instrument.signal
                            .frame(width: 2, height: 7 + 7 * nearness)
                            .opacity(nearness)
                    }
                    .frame(width: 2, height: 14, alignment: .bottom)
                }
            }
        }
        .foregroundStyle(Instrument.ink)
        .padding(.horizontal, phase == .scrubbing ? 18 : 14)
        .frame(minHeight: 36)
        .instrumentPanel(cornerRadius: 18)
        .scaleEffect(phase == .pressing ? 0.97 : 1)
        .animation(Instrument.press, value: phase)
        .contentShape(Rectangle().inset(by: -10))
        // High priority keeps the hold from also starting Home Screen editing or a page swipe.
        .highPriorityGesture(
            // Global: the pill resizes when scrubbing starts, which would shift local coordinates.
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .updating($isTouching) { _, state, _ in state = true }
                .onChanged(handleChange)
                .onEnded(handleEnd)
        )
        .onChange(of: isTouching) { _, touching in
            if !touching { handleCancel() }
        }
        .onChange(of: pager.page) { _, _ in
            if phase == .scrubbing {
                HapticEngine.play(.selection, enabled: system.hapticsEnabled)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Search")
        .accessibilityValue("Page \(pager.page + 1) of \(pageCount)")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { onSearch() }
        .accessibilityAction(named: "Next page") { pager.go(to: pager.page + 1) }
        .accessibilityAction(named: "Previous page") { pager.go(to: pager.page - 1) }
    }

    private func handleChange(_ value: DragGesture.Value) {
        latestTranslation = value.translation.width
        switch phase {
        case .idle:
            phase = .pressing
            holdTask = Task { @MainActor in
                try? await Task.sleep(for: holdDuration)
                guard !Task.isCancelled, phase == .pressing else { return }
                pager.beginScrub(translation: latestTranslation)
                phase = .scrubbing
                HapticEngine.play(.medium, enabled: system.hapticsEnabled)
            }
            fallthrough
        case .pressing:
            // Moving before the hold completes isn't a tap or a scrub.
            if hypot(value.translation.width, value.translation.height) > moveTolerance {
                holdTask?.cancel()
                phase = .cancelled
            }
        case .scrubbing:
            pager.scrubChanged(translation: value.translation.width)
        case .cancelled:
            break
        }
    }

    private func handleEnd(_ value: DragGesture.Value) {
        holdTask?.cancel()
        switch phase {
        case .pressing:
            HapticEngine.play(.selection, enabled: system.hapticsEnabled)
            onSearch()
        case .scrubbing:
            pager.scrubEnded(velocity: value.velocity.width)
        default:
            break
        }
        phase = .idle
    }

    private func handleCancel() {
        guard phase != .idle else { return }
        holdTask?.cancel()
        if phase == .scrubbing { pager.scrubEnded() }
        phase = .idle
    }
}

private struct SearchWidget: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                Text("Search apps and notes")
                    .font(.subheadline)
                    .foregroundStyle(Instrument.inkSecondary)
                Spacer()
            }
            .foregroundStyle(Instrument.ink)
            .padding(.horizontal, 17)
            .frame(minHeight: 50)
            .contentShape(Rectangle())
            .instrumentPanel(cornerRadius: 14)
        }
        .buttonStyle(PressableButtonStyle(scale: 0.98))
        .accessibilityLabel("Search apps and notes")
    }
}

/// Puts the cursor in the search field when search opens (iOS 18 and later;
/// on iOS 17 the person taps the field).
private struct FocusSearchOnAppear: ViewModifier {
    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .searchFocused($isFocused)
                .onAppear { isFocused = true }
        } else {
            content
        }
    }
}

/// Searches the app catalog and the person's notes. Results open the app.
private struct AppSearchView: View {
    @EnvironmentObject private var system: IndicaSystem
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var matchingApps: [BuiltInApp] {
        let apps = BuiltInApp.allCases.sorted { $0.name < $1.name }
        guard !trimmedQuery.isEmpty else { return apps }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(trimmedQuery) }
    }

    private var matchingNotes: [NoteItem] {
        guard !trimmedQuery.isEmpty else { return [] }
        return system.notes
            .filter {
                $0.title.localizedCaseInsensitiveContains(trimmedQuery)
                    || $0.body.localizedCaseInsensitiveContains(trimmedQuery)
            }
            .sorted { $0.modified > $1.modified }
    }

    var body: some View {
        NavigationStack {
            List {
                if !matchingApps.isEmpty {
                    Section(trimmedQuery.isEmpty ? "All Apps" : "Apps") {
                        ForEach(matchingApps) { app in
                            Button {
                                open(app)
                            } label: {
                                Label(app.name, systemImage: app.symbol)
                            }
                        }
                    }
                }
                if !matchingNotes.isEmpty {
                    Section("Notes") {
                        ForEach(matchingNotes) { note in
                            Button {
                                open(.notes)
                            } label: {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(note.title.isEmpty ? "Untitled" : note.title)
                                        .foregroundStyle(.primary)
                                    Text(note.body)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
            }
            .overlay {
                if matchingApps.isEmpty && matchingNotes.isEmpty {
                    ContentUnavailableView.search(text: trimmedQuery)
                }
            }
            .searchable(
                text: $query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Apps and notes"
            )
            .modifier(FocusSearchOnAppear())
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            // A list of apps isn't "current" or urgent, so it doesn't get the signal color.
            .tint(Instrument.ink)
        }
    }

    private func open(_ app: BuiltInApp) {
        dismiss()
        system.open(app)
    }
}

private struct LibraryHeader: View {
    @EnvironmentObject private var system: IndicaSystem
    let title: String
    let detail: String
    var verticalPadding: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.title3.weight(.semibold))
                .tracking(-0.3)
            Text(detail)
                .font(.footnote)
                .foregroundStyle(system.wallpaper.secondaryForeground)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.75)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, verticalPadding)
        .overlay(alignment: .top) { InstrumentRule(color: system.wallpaper.ruleForeground) }
        .overlay(alignment: .bottom) { InstrumentRule(color: system.wallpaper.ruleForeground) }
    }
}

private struct AppIcon: View {
    @EnvironmentObject private var system: IndicaSystem
    let app: BuiltInApp
    let isEditing: Bool
    var size: CGFloat = 62
    var showsLabel = true
    var isInDock = false
    var cancelsPress = false
    /// Nil for an icon that can't be removed, like one in the dock.
    var onRemove: (() -> Void)?
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @State private var wiggle = false

    private var reducesMotion: Bool { system.reduceMotion || systemReduceMotion }

    private func startWiggle() {
        guard !reducesMotion else { return }
        withAnimation(.easeInOut(duration: 0.13).repeatForever(autoreverses: true)) {
            wiggle = true
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                AppMark(app: app, size: size, isInverted: isInDock, isOnWallpaper: true)

                if showsLabel && system.showAppLabels {
                    Text(app.name)
                        .font(.caption2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .foregroundStyle(system.wallpaper.foreground)
                        // White labels need help where a gradient wallpaper turns light.
                        .shadow(color: system.wallpaper.hasWhiteForeground ? .black.opacity(0.5) : .clear, radius: 3, y: 1)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PressableButtonStyle(cancelsPress: cancelsPress))
        .accessibilityLabel(app.name)
        .accessibilityActions {
            if let onRemove {
                Button("Remove from Home Screen", action: onRemove)
            }
        }
        // Outside the icon's button: a button inside another's label can't be relied on.
        .overlay(alignment: .top) {
            if isEditing, let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "minus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Instrument.surface)
                        .frame(width: 20, height: 20)
                        .background(Instrument.ink, in: Circle())
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .offset(x: -size / 2, y: -22 + 6)
                .accessibilityLabel("Remove \(app.name) from Home Screen")
            }
        }
        .rotationEffect(.degrees(isEditing && !reducesMotion ? (wiggle ? 1.5 : -1.5) : 0))
        // On appear as well: icons rebuilt during editing wouldn't see a change.
        .onAppear { if isEditing { startWiggle() } }
        .onChange(of: isEditing) { _, newValue in
            if newValue {
                startWiggle()
            } else {
                wiggle = false
            }
        }
    }
}

private struct AppHost: View {
    @EnvironmentObject private var system: IndicaSystem
    let app: BuiltInApp

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                BuiltInAppView(app: app)
                    .environmentObject(system)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // A real top inset lets navigation bars extend their
                    // background beneath the status region, as on iOS.
                    .safeAreaInset(edge: .top, spacing: 0) {
                        SystemStatusBar(foreground: .primary)
                    }

                // Its own strip, not an inset: apps with a composer at the bottom ignore
                // insets, and the label covered their controls.
                if app.isConceptDemo {
                    Text("CONCEPT DEMO · SAMPLE DATA")
                        .font(Instrument.mono(.caption2))
                        .foregroundStyle(Instrument.inkSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, minHeight: 24)
                        .background(Instrument.surface)
                        .overlay(alignment: .top) { InstrumentRule(color: Instrument.rule) }
                        .accessibilityLabel("Concept demo. This app shows sample data and simulated results.")
                }

                HybridAppNavigationBar()
            }
        }
        // Keeps row text from taking the accent. It also turns destructive buttons
        // plain, so those that sit in a row set their own red.
        .foregroundStyle(.primary)
    }
}

private struct HybridAppNavigationBar: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var dragLift: CGFloat = 0

    var body: some View {
        HStack(spacing: 0) {
            Button {
                system.goHome()
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 17, weight: .regular))
                    .frame(width: 44, height: 44, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Back to Home")

            Button {
                system.goHome()
            } label: {
                Instrument.ink
                    .frame(width: 134, height: 2)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Home")
            .accessibilityHint("Tap or swipe up to return to the Home Screen")

            Button {
                system.showSwitcher()
            } label: {
                Image("glyph-recents")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 21, height: 21)
                    .frame(width: 44, height: 44, alignment: .trailing)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Recent Apps")
        }
        .buttonStyle(PressableButtonStyle(scale: 0.9))
        .foregroundStyle(Instrument.ink)
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity)
        .background(Instrument.surface)
        .overlay(alignment: .top) { InstrumentRule() }
        .offset(y: dragLift)
        .contentShape(Rectangle())
        .highPriorityGesture(
            DragGesture(minimumDistance: 7)
                .onChanged { value in
                    dragLift = max(-18, min(0, value.translation.height * 0.22))
                }
                .onEnded { value in
                    if value.translation.height < -30 {
                        system.goHome()
                    }
                    withAnimation(Instrument.motion) {
                        dragLift = 0
                    }
                }
        )
    }
}

/// Recent apps. One drag handles both axes: sideways moves through the cards and
/// settles on the nearest one; upward follows the finger on the card under it and
/// closes it past a distance or velocity threshold, otherwise it springs back. The
/// axis is chosen once per drag, so the two can't compete. Closing removes the
/// card only: saved content is untouched.
private struct AppSwitcher: View {
    @EnvironmentObject private var system: IndicaSystem

    private enum Axis {
        case horizontal, vertical
    }

    @State private var focusedIndex = 0
    @State private var dragX: CGFloat = 0
    @State private var axis: Axis?
    @State private var draggedApp: BuiltInApp?
    @State private var dragY: CGFloat = 0
    /// Cards flying away. A set, so a second flick can't undo the first.
    @State private var closingApps: Set<BuiltInApp> = []
    /// A button still fires when the finger lifts after a drag, so a release
    /// that ended a drag must not count as a tap.
    @State private var didDrag = false
    /// Resets by itself if the system cancels the touch, when `onEnded` doesn't run.
    @GestureState private var isDragging = false

    private let cardWidth: CGFloat = 292
    private let cardSpacing: CGFloat = 16
    private let closeDistance: CGFloat = 130
    private var step: CGFloat { cardWidth + cardSpacing }

    var body: some View {
        VStack(spacing: 0) {
            SystemStatusBar(foreground: system.wallpaper.foreground)

            Spacer(minLength: 42)

            if system.appHistory.isEmpty {
                ContentUnavailableView("No Recent Apps", systemImage: "rectangle.stack")
                    .foregroundStyle(system.wallpaper.foreground)
            } else {
                GeometryReader { proxy in
                    let leading = (proxy.size.width - cardWidth) / 2
                    HStack(spacing: cardSpacing) {
                        ForEach(system.appHistory) { app in
                            card(for: app)
                        }
                    }
                    .offset(x: leading - CGFloat(focusedIndex) * step + dragX)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .contentShape(Rectangle())
                    .simultaneousGesture(dragGesture(leading: leading))
                    .onChange(of: isDragging) { _, dragging in
                        if !dragging { resetAfterCancelledDrag() }
                    }
                    .accessibilityScrollAction { edge in
                        switch edge {
                        case .trailing: moveFocus(to: focusedIndex + 1)
                        case .leading: moveFocus(to: focusedIndex - 1)
                        default: break
                        }
                    }
                }
                .frame(height: 535)
            }

            Spacer()

            Text("Tap a card to open it. Swipe up to close it.")
                .font(.footnote)
                .foregroundStyle(system.wallpaper.secondaryForeground)

            HomeIndicator(color: system.wallpaper.foreground, accessibilityLabel: "Home") {
                system.goHome()
            }
            .padding(.top, 14)
            .padding(.bottom, 26)
        }
    }

    private func card(for app: BuiltInApp) -> some View {
        let lift = closingApps.contains(app) ? -900 : (draggedApp == app ? dragY : 0)
        return Button {
            guard !didDrag else { return }
            system.open(app)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    MiniAppMark(app: app)
                    Text(app.name)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }

                AppPreviewCard(app: app)
            }
            .foregroundStyle(Instrument.ink)
            .padding(12)
            .frame(width: cardWidth, height: 535)
            .instrumentPanel(cornerRadius: 24)
        }
        .buttonStyle(PressableButtonStyle(scale: 0.98))
        .offset(y: lift)
        .opacity(1 - min(Double(-lift) / 700, 0.6))
        .accessibilityLabel(app.name)
        .accessibilityHint("Opens the app")
        .accessibilityAction(named: "Close \(app.name)") {
            close(app)
        }
    }

    private func dragGesture(leading: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .updating($isDragging) { _, state, _ in state = true }
            .onChanged { value in
                didDrag = true
                if axis == nil {
                    let isUpward = value.translation.height < 0
                        && abs(value.translation.height) > abs(value.translation.width)
                    axis = isUpward ? .vertical : .horizontal
                    if isUpward {
                        draggedApp = app(atX: value.startLocation.x, leading: leading)
                        dragY = 0
                    }
                }
                switch axis {
                case .vertical:
                    // Downward movement resists, so the card can't be pulled away from its row.
                    dragY = value.translation.height < 0 ? value.translation.height : value.translation.height * 0.15
                case .horizontal:
                    let atFirst = focusedIndex == 0 && value.translation.width > 0
                    let atLast = focusedIndex == system.appHistory.count - 1 && value.translation.width < 0
                    dragX = atFirst || atLast ? value.translation.width * 0.3 : value.translation.width
                case nil:
                    break
                }
            }
            .onEnded { value in
                defer {
                    axis = nil
                    clearDidDragAfterRelease()
                }
                switch axis {
                case .vertical:
                    if let draggedApp,
                       value.translation.height < -closeDistance
                        || value.predictedEndTranslation.height < -closeDistance * 2.5 {
                        self.draggedApp = nil
                        dragY = 0
                        close(draggedApp)
                    } else {
                        withAnimation(Instrument.motion) {
                            dragY = 0
                        }
                    }
                case .horizontal:
                    let cardsMoved = Int((-value.predictedEndTranslation.width / step).rounded())
                    moveFocus(to: focusedIndex + cardsMoved)
                case nil:
                    break
                }
            }
    }

    /// The card under a screen position, given the row's current scroll position.
    /// A card already flying away doesn't count, so a quick second flick takes the
    /// one that's really there.
    private func app(atX x: CGFloat, leading: CGFloat) -> BuiltInApp? {
        let position = (x - leading) / step + CGFloat(focusedIndex)
        let index = min(max(Int(position.rounded(.down)), 0), system.appHistory.count - 1)
        guard system.appHistory.indices.contains(index) else { return nil }
        let app = system.appHistory[index]
        if !closingApps.contains(app) { return app }
        return system.appHistory[index...].first { !closingApps.contains($0) }
            ?? system.appHistory[..<index].last { !closingApps.contains($0) }
    }

    private func moveFocus(to target: Int) {
        withAnimation(Instrument.motion) {
            focusedIndex = min(max(target, 0), max(system.appHistory.count - 1, 0))
            dragX = 0
        }
    }

    private func clearDidDragAfterRelease() {
        Task {
            try? await Task.sleep(for: .milliseconds(80))
            didDrag = false
        }
    }

    /// The system took the touch away, so `onEnded` won't run. Put the card or row
    /// back; a normal release has already cleared `axis`, so this does nothing then.
    private func resetAfterCancelledDrag() {
        guard axis != nil else { return }
        axis = nil
        clearDidDragAfterRelease()
        withAnimation(Instrument.motion) {
            draggedApp = nil
            dragY = 0
            dragX = 0
        }
    }

    private func close(_ app: BuiltInApp) {
        HapticEngine.play(.light, enabled: system.hapticsEnabled)
        withAnimation(Instrument.motion) {
            _ = closingApps.insert(app)
        }
        Task {
            try? await Task.sleep(for: .milliseconds(220))
            withAnimation(Instrument.motion) {
                // Keep the focused card focused when one before it goes.
                if let closedIndex = system.appHistory.firstIndex(of: app), closedIndex < focusedIndex {
                    focusedIndex -= 1
                }
                system.appHistory.removeAll { $0 == app }
                focusedIndex = min(focusedIndex, max(system.appHistory.count - 1, 0))
                closingApps.remove(app)
                if system.appHistory.isEmpty {
                    system.goHome()
                }
            }
        }
    }
}

private struct AppPreviewCard: View {
    let app: BuiltInApp

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Instrument.ground
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    AppMark(app: app, size: 82)
                }

            Text(app.name)
                .font(.title2.weight(.semibold))
                .tracking(-0.4)

            ForEach(0..<4, id: \.self) { index in
                VStack(alignment: .leading, spacing: 8) {
                    InstrumentRule(color: Instrument.rule)
                    Instrument.rule
                        .frame(width: CGFloat(110 + index * 17), height: 7)
                    Instrument.rule
                        .opacity(0.6)
                        .frame(width: CGFloat(78 + index * 9), height: 6)
                }
            }

            Spacer()
        }
        .padding(.top, 4)
    }
}

private struct MiniAppMark: View {
    let app: BuiltInApp

    var body: some View {
        AppMark(app: app, size: 26)
    }
}

private struct ControlCenterOverlay: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var torchOn = false

    var body: some View {
        ZStack {
            Instrument.ground
                .onTapGesture {
                    withAnimation(Instrument.motion) {
                        system.overlay = nil
                    }
                }

            VStack(spacing: 14) {
                SystemStatusBar()

                HStack {
                    Text("Control Center")
                        .font(.title.weight(.semibold))
                        .tracking(-0.5)
                    Spacer()
                    Button {
                        system.lock()
                    } label: {
                        Image(systemName: "lock")
                            .frame(width: 44, height: 44)
                            .instrumentPanel(cornerRadius: 12)
                    }
                    .accessibilityLabel("Lock")
                }
                .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            ControlToggle(title: "Airplane Mode", symbol: "airplane", isOn: $system.airplaneMode)
                            ControlToggle(title: "Cellular", symbol: "antenna.radiowaves.left.and.right", isOn: .constant(true))
                                .disabled(true)
                        }
                        HStack(spacing: 12) {
                            ControlToggle(title: "Wi-Fi", symbol: "wifi", isOn: $system.wifiEnabled)
                            ControlToggle(title: "Bluetooth", symbol: "bolt.horizontal.fill", isOn: $system.bluetoothEnabled)
                        }
                    }
                    .padding(13)
                    .instrumentPanel()

                    VStack(spacing: 10) {
                        Image(systemName: "waveform")
                            .font(.system(size: 23))
                        Text("Quiet Hours")
                            .font(.footnote.weight(.semibold))
                        HStack(spacing: 16) {
                            Image(systemName: "backward.fill")
                            Image(systemName: "play.fill")
                            Image(systemName: "forward.fill")
                        }
                        .font(.footnote)
                    }
                    .frame(maxWidth: .infinity, minHeight: 139)
                    .instrumentPanel()
                }
                .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    VerticalSlider(title: "Brightness", value: $system.brightness, symbol: "sun.max")
                    VerticalSlider(title: "Volume", value: $system.volume, symbol: "speaker.wave.2")
                    VStack(spacing: 12) {
                        WideControl(title: "Focus", symbol: "moon", isOn: $system.isFocusEnabled)
                        WideControl(title: "Display", symbol: "rectangle.inset.filled") { system.open(.settings) }
                    }
                }
                .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    SmallControl(title: "Flashlight", symbol: "flashlight.on.fill", isOn: torchOn) {
                        torchOn = DeviceTorch.toggle()
                    }
                        .disabled(!DeviceTorch.isAvailable)
                        .opacity(DeviceTorch.isAvailable ? 1 : 0.4)
                    SmallControl(title: "Clock", symbol: "timer") { system.open(.clock) }
                    SmallControl(title: "Camera", symbol: "camera") { system.open(.camera) }
                    SmallControl(title: "Voice Memos", symbol: "waveform") { system.open(.voiceMemos) }
                }
                .padding(.horizontal, 20)

                Text("The switches, sliders and player here are simulated. They don't change this iPhone.")
                    .font(.footnote)
                    .foregroundStyle(Instrument.inkSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                Spacer()

                HomeIndicator(accessibilityLabel: "Close Control Center") {
                    withAnimation(Instrument.motion) { system.overlay = nil }
                }
                .padding(.bottom, 26)
            }
            .foregroundStyle(Instrument.ink)
            // A fixed layout with no scrolling, like Home.
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .onAppear { torchOn = DeviceTorch.isOn }
        }
    }
}

private struct ControlToggle: View {
    let title: String
    let symbol: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            withAnimation(Instrument.motion) {
                isOn.toggle()
            }
        } label: {
            // On is a solid block, like a selected day in Calendar.
            Image(systemName: symbol)
                .font(.system(size: 18))
                .foregroundStyle(isOn ? Instrument.surface : Instrument.ink)
                .frame(width: 48, height: 48)
                .background(isOn ? Instrument.ink : .clear, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Instrument.edge, lineWidth: Instrument.hairline)
                }
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

private struct VerticalSlider: View {
    let title: String
    @Binding var value: Double
    let symbol: String

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                Instrument.surface

                Instrument.ink
                    .frame(height: max(48, proxy.size.height * value))

                Image(systemName: symbol)
                    .font(.system(size: 17))
                    .foregroundStyle(Instrument.surface)
                    .padding(.bottom, 15)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        value = min(1, max(0, 1 - gesture.location.y / proxy.size.height))
                    }
            )
        }
        .frame(width: 74, height: 178)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Instrument.edge, lineWidth: Instrument.hairline)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("\(Int((value * 100).rounded())) percent")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: value = min(1, value + 0.1)
            case .decrement: value = max(0, value - 0.1)
            @unknown default: break
            }
        }
    }
}

private struct WideControl: View {
    let title: String
    let symbol: String
    var isOn: Binding<Bool>?
    var action: (() -> Void)?

    init(title: String, symbol: String, isOn: Binding<Bool>? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.symbol = symbol
        self.isOn = isOn
        self.action = action
    }

    var body: some View {
        let on = isOn?.wrappedValue == true
        Button {
            isOn?.wrappedValue.toggle()
            action?()
        } label: {
            HStack(spacing: 11) {
                Image(systemName: symbol)
                Text(title)
                    .font(.footnote.weight(.semibold))
                Spacer()
            }
            .foregroundStyle(on ? Instrument.surface : Instrument.ink)
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 83)
            .background(on ? Instrument.ink : Instrument.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Instrument.edge, lineWidth: Instrument.hairline)
            }
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

private struct SmallControl: View {
    let title: String
    let symbol: String
    /// Nil for a shortcut with no on or off state.
    var isOn: Bool?
    var action: () -> Void = {}

    var body: some View {
        let on = isOn == true
        let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18))
                .foregroundStyle(on ? Instrument.surface : Instrument.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 62)
                .background(on ? Instrument.ink : Instrument.surface, in: shape)
                .overlay { shape.strokeBorder(Instrument.edge, lineWidth: Instrument.hairline) }
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(title)
        .accessibilityValue(isOn.map { $0 ? "On" : "Off" } ?? "")
    }
}

private struct NotificationCenterOverlay: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        ZStack {
            Instrument.ground
                .onTapGesture {
                    withAnimation(Instrument.motion) { system.overlay = nil }
                }

            VStack(spacing: 0) {
                SystemStatusBar()

                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Notifications")
                            .font(.title.weight(.semibold))
                            .tracking(-0.5)
                        Text(system.notificationCountText)
                            .font(Instrument.mono(.footnote))
                            .foregroundStyle(Instrument.inkSecondary)
                    }
                    Spacer()
                    Button {
                        withAnimation(Instrument.motion) {
                            system.notifications.removeAll()
                        }
                    } label: {
                        Text("Clear")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Instrument.ink)
                            .padding(.horizontal, 14)
                            .frame(minHeight: 44)
                            .instrumentPanel(cornerRadius: 12)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)

                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(system.notifications) { notification in
                            NotificationCard(
                                notification: notification,
                                showsPreview: system.showsNotificationPreviews
                            )
                                .onTapGesture {
                                    system.open(notification.app)
                                }
                                .contextMenu {
                                    Button("Dismiss", role: .destructive) {
                                        system.dismissNotification(notification)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 13)
                }

                HomeIndicator(accessibilityLabel: "Close Notifications") {
                    withAnimation(Instrument.motion) { system.overlay = nil }
                }
                .padding(.bottom, 26)
            }
            .foregroundStyle(Instrument.ink)
        }
    }
}

private struct NotificationCard: View {
    let notification: SystemNotification
    var compact = false
    /// From the Show Previews setting. The Lock Screen counts as locked.
    var showsPreview = true

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            MiniAppMark(app: notification.app)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(showsPreview ? notification.title : notification.app.name)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    // In place of a time: a sample's time isn't real either.
                    if notification.isSample {
                        Text("SAMPLE")
                            .font(Instrument.mono(.caption2))
                            .foregroundStyle(Instrument.inkSecondary)
                    } else {
                        Text(notification.date, style: .relative)
                            .font(Instrument.mono(.caption2))
                            .foregroundStyle(Instrument.inkSecondary)
                    }
                }
                Text(showsPreview ? notification.body : "Notification")
                    .font(.footnote)
                    .lineLimit(compact ? 1 : 3)
                    .foregroundStyle(Instrument.inkSecondary)
            }
        }
        .foregroundStyle(Instrument.ink)
        .padding(13)
        .instrumentPanel(cornerRadius: 14)
    }
}

private struct WallpaperPickerOverlay: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.34)
                .onTapGesture {
                    withAnimation(Instrument.motion) { system.overlay = nil }
                }

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Wallpapers")
                            .font(.title.weight(.semibold))
                            .tracking(-0.5)
                        Text("Changes apply to Lock and Home.")
                            .font(.footnote)
                            .foregroundStyle(Instrument.inkSecondary)
                    }
                    Spacer()
                    Button("Done") {
                        withAnimation(Instrument.motion) { system.overlay = nil }
                    }
                    .fontWeight(.bold)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(WallpaperStyle.allCases) { wallpaper in
                            Button {
                                withAnimation(Instrument.motion) {
                                    system.wallpaper = wallpaper
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    IndicaWallpaper(style: wallpaper)
                                        .frame(width: 128, height: 218)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(system.wallpaper == wallpaper ? Instrument.signal : Instrument.edge, lineWidth: system.wallpaper == wallpaper ? 3 : Instrument.hairline)
                                        }
                                    Text(wallpaper.rawValue)
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(PressableButtonStyle(scale: 0.97))
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 18)
            .background(Instrument.surface)
            .overlay(alignment: .top) { InstrumentRule() }
        }
        .foregroundStyle(Instrument.ink)
    }
}

private struct LockCustomizationOverlay: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .onTapGesture { withAnimation(Instrument.motion) { system.overlay = nil } }

            VStack(spacing: 18) {
                HStack {
                    Text("Customize")
                        .font(.title2.weight(.semibold))
                    Spacer()
                    Button("Done") {
                        withAnimation(Instrument.motion) { system.overlay = nil }
                    }
                    .fontWeight(.bold)
                }

                IndicaWallpaper(style: system.wallpaper)
                    .overlay {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(Date.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)).uppercased())
                                .font(Instrument.mono(.caption2, weight: .medium))
                            Text(Date.now.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)).minute(.twoDigits)))
                                .font(.system(size: 52, weight: system.lockClockStyle.weight, design: system.lockClockStyle.design))
                            LedgerStrip(verticalPadding: 8)
                                .padding(.top, 8)
                            Spacer()
                        }
                        .padding(16)
                        .padding(.top, 16)
                        .foregroundStyle(system.wallpaper.foreground)
                    }
                    .frame(height: 475)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Instrument.edge, lineWidth: Instrument.hairline)
                    }

                HStack(spacing: 12) {
                    Button {
                        withAnimation(Instrument.motion) { system.overlay = .wallpaper }
                    } label: {
                        Label("Wallpaper", systemImage: "photo.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Instrument.ink, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .foregroundStyle(Instrument.surface)
                    }

                    Button {
                        let index = WallpaperStyle.allCases.firstIndex(of: system.wallpaper) ?? 0
                        system.wallpaper = WallpaperStyle.allCases[(index + 1) % WallpaperStyle.allCases.count]
                    } label: {
                        Image(systemName: "shuffle")
                            .frame(width: 48, height: 48)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(Instrument.edge, lineWidth: Instrument.hairline)
                            }
                    }
                    .accessibilityLabel("Next wallpaper")
                }
                .font(.subheadline.weight(.semibold))
            }
            .padding(20)
            .instrumentPanel(cornerRadius: 24)
            .padding(20)
        }
        .foregroundStyle(Instrument.ink)
    }
}

struct HomeIndicator: View {
    var color: Color = Instrument.ink
    let accessibilityLabel: String
    let action: () -> Void

    init(color: Color = Instrument.ink, accessibilityLabel: String, action: @escaping () -> Void) {
        self.color = color
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            color
                .frame(width: 134, height: 3)
                .frame(maxWidth: .infinity, minHeight: 16)
                // A thin bar, but a comfortable target. Overlaps its neighbors' margins only.
                .contentShape(Rectangle().inset(by: -14))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95
    /// A drag elsewhere took over this touch, so the control stops looking pressed.
    var cancelsPress = false

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed && !cancelsPress
        configuration.label
            .scaleEffect(isPressed ? scale : 1)
            .opacity(isPressed ? 0.8 : 1)
            .animation(Instrument.press, value: isPressed)
    }
}
