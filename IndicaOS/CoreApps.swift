import SwiftUI
import MapKit

struct BuiltInAppView: View {
    @EnvironmentObject private var system: IndicaSystem
    let app: BuiltInApp

    @ViewBuilder
    var body: some View {
        switch app {
        case .phone:
            PhoneApp()
        case .messages:
            MessagesApp()
        case .camera:
            CameraApp()
        case .photos:
            PhotosApp()
        case .browser:
            BrowserApp()
        case .mail:
            MailApp()
        case .maps:
            MapsApp()
        case .weather:
            WeatherApp()
        case .calendar:
            CalendarApp()
        case .clock:
            ClockApp()
        case .notes:
            NotesApp()
        case .reminders:
            RemindersApp()
        case .files:
            FilesApp()
        case .music:
            MusicApp()
        case .settings:
            SettingsApp()
        case .calculator:
            CalculatorApp()
        case .voiceMemos:
            VoiceMemosApp()
        case .translate:
            TranslateApp()
        case .home:
            SmartHomeApp()
        case .wallet:
            WalletApp()
        case .health:
            HealthApp()
        case .shortcuts:
            ShortcutsApp()
        case .find:
            FindApp()
        case .contacts:
            ContactsApp()
        case .video, .podcasts, .news, .books, .store:
            MediaCatalogApp(app: app)
        case .compass, .measure, .magnifier, .stocks, .fitness:
            SensorUtilityApp(app: app)
        case .tips, .canvas, .journal, .passwords, .watch, .videoCall:
            EverydayApp(app: app)
        case .accounts:
            ConnectionsApp()
        case .chatGPT, .claude:
            AIAssistantApp(app: app)
        case .spotify, .youtube, .notion, .discord, .telegram, .gmail, .outlook:
            ConnectedServiceApp(app: app)
        }
    }
}

private struct PhoneApp: View {
    @State private var tab = 1
    @State private var number = ""
    @State private var activeCall: String?

    private let recents = [
        ("Maya Chen", "mobile", "10:42 AM", false),
        ("Studio", "work", "Yesterday", true),
        ("Jordan Lee", "mobile", "Monday", false),
        ("Unknown", "New York, NY", "Sunday", true)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Phone section", selection: $tab) {
                    Text("Recents").tag(0)
                    Text("Keypad").tag(1)
                    Text("Voicemail").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 12)

