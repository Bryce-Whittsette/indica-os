import QuickLook
import SwiftUI
import UniformTypeIdentifiers

/// One file or folder in Swift UI's own storage.
struct StoredFile: Identifiable, Hashable {
    let url: URL
    let isFolder: Bool
    let size: Int64
    let modified: Date

    var id: URL { url }
    var name: String { url.lastPathComponent }
}

/// File work for the Files app. Everything runs off the main actor, and every path
/// stays inside this app's Documents folder.
enum FileStorage {
    enum Failure: LocalizedError {
        case invalidName
        case nameTaken(String)

        var errorDescription: String? {
            switch self {
            case .invalidName: "Names can't be empty, start with a period, or contain a slash or colon."
            case .nameTaken(let name): "There's already an item named “\(name)”."
            }
        }
    }

    static var root: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func contents(of folder: URL) async throws -> [StoredFile] {
        try await Task.detached(priority: .userInitiated) {
            let keys: [URLResourceKey] = [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey]
            let urls = try FileManager.default.contentsOfDirectory(
                at: folder,
                includingPropertiesForKeys: keys,
                options: [.skipsHiddenFiles]
            )
            return urls.map { url in
                let values = try? url.resourceValues(forKeys: Set(keys))
                return StoredFile(
                    url: url,
                    isFolder: values?.isDirectory ?? false,
                    size: Int64(values?.fileSize ?? 0),
                    modified: values?.contentModificationDate ?? .distantPast
                )
            }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        }.value
    }

    static func validated(_ name: String) throws -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("."), !trimmed.contains("/"), !trimmed.contains(":") else {
            throw Failure.invalidName
        }
        return trimmed
    }

    static func createFolder(named name: String, in parent: URL) async throws {
        let valid = try validated(name)
        try await Task.detached(priority: .userInitiated) {
            let target = parent.appendingPathComponent(valid, isDirectory: true)
            guard !FileManager.default.fileExists(atPath: target.path) else { throw Failure.nameTaken(valid) }
            try FileManager.default.createDirectory(at: target, withIntermediateDirectories: false)
        }.value
    }

    static func rename(_ file: URL, to name: String) async throws {
        let valid = try validated(name)
        try await Task.detached(priority: .userInitiated) {
            let target = file.deletingLastPathComponent().appendingPathComponent(valid)
            guard target.lastPathComponent != file.lastPathComponent else { return }
            // A change in capitalization alone is the same path on this file system.
            let isSameItem = target.path.lowercased() == file.path.lowercased()
            guard isSameItem || !FileManager.default.fileExists(atPath: target.path) else {
                throw Failure.nameTaken(valid)
            }
            try FileManager.default.moveItem(at: file, to: target)
        }.value
    }

    static func delete(_ file: URL) async throws {
        try await Task.detached(priority: .userInitiated) {
            try FileManager.default.removeItem(at: file)
        }.value
    }

    /// Copies a file from outside the app. A name already in use gets a number, so
    /// an import never overwrites anything.
    static func importFile(from source: URL, into folder: URL) async throws {
        try await Task.detached(priority: .userInitiated) {
            let didAccess = source.startAccessingSecurityScopedResource()
            defer { if didAccess { source.stopAccessingSecurityScopedResource() } }
            let target = availableURL(named: source.lastPathComponent, in: folder)
            try FileManager.default.copyItem(at: source, to: target)
        }.value
    }

    private static func availableURL(named name: String, in folder: URL) -> URL {
        let base = (name as NSString).deletingPathExtension
        let suffix = (name as NSString).pathExtension
        var candidate = folder.appendingPathComponent(name)
        var number = 2
        while FileManager.default.fileExists(atPath: candidate.path) {
            let numbered = "\(base) \(number)"
            candidate = folder.appendingPathComponent(suffix.isEmpty ? numbered : "\(numbered).\(suffix)")
            number += 1
        }
        return candidate
    }
}

struct FilesApp: View {
    var body: some View {
        NavigationStack {
            FolderView(folder: FileStorage.root, title: "Swift UI Files")
        }
    }
}

private struct FolderView: View {
    let folder: URL
    let title: String

