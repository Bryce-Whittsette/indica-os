import SwiftUI
import MapKit

struct CalculatorApp: View {
    @State private var calculator = CalculatorEngine()

    private let keys = [
        "AC", "±", "%", "÷",
        "7", "8", "9", "×",
        "4", "5", "6", "−",
        "1", "2", "3", "+",
        "0", ".", "⌫", "="
    ]

    var body: some View {
        ZStack {
            Color.black
            VStack(spacing: 12) {
                Spacer()
                Text(calculator.display)
                    .font(.system(size: 72, weight: .light, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.35)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 25)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(keys, id: \.self) { key in
                        Button {
                            calculator.tap(key)
                        } label: {
                            Text(key)
                                .font(.system(size: 27, weight: .medium, design: .rounded))
                                .foregroundStyle(keyColor(key))
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .background(keyBackground(key), in: Circle())
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
    }

    private func keyBackground(_ key: String) -> Color {
        if ["÷", "×", "−", "+", "="].contains(key) { return .orange }
        if ["AC", "±", "%"].contains(key) { return Color(hex: 0xA8A8A8) }
        return Color(hex: 0x333333)
    }

    private func keyColor(_ key: String) -> Color {
        ["AC", "±", "%"].contains(key) ? .black : .white
    }
}

struct VoiceMemosApp: View {
    @State private var recordingStart: Date?
    @State private var recordings = [
        ("Design thought", "0:18", "Today, 10:22 AM"),
        ("Melody idea", "0:42", "Yesterday"),
        ("Street ambience", "1:12", "Monday")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Recording simulation · no microphone audio is captured")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding()
                List {
                    ForEach(Array(recordings.enumerated()), id: \.offset) { _, recording in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                Text(recording.0)
                                    .font(.headline)
                                Spacer()
                                Text(recording.1)
                                    .foregroundStyle(.secondary)
                            }
                            Text(recording.2)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            WaveformBars(active: false)
                                .frame(height: 28)
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete { recordings.remove(atOffsets: $0) }
                }
                .listStyle(.plain)

                VStack(spacing: 12) {
                    if let recordingStart {
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            let seconds = Int(context.date.timeIntervalSince(recordingStart))
                            Text(String(format: "%02d:%02d", seconds / 60, seconds % 60))
                                .font(.system(size: 28, weight: .regular, design: .monospaced))
                        }
                        WaveformBars(active: true)
                            .frame(height: 42)
                    }

                    Button {
                        toggleRecording()
                    } label: {
                        Circle()
                            .stroke(.red, lineWidth: 3)
                            .frame(width: 70, height: 70)
                            .overlay {
                                RoundedRectangle(cornerRadius: recordingStart == nil ? 28 : 8)
                                    .fill(.red)
                                    .frame(width: recordingStart == nil ? 58 : 30, height: recordingStart == nil ? 58 : 30)
                            }
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .background(.bar)
            }
            .navigationTitle("Voice Memos")
        }
    }

    private func toggleRecording() {
        if let start = recordingStart {
            let duration = max(1, Int(Date().timeIntervalSince(start)))
            recordings.insert(("New Recording \(recordings.count + 1)", String(format: "0:%02d", duration), "Just now"), at: 0)
            recordingStart = nil
        } else {
            recordingStart = .now
        }
    }
}

private struct WaveformBars: View {
    let active: Bool
    @State private var animate = false

    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(0..<28, id: \.self) { index in
                Capsule()
                    .fill(active ? Color.red : Color.secondary.opacity(0.45))
                    .frame(width: 3, height: active ? (animate ? CGFloat(8 + (index * 13) % 31) : CGFloat(8 + (index * 7) % 23)) : CGFloat(7 + (index * 5) % 18))
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            if active {
                withAnimation(.easeInOut(duration: 0.46).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
        }
    }
}

struct TranslateApp: View {
    @State private var sourceLanguage = "English"
    @State private var targetLanguage = "Spanish"
    @State private var sourceText = ""
    @State private var translatedText = ""

    private let dictionary = [
        "hello": "hola",
        "good morning": "buenos días",
        "thank you": "gracias",
        "how are you": "cómo estás",
        "where is the studio": "dónde está el estudio",
        "i love this": "me encanta esto"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Menu(sourceLanguage) {
                        Button("English") { sourceLanguage = "English" }
                        Button("Spanish") { sourceLanguage = "Spanish" }
                    }
                    Spacer()
                    Button {
                        swap(&sourceLanguage, &targetLanguage)
                        swap(&sourceText, &translatedText)
                    } label: {
                        Image(systemName: "arrow.left.arrow.right")
                            .frame(width: 42, height: 42)
                            .background(Color.primary.opacity(0.07), in: Circle())
                    }
                    Spacer()
                    Menu(targetLanguage) {
                        Button("Spanish") { targetLanguage = "Spanish" }
                        Button("English") { targetLanguage = "English" }
                        Button("French") { targetLanguage = "French" }
                    }
                }
                .font(.headline)

                TextEditor(text: $sourceText)
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .frame(height: 180)
                    .padding(12)
                    .background(Color.primary.opacity(0.055), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(alignment: .topLeading) {
                        if sourceText.isEmpty {
                            Text("Enter text")
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                                .foregroundStyle(.tertiary)
                                .padding(20)
                                .allowsHitTesting(false)
                        }
                    }

                HStack {
                    Button {
                        translate()
                    } label: {
                        Label("Translate", systemImage: "character.bubble.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(.blue, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    Button {
                        sourceText = ""
                        translatedText = ""
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 48, height: 48)
                            .background(Color.primary.opacity(0.07), in: Circle())
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(targetLanguage.uppercased())
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(translatedText.isEmpty ? "Translation appears here" : translatedText)
                        .font(.system(size: 27, weight: .medium, design: .rounded))
                        .foregroundStyle(translatedText.isEmpty ? .tertiary : .primary)
                    Spacer()
                    HStack {
                        Button {} label: { Image(systemName: "speaker.wave.2.fill") }
                        Button {} label: { Image(systemName: "star") }
                        Button {} label: { Image(systemName: "doc.on.doc") }
                    }
                    .font(.title3)
                    .buttonStyle(.bordered)
                }
                .padding(18)
                .frame(maxWidth: .infinity, minHeight: 210, alignment: .leading)
                .background(Color.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                Spacer()
            }
            .padding()
            .navigationTitle("Translate")
        }
    }

    private func translate() {
        let key = sourceText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if sourceLanguage == "English", targetLanguage == "Spanish" {
            translatedText = dictionary[key] ?? "«\(sourceText)»"
        } else if sourceLanguage == "Spanish", targetLanguage == "English" {
            translatedText = dictionary.first(where: { $0.value == key })?.key.capitalized ?? "“\(sourceText)”"
        } else {
            translatedText = sourceText
        }
    }
}

struct SmartHomeApp: View {
    @EnvironmentObject private var system: IndicaSystem

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("My Home")
                            .font(.system(size: 33, weight: .bold, design: .rounded))
                        Text("4 accessories · All secure")
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 12) {
                        SceneButton(title: "Good Morning", symbol: "sun.max.fill", tint: .orange)
                        SceneButton(title: "Movie Time", symbol: "play.tv.fill", tint: .purple)
                    }

                    Text("Favorites")
                        .font(.title2.bold())

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(system.homeAccessories.keys.sorted(), id: \.self) { name in
                            let binding = Binding(
                                get: { system.homeAccessories[name, default: false] },
                                set: { system.homeAccessories[name] = $0 }
                            )
                            HomeAccessory(name: name, isOn: binding)
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Label("Climate", systemImage: "thermometer.medium")
                            .font(.headline)
                        HStack(alignment: .firstTextBaseline) {
                            Text("72°")
                                .font(.system(size: 48, weight: .medium, design: .rounded))
                            Text("Inside")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("Comfortable")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(17)
                    .background(Color.primary.opacity(0.055), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
                .padding()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {} label: { Image(systemName: "plus") }
            }
        }
    }
}

private struct SceneButton: View {
    let title: String
    let symbol: String
    let tint: Color
    @State private var ran = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) { ran.toggle() }
        } label: {
            HStack {
                Image(systemName: ran ? "checkmark" : symbol)
                Text(ran ? "Scene Set" : title)
                    .font(.subheadline.bold())
                Spacer()
            }
            .foregroundStyle(ran ? .white : .primary)
            .padding(15)
            .background(ran ? tint : Color.primary.opacity(0.055), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
    }
}

private struct HomeAccessory: View {
    let name: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) { isOn.toggle() }
        } label: {
            VStack(alignment: .leading, spacing: 19) {
                Image(systemName: name.contains("Door") ? "lock.fill" : "lightbulb.fill")
                    .font(.title2)
                    .foregroundStyle(isOn ? .white : .secondary)
                VStack(alignment: .leading, spacing: 3) {
                    Text(name)
                        .font(.headline)
                    Text(isOn ? (name.contains("Door") ? "Locked" : "On") : "Off")
                        .font(.caption)
                        .opacity(0.68)
                }
            }
            .foregroundStyle(isOn ? .white : .primary)
            .frame(maxWidth: .infinity, minHeight: 116, alignment: .leading)
            .padding(15)
            .background(isOn ? Color.orange : Color.primary.opacity(0.055), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct WalletApp: View {
    @State private var selected = 0
    @State private var showingPass = false

    private let cards: [(String, String, [Color])] = [
        ("Indica Cash", "$842.16", [.black, Color(hex: 0x3D4050)]),
        ("Metro Pass", "Unlimited", [.purple, .indigo]),
        ("Studio Card", "•• 4802", [.orange, .pink])
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TabView(selection: $selected) {
                    ForEach(cards.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "sparkles")
                                Spacer()
                                Image(systemName: "wave.3.right")
                            }
                            Spacer()
                            Text(cards[index].0)
                                .font(.title2.bold())
                            Text(cards[index].1)
                                .font(.headline)
                                .opacity(0.75)
                        }
                        .padding(22)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(colors: cards[index].2, startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 27, style: .continuous)
                        )
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 245)

                Button {
                    showingPass = true
                } label: {
                    Label("Present Card", systemImage: "wave.3.right.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.primary, in: Capsule())
                        .foregroundStyle(Color(uiColor: .systemBackground))
                }
                .padding(.horizontal, 24)

                List {
                    Section("Latest Transactions") {
                        WalletTransaction(title: "Coffee Room", amount: "−$6.40", symbol: "cup.and.saucer.fill", tint: .brown)
                        WalletTransaction(title: "Metro", amount: "−$2.90", symbol: "tram.fill", tint: .blue)
                        WalletTransaction(title: "Deposit", amount: "+$180.00", symbol: "arrow.down.circle.fill", tint: .green)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Wallet")
            .sheet(isPresented: $showingPass) {
                VStack(spacing: 24) {
                    Capsule().fill(.secondary.opacity(0.3)).frame(width: 42, height: 5)
                    Text(cards[selected].0)
                        .font(.title.bold())
                    Image(systemName: "wave.3.right.circle.fill")
                        .font(.system(size: 94))
                        .symbolEffect(.pulse)
                    Text("Hold near reader")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(30)
                .presentationDetents([.medium])
            }
        }
    }
}

private struct WalletTransaction: View {
    let title: String
    let amount: String
    let symbol: String
    let tint: Color

    var body: some View {
        HStack {
            Image(systemName: symbol)
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(tint, in: Circle())
            Text(title)
            Spacer()
            Text(amount)
                .fontWeight(.semibold)
        }
    }
}

struct HealthApp: View {
    @State private var period = "W"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Picker("Period", selection: $period) {
                        ForEach(["D", "W", "M", "6M", "Y"], id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.segmented)

                    HealthMetric(title: "Steps", value: "5,804", detail: "Goal 8,000", symbol: "figure.walk", tint: .orange, values: [4, 8, 6, 11, 9, 13, 10])
                    HealthMetric(title: "Sleep", value: "7 hr 24 min", detail: "42 min more than last week", symbol: "bed.double.fill", tint: .indigo, values: [9, 8, 10, 7, 11, 9, 12])
                    HealthMetric(title: "Heart Rate", value: "68 BPM", detail: "Resting range 62 to 74", symbol: "heart.fill", tint: .red, values: [7, 11, 8, 13, 9, 12, 10])

                    Text("Highlights")
                        .font(.title2.bold())
                    Label("Your walking steadiness is strong this week.", systemImage: "sparkles")
                        .padding(17)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding()
            }
            .navigationTitle("Health")
        }
    }
}

private struct HealthMetric: View {
    let title: String
    let value: String
    let detail: String
    let symbol: String
    let tint: Color
    let values: [CGFloat]

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Label(title, systemImage: symbol)
                .font(.headline)
                .foregroundStyle(tint)
            Text(value)
                .font(.system(size: 31, weight: .bold, design: .rounded))
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(values.indices, id: \.self) { index in
                    Capsule()
                        .fill(tint.opacity(0.75))
                        .frame(maxWidth: .infinity)
                        .frame(height: values[index] * 5)
                }
            }
            .frame(height: 70, alignment: .bottom)
        }
        .padding(17)
        .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct ShortcutsApp: View {
    @EnvironmentObject private var system: IndicaSystem
    @State private var lastRun = ""

    private let shortcuts = [
        ("Morning Mode", "sunrise.fill", Color.orange),
        ("Focus Studio", "moon.stars.fill", Color.indigo),
        ("Play Quiet Hours", "music.note", Color.pink),
        ("Heading Home", "house.fill", Color.green),
        ("Capture Idea", "lightbulb.fill", Color.yellow),
        ("Battery Check", "battery.100percent", Color.teal)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 13) {
                    ForEach(shortcuts, id: \.0) { shortcut in
                        Button {
                            run(shortcut.0)
                        } label: {
                            VStack(alignment: .leading, spacing: 24) {
                                Image(systemName: shortcut.1)
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .frame(width: 42, height: 42)
                                    .background(.white.opacity(0.17), in: Circle())
                                Text(shortcut.0)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
                            .padding(16)
                            .background(shortcut.2, in: RoundedRectangle(cornerRadius: 23, style: .continuous))
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Shortcuts")
            .overlay(alignment: .bottom) {
                if !lastRun.isEmpty {
                    Label("\(lastRun) completed", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 11)
                        .background(.regularMaterial, in: Capsule())
                        .padding(.bottom, 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }

    private func run(_ name: String) {
        withAnimation {
            lastRun = name
            if name.contains("Focus") { system.isFocusEnabled = true }
            if name.contains("Morning") {
                system.isFocusEnabled = false
                system.brightness = 0.85
            }
            if name.contains("Battery") { system.brightness = 0.55 }
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation { lastRun = "" }
        }
    }
}

struct FindApp: View {
    @State private var selected = "Demo iPhone"
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.718, longitude: -73.98),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                Marker("Demo iPhone", systemImage: "iphone", coordinate: CLLocationCoordinate2D(latitude: 40.718, longitude: -73.98))
                    .tint(.green)
                Marker("Maya", systemImage: "person.fill", coordinate: CLLocationCoordinate2D(latitude: 40.734, longitude: -73.97))
                    .tint(.purple)
            }

            VStack(spacing: 12) {
                Capsule()
                    .fill(.secondary.opacity(0.35))
                    .frame(width: 40, height: 5)
                HStack {
                    Image(systemName: "iphone")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(.green, in: Circle())
                    VStack(alignment: .leading) {
                        Text(selected)
                            .font(.headline)
                        Text("With You · Now")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {} label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .frame(width: 42, height: 42)
                            .background(Color.primary.opacity(0.08), in: Circle())
                    }
                }
                HStack {
                    Button("Directions") {}
                        .buttonStyle(.borderedProminent)
                    Button("Play Sound") {}
                        .buttonStyle(.bordered)
                    Spacer()
                }
            }
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(12)
        }
    }
}

struct ContactsApp: View {
    @State private var contacts = ["Maya Chen", "Jordan Lee", "Avery Stone", "Studio Desk", "Mom", "Noah Kim"]
    @State private var newContact = ""
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 13) {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom))
                            .frame(width: 56, height: 56)
                            .overlay(Text("B").font(.title.bold()).foregroundStyle(.white))
                        VStack(alignment: .leading) {
                            Text("Demo User")
                                .font(.title3.bold())
                            Text("My Card")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Contacts") {
                    ForEach(contacts, id: \.self) { contact in
                        NavigationLink {
                            ContactDetail(name: contact)
                        } label: {
                            Text(contact)
                        }
                    }
                    .onDelete { contacts.remove(atOffsets: $0) }
                }
            }
            .navigationTitle("Contacts")
            .searchable(text: .constant(""))
            .toolbar {
                Button {
                    showingAdd = true
                } label: { Image(systemName: "plus") }
            }
            .alert("New Contact", isPresented: $showingAdd) {
                TextField("Name", text: $newContact)
                Button("Cancel", role: .cancel) {}
                Button("Add") {
                    if !newContact.isEmpty { contacts.append(newContact) }
                    newContact = ""
                }
            }
        }
    }
}