                if tab == 0 {
                    List {
                        ForEach(Array(recents.enumerated()), id: \.offset) { _, recent in
                            Button {
                                activeCall = recent.0
                            } label: {
                                HStack(spacing: 13) {
                                    Image(systemName: recent.3 ? "phone.arrow.down.left.fill" : "phone.fill")
                                        .foregroundStyle(recent.3 ? .red : .green)
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(recent.0)
                                            .font(.headline)
                                            .foregroundStyle(recent.3 ? .red : .primary)
                                        Text(recent.1)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(recent.2)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Image(systemName: "info.circle")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                } else if tab == 1 {
                    VStack(spacing: 15) {
                        Text(number.isEmpty ? " " : number)
                            .font(.system(size: 30, weight: .medium, design: .rounded))
                            .minimumScaleFactor(0.7)
                            .frame(height: 48)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 13) {
                            ForEach(["1", "2\nABC", "3\nDEF", "4\nGHI", "5\nJKL", "6\nMNO", "7\nPQRS", "8\nTUV", "9\nWXYZ", "*", "0\n+", "#"], id: \.self) { key in
                                Button {
                                    number.append(contentsOf: key.prefix(1))
                                } label: {
                                    VStack(spacing: -2) {
                                        Text(String(key.prefix(1)))
                                            .font(.system(size: 28, weight: .regular, design: .rounded))
                                        if key.contains("\n") {
                                            Text(String(key.split(separator: "\n").last ?? ""))
                                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                                .tracking(1.4)
                                        }
                                    }
                                    .frame(width: 72, height: 72)
                                    .background(Color.primary.opacity(0.085), in: Circle())
                                }
                                .buttonStyle(PressableButtonStyle())
                            }
                        }

                        HStack(spacing: 34) {
                            Color.clear.frame(width: 62, height: 62)
                            Button {
                                guard !number.isEmpty else { return }
                                activeCall = number
                            } label: {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 64, height: 64)
                                    .background(.green, in: Circle())
                            }
                            .buttonStyle(PressableButtonStyle())

                            Button {
                                if !number.isEmpty { number.removeLast() }
                            } label: {
                                Image(systemName: "delete.left.fill")
                                    .frame(width: 62, height: 62)
                            }
                            .opacity(number.isEmpty ? 0 : 1)
                        }
                    }
                    .padding(.horizontal, 30)
                } else {
                    List {
                        Label("No new voicemail", systemImage: "waveform.circle")
                            .foregroundStyle(.secondary)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Phone")
            .sheet(item: $activeCall) { contact in
                CallScreen(contact: contact)
            }
        }
    }
}

private struct CallScreen: View {
    let contact: String
    @Environment(\.dismiss) private var dismiss
    @State private var muted = false
    @State private var speaker = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0x272A35), Color(hex: 0x090A0D)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Text(contact)
                    .font(.system(size: 31, weight: .semibold, design: .rounded))
                Text("calling…")
                    .foregroundStyle(.white.opacity(0.64))

                Spacer()

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 22) {
                    CallAction(symbol: "mic.slash.fill", title: "mute", isOn: $muted)
                    CallAction(symbol: "circle.grid.3x3.fill", title: "keypad")
                    CallAction(symbol: "speaker.wave.2.fill", title: "audio", isOn: $speaker)
                    CallAction(symbol: "plus", title: "add call")
                    CallAction(symbol: "video.fill", title: "video")
                    CallAction(symbol: "person.crop.circle", title: "contacts")
                }

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 27, weight: .semibold))
                        .frame(width: 72, height: 72)
                        .background(.red, in: Circle())
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.bottom, 42)
            }
            .padding(.horizontal, 28)
            .padding(.top, 38)
            .foregroundStyle(.white)
        }
    }
}

private struct CallAction: View {
    let symbol: String
    let title: String
    var isOn: Binding<Bool>?

    init(symbol: String, title: String, isOn: Binding<Bool>? = nil) {
        self.symbol = symbol
        self.title = title
        self.isOn = isOn
    }

    var body: some View {
        Button {
            isOn?.wrappedValue.toggle()
        } label: {
            VStack(spacing: 7) {
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 62, height: 62)
                    .background(isOn?.wrappedValue == true ? .white : .white.opacity(0.15), in: Circle())
                    .foregroundStyle(isOn?.wrappedValue == true ? .black : .white)
                Text(title)
                    .font(.caption)
            }
        }
        .buttonStyle(PressableButtonStyle())
    }
}

private struct MessagesApp: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var draft = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 9) {
                        ForEach(system.messages) { message in
                            HStack {
                                if message.isMine { Spacer(minLength: 62) }
                                Text(message.text)
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(message.isMine ? Color.blue : Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 19, style: .continuous))
                                    .foregroundStyle(message.isMine ? .white : .primary)
                                if !message.isMine { Spacer(minLength: 62) }
                            }
                        }
                    }
                    .padding()
                }

                HStack(spacing: 9) {
                    Button {} label: {
                        Image(systemName: "plus")
                            .frame(width: 34, height: 34)
                            .background(Color.primary.opacity(0.08), in: Circle())
                    }
                    TextField("Message", text: $draft, axis: .vertical)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 9)
                        .background(Color.primary.opacity(0.07), in: Capsule())
                    Button {
                        send()
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue, in: Circle())
                    }
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.bar)
            }
            .navigationTitle("Maya")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {} label: { Image(systemName: "chevron.left") }
                }
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom))
                            .frame(width: 30, height: 30)
                            .overlay(Text("M").foregroundStyle(.white).fontWeight(.bold))
                        Text("Maya")
                            .font(.caption2)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: { Image(systemName: "video.fill") }
                }
            }
        }
    }

    private func send() {
        let clean = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.84)) {
            system.messages.append(MessageItem(text: clean, isMine: true))
            draft = ""
        }
    }
}

