import AVFoundation
import SwiftUI

struct VoiceMemo: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    let fileName: String
    let duration: TimeInterval
    let createdAt: Date
}

/// Live microphone levels, separate from the store so only the meter updates 20
/// times a second, not the memo list.
@MainActor
final class RecordingMeter: ObservableObject {
    @Published var samples = [CGFloat](repeating: 0, count: 32)
    @Published var elapsed: TimeInterval = 0
}

/// Real recording and playback. Audio files live in Application Support, and
/// `index.json` beside them holds names and dates.
@MainActor
final class VoiceMemoStore: NSObject, ObservableObject {
    static let shared = VoiceMemoStore()

    enum RecordPermission {
        case undetermined, granted, denied
    }

    @Published private(set) var memos: [VoiceMemo] = []
    @Published private(set) var isRecording = false
    @Published private(set) var playingID: UUID?
    @Published private(set) var isPaused = false
    @Published var errorMessage: String?
    let meter = RecordingMeter()

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var currentFileName: String?
    private var meterTimer: Timer?
    private let queue = DispatchQueue(label: "IndicaOS.VoiceMemoStore", qos: .utility)

    private static var folder: URL {
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("VoiceMemos", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private static var indexURL: URL { folder.appendingPathComponent("index.json") }

    private override init() {
        super.init()
        if let data = try? Data(contentsOf: Self.indexURL),
           let saved = try? JSONDecoder().decode([VoiceMemo].self, from: data) {
            // A record whose audio is gone can't be played, so it isn't listed.
            memos = saved.filter { FileManager.default.fileExists(atPath: Self.folder.appendingPathComponent($0.fileName).path) }
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    private func saveIndex() {
        let snapshot = memos
        let url = Self.indexURL
        queue.async {
            guard let data = try? JSONEncoder().encode(snapshot) else { return }
            try? data.write(to: url, options: .atomic)
        }
    }

    func url(for memo: VoiceMemo) -> URL {
        Self.folder.appendingPathComponent(memo.fileName)
    }

    var permission: RecordPermission {
        switch AVAudioApplication.shared.recordPermission {
        case .granted: .granted
        case .denied: .denied
        default: .undetermined
        }
    }

    // MARK: Recording

    func toggleRecording() async {
        if isRecording {
            stopRecording()
        } else {
            await startRecording()
        }
    }

    private func startRecording() async {
        if permission == .undetermined {
            _ = await AVAudioApplication.requestRecordPermission()
            objectWillChange.send()
        }
        guard permission == .granted else { return }

        stopPlayback()
        let fileName = "\(UUID().uuidString).m4a"
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            let recorder = try AVAudioRecorder(url: Self.folder.appendingPathComponent(fileName), settings: settings)
            recorder.isMeteringEnabled = true
            guard recorder.record() else {
                errorMessage = "Recording couldn't start. Another app may be using the microphone."
                try? session.setActive(false, options: .notifyOthersOnDeactivation)
                return
            }
            self.recorder = recorder
            currentFileName = fileName
            isRecording = true
            startMeter()
        } catch {
            errorMessage = "Recording couldn't start: \(error.localizedDescription)"
        }
    }

    /// Saves whatever was captured. Leaving the app, an interruption and the stop
    /// button all end here, so nothing recorded is lost.
    func stopRecording() {
        guard let recorder, let fileName = currentFileName else { return }
        // `currentTime` is only valid while recording, and an interruption may already
        // have stopped it, so the finished file decides the duration.
        let timeAtStop = recorder.currentTime
        recorder.stop()
        self.recorder = nil
        currentFileName = nil
        isRecording = false
        stopMeter()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        let url = Self.folder.appendingPathComponent(fileName)
        let fileDuration = (try? AVAudioPlayer(contentsOf: url))?.duration ?? 0
        let duration = max(fileDuration, timeAtStop)
        guard duration >= 0.2 else {
            try? FileManager.default.removeItem(at: url)
            return
        }
        memos.insert(
            VoiceMemo(id: UUID(), name: nextDefaultName(), fileName: fileName, duration: duration, createdAt: .now),
            at: 0
        )
        saveIndex()
    }

    private func nextDefaultName() -> String {
        var number = memos.count + 1
        while memos.contains(where: { $0.name == "New Recording \(number)" }) { number += 1 }
        return "New Recording \(number)"
    }

    private func startMeter() {
        meter.samples = [CGFloat](repeating: 0, count: meter.samples.count)
        meter.elapsed = 0
        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.updateMeter() }
        }
    }

    private func stopMeter() {
        meterTimer?.invalidate()
        meterTimer = nil
    }

    private func updateMeter() {
        guard let recorder else { return }
        recorder.updateMeters()
        // -50 dB and below reads as silence.
        let level = CGFloat(max(0, (recorder.averagePower(forChannel: 0) + 50) / 50))
        meter.samples.removeFirst()
        meter.samples.append(level)
        meter.elapsed = recorder.currentTime
    }

    /// This notification has no guaranteed thread, so it hops to the main actor.
    @objc nonisolated private func handleInterruption(_ notification: Notification) {
        guard let raw = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              AVAudioSession.InterruptionType(rawValue: raw) == .began else { return }
        Task { @MainActor in
            self.stopRecording()
            self.player?.pause()
            if self.playingID != nil { self.isPaused = true }
        }
    }

    // MARK: Playback

    func togglePlayback(of memo: VoiceMemo) {
        if playingID == memo.id, let player {
            if player.isPlaying {
                player.pause()
                isPaused = true
            } else {
                player.play()
                isPaused = false
            }
            return
        }
        stopPlayback()
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            let player = try AVAudioPlayer(contentsOf: url(for: memo))
            player.delegate = self
            guard player.play() else {
                errorMessage = "This recording couldn't play."
                return
            }
            self.player = player
            playingID = memo.id
            isPaused = false
        } catch {
            errorMessage = "This recording couldn't play: \(error.localizedDescription)"
        }
    }