private struct ContactDetail: View {
    let name: String

    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 112, height: 112)
                .overlay {
                    Text(String(name.prefix(1)))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            Text(name)
                .font(.title.bold())
            HStack(spacing: 14) {
                ContactAction(symbol: "message.fill", title: "message")
                ContactAction(symbol: "phone.fill", title: "call")
                ContactAction(symbol: "video.fill", title: "video")
                ContactAction(symbol: "envelope.fill", title: "mail")
            }
            List {
                LabeledContent("mobile", value: "(555) 013-2048")
                LabeledContent("email", value: "\(name.lowercased().replacingOccurrences(of: " ", with: "."))@example.com")
                LabeledContent("birthday", value: "September 12")
            }
        }
        .padding(.top)
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ContactAction: View {
    let symbol: String
    let title: String

    var body: some View {
        Button {} label: {
            VStack(spacing: 5) {
                Image(systemName: symbol)
                    .frame(width: 44, height: 44)
                    .background(.blue.opacity(0.12), in: Circle())
                Text(title)
                    .font(.caption2)
            }
        }
    }
}

struct MediaCatalogApp: View {
    let app: BuiltInApp
    @State private var selectedItem: String?
    @State private var saved = Set<String>()

    private var items: [(String, String, String)] {
        switch app {
        case .video:
            [("Afterlight", "Drama · 1h 48m", "film.fill"), ("Soft Machines", "Sci-Fi · 2h 02m", "sparkles.tv.fill"), ("The Long Way", "Documentary · 58m", "globe")]
        case .podcasts:
            [("Design Details", "New episode · 42m", "mic.fill"), ("City Signals", "Episode 18 · 31m", "building.2.fill"), ("Quiet Systems", "Episode 7 · 54m", "waveform")]
        case .news:
            [("Indica OS becomes interactive", "Technology · 12m ago", "newspaper.fill"), ("A softer approach to phone design", "Design · 1h ago", "paintpalette.fill"), ("Tonight’s city guide", "Local · 2h ago", "location.fill")]
        case .books:
            [("Interfaces That Breathe", "Amara Cole · 38%", "book.closed.fill"), ("The Quiet City", "Noah Vale · New", "building.columns.fill"), ("Motion with Meaning", "Ren Ito · 72%", "figure.walk.motion")]
        case .store:
            [("Arcade Garden", "Game · Free", "gamecontroller.fill"), ("Paper Studio", "Creativity · $4.99", "paintbrush.fill"), ("Transit Lens", "Travel · Free", "tram.fill")]
        default:
            []
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    let featured = items.first
                    if let featured {
                        ZStack(alignment: .bottomLeading) {
                            LinearGradient(colors: app.palette, startPoint: .topLeading, endPoint: .bottomTrailing)
                            VStack(alignment: .leading, spacing: 6) {
                                Text("FEATURED")
                                    .font(.caption.bold())
                                    .tracking(1.4)
                                Text(featured.0)
                                    .font(.system(size: 31, weight: .bold, design: .rounded))
                                Text(featured.1)
                                    .opacity(0.72)
                            }
                            .foregroundStyle(.white)
                            .padding(20)
                        }
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    }

                    Text(app == .store ? "Apps We Love" : "Up Next")
                        .font(.title2.bold())

                    ForEach(items, id: \.0) { item in
                        Button {
                            selectedItem = item.0
                        } label: {
                            HStack(spacing: 13) {
                                Image(systemName: item.2)
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .frame(width: 62, height: 62)
                                    .background(
                                        LinearGradient(colors: app.palette, startPoint: .topLeading, endPoint: .bottomTrailing),
                                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    )
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.0)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(item.1)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button {
                                    if saved.contains(item.0) { saved.remove(item.0) } else { saved.insert(item.0) }
                                } label: {
                                    Image(systemName: saved.contains(item.0) ? "checkmark.circle.fill" : "plus.circle")
                                        .font(.title3)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        Divider()
                    }
                }
                .padding()
            }
            .navigationTitle(app.name)
            .sheet(item: $selectedItem) { item in
                VStack(spacing: 22) {
                    Capsule().fill(.secondary.opacity(0.3)).frame(width: 42, height: 5)
                    Image(systemName: app.symbol)
                        .font(.system(size: 58))
                        .foregroundStyle(app.palette[0])
                    Text(item)
                        .font(.title.bold())
                    Text("This is a functional local catalog detail. Save the item, start playback, or return to browse.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    Button(app == .store ? "Get" : "Play") {
                        saved.insert(item)
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                .padding(28)
                .presentationDetents([.medium])
            }
        }
    }
}

struct SensorUtilityApp: View {
    let app: BuiltInApp
    @State private var angle = 28.0
    @State private var zoom = 2.0
    @State private var measure = 12.4

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                switch app {
                case .compass:
                    CompassFace(angle: angle)
                    Slider(value: $angle, in: 0...359)
                    Text("\(Int(angle))° NE")
                        .font(.system(size: 33, weight: .medium, design: .rounded))
                case .measure:
                    ZStack {
                        LinearGradient(colors: [.black, Color(hex: 0x33363B)], startPoint: .top, endPoint: .bottom)
                        HStack(spacing: 0) {
                            Circle().fill(.yellow).frame(width: 11, height: 11)
                            Rectangle().fill(.yellow).frame(height: 2)
                            Circle().fill(.yellow).frame(width: 11, height: 11)
                        }
                        .padding(.horizontal, 42)
                        Text(String(format: "%.1f in", measure))
                            .font(.title.bold())
                            .foregroundStyle(.white)
                            .padding(9)
                            .background(.black.opacity(0.55), in: Capsule())
                            .offset(y: -38)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    Slider(value: $measure, in: 1...48)
                case .magnifier:
                    ZStack {
                        LinearGradient(colors: [.cyan, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                        Image(systemName: "textformat.size.larger")
                            .font(.system(size: CGFloat(38 * zoom)))
                            .foregroundStyle(.white)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    HStack {
                        Image(systemName: "minus.magnifyingglass")
                        Slider(value: $zoom, in: 1...4)
                        Image(systemName: "plus.magnifyingglass")
                    }
                case .stocks:
                    StocksBoard()
                case .fitness:
                    FitnessBoard()
                default:
                    EmptyView()
                }

                Spacer()
            }
            .padding()
            .navigationTitle(app.name)
        }
    }
}

private struct CompassFace: View {
    let angle: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.15), lineWidth: 18)
            ForEach(0..<36, id: \.self) { tick in
                Capsule()
                    .fill(tick % 9 == 0 ? Color.red : Color.primary.opacity(0.45))
                    .frame(width: tick % 9 == 0 ? 4 : 2, height: tick % 9 == 0 ? 20 : 10)
                    .offset(y: -123)
                    .rotationEffect(.degrees(Double(tick) * 10 - angle))
            }
            Text("N")
                .font(.title.bold())
                .foregroundStyle(.red)
                .offset(y: -88)
                .rotationEffect(.degrees(-angle))
            Image(systemName: "location.north.fill")
                .font(.system(size: 72))
                .foregroundStyle(.red)
                .rotationEffect(.degrees(angle))
        }
        .frame(width: 280, height: 280)
    }
}