private struct CameraApp: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var mode = "PHOTO"
    @State private var flash = false
    @State private var captured = false

    private let modes = ["VIDEO", "PHOTO", "PORTRAIT"]

    var body: some View {
        ZStack {
            Color.black

            GeometryReader { proxy in
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: 0x151A24), Color(hex: 0x4D6575), Color(hex: 0xD5A076)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Circle()
                        .fill(.white.opacity(0.28))
                        .frame(width: 260)
                        .blur(radius: 40)
                        .offset(x: 120, y: -230)

                    VStack {
                        HStack {
                            Button {
                                flash.toggle()
                            } label: {
                                Image(systemName: flash ? "bolt.fill" : "bolt.slash.fill")
                                    .foregroundStyle(flash ? .yellow : .white)
                                    .frame(width: 42, height: 42)
                                    .background(.black.opacity(0.3), in: Circle())
                            }
                            Spacer()
                            Button {} label: {
                                Image(systemName: "chevron.down")
                                    .frame(width: 42, height: 42)
                                    .background(.black.opacity(0.3), in: Circle())
                            }
                            Spacer()
                            Button {} label: {
                                Image(systemName: "camera.filters")
                                    .frame(width: 42, height: 42)
                                    .background(.black.opacity(0.3), in: Circle())
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 16)

                        Spacer()

                        ZStack {
                            RoundedRectangle(cornerRadius: 11)
                                .stroke(.yellow, lineWidth: 1)
                                .frame(width: 84, height: 84)
                            Text("AE/AF")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                                .offset(y: -51)
                        }
                        .opacity(captured ? 1 : 0)

                        Spacer()

                        VStack(spacing: 16) {
                            Picker("Camera mode", selection: $mode) {
                                ForEach(modes, id: \.self) { Text($0).tag($0) }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 50)

                            HStack {
                                Button {
                                    system.open(.photos)
                                } label: {
                                    RoundedRectangle(cornerRadius: 9)
                                        .fill(LinearGradient(colors: [.purple, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 46, height: 46)
                                        .overlay {
                                            Text("\(system.capturedMoments)")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                        }
                                }

                                Spacer()

                                Button {
                                    capture()
                                } label: {
                                    Circle()
                                        .stroke(.white, lineWidth: 4)
                                        .frame(width: 74, height: 74)
                                        .overlay {
                                            Circle()
                                                .fill(.white)
                                                .frame(width: 62, height: 62)
                                                .scaleEffect(captured ? 0.86 : 1)
                                        }
                                }
                                .buttonStyle(PressableButtonStyle())

                                Spacer()

                                Button {} label: {
                                    Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                                        .font(.system(size: 22, weight: .semibold))
                                        .frame(width: 46, height: 46)
                                        .background(.black.opacity(0.45), in: Circle())
                                }
                            }
                            .padding(.horizontal, 30)
                        }
                        .padding(.vertical, 18)
                        .background(.black.opacity(0.46))
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .foregroundStyle(.white)
    }

    private func capture() {
        system.capturedMoments += 1
        withAnimation(.easeOut(duration: 0.1)) { captured = true }
        Task {
            try? await Task.sleep(for: .milliseconds(180))
            withAnimation(.easeIn(duration: 0.18)) { captured = false }
        }
    }
}

private struct PhotosApp: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var selectedIndex: Int?

    private let colors: [[Color]] = [
        [.pink, .orange], [.blue, .cyan], [.purple, .pink], [.green, .mint],
        [.indigo, .blue], [.orange, .yellow], [.teal, .blue], [.red, .purple]
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                    ForEach(0..<(24 + system.capturedMoments), id: \.self) { index in
                        Button {
                            selectedIndex = index
                        } label: {
                            ZStack {
                                LinearGradient(
                                    colors: colors[index % colors.count],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                Image(systemName: index % 3 == 0 ? "mountain.2.fill" : index % 3 == 1 ? "person.crop.square.fill" : "sparkles")
                                    .font(.system(size: 26, weight: .light))
                                    .foregroundStyle(.white.opacity(0.72))
                            }
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
            .navigationTitle("Photos")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("\(24 + system.capturedMoments) Items")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Select") {}
                }
            }
            .sheet(item: $selectedIndex) { index in
                PhotoDetail(index: index, colors: colors[index % colors.count])
            }
        }
    }
}

private struct PhotoDetail: View {
    let index: Int
    let colors: [Color]
    @Environment(\.dismiss) private var dismiss
    @State private var favorite = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                Image(systemName: "photo.artframe")
                    .font(.system(size: 90, weight: .thin))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .navigationTitle("Moment \(index + 1)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        favorite.toggle()
                    } label: {
                        Image(systemName: favorite ? "heart.fill" : "heart")
                    }
                    Spacer()
                    Button {} label: { Image(systemName: "square.and.arrow.up") }
                    Spacer()
                    Button(role: .destructive) {} label: { Image(systemName: "trash") }
                }
            }
        }
    }
}