    func stopPlayback() {
        player?.stop()
        let wasPlaying = player != nil
        player = nil
        playingID = nil
        isPaused = false
        // Lets other apps' audio resume.
        if wasPlaying {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }

    func progress(of memo: VoiceMemo) -> Double {
        guard playingID == memo.id, let player, player.duration > 0 else { return 0 }
        return player.currentTime / player.duration
    }

    // MARK: Editing

    func rename(_ memo: VoiceMemo, to name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = memos.firstIndex(where: { $0.id == memo.id }) else { return }
        memos[index].name = trimmed
        saveIndex()
    }

    func delete(_ memo: VoiceMemo) {
        if playingID == memo.id { stopPlayback() }
        try? FileManager.default.removeItem(at: url(for: memo))
        memos.removeAll { $0.id == memo.id }
        saveIndex()
    }
}

extension VoiceMemoStore: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.stopPlayback()
        }
    }
}

struct VoiceMemosApp: View {
    @ObservedObject private var store = VoiceMemoStore.shared
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var system: IndicaSystem
    @State private var renaming: VoiceMemo?
    @State private var renameText = ""
    @State private var deleting: VoiceMemo?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    ForEach(store.memos) { memo in
                        MemoRow(memo: memo, store: store)
                            .swipeActions {
                                Button("Delete", role: .destructive) { deleting = memo }
                                Button("Rename") {
                                    renameText = memo.name
                                    renaming = memo
                                }
                            }
                            .contextMenu {
                                Button { renameText = memo.name; renaming = memo } label: { Label("Rename", systemImage: "pencil") }
                                ShareLink(item: store.url(for: memo)) { Label("Share", systemImage: "square.and.arrow.up") }
                                Button(role: .destructive) { deleting = memo } label: { Label("Delete", systemImage: "trash") }
                            }
                    }
                }
                .listStyle(.plain)
                .overlay {
                    if store.memos.isEmpty && !store.isRecording {
                        ContentUnavailableView(
                            "No Recordings",
                            systemImage: "waveform",
                            description: Text("Tap the red button to record. Recordings stay on this iPhone.")
                        )
                    }
                }

                RecordingPanel(store: store, meter: store.meter) {
                    HapticEngine.play(store.isRecording ? .light : .medium, enabled: system.hapticsEnabled)
                }
            }
            .navigationTitle("Voice Memos")
            .alert("Rename", isPresented: Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } })) {
                TextField("Name", text: $renameText)
                Button("Cancel", role: .cancel) {}
                Button("Rename") {
                    if let memo = renaming { store.rename(memo, to: renameText) }
                }
            }
            .confirmationDialog(
                "Delete this recording?",
                isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let memo = deleting { store.delete(memo) }
                }
            } message: {
                Text("This can't be undone.")
            }
            .alert("Voice Memos", isPresented: Binding(get: { store.errorMessage != nil }, set: { if !$0 { store.errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(store.errorMessage ?? "")
            }
        }
        // Without background audio, recording can't continue once the app leaves the
        // screen, so it stops and saves.
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { store.stopRecording() }
        }
        .onDisappear {
            store.stopRecording()
            store.stopPlayback()
        }
    }
}