private struct StocksBoard: View {
    private let stocks = [("INDC", "+4.12%", 186.42), ("AURA", "+1.83%", 82.17), ("TIDE", "−0.44%", 41.08), ("BLOM", "+2.09%", 73.55)]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(stocks, id: \.0) { stock in
                HStack {
                    VStack(alignment: .leading) {
                        Text(stock.0).font(.headline)
                        Text(stock.1)
                            .font(.caption)
                            .foregroundStyle(stock.1.hasPrefix("+") ? .green : .red)
                    }
                    Spacer()
                    MiniLineChart(up: stock.1.hasPrefix("+"))
                        .frame(width: 86, height: 34)
                    Text(String(format: "%.2f", stock.2))
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 72, alignment: .trailing)
                }
                .padding(.vertical, 14)
                Divider()
            }
        }
    }
}

private struct MiniLineChart: View {
    let up: Bool

    var body: some View {
        GeometryReader { proxy in
            Path { path in
                let points: [CGFloat] = up ? [0.75, 0.58, 0.66, 0.42, 0.5, 0.22] : [0.25, 0.38, 0.31, 0.58, 0.46, 0.73]
                for (index, y) in points.enumerated() {
                    let point = CGPoint(x: proxy.size.width * CGFloat(index) / CGFloat(points.count - 1), y: proxy.size.height * y)
                    index == 0 ? path.move(to: point) : path.addLine(to: point)
                }
            }
            .stroke(up ? .green : .red, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        }
    }
}

private struct FitnessBoard: View {
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Ring(progress: 0.82, color: .pink, size: 250)
                Ring(progress: 0.66, color: .green, size: 196)
                Ring(progress: 0.54, color: .cyan, size: 142)
                Image(systemName: "figure.run")
                    .font(.system(size: 35))
            }
            VStack(spacing: 12) {
                FitnessRow(color: .pink, title: "Move", value: "410 / 500 CAL")
                FitnessRow(color: .green, title: "Exercise", value: "20 / 30 MIN")
                FitnessRow(color: .cyan, title: "Stand", value: "7 / 12 HRS")
            }
        }
    }
}