private struct BrowserApp: View {
    @State private var address = "indica://start"
    @State private var pageTitle = "Start Page"
    @State private var pageBody = "A calm place to begin."
    @State private var history: [String] = []
    @FocusState private var isAddressFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(pageTitle)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text(pageBody)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)

                    if pageTitle == "Start Page" {
                        Text("Favorites")
                            .font(.title2.bold())
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 18) {
                            ForEach([
                                ("Design", "paintpalette.fill", Color.purple),
                                ("Music", "music.note", Color.pink),
                                ("News", "newspaper.fill", Color.red),
                                ("Weather", "cloud.sun.fill", Color.blue)
                            ], id: \.0) { item in
                                Button {
                                    address = item.0.lowercased()
                                    load()
                                } label: {
                                    VStack(spacing: 7) {
                                        Image(systemName: item.1)
                                            .font(.system(size: 22))
                                            .foregroundStyle(.white)
                                            .frame(width: 53, height: 53)
                                            .background(item.2, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        Text(item.0)
                                            .font(.caption)
                                            .foregroundStyle(.primary)
                                    }
                                }
                            }
                        }

                        Text("Privacy Report")
                            .font(.title2.bold())
                            .padding(.top, 8)
                        Label("Indica blocked 12 trackers in this demo session.", systemImage: "hand.raised.fill")
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }
                .padding(20)
            }

            VStack(spacing: 9) {
                HStack {
                    Button {
                        if let last = history.popLast() {
                            address = last
                            load(recordHistory: false)
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Button {} label: { Image(systemName: "chevron.right") }
                    Spacer()
                    Button {} label: { Image(systemName: "square.and.arrow.up") }
                    Spacer()
                    Button {} label: { Image(systemName: "book") }
                    Spacer()
                    Button {} label: { Image(systemName: "square.on.square") }
                }
                .font(.system(size: 17, weight: .semibold))
                .padding(.horizontal, 18)

                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                    TextField("Search or enter address", text: $address)
                        .focused($isAddressFocused)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.go)
                        .onSubmit { load() }
                    Button {
                        address = ""
                        isAddressFocused = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 13)
                .frame(height: 42)
                .background(Color.primary.opacity(0.07), in: Capsule())
                .padding(.horizontal, 10)
            }
            .padding(.vertical, 9)
            .background(.bar)
        }
    }

    private func load(recordHistory: Bool = true) {
        let query = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        if recordHistory {
            history.append(pageTitle == "Start Page" ? "indica://start" : pageTitle.lowercased())
        }
        if query.contains("weather") {
            pageTitle = "Weather"
            pageBody = "72°, partly cloudy. A light shower may arrive after sunset."
        } else if query.contains("music") {
            pageTitle = "Now Playing"
            pageBody = "Quiet Hours, an original demo playlist for Indica OS."
        } else if query.contains("design") {
            pageTitle = "Indica Design"
            pageBody = "Clarity first. Material responds to content, motion explains state, and personality lives in details."
        } else if query.contains("news") {
            pageTitle = "Today"
            pageBody = "Indica OS prototype reaches its first interactive system build."
        } else if query.contains("start") {
            pageTitle = "Start Page"
            pageBody = "A calm place to begin."
        } else {
            pageTitle = query.capitalized
            pageBody = "This offline simulator rendered a local preview for “\(query)”. Enter weather, design, music, or news to explore the demo."
        }
        isAddressFocused = false
    }
}

