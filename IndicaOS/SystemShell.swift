import SwiftUI

struct SystemShell: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var didStart = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                IndicaWallpaper(style: system.wallpaper)

                phaseContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if let overlay = system.overlay {
                    overlayView(overlay)
                        .zIndex(20)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .simultaneousGesture(systemGesture(in: proxy.size))
            .onAppear {
                guard !didStart else { return }
                didStart = true
                guard system.phase == .booting else { return }
                Task {
                    try? await Task.sleep(for: .seconds(1.25))
                    system.finishBoot()
                }
            }
        }
        .statusBarHidden(true)
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
            HomeScreen()
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

    private func systemGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                let startedAtTop = value.startLocation.y < 82
                let startedAtBottom = value.startLocation.y > size.height - 172

                if startedAtTop, value.translation.height > 70 {
                    withAnimation(.spring(response: 0.44, dampingFraction: 0.88)) {
                        system.overlay = value.startLocation.x > size.width * 0.53 ? .controlCenter : .notifications
                    }
                } else if startedAtBottom, value.translation.height < -46 {
                    switch system.phase {
                    case .app:
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
    @State private var breathing = false

    var body: some View {
        ZStack {
            Color.black

            VStack(spacing: 18) {
                IndicaBrandMark()
                    .frame(width: 88, height: 88)
                .scaleEffect(breathing ? 1.04 : 0.96)
                .shadow(color: Color(hex: 0xB88C68).opacity(0.20), radius: 28)

                Text("INDICA")
                    .font(.system(size: 13, weight: .semibold, design: .default))
                    .tracking(6)
                    .foregroundStyle(.white.opacity(0.82))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                breathing = true
            }
        }
    }
}

private struct IndicaBrandMark: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: 0x232635), Color(hex: 0x07080B)],
                        center: .topLeading,
                        startRadius: 2,
                        endRadius: 78
                    )
                )
                .overlay {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: 0xD7B18E), Color(hex: 0x54463B)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.4
                        )
                }

            VStack(spacing: 6) {
                Capsule()
                    .fill(Color(hex: 0xD7B18E))
                    .frame(width: 13, height: 27)
                Capsule()
                    .fill(Color(hex: 0xF0D6BA))
                    .frame(width: 23, height: 7)
                Capsule()
                    .fill(Color(hex: 0xD7B18E))
                    .frame(width: 13, height: 27)
            }
            .shadow(color: Color(hex: 0x7967C7).opacity(0.42), radius: 5)
        }
    }
}

struct IndicaWallpaper: View {
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

                RadialGradient(
                    colors: [
                        Color.white.opacity(style == .daylight ? 0.26 : 0.11),
                        .clear
                    ],
                    center: .topTrailing,
                    startRadius: 4,
                    endRadius: size.width * 0.75
                )

                RadialGradient(
                    colors: [
                        Color(hex: 0xD9BFA8).opacity(style == .aura ? 0.16 : 0.04),
                        .clear
                    ],
                    center: .bottomLeading,
                    startRadius: 10,
                    endRadius: size.width * 0.92
                )

                LinearGradient(
                    colors: [
                        .white.opacity(style == .daylight ? 0.20 : 0.055),
                        .clear,
                        .black.opacity(style == .daylight ? 0.08 : 0.32)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                    drift.toggle()
                }
            }
        }
    }
}

struct SystemStatusBar: View {
    var foreground: Color = .white
    var showIsland = true

    var body: some View {
        HStack {
            TimelineView(.periodic(from: .now, by: 30)) { context in
                Text(context.date.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)).minute(.twoDigits)))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }

            Spacer()

            if showIsland {
                DynamicIslandControl()
                    .zIndex(30)
            }

            Spacer()

            HStack(spacing: 5) {
                Image(systemName: "cellularbars")
                Image(systemName: "wifi")
                Image(systemName: "battery.100percent")
            }
            .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 22)
        .frame(height: 58)
        .padding(.top, 5)
    }
}