private struct Ring: View {
    let progress: Double
    let color: Color
    let size: CGFloat

    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(color.gradient, style: StrokeStyle(lineWidth: 22, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .frame(width: size, height: size)
            .background {
                Circle()
                    .stroke(color.opacity(0.14), lineWidth: 22)
                    .frame(width: size, height: size)
            }
    }
}

private struct FitnessRow: View {
    let color: Color
    let title: String
    let value: String

    var body: some View {
        HStack {
            Circle().fill(color).frame(width: 11, height: 11)
            Text(title).fontWeight(.semibold)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }
}

struct EverydayApp: View {
    let app: BuiltInApp

    var body: some View {
        switch app {
        case .tips:
            TipsApp()
        case .canvas:
            CanvasApp()
        case .journal:
            JournalApp()
        case .passwords:
            PasswordsApp()
        case .watch:
            WatchApp()
        case .videoCall:
            VideoCallApp()
        default:
            EmptyView()
        }
    }
}

private struct TipsApp: View {
    @State private var page = 0
    private let tips = [
        ("System gestures", "Pull from the top-right for Control Center and top-left for notifications.", "hand.draw.fill", Color.blue),
        ("Make it yours", "Long-press the Lock Screen or Home Screen to enter customization.", "paintbrush.pointed.fill", Color.purple),
        ("Switch quickly", "Swipe up from the bottom inside an app to reach the app switcher.", "rectangle.stack.fill", Color.orange)
    ]