private struct MailApp: View {
    @State private var showingComposer = false
    @State private var unread = Set([0, 2])

    private let mail = [
        ("Indica Design", "Review notes", "The Lock Screen direction is ready for feedback.", "11:24 AM"),
        ("Maya", "Tonight?", "I found a place near the studio.", "10:08 AM"),
        ("Build System", "Prototype succeeded", "All simulator checks completed successfully.", "Yesterday"),
        ("Community", "Your weekly digest", "New ideas from people you follow.", "Monday")
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(mail.enumerated()), id: \.offset) { index, item in
                    Button {
                        unread.remove(index)
                    } label: {
                        HStack(alignment: .top, spacing: 11) {
                            Circle()
                                .fill(unread.contains(index) ? .blue : .clear)
                                .frame(width: 9, height: 9)
                                .padding(.top, 6)
                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(item.0)
                                        .font(.headline)
                                    Spacer()
                                    Text(item.3)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text(item.1)
                                    .fontWeight(unread.contains(index) ? .semibold : .regular)
                                Text(item.2)
                                    .lineLimit(2)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Inbox")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Edit") {}
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingComposer = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingComposer) {
                MailComposer()
            }
        }
    }
}

private struct MailComposer: View {
    @Environment(\.dismiss) private var dismiss
    @State private var to = ""
    @State private var subject = ""
    @State private var bodyText = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("To", text: $to)
                    .textInputAutocapitalization(.never)
                TextField("Subject", text: $subject)
                TextEditor(text: $bodyText)
                    .frame(minHeight: 250)
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") { dismiss() }
                        .disabled(to.isEmpty)
                }
            }
        }
    }
}

private struct MapsApp: View {
    @State private var search = ""
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
        )
    )
    @State private var selectedPlace = "Brooklyn"

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                Marker("Studio", coordinate: CLLocationCoordinate2D(latitude: 40.718, longitude: -73.958))
                    .tint(.purple)
                Marker("Coffee", coordinate: CLLocationCoordinate2D(latitude: 40.724, longitude: -73.995))
                    .tint(.orange)
            }
            .mapStyle(.standard(elevation: .realistic))

            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search Maps", text: $search)
                        .submitLabel(.search)
                        .onSubmit {
                            selectedPlace = search.isEmpty ? "Brooklyn" : search
                        }
                    Image(systemName: "mic.fill")
                }
                .padding(.horizontal, 14)
                .frame(height: 45)
                .background(.regularMaterial, in: Capsule())

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedPlace)
                            .font(.title3.bold())
                        Text("12 min away · Light traffic")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {} label: {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(.blue, in: Circle())
                    }
                }
                .padding(15)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .padding(14)
        }
    }
}

private struct WeatherApp: View {
    @State private var cityIndex = 0

    private let cities = [
        ("Brooklyn", 72, "Partly Cloudy", Color(hex: 0x3478CE), Color(hex: 0x73B7E8)),
        ("Los Angeles", 84, "Sunny", Color(hex: 0xE88548), Color(hex: 0xF6C164)),
        ("London", 61, "Light Rain", Color(hex: 0x445A7A), Color(hex: 0x8197AE))
    ]