private struct DynamicIslandControl: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var isExpanded = false
    @State private var isPointerInside = false

    private var activeTitle: String {
        switch system.phase {
        case .app(let app):
            app.name
        case .locked:
            "Indica Locked"
        case .switcher:
            "App Switcher"
        case .booting, .home:
            "Indica OS"
        }
    }

    var body: some View {
        Color.clear
            .frame(width: 116, height: 34)
            .overlay {
                ZStack {
                    RoundedRectangle(
                        cornerRadius: isExpanded ? 27 : 18,
                        style: .continuous
                    )
                    .fill(Color.black)
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: isExpanded ? 27 : 18,
                            style: .continuous
                        )
                        .stroke(.white.opacity(isExpanded ? 0.10 : 0.035), lineWidth: 0.65)
                    }
                    .shadow(
                        color: .black.opacity(isExpanded ? 0.34 : 0.10),
                        radius: isExpanded ? 18 : 5,
                        y: isExpanded ? 10 : 2
                    )

                    if isExpanded {
                        expandedContent
                            .transition(.opacity.combined(with: .scale(scale: 0.92)))
                    } else {
                        compactContent
                            .transition(.opacity)
                    }
                }
                .frame(
                    width: isExpanded ? 270 : 116,
                    height: isExpanded ? 88 : 34
                )
                .offset(y: isExpanded ? 27 : 0)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                HapticEngine.play(.medium, enabled: system.hapticsEnabled)
                withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                    isExpanded.toggle()
                }
            }
            .onLongPressGesture(minimumDuration: 0.42) {
                HapticEngine.play(.rigid, enabled: system.hapticsEnabled)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.80)) {
                    isExpanded = true
                }
            }
            .onHover { hovering in
                isPointerInside = hovering
                if hovering {
                    guard !isExpanded else { return }
                    HapticEngine.play(.selection, enabled: system.hapticsEnabled)
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.84)) {
                        isExpanded = true
                    }
                } else {
                    Task {
                        try? await Task.sleep(for: .milliseconds(420))
                        guard !isPointerInside else { return }
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.88)) {
                            isExpanded = false
                        }
                    }
                }
            }
            .hoverEffect(.highlight)
            .accessibilityLabel("Dynamic Island")
            .accessibilityHint("Tap or press and hold to expand")
            .accessibilityAddTraits(.isButton)
    }

    private var compactContent: some View {
        HStack(spacing: 8) {
            if isPointerInside {
                Image(systemName: "waveform")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(hex: 0xC6A17E))
                Text("Indica")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Spacer(minLength: 0)
            } else {
                Spacer(minLength: 0)
                Capsule()
                    .fill(Color(hex: 0x17191E))
                    .frame(width: 42, height: 8)
                Spacer(minLength: 0)
                Circle()
                    .fill(Color(hex: 0x15161A))
                    .frame(width: 11, height: 11)
                    .overlay {
                        Circle()
                            .fill(Color(hex: 0x26355E))
                            .frame(width: 4, height: 4)
                    }
            }
        }
        .padding(.horizontal, 9)
    }

    private var expandedContent: some View {
        VStack(spacing: 10) {
            HStack(spacing: 11) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0xD7B18E), Color(hex: 0x504239)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: "waveform")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.black)
                }
                .frame(width: 37, height: 37)

                VStack(alignment: .leading, spacing: 2) {
                    Text(activeTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text("System activity")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.58))
                }

                Spacer()

                Text("LIVE")
                    .font(.system(size: 8, weight: .black))
                    .tracking(0.7)
                    .foregroundStyle(Color(hex: 0xD7B18E))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Color(hex: 0xD7B18E).opacity(0.12), in: Capsule())
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.12))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0xD7B18E), Color(hex: 0x7A6AC6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * 0.64)
                }
            }
            .frame(height: 3)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
    }
}

private struct LockScreen: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            SystemStatusBar(foreground: system.wallpaper.foreground)

            VStack(spacing: 6) {
                TimelineView(.periodic(from: .now, by: 60)) { context in
                    Text(context.date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .tracking(-0.2)
                }

                TimelineView(.periodic(from: .now, by: 1)) { context in
                    Text(context.date.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)).minute(.twoDigits)))
                        .font(.system(size: 82, weight: system.lockClockStyle.weight, design: system.lockClockStyle.design))
                        .tracking(system.lockClockStyle == .classic ? -5.4 : -4)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
            }
            .shadow(color: .black.opacity(0.14), radius: 8, y: 2)
            .padding(.top, 8)

            if system.showLockWidgets {
                HStack(spacing: 10) {
                    LockWidget(symbol: "cloud.sun.fill", title: "72°", detail: "Brooklyn")
                    LockWidget(symbol: "figure.walk", title: "5,804", detail: "steps")
                    LockWidget(symbol: "calendar", title: "2:30", detail: "Review")
                }
                .padding(.horizontal, 18)
                .padding(.top, 20)
            }

            Spacer()

            VStack(spacing: 10) {
                ForEach(system.notifications.prefix(2)) { notification in
                    NotificationCard(notification: notification, compact: true)
                }
            }
            .padding(.horizontal, 12)

            Spacer(minLength: 22)

            HStack {
                LockActionButton(symbol: "flashlight.on.fill") {}
                Spacer()
                Text("Swipe up to open")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(system.wallpaper.foreground.opacity(0.72))
                Spacer()
                LockActionButton(symbol: "camera.fill") {
                    system.unlock()
                    Task {
                        try? await Task.sleep(for: .milliseconds(320))
                        system.open(.camera)
                    }
                }
            }
            .padding(.horizontal, 28)

            HomeIndicator(color: system.wallpaper.foreground)
                .padding(.top, 16)
                .padding(.bottom, 9)
        }
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
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        dragOffset = 0
                    }
                }
        )
        .onLongPressGesture(minimumDuration: 0.55) {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                system.overlay = .lockCustomization
            }
        }
        .foregroundStyle(system.wallpaper.foreground)
    }
}

private struct LockWidget: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .default))
            Text(detail)
                .font(.system(size: 10, weight: .medium, design: .default))
                .opacity(0.68)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.black.opacity(0.10), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .liquidGlass(cornerRadius: 20, intensity: 0.48)
    }
}

private struct LockActionButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 48, height: 48)
                .liquidGlass(cornerRadius: 24, intensity: 0.72)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