    var body: some View {
        NavigationStack {
            TabView(selection: $page) {
                ForEach(tips.indices, id: \.self) { index in
                    VStack(spacing: 24) {
                        Image(systemName: tips[index].2)
                            .font(.system(size: 74, weight: .light))
                            .foregroundStyle(.white)
                            .frame(width: 160, height: 160)
                            .background(tips[index].3.gradient, in: RoundedRectangle(cornerRadius: 42, style: .continuous))
                        Text(tips[index].0)
                            .font(.system(size: 31, weight: .bold, design: .rounded))
                        Text(tips[index].1)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 26)
                        Spacer()
                    }
                    .padding(.top, 30)
                    .tag(index)
                }
            }
            .tabViewStyle(.page)
            .navigationTitle("Tips")
        }
    }
}

private struct CanvasApp: View {
    @State private var lines: [[CGPoint]] = []
    @State private var currentLine: [CGPoint] = []
    @State private var color: Color = .indigo

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Canvas { context, _ in
                    for line in lines + [currentLine] where line.count > 1 {
                        var path = Path()
                        path.move(to: line[0])
                        for point in line.dropFirst() { path.addLine(to: point) }
                        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    }
                }
                .background(Color(hex: 0xF8F4EC))
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { currentLine.append($0.location) }
                        .onEnded { _ in
                            lines.append(currentLine)
                            currentLine = []
                        }
                )