    var body: some View {
        let city = cities[cityIndex]
        ZStack {
            LinearGradient(colors: [city.3, city.4], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    Menu {
                        ForEach(cities.indices, id: \.self) { index in
                            Button(cities[index].0) { cityIndex = index }
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(city.0)
                                .font(.system(size: 31, weight: .medium, design: .rounded))
                            Text("\(city.1)°")
                                .font(.system(size: 88, weight: .thin, design: .rounded))
                            Text(city.2)
                                .font(.headline)
                            Text("H: \(city.1 + 4)°  L: \(city.1 - 9)°")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.white)
                    }

                    HStack {
                        ForEach(0..<5, id: \.self) { index in
                            VStack(spacing: 9) {
                                Text(index == 0 ? "Now" : "\(index + 1) PM")
                                    .font(.caption)
                                Image(systemName: index > 2 ? "cloud.rain.fill" : "cloud.sun.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .font(.title3)
                                Text("\(city.1 - index)°")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(15)
                    .liquidGlass(cornerRadius: 24, intensity: 0.75)

                    VStack(alignment: .leading, spacing: 15) {
                        Label("10-DAY FORECAST", systemImage: "calendar")
                            .font(.caption.bold())
                            .opacity(0.66)
                        ForEach(0..<7, id: \.self) { day in
                            HStack {
                                Text(day == 0 ? "Today" : Calendar.current.weekdaySymbols[(day + 5) % 7])
                                    .frame(width: 80, alignment: .leading)
                                Image(systemName: day % 3 == 2 ? "cloud.rain.fill" : "cloud.sun.fill")
                                    .symbolRenderingMode(.multicolor)
                                Spacer()
                                Text("\(city.1 - 9 - day)°")
                                    .opacity(0.62)
                                Capsule()
                                    .fill(LinearGradient(colors: [.cyan, .yellow], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: 92, height: 5)
                                Text("\(city.1 + 3 - day)°")
                            }
                            .font(.subheadline.weight(.semibold))
                            if day < 6 { Divider().opacity(0.24) }
                        }
                    }
                    .padding(16)
                    .liquidGlass(cornerRadius: 24, intensity: 0.75)
                }
                .padding(16)
                .padding(.top, 24)
            }
        }
        .foregroundStyle(.white)
    }
}

private struct CalendarApp: View {
    @State private var selectedDay = 17
    @State private var events: [Int: [String]] = [
        17: ["Design review · 2:30 PM", "Dinner with Maya · 7:00 PM"],
        21: ["Prototype handoff · 10:00 AM"]
    ]
    @State private var showingAdd = false
    @State private var newEvent = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    HStack {
                        ForEach(Calendar.current.veryShortWeekdaySymbols, id: \.self) { day in
                            Text(day)
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                        ForEach(1...31, id: \.self) { day in
                            Button {
                                selectedDay = day
                            } label: {
                                VStack(spacing: 4) {
                                    Text("\(day)")
                                        .font(.system(size: 15, weight: selectedDay == day ? .bold : .medium, design: .rounded))
                                        .frame(width: 34, height: 34)
                                        .background(selectedDay == day ? .red : .clear, in: Circle())
                                        .foregroundStyle(selectedDay == day ? .white : .primary)
                                    Circle()
                                        .fill(events[day]?.isEmpty == false ? Color.red : .clear)
                                        .frame(width: 4, height: 4)
                                }
                            }
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("July \(selectedDay)")
                            .font(.title2.bold())
                        if let dayEvents = events[selectedDay], !dayEvents.isEmpty {
                            ForEach(dayEvents, id: \.self) { event in
                                HStack(spacing: 12) {
                                    Capsule()
                                        .fill(.red)
                                        .frame(width: 4, height: 45)
                                    Text(event)
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        } else {
                            ContentUnavailableView("No Events", systemImage: "calendar.badge.plus", description: Text("Tap + to add one."))
                                .frame(height: 180)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .navigationTitle("July 2026")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: { Image(systemName: "plus") }
                }
            }
            .alert("New Event", isPresented: $showingAdd) {
                TextField("Event name", text: $newEvent)
                Button("Cancel", role: .cancel) {}
                Button("Add") {
                    guard !newEvent.isEmpty else { return }
                    events[selectedDay, default: []].append(newEvent)
                    newEvent = ""
                }
            }
        }
    }
}

private struct ClockApp: View {
    @State private var tab = 0
    @State private var endDate: Date?
    @State private var timerSeconds = 300.0

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Clock mode", selection: $tab) {
                    Text("World").tag(0)
                    Text("Alarm").tag(1)
                    Text("Timer").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()

                if tab == 0 {
                    List {
                        ClockRow(city: "New York", offset: "Today, -3HRS", time: Date())
                        ClockRow(city: "London", offset: "Today, +2HRS", time: Date().addingTimeInterval(5 * 3600))
                        ClockRow(city: "Tokyo", offset: "Tomorrow, +11HRS", time: Date().addingTimeInterval(13 * 3600))
                    }
                    .listStyle(.plain)
                } else if tab == 1 {
                    List {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("7:30")
                                    .font(.largeTitle)
                                Text("Weekdays · Morning")
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: .constant(true))
                        }
                        HStack {
                            VStack(alignment: .leading) {
                                Text("9:00")
                                    .font(.largeTitle)
                                Text("Saturday · Studio")
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: .constant(false))
                        }
                    }
                    .listStyle(.plain)
                } else {
                    VStack(spacing: 30) {
                        Spacer()
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            let remaining = max(0, Int((endDate ?? context.date).timeIntervalSince(context.date)))
                            Text(String(format: "%02d:%02d", remaining / 60, remaining % 60))
                                .font(.system(size: 78, weight: .thin, design: .rounded))
                                .monospacedDigit()
                        }
                        Slider(value: $timerSeconds, in: 60...3600, step: 60)
                            .padding(.horizontal, 32)
                        Text("\(Int(timerSeconds / 60)) minutes")
                            .foregroundStyle(.secondary)
                        Button {
                            if endDate == nil {
                                endDate = .now.addingTimeInterval(timerSeconds)
                            } else {
                                endDate = nil
                            }
                        } label: {
                            Text(endDate == nil ? "Start" : "Cancel")
                                .font(.headline)
                                .frame(width: 86, height: 86)
                                .background(endDate == nil ? Color.green.opacity(0.2) : Color.red.opacity(0.2), in: Circle())
                                .foregroundStyle(endDate == nil ? .green : .red)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Clock")
        }
    }
}

private struct ClockRow: View {
    let city: String
    let offset: String
    let time: Date

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(city)
                    .font(.title2)
                Text(offset)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(time, format: .dateTime.hour().minute())
                .font(.system(size: 38, weight: .light, design: .rounded))
        }
        .padding(.vertical, 6)
    }
}

private struct NotesApp: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var editor: NoteItem?

    var body: some View {
        NavigationStack {
            List {
                ForEach(system.notes.sorted { $0.modified > $1.modified }) { note in
                    Button {
                        editor = note
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title.isEmpty ? "Untitled" : note.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(note.body)
                                .lineLimit(1)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(note.modified, style: .relative)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .onDelete { offsets in
                    let sorted = system.notes.sorted { $0.modified > $1.modified }
                    let ids = offsets.map { sorted[$0].id }
                    system.notes.removeAll { ids.contains($0.id) }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editor = NoteItem(title: "", body: "")
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(item: $editor) { note in
                NoteEditor(note: note)
            }
        }
    }
}

private struct NoteEditor: View {
    @EnvironmentObject private var system: IndicaSystem
    @Environment(\.dismiss) private var dismiss
    @State private var note: NoteItem

    init(note: NoteItem) {
        _note = State(initialValue: note)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextField("Title", text: $note.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .padding(.horizontal)
                    .padding(.top)
                TextEditor(text: $note.body)
                    .font(.body)
                    .padding(.horizontal, 11)
            }
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        note.modified = .now
                        if let index = system.notes.firstIndex(where: { $0.id == note.id }) {
                            system.notes[index] = note
                        } else {
                            system.notes.append(note)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct RemindersApp: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var newReminder = ""

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("New reminder", text: $newReminder)
                        .textFieldStyle(.roundedBorder)
                    Button("Add") {
                        guard !newReminder.isEmpty else { return }
                        withAnimation {
                            system.reminders.append(ReminderItem(title: newReminder))
                            newReminder = ""
                        }
                    }
                    .fontWeight(.semibold)
                }
                .padding()

                List {
                    Section("My List") {
                        ForEach($system.reminders) { $reminder in
                            HStack(spacing: 12) {
                                Button {
                                    reminder.isComplete.toggle()
                                } label: {
                                    Image(systemName: reminder.isComplete ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundStyle(reminder.isComplete ? .blue : .secondary)
                                }
                                Text(reminder.title)
                                    .strikethrough(reminder.isComplete)
                                    .foregroundStyle(reminder.isComplete ? .secondary : .primary)
                            }
                        }
                        .onDelete { system.reminders.remove(atOffsets: $0) }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Reminders")
        }
    }
}

private struct FilesApp: View {
    @State private var folders = ["Indica Projects", "Downloads", "On My iPhone"]
    @State private var showingNewFolder = false
    @State private var newFolder = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Locations") {
                    Label("Indica Drive", systemImage: "icloud.fill")
                    Label("On My iPhone", systemImage: "iphone")
                    Label("Recently Deleted", systemImage: "trash")
                }

                Section("Favorites") {
                    ForEach(folders, id: \.self) { folder in
                        Label(folder, systemImage: "folder.fill")
                            .foregroundStyle(.blue)
                    }
                    .onDelete { folders.remove(atOffsets: $0) }
                }

                Section("Recent") {
                    FileRow(name: "Indica OS brief", detail: "PDF · Today", symbol: "doc.fill")
                    FileRow(name: "Wallpaper studies", detail: "Folder · Yesterday", symbol: "folder.fill")
                    FileRow(name: "Motion notes", detail: "Text · Monday", symbol: "doc.text.fill")
                }
            }
            .navigationTitle("Browse")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewFolder = true
                    } label: { Image(systemName: "folder.badge.plus") }
                }
            }
            .alert("New Folder", isPresented: $showingNewFolder) {
                TextField("Name", text: $newFolder)
                Button("Cancel", role: .cancel) {}
                Button("Create") {
                    if !newFolder.isEmpty { folders.append(newFolder) }
                    newFolder = ""
                }
            }
        }
    }
}