private struct MemoRow: View {
    let memo: VoiceMemo
    @ObservedObject var store: VoiceMemoStore

    private var isCurrent: Bool { store.playingID == memo.id }
    private var isPlaying: Bool { isCurrent && !store.isPaused }

    private func format(_ duration: TimeInterval) -> String {
        Duration.seconds(duration).formatted(.time(pattern: .minuteSecond))
    }

    var body: some View {
        HStack(spacing: 12) {
            Button {
                store.togglePlayback(of: memo)
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
            .disabled(store.isRecording)
            .accessibilityLabel(isPlaying ? "Pause \(memo.name)" : "Play \(memo.name)")

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(memo.name)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(format(memo.duration))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                Text(memo.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if isCurrent {
                    TimelineView(.animation(minimumInterval: 0.1, paused: !isPlaying)) { _ in
                        ProgressView(value: store.progress(of: memo))
                            .accessibilityLabel("Playback progress")
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private struct RecordingPanel: View {
    @ObservedObject var store: VoiceMemoStore
    @ObservedObject var meter: RecordingMeter
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if store.permission == .denied {
                VStack(spacing: 6) {
                    Text("Microphone access is off, so Swift UI can't record. You can still play your saved recordings.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.footnote.weight(.semibold))
                }
                .padding(.horizontal)
            }

            if store.isRecording {
                Text(Duration.seconds(meter.elapsed).formatted(.time(pattern: .minuteSecond)))
                    .font(.title2)
                    .monospacedDigit()
                    .accessibilityLabel("Recording time")

                HStack(spacing: 3) {
                    ForEach(Array(meter.samples.enumerated()), id: \.offset) { _, level in
                        Capsule()
                            .fill(Color.red)
                            .frame(width: 3, height: 3 + level * 39)
                    }
                }
                .frame(height: 42)
                .accessibilityHidden(true)
            }

            Button {
                onToggle()
                Task { await store.toggleRecording() }
            } label: {
                Circle()
                    .stroke(.red, lineWidth: 3)
                    .frame(width: 70, height: 70)
                    .overlay {
                        RoundedRectangle(cornerRadius: store.isRecording ? 8 : 28)
                            .fill(.red)
                            .frame(width: store.isRecording ? 30 : 58, height: store.isRecording ? 30 : 58)
                    }
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(store.permission == .denied)
            .accessibilityLabel(store.isRecording ? "Stop recording" : "Record")
        }
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity)
        .background(.bar)
    }
}