private struct HomeScreen: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var page = 0

    var body: some View {
        GeometryReader { proxy in
            let metrics = HomeLayoutMetrics(
                size: proxy.size,
                density: system.homeLayoutDensity
            )

            VStack(spacing: 0) {
                SystemStatusBar(foreground: system.wallpaper.foreground)

                TabView(selection: $page) {
                    ForEach(Array(system.homePages.enumerated()), id: \.offset) { pageIndex, apps in
                        VStack(spacing: metrics.sectionSpacing) {
                            if pageIndex == 0 {
                                HomeWidgetRow(height: metrics.widgetHeight)
                                    .padding(.horizontal, metrics.horizontalPadding)
                            } else if pageIndex == 1 {
                                SearchWidget()
                                    .padding(.horizontal, metrics.horizontalPadding)
                            } else {
                                LibraryHeader()
                                    .padding(.horizontal, metrics.horizontalPadding + 2)
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
                                        size: metrics.iconSize
                                    ) {
                                        guard !system.isEditingHome else { return }
                                        system.open(app)
                                    }
                                }
                            }
                            .padding(.horizontal, metrics.horizontalPadding)

                            Spacer(minLength: 2)
                        }
                        .tag(pageIndex)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Button {
                    HapticEngine.play(.selection, enabled: system.hapticsEnabled)
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.84)) {
                        page = page == 1 ? 0 : min(1, system.homePages.count - 1)
                    }
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: page == 1 ? "house.fill" : "magnifyingglass")
                            .font(.system(size: 9, weight: .bold))

                        Text(page == 1 ? "Home" : "Search")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))

                        HStack(spacing: 4) {
                            ForEach(system.homePages.indices, id: \.self) { index in
                                Capsule()
                                    .fill(system.wallpaper.foreground.opacity(index == page ? 0.92 : 0.32))
                                    .frame(width: index == page ? 12 : 5, height: 5)
                            }
                        }
                    }
                    .padding(.horizontal, 11)
                    .frame(height: 28)
                    .liquidGlass(cornerRadius: 14, intensity: 0.54)
                }
                .buttonStyle(PressableButtonStyle(scale: 0.95))
                .padding(.vertical, metrics.pageIndicatorPadding)

                HStack(spacing: metrics.dockSpacing) {
                    ForEach(system.dockApps) { app in
                        AppIcon(
                            app: app,
                            isEditing: false,
                            size: metrics.dockIconSize,
                            showsLabel: false
                        ) {
                            system.open(app)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 14)
                .padding(.vertical, metrics.dockVerticalPadding)
                .background(
                    Color.black.opacity(0.13),
                    in: RoundedRectangle(cornerRadius: 31, style: .continuous)
                )
                .liquidGlass(cornerRadius: 31, intensity: 0.58)
                .overlay {
                    RoundedRectangle(cornerRadius: 31, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: 0xE8D1BA).opacity(0.24),
                                    .white.opacity(0.06),
                                    .black.opacity(0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.65
                        )
                }
                .shadow(color: .black.opacity(0.24), radius: 18, y: 9)
                .padding(.horizontal, metrics.dockHorizontalPadding)

                HomeIndicator(color: system.wallpaper.foreground)
                    .padding(.top, metrics.homeIndicatorTopPadding)
                    .padding(.bottom, 7)
            }
            .onChange(of: page) { _, _ in
                HapticEngine.play(.selection, enabled: system.hapticsEnabled)
            }
            .onLongPressGesture(minimumDuration: 0.52) {
                HapticEngine.play(.rigid, enabled: system.hapticsEnabled)
                withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                    system.isEditingHome.toggle()
                }
            }
            .overlay(alignment: .topTrailing) {
                if system.isEditingHome {
                    Button("Done") {
                        HapticEngine.play(.selection, enabled: system.hapticsEnabled)
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
                            system.isEditingHome = false
                        }
                    }
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .liquidGlass(cornerRadius: 18, intensity: 0.78)
                    .padding(.top, 64)
                    .padding(.trailing, 18)
                }
            }
            .foregroundStyle(system.wallpaper.foreground)
        }
    }
}

private struct HomeLayoutMetrics {
    let size: CGSize
    let density: HomeLayoutDensity

    private var compactHeight: Bool { size.height < 860 }

    var columnCount: Int { density == .compact ? 5 : 4 }
    var horizontalPadding: CGFloat { size.width >= 430 ? 20 : 16 }
    var sectionSpacing: CGFloat { compactHeight ? 8 : 12 }
    var columnSpacing: CGFloat { density == .compact ? 7 : (compactHeight ? 9 : 12) }
    var rowSpacing: CGFloat { density == .compact ? (compactHeight ? 8 : 11) : (compactHeight ? 10 : 16) }
    var iconSize: CGFloat {
        if density == .compact {
            return compactHeight ? 49 : 52
        }
        return compactHeight ? 56 : 60
    }
    var dockIconSize: CGFloat { compactHeight ? 56 : 60 }
    var widgetHeight: CGFloat { compactHeight ? 92 : 101 }
    var pageIndicatorPadding: CGFloat { compactHeight ? 5 : 8 }
    var dockVerticalPadding: CGFloat { compactHeight ? 8 : 10 }
    var dockHorizontalPadding: CGFloat { size.width >= 430 ? 18 : 14 }
    var dockSpacing: CGFloat { size.width >= 430 ? 17 : 13 }
    var homeIndicatorTopPadding: CGFloat { compactHeight ? 6 : 9 }
}

private struct HomeWidgetRow: View {
    let height: CGFloat

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("BROOKLYN")
                        .tracking(1.5)
                    Spacer()
                    Image(systemName: "location.fill")
                }
                .font(.system(size: 9, weight: .bold, design: .default))
                .opacity(0.64)
                HStack(alignment: .top, spacing: 5) {
                    Text("72°")
                        .font(.system(size: 34, weight: .medium, design: .default))
                        .tracking(-1.4)
                    Image(systemName: "cloud.sun.fill")
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 19))
                }
                Text("Feels like 74°")
                    .font(.system(size: 10, weight: .medium))
                    .opacity(0.66)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.black.opacity(0.12), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .liquidGlass(cornerRadius: 24, intensity: 0.56)

            VStack(alignment: .leading, spacing: 7) {
                Text("UP NEXT")
                    .font(.system(size: 9, weight: .bold, design: .default))
                    .tracking(1.5)
                    .opacity(0.62)
                Text("Design review")
                    .font(.system(size: 14, weight: .semibold, design: .default))
                Text("2:30 PM")
                    .font(.system(size: 11, weight: .semibold))
                    .opacity(0.72)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0xE8C5A3), Color(hex: 0xA67A58)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.black.opacity(0.12), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .liquidGlass(cornerRadius: 24, intensity: 0.56)
        }
        .frame(height: height)
    }
}