private struct FileRow: View {
    let name: String
    let detail: String
    let symbol: String

    var body: some View {
        HStack {
            Image(systemName: symbol)
                .foregroundStyle(.blue)
                .frame(width: 28)
            VStack(alignment: .leading) {
                Text(name)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct MusicApp: View {
    @State private var trackIndex = 0
    @State private var isPlaying = false
    @State private var progress = 0.32

    private let tracks = [
        ("Quiet Hours", "Indica Studio", [Color.purple, Color.indigo]),
        ("Slow Orbit", "Blue Static", [Color.cyan, Color.blue]),
        ("Soft Focus", "Glass Garden", [Color.pink, Color.orange])
    ]

    var body: some View {
        let track = tracks[trackIndex]
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(LinearGradient(colors: track.2, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            Image(systemName: "waveform")
                                .font(.system(size: 72, weight: .thin))
                                .foregroundStyle(.white.opacity(0.82))
                                .symbolEffect(.variableColor.iterative, isActive: isPlaying)
                        }
                        .shadow(color: track.2[0].opacity(0.35), radius: 26, y: 16)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(track.0)
                                .font(.title2.bold())
                            Text(track.1)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {} label: { Image(systemName: "ellipsis.circle") }
                    }

                    Slider(value: $progress)
                        .tint(.primary)

                    HStack(spacing: 48) {
                        Button {
                            trackIndex = (trackIndex - 1 + tracks.count) % tracks.count
                        } label: {
                            Image(systemName: "backward.fill")
                        }
                        Button {
                            isPlaying.toggle()
                        } label: {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 34, weight: .semibold))
                        }
                        Button {
                            trackIndex = (trackIndex + 1) % tracks.count
                        } label: {
                            Image(systemName: "forward.fill")
                        }
                    }
                    .font(.system(size: 24))

                    HStack {
                        Image(systemName: "speaker.fill")
                        Slider(value: .constant(0.55))
                        Image(systemName: "speaker.wave.3.fill")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(24)
            }
            .navigationTitle("Now Playing")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct SettingsApp: View {
    var body: some View {
        IndicaSettingsApp()
    }
}

private struct SettingsToggle: View {
    let title: String
    let symbol: String
    let tint: Color
    @Binding var value: Bool

    var body: some View {
        HStack {
            SettingsSymbol(symbol: symbol, tint: tint)
            Text(title)
            Spacer()
            Toggle("", isOn: $value)
                .labelsHidden()
        }
    }
}

struct SettingsRow: View {
    let title: String
    let detail: String?
    let symbol: String
    let tint: Color

    var body: some View {
        HStack {
            SettingsSymbol(symbol: symbol, tint: tint)
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            if let detail {
                Text(detail)
                    .foregroundStyle(.secondary)
            }
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
        }
    }
}

private struct SettingsSymbol: View {
    let symbol: String
    let tint: Color

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 28, height: 28)
            .background(tint, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}