    @State private var items: [StoredFile] = []
    @State private var hasLoaded = false
    @State private var importing = false
    @State private var newFolderName = ""
    @State private var showingNewFolder = false
    @State private var renaming: StoredFile?
    @State private var renameText = ""
    @State private var deleting: StoredFile?
    @State private var previewURL: URL?
    @State private var errorMessage: String?

    private var isRoot: Bool { folder == FileStorage.root }

    var body: some View {
        List {
            ForEach(items) { item in
                row(item)
            }

            if isRoot {
                Section {
                } footer: {
                    Text("These files are stored in Swift UI on this iPhone. They aren't iCloud Drive or the iOS Files app. Use Import to copy a file in, and Share to send a copy out.")
                }
            }
        }
        .listStyle(.plain)
        .overlay {
            if hasLoaded && items.isEmpty {
                ContentUnavailableView {
                    Label(isRoot ? "No Files" : "Empty Folder", systemImage: "folder")
                } description: {
                    Text("Import a file or create a folder.")
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button { showingNewFolder = true } label: { Image(systemName: "folder.badge.plus") }
                    .accessibilityLabel("New folder")
                Button { importing = true } label: { Image(systemName: "square.and.arrow.down") }
                    .accessibilityLabel("Import file")
            }
        }
        .task { await reload() }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
            handleImport(result)
        }
        .quickLookPreview($previewURL)
        .alert("New Folder", isPresented: $showingNewFolder) {
            TextField("Name", text: $newFolderName)
            Button("Cancel", role: .cancel) { newFolderName = "" }
            Button("Create") {
                let name = newFolderName
                newFolderName = ""
                run { try await FileStorage.createFolder(named: name, in: folder) }
            }
        }
        .alert("Rename", isPresented: Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } })) {
            TextField("Name", text: $renameText)
            Button("Cancel", role: .cancel) {}
            Button("Rename") {
                guard let file = renaming else { return }
                let name = renameText
                run { try await FileStorage.rename(file.url, to: name) }
            }
        }
        .confirmationDialog(
            deleting?.isFolder == true ? "Delete this folder and everything in it?" : "Delete this file?",
            isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                guard let file = deleting else { return }
                run { try await FileStorage.delete(file.url) }
            }
        } message: {
            Text("This can't be undone.")
        }
        .alert("Couldn't Do That", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    @ViewBuilder
    private func row(_ item: StoredFile) -> some View {
        Group {
            if item.isFolder {
                NavigationLink {
                    FolderView(folder: item.url, title: item.name)
                } label: {
                    rowLabel(item)
                }
            } else {
                Button {
                    previewURL = item.url
                } label: {
                    rowLabel(item)
                }
                .foregroundStyle(.primary)
            }
        }
        .swipeActions {
            Button("Delete", role: .destructive) { deleting = item }
            Button("Rename") {
                renameText = item.name
                renaming = item
            }
        }
        .contextMenu {
            Button { renameText = item.name; renaming = item } label: { Label("Rename", systemImage: "pencil") }
            if !item.isFolder {
                ShareLink(item: item.url) { Label("Share", systemImage: "square.and.arrow.up") }
            }
            Button(role: .destructive) { deleting = item } label: { Label("Delete", systemImage: "trash") }
        }
    }

    private func rowLabel(_ item: StoredFile) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.isFolder ? "folder.fill" : "doc.fill")
                .foregroundStyle(.blue)
                .frame(width: 28)
            VStack(alignment: .leading) {
                Text(item.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(detail(item))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func detail(_ item: StoredFile) -> String {
        let date = item.modified.formatted(date: .abbreviated, time: .omitted)
        if item.isFolder { return "Folder · \(date)" }
        return "\(item.size.formatted(.byteCount(style: .file))) · \(date)"
    }

    private func reload() async {
        do {
            items = try await FileStorage.contents(of: folder)
        } catch {
            errorMessage = error.localizedDescription
        }
        hasLoaded = true
    }

    private func run(_ action: @escaping () async throws -> Void) {
        Task {
            do {
                try await action()
            } catch {
                errorMessage = error.localizedDescription
            }
            await reload()
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            run {
                for url in urls {
                    try await FileStorage.importFile(from: url, into: folder)
                }
            }
        case .failure(let error):
            // Cancelling isn't a failure: the picker reports it as success with nothing.
            errorMessage = error.localizedDescription
        }
    }
}