private struct SearchWidget: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
            Text("Search apps and actions")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .opacity(0.72)
            Spacer()
            Image(systemName: "mic.fill")
                .opacity(0.72)
        }
        .padding(.horizontal, 17)
        .frame(height: 50)
        .liquidGlass(cornerRadius: 25, intensity: 0.72)
    }
}

private struct LibraryHeader: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("App Library")
                    .font(.system(size: 27, weight: .bold, design: .default))
                Text("Utilities and extras")
                    .font(.system(size: 13, weight: .medium))
                    .opacity(0.65)
            }
            Spacer()
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 19, weight: .semibold))
        }
        .padding(16)
        .liquidGlass(cornerRadius: 25, intensity: 0.68)
    }
}

private struct AppIcon: View {
    @EnvironmentObject private var system: IndicaSystem
    let app: BuiltInApp
    let isEditing: Bool
    var size: CGFloat = 60
    var showsLabel = true
    let action: () -> Void
    @State private var wiggle = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                PremiumAppMark(app: app, size: size)
                .overlay {
                    if system.iconAppearance == .clear {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(.white.opacity(0.52), lineWidth: 0.8)
                    }
                }
                .overlay(alignment: .topLeading) {
                    if isEditing {
                        Image(systemName: "minus")
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(.black)
                            .frame(width: 19, height: 19)
                            .background(.white, in: Circle())
                            .offset(x: -5, y: -5)
                    }
                }

                if showsLabel && system.showAppLabels {
                    Text(app.name)
                        .font(.system(size: 11, weight: .semibold, design: .default))
                        .tracking(-0.1)
                        .lineLimit(1)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.72), radius: 4, y: 1)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PressableButtonStyle())
        .rotationEffect(.degrees(isEditing ? (wiggle ? 1.5 : -1.5) : 0))
        .onChange(of: isEditing) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.13).repeatForever(autoreverses: true)) {
                    wiggle.toggle()
                }
            } else {
                wiggle = false
            }
        }
    }
}

struct PremiumAppMark: View {
    @EnvironmentObject private var system: IndicaSystem
    let app: BuiltInApp
    var size: CGFloat = 60

    private var cornerRadius: CGFloat { size * 0.27 }

    private var automaticColors: [Color] {
        switch app {
        case .calendar:
            [Color(hex: 0xFAFAF8), Color(hex: 0xD9DDE2)]
        case .photos:
            [Color(hex: 0xFBFAF6), Color(hex: 0xDDE2E7)]
        case .health:
            [Color(hex: 0xFAF8F7), Color(hex: 0xE1E3E8)]
        case .maps:
            [Color(hex: 0xDCE9D8), Color(hex: 0x80B6A9)]
        case .notes:
            [Color(hex: 0xF4D66B), Color(hex: 0xC99B2D)]
        case .camera, .clock, .compass, .stocks, .watch, .notion:
            [Color(hex: 0x3B414A), Color(hex: 0x080A0D)]
        case .wallet:
            [Color(hex: 0x41464E), Color(hex: 0x111318)]
        case .settings:
            [Color(hex: 0xB9BEC6), Color(hex: 0x4B515C)]
        default:
            [
                (app.palette.first ?? Color(hex: 0x6E7785)).opacity(0.86),
                (app.palette.last ?? Color(hex: 0x242832)).opacity(0.92)
            ]
        }
    }

    private var surfaceColors: [Color] {
        switch system.iconAppearance {
        case .automatic:
            automaticColors
        case .light:
            [automaticColors.first ?? .white, Color.white.opacity(0.88)]
        case .dark:
            [automaticColors.first?.opacity(0.76) ?? .gray, Color(hex: 0x080A0D)]
        case .clear:
            [Color.white.opacity(0.18), Color.white.opacity(0.045)]
        case .tinted:
            [system.accent.opacity(0.96), Color(hex: 0x10131A)]
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.black.opacity(0.88))

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: surfaceColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RadialGradient(
                colors: [.white.opacity(0.29), .white.opacity(0.075), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: size * 0.82
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .blendMode(.screen)

            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .white.opacity(0.04), location: 0.24),
                    .init(color: .white.opacity(0.31), location: 0.34),
                    .init(color: .white.opacity(0.055), location: 0.45),
                    .init(color: .clear, location: 0.62)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .blendMode(.screen)

            RadialGradient(
                colors: [
                    (app.palette.last ?? .white).opacity(0.12),
                    .clear
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: size * 0.78
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

            PremiumIconGlyph(app: app, size: size)
                .padding(size * 0.17)
        }
        .frame(width: size, height: size)
        .background {
            if system.iconAppearance == .clear {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.48),
                            .white.opacity(0.10),
                            .black.opacity(0.20)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.55
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .inset(by: 1.8)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.16),
                            .clear,
                            .white.opacity(0.055)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.55
                )
        }
        .overlay(alignment: .top) {
            Capsule()
                .fill(.white.opacity(0.34))
                .frame(width: size * 0.48, height: max(0.65, size * 0.012))
                .blur(radius: 0.25)
                .padding(.top, size * 0.035)
                .blendMode(.screen)
        }
        .shadow(color: (app.palette.last ?? .black).opacity(0.13), radius: 9, y: 5)
        .shadow(color: .black.opacity(0.22), radius: 9, y: 5)
    }
}