                HStack(spacing: 20) {
                    ForEach([Color.indigo, .pink, .orange, .black], id: \.description) { item in
                        Button { color = item } label: {
                            Circle()
                                .fill(item)
                                .frame(width: 29, height: 29)
                                .overlay {
                                    if color == item { Circle().stroke(.primary, lineWidth: 3).padding(-4) }
                                }
                        }
                    }
                    Spacer()
                    Button { lines.removeLast() } label: { Image(systemName: "arrow.uturn.backward") }
                        .disabled(lines.isEmpty)
                    Button(role: .destructive) { lines.removeAll() } label: { Image(systemName: "trash") }
                }
                .padding()
                .background(.bar)
            }
            .navigationTitle("Canvas")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct JournalApp: View {
    @State private var text = ""
    @State private var entries = ["Today I started rebuilding Indica OS as a complete interactive system."]

    var body: some View {
        NavigationStack {
            List {
                Section("New Entry") {
                    TextField("What’s on your mind?", text: $text, axis: .vertical)
                        .lineLimit(3...7)
                    Button("Save Entry") {
                        guard !text.isEmpty else { return }
                        entries.insert(text, at: 0)
                        text = ""
                    }
                    .disabled(text.isEmpty)
                }
                Section("Recent") {
                    ForEach(entries, id: \.self) { entry in
                        VStack(alignment: .leading, spacing: 7) {
                            Text(entry)
                            Text("July 17, 2026")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { entries.remove(atOffsets: $0) }
                }
            }
            .navigationTitle("Journal")
        }
    }
}

private struct PasswordsApp: View {
    @State private var unlocked = false
    @State private var revealed = Set<String>()
    private let passwords = [("account.example", "sample-only"), ("studio.example", "example-entry"), ("music.example", "demo-password")]

    var body: some View {
        NavigationStack {
            if !unlocked {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "key.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.blue)
                    Text("Passwords")
                        .font(.title.bold())
                    Text("Example entries for a UI demonstration. No authentication or real passwords.")
                        .foregroundStyle(.secondary)
                    Button("Unlock Demo Vault") { unlocked = true }
                        .buttonStyle(.borderedProminent)
                    Spacer()
                }
            } else {
                List {
                    ForEach(passwords, id: \.0) { item in
                        Button {
                            if revealed.contains(item.0) { revealed.remove(item.0) } else { revealed.insert(item.0) }
                        } label: {
                            HStack {
                                Image(systemName: "key.fill")
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(.blue, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                VStack(alignment: .leading) {
                                    Text(item.0)
                                        .foregroundStyle(.primary)
                                    Text(revealed.contains(item.0) ? item.1 : "••••••••")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: revealed.contains(item.0) ? "eye.slash" : "eye")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Passwords")
    }
}

private struct WatchApp: View {
    @State private var paired = true
    @State private var notifications = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 13) {
                        RoundedRectangle(cornerRadius: 35, style: .continuous)
                            .fill(.black)
                            .frame(width: 132, height: 158)
                            .overlay {
                                VStack {
                                    Text("10:09")
                                        .font(.title.bold())
                                    HStack {
                                        Text("72°")
                                        Image(systemName: "cloud.sun.fill")
                                    }
                                    .font(.caption)
                                }
                                .foregroundStyle(.white)
                            }
                        Text("Indica Watch")
                            .font(.title2.bold())
                        Text(paired ? "Connected" : "Not connected")
                            .foregroundStyle(paired ? .green : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                Section("Connection") {
                    Toggle("Paired", isOn: $paired)
                    Toggle("Mirror Notifications", isOn: $notifications)
                }
                Section("Faces") {
                    Label("Aura", systemImage: "sparkles")
                    Label("Utility", systemImage: "clock.fill")
                    Label("Activity", systemImage: "figure.run")
                }
            }
            .navigationTitle("Watch")
        }
    }
}

private struct VideoCallApp: View {
    @State private var inCall = false
    @State private var cameraOn = true
    @State private var muted = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [.green.opacity(0.7), .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            if inCall {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 27, style: .continuous)
                            .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Image(systemName: cameraOn ? "person.crop.rectangle.fill" : "video.slash.fill")
                            .font(.system(size: 74, weight: .light))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding()

                    HStack(spacing: 20) {
                        CallControl(symbol: muted ? "mic.slash.fill" : "mic.fill", active: muted) { muted.toggle() }
                        CallControl(symbol: cameraOn ? "video.fill" : "video.slash.fill", active: !cameraOn) { cameraOn.toggle() }
                        CallControl(symbol: "phone.down.fill", tint: .red) { inCall = false }
                    }
                    .padding(.bottom, 24)
                }
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "video.fill")
                        .font(.system(size: 62))
                    Text("Start a Video Call")
                        .font(.title.bold())
                    Text("This demo call remains entirely on-device.")
                        .foregroundStyle(.white.opacity(0.7))
                    Button("Call Maya") { inCall = true }
                        .font(.headline)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 13)
                        .background(.white, in: Capsule())
                        .foregroundStyle(.green)
                    Spacer()
                }
            }
        }
        .foregroundStyle(.white)
    }
}

private struct CallControl: View {
    let symbol: String
    var active = false
    var tint: Color = .white.opacity(0.17)
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .semibold))
                .frame(width: 62, height: 62)
                .background(active ? .white : tint, in: Circle())
                .foregroundStyle(active ? .black : .white)
        }
        .buttonStyle(PressableButtonStyle())
    }
}