private struct PremiumIconGlyph: View {
    let app: BuiltInApp
    let size: CGFloat

    @ViewBuilder
    var body: some View {
        switch app {
        case .calendar:
            VStack(spacing: -1) {
                Text(Date.now.formatted(.dateTime.weekday(.abbreviated)).uppercased())
                    .font(.system(size: size * 0.12, weight: .black, design: .default))
                    .tracking(0.6)
                    .foregroundStyle(Color(hex: 0xD93543))
                Text(Date.now.formatted(.dateTime.day()))
                    .font(.system(size: size * 0.39, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: 0x20242A))
            }
        case .photos:
            ZStack {
                ForEach(0..<8, id: \.self) { index in
                    Capsule()
                        .fill(
                            Color(
                                hue: Double(index) / 8.0,
                                saturation: 0.72,
                                brightness: 0.98
                            )
                        )
                        .frame(width: size * 0.11, height: size * 0.31)
                        .offset(y: -size * 0.12)
                        .rotationEffect(.degrees(Double(index) * 45))
                }
                Circle()
                    .fill(.white)
                    .frame(width: size * 0.13, height: size * 0.13)
                    .shadow(color: .black.opacity(0.16), radius: 2, y: 1)
            }
        case .clock:
            ZStack {
                Circle()
                    .fill(Color(hex: 0xF4F0E8))
                    .overlay {
                        Circle().stroke(.white.opacity(0.75), lineWidth: 1)
                    }
                ForEach(0..<12, id: \.self) { index in
                    Capsule()
                        .fill(Color(hex: 0x30343B).opacity(index.isMultiple(of: 3) ? 0.92 : 0.48))
                        .frame(width: index.isMultiple(of: 3) ? 1.8 : 1.1, height: index.isMultiple(of: 3) ? 4.4 : 3)
                        .offset(y: -size * 0.245)
                        .rotationEffect(.degrees(Double(index) * 30))
                }
                Capsule()
                    .fill(Color(hex: 0x20242A))
                    .frame(width: 2.2, height: size * 0.18)
                    .offset(y: -size * 0.07)
                    .rotationEffect(.degrees(-4), anchor: .bottom)
                Capsule()
                    .fill(Color(hex: 0x20242A))
                    .frame(width: 2, height: size * 0.24)
                    .offset(y: -size * 0.10)
                    .rotationEffect(.degrees(92), anchor: .bottom)
                Circle()
                    .fill(Color(hex: 0xD44842))
                    .frame(width: 4, height: 4)
            }
            .padding(size * 0.01)
        case .camera:
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.09, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0xE8EBEF), Color(hex: 0xAAB1BA)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.58, height: size * 0.42)
                Circle()
                    .fill(Color(hex: 0x11151B))
                    .frame(width: size * 0.28, height: size * 0.28)
                    .overlay {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: 0x7DAAD1), Color(hex: 0x282D38)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: size * 0.055
                            )
                    }
                Circle()
                    .fill(.white.opacity(0.82))
                    .frame(width: size * 0.055, height: size * 0.055)
                    .offset(x: size * 0.20, y: -size * 0.12)
            }
        case .weather:
            Image(systemName: "cloud.sun.fill")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: size * 0.48, weight: .semibold))
        case .notes:
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.055, style: .continuous)
                    .fill(Color(hex: 0xFFFDF6))
                    .frame(width: size * 0.52, height: size * 0.55)
                VStack(spacing: size * 0.055) {
                    ForEach(0..<4, id: \.self) { index in
                        Capsule()
                            .fill(Color(hex: 0x8D7853).opacity(0.72))
                            .frame(width: index == 3 ? size * 0.25 : size * 0.36, height: 1.5)
                    }
                }
            }
        case .maps:
            ZStack {
                Image(systemName: "map.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color(hex: 0xF2F3EA), Color(hex: 0x5F9B82))
                    .font(.system(size: size * 0.49, weight: .semibold))
                Image(systemName: "mappin.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color(hex: 0xE24E48), .white)
                    .font(.system(size: size * 0.24, weight: .bold))
                    .offset(x: size * 0.10, y: -size * 0.09)
            }
        case .settings:
            Image(systemName: "gearshape.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: size * 0.48, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(hex: 0xD2D7DE)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.24), radius: 2, y: 1)
        case .health:
            Image(systemName: "heart.fill")
                .font(.system(size: size * 0.43, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: 0xFF5D78), Color(hex: 0xD71F48)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(hex: 0xD71F48).opacity(0.24), radius: 4, y: 2)
        case .browser:
            ZStack {
                Circle()
                    .fill(.white.opacity(0.94))
                Circle()
                    .stroke(Color(hex: 0xD7E6EE), lineWidth: 1)
                Image(systemName: "location.north.fill")
                    .font(.system(size: size * 0.28, weight: .bold))
                    .foregroundStyle(Color(hex: 0x287FD0))
                    .rotationEffect(.degrees(42))
            }
            .padding(size * 0.02)
        default:
            Image(systemName: app.symbol)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.24), radius: 2, y: 1)
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
                SystemStatusBar(foreground: .primary)

                BuiltInAppView(app: app)
                    .environmentObject(system)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                HybridAppNavigationBar()
            }
        }
        .foregroundStyle(.primary)
    }
}

private struct HybridAppNavigationBar: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var dragLift: CGFloat = 0
    @State private var isHintVisible = true

    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 12) {
                Button {
                    system.goHome()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 42, height: 38)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Back to Home")

                Button {
                    system.goHome()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 7, weight: .black))
                            .opacity(isHintVisible ? 0.72 : 0.32)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.primary.opacity(0.96),
                                        Color.primary.opacity(0.66)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 106, height: 5)
                            .shadow(color: Color.primary.opacity(0.20), radius: 5)
                    }
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .contentShape(Rectangle())
                }
                .accessibilityLabel("Home")
                .accessibilityHint("Tap or swipe up to return to the Indica Home Screen")

                Button {
                    system.showSwitcher()
                } label: {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 42, height: 38)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Recent Apps")
            }
            .buttonStyle(PressableButtonStyle(scale: 0.91))

            if isHintVisible {
                Text("Swipe up for Indica Home")
                    .font(.system(size: 8, weight: .semibold, design: .rounded))
                    .tracking(0.3)
                    .foregroundStyle(.secondary)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity)
        .background(Color.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .liquidGlass(cornerRadius: 28, intensity: 0.96)
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.46),
                            .white.opacity(0.10),
                            .black.opacity(0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.75
                )
        }
        .shadow(color: system.accent.opacity(0.10), radius: 16, y: 7)
        .padding(.horizontal, 16)
        .padding(.top, 7)
        .padding(.bottom, 18)
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
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                        dragLift = 0
                    }
                }
        )
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(2.8))
                withAnimation(.easeOut(duration: 0.38)) {
                    isHintVisible = false
                }
            }
        }
    }
}

private struct AppSwitcher: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        VStack(spacing: 0) {
            SystemStatusBar(foreground: system.wallpaper.foreground)

            Spacer(minLength: 42)

            if system.appHistory.isEmpty {
                ContentUnavailableView("No Recent Apps", systemImage: "rectangle.stack")
                    .foregroundStyle(system.wallpaper.foreground)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(system.appHistory) { app in
                            Button {
                                system.open(app)
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        MiniAppMark(app: app)
                                        Text(app.name)
                                            .font(.system(size: 14, weight: .semibold, design: .default))
                                        Spacer()
                                        Button {
                                            withAnimation {
                                                system.appHistory.removeAll { $0 == app }
                                            }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    AppPreviewCard(app: app)
                                }
                                .padding(12)
                                .frame(width: 292, height: 535)
                                .background(Color(uiColor: .systemBackground), in: RoundedRectangle(cornerRadius: 32, style: .continuous))
                                .shadow(color: .black.opacity(0.3), radius: 24, y: 14)
                            }
                            .buttonStyle(PressableButtonStyle(scale: 0.98))
                        }
                    }
                    .padding(.horizontal, 48)
                }
            }

            Spacer()

            Text("Swipe up on a card to close")
                .font(.system(size: 11, weight: .semibold, design: .default))
                .foregroundStyle(system.wallpaper.foreground.opacity(0.65))

            HomeIndicator(color: system.wallpaper.foreground) {
                system.goHome()
            }
            .padding(.top, 17)
            .padding(.bottom, 8)
        }
    }
}

private struct AppPreviewCard: View {
    let app: BuiltInApp

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 23, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(uiColor: .secondarySystemBackground),
                            (app.palette.last ?? .gray).opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 160)
                .overlay {
                    PremiumAppMark(app: app, size: 82)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 23, style: .continuous)
                        .stroke(.white.opacity(0.18), lineWidth: 0.7)
                }

            Text(app.name)
                .font(.system(size: 27, weight: .bold, design: .default))

            ForEach(0..<4, id: \.self) { index in
                HStack(spacing: 11) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(app.palette[index % app.palette.count].opacity(0.22))
                        .frame(width: 38, height: 38)
                    VStack(alignment: .leading, spacing: 5) {
                        Capsule()
                            .fill(Color.primary.opacity(0.18))
                            .frame(width: CGFloat(110 + index * 17), height: 7)
                        Capsule()
                            .fill(Color.primary.opacity(0.09))
                            .frame(width: CGFloat(78 + index * 9), height: 6)
                    }
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
        PremiumAppMark(app: app, size: 26)
    }
}

private struct ControlCenterOverlay: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .background(.black.opacity(0.25))
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                        system.overlay = nil
                    }
                }

            VStack(spacing: 14) {
                SystemStatusBar()

                HStack {
                    Text("Control Center")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Spacer()
                    Button {
                        system.lock()
                    } label: {
                        Image(systemName: "lock.fill")
                            .frame(width: 42, height: 42)
                            .liquidGlass(cornerRadius: 21, intensity: 0.92)
                    }
                }
                .padding(.horizontal, 19)

                HStack(spacing: 12) {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            ControlToggle(symbol: "airplane", isOn: $system.airplaneMode, tint: .orange)
                            ControlToggle(symbol: "antenna.radiowaves.left.and.right", isOn: .constant(true), tint: .green)
                        }
                        HStack(spacing: 12) {
                            ControlToggle(symbol: "wifi", isOn: $system.wifiEnabled, tint: .blue)
                            ControlToggle(symbol: "bolt.horizontal.fill", isOn: $system.bluetoothEnabled, tint: .blue)
                        }
                    }
                    .padding(13)
                    .liquidGlass(cornerRadius: 27, intensity: 0.9)

                    VStack(spacing: 10) {
                        Image(systemName: "waveform")
                            .font(.system(size: 23, weight: .semibold))
                        Text("Quiet Hours")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                        HStack(spacing: 16) {
                            Image(systemName: "backward.fill")
                            Image(systemName: "play.fill")
                            Image(systemName: "forward.fill")
                        }
                        .font(.system(size: 13, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, minHeight: 139)
                    .liquidGlass(cornerRadius: 27, intensity: 0.9)
                }
                .padding(.horizontal, 16)

                HStack(spacing: 12) {
                    VerticalSlider(value: $system.brightness, symbol: "sun.max.fill")
                    VerticalSlider(value: $system.volume, symbol: "speaker.wave.2.fill")
                    VStack(spacing: 12) {
                        WideControl(title: "Focus", symbol: "moon.fill", isOn: $system.isFocusEnabled)
                        WideControl(title: "Screen", symbol: "rectangle.inset.filled")
                    }
                }
                .padding(.horizontal, 16)

                HStack(spacing: 15) {
                    SmallControl(symbol: "flashlight.on.fill")
                    SmallControl(symbol: "timer")
                    SmallControl(symbol: "camera.fill") { system.open(.camera) }
                    SmallControl(symbol: "waveform") { system.open(.voiceMemos) }
                }
                .padding(.horizontal, 18)

                Spacer()

                HomeIndicator()
                    .padding(.bottom, 9)
            }
            .foregroundStyle(.white)
        }
    }
}

private struct ControlToggle: View {
    let symbol: String
    @Binding var isOn: Bool
    let tint: Color

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                isOn.toggle()
            }
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(isOn ? .white : .primary.opacity(0.66))
                .frame(width: 48, height: 48)
                .background(isOn ? tint : Color.primary.opacity(0.08), in: Circle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

private struct VerticalSlider: View {
    @Binding var value: Double
    let symbol: String

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(.white.opacity(0.11))

                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(.white.opacity(0.92))
                    .frame(height: max(48, proxy.size.height * value))

                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(value > 0.3 ? .black : .white)
                    .padding(.bottom, 17)
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
        .liquidGlass(cornerRadius: 27, intensity: 0.88)
    }
}

private struct WideControl: View {
    let title: String
    let symbol: String
    var isOn: Binding<Bool>?

    init(title: String, symbol: String, isOn: Binding<Bool>? = nil) {
        self.title = title
        self.symbol = symbol
        self.isOn = isOn
    }

    var body: some View {
        Button {
            isOn?.wrappedValue.toggle()
        } label: {
            HStack(spacing: 11) {
                Image(systemName: symbol)
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                Spacer()
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 81)
            .background((isOn?.wrappedValue == true ? Color.indigo : .clear).opacity(0.78), in: RoundedRectangle(cornerRadius: 23, style: .continuous))
            .liquidGlass(cornerRadius: 23, intensity: 0.82)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

private struct SmallControl: View {
    let symbol: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 62)
                .liquidGlass(cornerRadius: 23, intensity: 0.86)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

private struct NotificationCenterOverlay: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        ZStack {
            IndicaWallpaper(style: system.wallpaper)
                .blur(radius: 14)
                .overlay(.black.opacity(0.18))
                .onTapGesture {
                    withAnimation { system.overlay = nil }
                }

            VStack(spacing: 0) {
                SystemStatusBar(foreground: system.wallpaper.foreground)

                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Notifications")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                        Text("\(system.notifications.count) recent")
                            .font(.system(size: 13, weight: .semibold))
                            .opacity(0.64)
                    }
                    Spacer()
                    Button("Clear") {
                        withAnimation {
                            system.notifications.removeAll()
                        }
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .liquidGlass(cornerRadius: 17, intensity: 0.8)
                }
                .padding(.horizontal, 17)
                .padding(.top, 14)

                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(system.notifications) { notification in
                            NotificationCard(notification: notification)
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
                    .padding(13)
                }

                HomeIndicator(color: system.wallpaper.foreground) {
                    withAnimation { system.overlay = nil }
                }
                .padding(.bottom, 8)
            }
            .foregroundStyle(system.wallpaper.foreground)
        }
    }
}

private struct NotificationCard: View {
    let notification: SystemNotification
    var compact = false

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            MiniAppMark(app: notification.app)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(notification.title)
                        .font(.system(size: 14, weight: .semibold, design: .default))
                    Spacer()
                    Text(notification.date, style: .relative)
                        .font(.system(size: 10, weight: .medium))
                        .opacity(0.54)
                }
                Text(notification.body)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .lineLimit(compact ? 1 : 3)
                    .opacity(0.82)
            }
        }
        .padding(13)
        .background(.black.opacity(0.08), in: RoundedRectangle(cornerRadius: 21, style: .continuous))
        .liquidGlass(cornerRadius: 21, intensity: 0.70)
    }
}

private struct WallpaperPickerOverlay: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.34)
                .onTapGesture {
                    withAnimation { system.overlay = nil }
                }

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Wallpapers")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        Text("Changes apply to Lock and Home.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Done") {
                        withAnimation { system.overlay = nil }
                    }
                    .fontWeight(.bold)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(WallpaperStyle.allCases) { wallpaper in
                            Button {
                                withAnimation(.spring(response: 0.44, dampingFraction: 0.86)) {
                                    system.wallpaper = wallpaper
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    IndicaWallpaper(style: wallpaper)
                                        .frame(width: 128, height: 218)
                                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                                .stroke(system.wallpaper == wallpaper ? system.accent : .white.opacity(0.22), lineWidth: system.wallpaper == wallpaper ? 4 : 1)
                                        }
                                    Text(wallpaper.rawValue)
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                }
                            }
                            .buttonStyle(PressableButtonStyle(scale: 0.97))
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 18)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
        }
        .foregroundStyle(.primary)
    }
}

private struct LockCustomizationOverlay: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .onTapGesture { withAnimation { system.overlay = nil } }

            VStack(spacing: 18) {
                HStack {
                    Text("Customize")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                    Spacer()
                    Button("Done") {
                        withAnimation { system.overlay = nil }
                    }
                    .fontWeight(.bold)
                }

                IndicaWallpaper(style: system.wallpaper)
                    .overlay {
                        VStack {
                            Text("Friday, July 17")
                                .font(.system(size: 11, weight: .semibold))
                            Text("9:41")
                                .font(.system(size: 52, weight: .medium, design: .rounded))
                            HStack(spacing: 7) {
                                LockWidget(symbol: "cloud.sun.fill", title: "72°", detail: "Weather")
                                LockWidget(symbol: "calendar", title: "2:30", detail: "Next")
                            }
                            .padding(10)
                            Spacer()
                        }
                        .padding(.top, 32)
                        .foregroundStyle(system.wallpaper.foreground)
                    }
                    .frame(height: 475)
                    .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(.white.opacity(0.28))
                    }

                HStack(spacing: 12) {
                    Button {
                        withAnimation { system.overlay = .wallpaper }
                    } label: {
                        Label("Wallpaper", systemImage: "photo.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(system.accent, in: Capsule())
                            .foregroundStyle(.white)
                    }

                    Button {
                        let index = WallpaperStyle.allCases.firstIndex(of: system.wallpaper) ?? 0
                        system.wallpaper = WallpaperStyle.allCases[(index + 1) % WallpaperStyle.allCases.count]
                    } label: {
                        Image(systemName: "shuffle")
                            .frame(width: 48, height: 48)
                            .background(Color.primary.opacity(0.08), in: Circle())
                    }
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .padding(20)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 36, style: .continuous))
            .padding(20)
        }
        .foregroundStyle(.primary)
    }
}

struct HomeIndicator: View {
    var color: Color = .white
    var action: (() -> Void)?

    init(color: Color = .white, action: (() -> Void)? = nil) {
        self.color = color
        self.action = action
    }

    var body: some View {
        Button {
            action?()
        } label: {
            Capsule()
                .fill(color.opacity(0.88))
                .frame(width: 134, height: 5)
                .frame(maxWidth: .infinity, minHeight: 16)
        }
        .buttonStyle(.plain)
    }
}

struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.92

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .brightness(configuration.isPressed ? 0.05 : 0)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

private struct LiquidGlassModifier: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var systemReduceTransparency
    @EnvironmentObject private var system: IndicaSystem
    let cornerRadius: CGFloat
    let intensity: Double

    private var resolvedIntensity: Double {
        min(1.45, max(0.24, intensity * system.glassIntensity * 1.18))
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if system.reduceTransparency || systemReduceTransparency {
            content
                .background(
                    Color(uiColor: .secondarySystemBackground).opacity(0.96),
                    in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 0.8)
                }
                .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
        } else if #available(iOS 26.0, *) {
            content
                .glassEffect(
                    .regular,
                    in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
                .overlay {
                    GlassSpecularSheen(
                        cornerRadius: cornerRadius,
                        intensity: resolvedIntensity
                    )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.48 * resolvedIntensity),
                                    .white.opacity(0.10),
                                    Color(hex: 0xD9B99C).opacity(0.15 * resolvedIntensity),
                                    .black.opacity(0.16)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.65
                        )
                }
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(.white.opacity(0.24 * resolvedIntensity))
                        .frame(height: 1)
                        .padding(.horizontal, cornerRadius * 0.88)
                        .padding(.top, 1)
                }
                .shadow(color: system.accent.opacity(0.055 * resolvedIntensity), radius: 18, y: 4)
                .shadow(color: .black.opacity(0.19 * resolvedIntensity), radius: 19, y: 9)
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .background(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.16 * resolvedIntensity),
                            .white.opacity(0.035 * resolvedIntensity),
                            system.accent.opacity(0.045 * resolvedIntensity),
                            .black.opacity(0.06 * resolvedIntensity)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
                .overlay {
                    GlassSpecularSheen(
                        cornerRadius: cornerRadius,
                        intensity: resolvedIntensity
                    )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.54 * resolvedIntensity),
                                    .white.opacity(0.12),
                                    .black.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                }
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(.white.opacity(0.22 * resolvedIntensity))
                        .frame(height: 1)
                        .padding(.horizontal, cornerRadius * 0.8)
                        .padding(.top, 1)
                }
                .shadow(color: system.accent.opacity(0.05 * resolvedIntensity), radius: 16, y: 4)
                .shadow(color: .black.opacity(0.16 * resolvedIntensity), radius: 16, y: 8)
        }
    }
}

private struct GlassSpecularSheen: View {
    let cornerRadius: CGFloat
    let intensity: Double

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: .white.opacity(0.25 * intensity), location: 0),
                        .init(color: .white.opacity(0.08 * intensity), location: 0.23),
                        .init(color: .clear, location: 0.46),
                        .init(color: .clear, location: 0.73),
                        .init(color: .white.opacity(0.035 * intensity), location: 1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(alignment: .topLeading) {
                Ellipse()
                    .fill(.white.opacity(0.15 * intensity))
                    .frame(width: max(28, cornerRadius * 2.8), height: max(10, cornerRadius * 0.72))
                    .blur(radius: max(5, cornerRadius * 0.38))
                    .offset(x: -cornerRadius * 0.25, y: -cornerRadius * 0.38)
            }
            .blendMode(.screen)
            .allowsHitTesting(false)
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 24, intensity: Double = 1) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius, intensity: intensity))
    }
}
