import SwiftUI
import AuthenticationServices
import CryptoKit
import Security
import UIKit

enum ConnectedService: String, CaseIterable, Identifiable, Codable {
    case apple
    case spotify
    case google
    case microsoft
    case notion
    case discord
    case telegram
    case openAI
    case anthropic

    var id: String { rawValue }

    var name: String {
        switch self {
        case .apple: "Device & Apple Services"
        case .spotify: "Spotify"
        case .google: "Google"
        case .microsoft: "Microsoft"
        case .notion: "Notion"
        case .discord: "Discord"
        case .telegram: "Telegram"
        case .openAI: "OpenAI API"
        case .anthropic: "Anthropic API"
        }
    }

    var shortName: String {
        switch self {
        case .apple: "Apple"
        case .microsoft: "Microsoft"
        case .openAI: "OpenAI"
        case .anthropic: "Anthropic"
        default: name
        }
    }

    var symbol: String {
        switch self {
        case .apple: "iphone.gen3"
        case .spotify: "waveform.circle.fill"
        case .google: "g.circle.fill"
        case .microsoft: "square.grid.2x2.fill"
        case .notion: "doc.richtext.fill"
        case .discord: "bubble.left.and.bubble.right.fill"
        case .telegram: "paperplane.fill"
        case .openAI: "sparkles"
        case .anthropic: "sun.max.fill"
        }
    }

    var tint: Color {
        switch self {
        case .apple: .gray
        case .spotify: Color(hex: 0x20C968)
        case .google: Color(hex: 0x4285F4)
        case .microsoft: Color(hex: 0x2C8CE5)
        case .notion: Color(hex: 0x38383B)
        case .discord: Color(hex: 0x697BF0)
        case .telegram: Color(hex: 0x34A9E8)
        case .openAI: Color(hex: 0x33A68C)
        case .anthropic: Color(hex: 0xD68B5C)
        }
    }

    var connectionKind: String {
        switch self {
        case .apple: "On-device permission"
        case .spotify: "OAuth 2.0 + PKCE"
        case .google: "Google Sign-In"
        case .microsoft: "Microsoft identity"
        case .notion: "OAuth + secure backend"
        case .discord: "OAuth public client"
        case .telegram: "Telegram client authorization"
        case .openAI, .anthropic: "Developer API key"
        }
    }

    var summary: String {
        switch self {
        case .apple:
            "Calendar, Reminders, Photos, Contacts, and Apple Music use the permissions on this iPhone."
        case .spotify:
            "Personal profile, top music, library, and playback state through Spotify’s official Web API."
        case .google:
            "One consent flow for YouTube and Gmail, using only the scopes you approve."
        case .microsoft:
            "Personal Outlook mail and calendar through Microsoft Graph."
        case .notion:
            "Pages and databases that you explicitly select in Notion’s authorization picker."
        case .discord:
            "Discord identity, servers, and approved connection data. Private messages are not exposed."
        case .telegram:
            "A full personal account requires Telegram’s native client API and phone or QR authorization."
        case .openAI:
            "Developer API access for an Indica assistant. ChatGPT subscriptions and chat history are separate."
        case .anthropic:
            "Developer API access for a Claude-powered assistant. Claude subscriptions and chat history are separate."
        }
    }

    var capabilities: [String] {
        switch self {
        case .apple:
            ["Calendar and reminders", "Photos and camera", "Contacts", "Apple Music library"]
        case .spotify:
            ["Profile", "Top tracks and artists", "Library", "Currently playing"]
        case .google:
            ["YouTube profile and playlists", "Gmail inbox", "Google account identity"]
        case .microsoft:
            ["Outlook inbox", "Calendar", "Microsoft account identity"]
        case .notion:
            ["Selected pages", "Databases", "Search", "Create and update content"]
        case .discord:
            ["Identity", "Servers", "Linked connections", "Open the Discord app"]
        case .telegram:
            ["Personal chats with native client setup", "Contacts", "Channels", "Open Telegram"]
        case .openAI, .anthropic:
            ["Private API credential in Keychain", "Indica assistant", "No access to consumer chat history"]
        }
    }

    var setupRequirement: String {
        switch self {
        case .apple:
            "No third-party account credential is copied. Indica asks for each iPhone permission when the related feature is used."
        case .spotify:
            "Add a Spotify developer client ID and register indicaos://oauth/spotify as the redirect URI."
        case .google:
            "Create an iOS OAuth client for com.indicaos.prototype and enable the Gmail and YouTube APIs."
        case .microsoft:
            "Register the iOS app in Microsoft Entra and add Microsoft’s MSAL package and redirect URI."
        case .notion:
            "A small secure backend is required because Notion’s token exchange uses a client secret."
        case .discord:
            "Create a Discord developer application, enable it as a public client, and register the redirect URI."
        case .telegram:
            "Create a Telegram api_id and api_hash, then integrate TDLib before enabling personal chat login."
        case .openAI:
            "Use an API-platform key. A ChatGPT Plus or Pro subscription does not include API usage."
        case .anthropic:
            "Use an Anthropic Console API key. A Claude Pro subscription does not include API usage."
        }
    }

    var webURL: URL {
        switch self {
        case .apple: URL(string: "https://support.apple.com/guide/iphone/control-access-to-information-in-apps-iph251e92810/ios")!
        case .spotify: URL(string: "https://open.spotify.com")!
        case .google: URL(string: "https://myaccount.google.com")!
        case .microsoft: URL(string: "https://outlook.live.com")!
        case .notion: URL(string: "https://www.notion.so")!
        case .discord: URL(string: "https://discord.com/app")!
        case .telegram: URL(string: "https://web.telegram.org")!
        case .openAI: URL(string: "https://platform.openai.com/api-keys")!
        case .anthropic: URL(string: "https://console.anthropic.com/settings/keys")!
        }
    }

    var deepLinkURL: URL? {
        switch self {
        case .apple: URL(string: UIApplication.openSettingsURLString)
        case .spotify: URL(string: "spotify://")
        case .google: URL(string: "youtube://")
        case .microsoft: URL(string: "ms-outlook://")
        case .notion: URL(string: "notion://")
        case .discord: URL(string: "discord://")
        case .telegram: URL(string: "tg://")
        case .openAI: URL(string: "chatgpt://")
        case .anthropic: URL(string: "claude://")
        }
    }

    static func service(for app: BuiltInApp) -> ConnectedService? {
        switch app {
        case .spotify: .spotify
        case .youtube, .gmail: .google
        case .outlook: .microsoft
        case .notion: .notion
        case .discord: .discord
        case .telegram: .telegram
        case .chatGPT: .openAI
        case .claude: .anthropic
        default: nil
        }
    }
}

struct ConnectedAccountRecord: Codable, Equatable {
    var displayName: String
    var detail: String
    var connectedAt: Date
}

struct SpotifyTrack: Identifiable, Equatable {
    let id: String
    let name: String
    let artist: String
}

enum ConnectionError: LocalizedError {
    case missingClientID
    case invalidAuthorizationResponse
    case stateMismatch
    case authorizationDidNotStart
    case tokenExchangeFailed(String)
    case noCredential
    case apiRequestFailed(String)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .missingClientID:
            "A developer client ID has not been configured."
        case .invalidAuthorizationResponse:
            "The sign-in response was incomplete."
        case .stateMismatch:
            "The sign-in response could not be verified. Please try again."
        case .authorizationDidNotStart:
            "The secure sign-in window could not be opened."
        case .tokenExchangeFailed(let message):
            "The service rejected the connection: \(message)"
        case .noCredential:
            "No saved credential is available."
        case .apiRequestFailed(let message):
            "The assistant request failed: \(message)"
        case .emptyResponse:
            "The assistant returned an empty response."
        }
    }
}

struct AIConversationMessage: Identifiable, Equatable {
    enum Role: String {
        case user
        case assistant
    }

    let id: UUID
    let role: Role
    let text: String
    let createdAt: Date

    init(id: UUID = UUID(), role: Role, text: String, createdAt: Date = .now) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}

enum CredentialVault {
    private static let service = "com.indicaos.prototype.credentials"

    static func save(_ value: String, account: String) throws {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let updateStatus = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if updateStatus == errSecSuccess { return }
        guard updateStatus == errSecItemNotFound else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(updateStatus))
        }
        var insert = query
        insert[kSecValueData as String] = data
        insert[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(insert as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }

    static func load(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        guard
            SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
            let data = result as? Data
        else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    static func delete(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}

@MainActor
final class ConnectionStore: ObservableObject {
    @Published private(set) var accounts: [String: ConnectedAccountRecord] = [:]
    @Published private(set) var spotifyTracks: [SpotifyTrack] = []
    @Published private(set) var isLoadingSpotify = false
    @Published var lastError: String?

    private var clientIDs: [String: String] = [:]
    private var authenticationSession: ASWebAuthenticationSession?
    private let presentationProvider = OAuthPresentationProvider()

    init() {
        if
            let data = UserDefaults.standard.data(forKey: "connectedAccounts"),
            let value = try? JSONDecoder().decode([String: ConnectedAccountRecord].self, from: data)
        {
            accounts = value
        }
        if
            let data = UserDefaults.standard.data(forKey: "integrationClientIDs"),
            let value = try? JSONDecoder().decode([String: String].self, from: data)
        {
            clientIDs = value
        }
    }

    var connectedCount: Int {
        ConnectedService.allCases.filter(isConnected).count
    }

    func isConnected(_ service: ConnectedService) -> Bool {
#if DEBUG
        if
            ProcessInfo.processInfo.arguments.contains("--assistant-preview"),
            service == .openAI || service == .anthropic
        {
            return true
        }
#endif
        guard accounts[service.rawValue] != nil else { return false }
        switch service {
        case .openAI, .anthropic:
            return CredentialVault.load(account: "\(service.rawValue).apiKey") != nil
        case .spotify:
            return CredentialVault.load(account: "spotify.accessToken") != nil
        case .apple:
            return true
        default:
            return true
        }
    }

    func account(for service: ConnectedService) -> ConnectedAccountRecord? {
        accounts[service.rawValue]
    }

    func clientID(for service: ConnectedService) -> String {
        clientIDs[service.rawValue, default: ""]
    }

    func setClientID(_ value: String, for service: ConnectedService) {
        clientIDs[service.rawValue] = value.trimmingCharacters(in: .whitespacesAndNewlines)
        saveClientIDs()
    }

    func saveAPIKey(_ value: String, for service: ConnectedService) throws {
        guard service == .openAI || service == .anthropic else { return }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 12 else { throw ConnectionError.noCredential }
        try CredentialVault.save(trimmed, account: "\(service.rawValue).apiKey")
        accounts[service.rawValue] = ConnectedAccountRecord(
            displayName: "\(service.shortName) Developer API",
            detail: "Credential stored in this device’s Keychain",
            connectedAt: .now
        )
        saveAccounts()
    }

    func disconnect(_ service: ConnectedService) {
        switch service {
        case .spotify:
            CredentialVault.delete(account: "spotify.accessToken")
            CredentialVault.delete(account: "spotify.refreshToken")
            spotifyTracks = []
        case .openAI, .anthropic:
            CredentialVault.delete(account: "\(service.rawValue).apiKey")
        default:
            break
        }
        accounts.removeValue(forKey: service.rawValue)
        saveAccounts()
    }

    func markAppleServicesReady() {
        accounts[ConnectedService.apple.rawValue] = ConnectedAccountRecord(
            displayName: "This iPhone",
            detail: "Permission is requested feature by feature",
            connectedAt: .now
        )
        saveAccounts()
    }

    func connectSpotify() async throws {
        guard authenticationSession == nil else {
            throw ConnectionError.apiRequestFailed("A sign-in is already in progress.")
        }
        let clientID = clientID(for: .spotify)
        guard !clientID.isEmpty else { throw ConnectionError.missingClientID }

        let verifier = try Self.randomURLSafeString(byteCount: 48)
        let state = try Self.randomURLSafeString(byteCount: 24)
        let challenge = Data(SHA256.hash(data: Data(verifier.utf8))).base64URLEncodedString()
        let redirectURI = "indicaos://oauth/spotify"

        var components = URLComponents(string: "https://accounts.spotify.com/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: "user-read-private user-read-email user-read-currently-playing user-top-read user-library-read"),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "state", value: state)
        ]
        guard let authorizationURL = components.url else {
            throw ConnectionError.invalidAuthorizationResponse
        }

        defer { authenticationSession = nil }
        let callbackURL: URL = try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authorizationURL,
                callbackURLScheme: "indicaos"
            ) { url, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: ConnectionError.invalidAuthorizationResponse)
                }
            }
            session.presentationContextProvider = presentationProvider
            session.prefersEphemeralWebBrowserSession = false
            authenticationSession = session
            guard session.start() else {
                continuation.resume(throwing: ConnectionError.authorizationDidNotStart)
                return
            }
        }
        guard callbackURL.scheme == "indicaos", callbackURL.host == "oauth",
              callbackURL.path == "/spotify" else {
            throw ConnectionError.invalidAuthorizationResponse
        }
        let callback = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)
        let returnedState = callback?.queryItems?.first(where: { $0.name == "state" })?.value
        guard returnedState == state else { throw ConnectionError.stateMismatch }
        guard let code = callback?.queryItems?.first(where: { $0.name == "code" })?.value else {
            let message = callback?.queryItems?.first(where: { $0.name == "error" })?.value ?? "No authorization code was returned."
            throw ConnectionError.tokenExchangeFailed(message)
        }

        let token = try await exchangeSpotifyCode(
            code,
            verifier: verifier,
            clientID: clientID,
            redirectURI: redirectURI
        )
        try CredentialVault.save(token.accessToken, account: "spotify.accessToken")
        if let refreshToken = token.refreshToken {
            try CredentialVault.save(refreshToken, account: "spotify.refreshToken")
        }

        let profile = try await fetchSpotifyProfile(accessToken: token.accessToken)
        accounts[ConnectedService.spotify.rawValue] = ConnectedAccountRecord(
            displayName: profile.displayName ?? profile.id,
            detail: profile.email ?? "Spotify account",
            connectedAt: .now
        )
        saveAccounts()
        await loadSpotifyTopTracks()
    }

    func loadSpotifyTopTracks() async {
        guard !isLoadingSpotify else { return }
        guard let token = CredentialVault.load(account: "spotify.accessToken") else {
            lastError = ConnectionError.noCredential.localizedDescription
            return
        }
        isLoadingSpotify = true
        defer { isLoadingSpotify = false }
        do {
            var request = URLRequest(url: URL(string: "https://api.spotify.com/v1/me/top/tracks?limit=6&time_range=short_term")!)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            var (data, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 401 {
                let refreshed = try await refreshSpotifyToken()
                request.setValue("Bearer \(refreshed)", forHTTPHeaderField: "Authorization")
                (data, response) = try await URLSession.shared.data(for: request)
            }
            guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                throw ConnectionError.tokenExchangeFailed("Spotify data could not be loaded.")
            }
            let result = try JSONDecoder().decode(SpotifyTopTracksResponse.self, from: data)
            spotifyTracks = result.items.map {
                SpotifyTrack(
                    id: $0.id,
                    name: $0.name,
                    artist: $0.artists.map(\.name).joined(separator: ", ")
                )
            }
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func openOfficialAppOrWebsite(_ service: ConnectedService) {
        guard let deepLink = service.deepLinkURL else {
            UIApplication.shared.open(service.webURL)
            return
        }
        UIApplication.shared.open(deepLink, options: [:]) { opened in
            if !opened {
                UIApplication.shared.open(service.webURL)
            }
        }
    }

    func sendAIMessage(
        history: [AIConversationMessage],
        service: ConnectedService,
        model: String
    ) async throws -> String {
        guard service == .openAI || service == .anthropic else {
            throw ConnectionError.apiRequestFailed("This provider is not an AI assistant.")
        }
        guard let apiKey = CredentialVault.load(account: "\(service.rawValue).apiKey") else {
            throw ConnectionError.noCredential
        }

        let cleanModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanModel.isEmpty else {
            throw ConnectionError.apiRequestFailed("Choose a model in Assistant Settings.")
        }

        switch service {
        case .openAI:
            return try await sendOpenAIMessage(history: history, model: cleanModel, apiKey: apiKey)
        case .anthropic:
            return try await sendAnthropicMessage(history: history, model: cleanModel, apiKey: apiKey)
        default:
            throw ConnectionError.apiRequestFailed("Unsupported provider.")
        }
    }

    private func refreshSpotifyToken() async throws -> String {
        guard let refreshToken = CredentialVault.load(account: "spotify.refreshToken") else {
            throw ConnectionError.noCredential
        }
        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var body = URLComponents()
        body.queryItems = [URLQueryItem(name: "grant_type", value: "refresh_token"),
                           URLQueryItem(name: "refresh_token", value: refreshToken),
                           URLQueryItem(name: "client_id", value: clientID(for: .spotify))]
        request.httpBody = body.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B").data(using: .utf8)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw ConnectionError.tokenExchangeFailed("Spotify authorization expired. Reconnect your account.")
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let token = try decoder.decode(SpotifyTokenResponse.self, from: data)
        try CredentialVault.save(token.accessToken, account: "spotify.accessToken")
        if let replacement = token.refreshToken {
            try CredentialVault.save(replacement, account: "spotify.refreshToken")
        }
        return token.accessToken
    }

    private func exchangeSpotifyCode(
        _ code: String,
        verifier: String,
        clientID: String,
        redirectURI: String
    ) async throws -> SpotifyTokenResponse {
        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var body = URLComponents()
        body.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "code_verifier", value: verifier)
        ]
        request.httpBody = body.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B").data(using: .utf8)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            let message = String(data: data, encoding: .utf8) ?? "Token exchange failed."
            throw ConnectionError.tokenExchangeFailed(message)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(SpotifyTokenResponse.self, from: data)
    }

    private func fetchSpotifyProfile(accessToken: String) async throws -> SpotifyProfileResponse {
        var request = URLRequest(url: URL(string: "https://api.spotify.com/v1/me")!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw ConnectionError.tokenExchangeFailed("Spotify profile could not be loaded.")
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(SpotifyProfileResponse.self, from: data)
    }

    private func sendOpenAIMessage(
        history: [AIConversationMessage],
        model: String,
        apiKey: String
    ) async throws -> String {
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/responses")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "model": model,
            "instructions": "You are the helpful assistant inside Indica OS. Be clear, concise, and friendly.",
            "input": history.map { message in
                [
                    "role": message.role.rawValue,
                    "content": message.text
                ]
            },
            "max_output_tokens": 1200
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateAIResponse(data: data, response: response)
        guard
            let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let output = root["output"] as? [[String: Any]]
        else {
            throw ConnectionError.emptyResponse
        }

        let text = output
            .compactMap { $0["content"] as? [[String: Any]] }
            .flatMap { $0 }
            .compactMap { $0["text"] as? String }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else { throw ConnectionError.emptyResponse }
        return text
    }

    private func sendAnthropicMessage(
        history: [AIConversationMessage],
        model: String,
        apiKey: String
    ) async throws -> String {
        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "model": model,
            "system": "You are the helpful assistant inside Indica OS. Be clear, concise, and friendly.",
            "messages": history.map { message in
                [
                    "role": message.role.rawValue,
                    "content": message.text
                ]
            },
            "max_tokens": 1200
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateAIResponse(data: data, response: response)
        guard
            let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let content = root["content"] as? [[String: Any]]
        else {
            throw ConnectionError.emptyResponse
        }

        let text = content
            .compactMap { $0["text"] as? String }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else { throw ConnectionError.emptyResponse }
        return text
    }

    private func validateAIResponse(data: Data, response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw ConnectionError.apiRequestFailed("No server response was received.")
        }
        guard 200..<300 ~= http.statusCode else {
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let error = root?["error"] as? [String: Any]
            let message = error?["message"] as? String
                ?? HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
            throw ConnectionError.apiRequestFailed(message)
        }
    }

    private func saveAccounts() {
        if let data = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(data, forKey: "connectedAccounts")
        }
    }

    private func saveClientIDs() {
        if let data = try? JSONEncoder().encode(clientIDs) {
            UserDefaults.standard.set(data, forKey: "integrationClientIDs")
        }
    }

    private static func randomURLSafeString(byteCount: Int) throws -> String {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status != errSecSuccess {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
        return Data(bytes).base64URLEncodedString()
    }
}

private struct SpotifyTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
}

private struct SpotifyProfileResponse: Decodable {
    let id: String
    let displayName: String?
    let email: String?
}

private struct SpotifyTopTracksResponse: Decodable {
    struct Track: Decodable {
        struct Artist: Decodable {
            let name: String
        }

        let id: String
        let name: String
        let artists: [Artist]
    }

    let items: [Track]
}

private final class OAuthPresentationProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        if let keyWindow = scenes.flatMap(\.windows).first(where: \.isKeyWindow) {
            return keyWindow
        }
        return scenes.first?.windows.first ?? UIWindow()
    }
}

private extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

struct ConnectionsApp: View {
    @EnvironmentObject private var store: ConnectionStore

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ConnectionsSummaryCard()
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                Section("On this iPhone") {
                    NavigationLink {
                        ServiceConnectionDetail(service: .apple)
                    } label: {
                        ConnectionServiceRow(service: .apple)
                    }
                }

                Section("Daily Apps") {
                    ForEach([
                        ConnectedService.spotify,
                        .google,
                        .microsoft,
                        .notion,
                        .discord,
                        .telegram
                    ]) { service in
                        NavigationLink {
                            ServiceConnectionDetail(service: service)
                        } label: {
                            ConnectionServiceRow(service: service)
                        }
                    }
                }

                Section {
                    ForEach([ConnectedService.openAI, .anthropic]) { service in
                        NavigationLink {
                            ServiceConnectionDetail(service: service)
                        } label: {
                            ConnectionServiceRow(service: service)
                        }
                    }
                } header: {
                    Text("Developer Assistants")
                } footer: {
                    Text("Developer API access is separate from consumer ChatGPT and Claude subscriptions.")
                }

                Section("Privacy") {
                    Label("Credentials stay in the iPhone Keychain", systemImage: "key.fill")
                    Label("Passwords and Mac sessions are never copied", systemImage: "hand.raised.fill")
                    Label("Disconnect deletes the local credential", systemImage: "trash.slash.fill")
                }
                .font(.subheadline)
            }
            .navigationTitle("Connections")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

private struct ConnectionsSummaryCard: View {
    @EnvironmentObject private var store: ConnectionStore

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0x9E8AFF), Color(hex: 0x4D73F0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 29, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 66, height: 66)

            VStack(alignment: .leading, spacing: 4) {
                Text("Indica Account Center")
                    .font(.title3.bold())
                Text("\(store.connectedCount) services ready")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Label("Private by default", systemImage: "lock.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.green)
            }

            Spacer()
        }
        .padding(18)
        .liquidGlass(cornerRadius: 28, intensity: 0.92)
        .padding(.vertical, 4)
    }
}

private struct ConnectionServiceRow: View {
    @EnvironmentObject private var store: ConnectionStore
    let service: ConnectedService

    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: service.symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(service.tint, in: RoundedRectangle(cornerRadius: 11, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(service.name)
                    .foregroundStyle(.primary)
                Text(store.isConnected(service) ? (store.account(for: service)?.displayName ?? "Connected") : service.connectionKind)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if store.isConnected(service) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Text("Set Up")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 3)
    }
}

struct ServiceConnectionDetail: View {
    @EnvironmentObject private var store: ConnectionStore
    let service: ConnectedService

    @State private var showingClientSetup = false
    @State private var showingAPIKey = false
    @State private var isConnecting = false
    @State private var message: String?

    var body: some View {
        List {
            Section {
                VStack(spacing: 14) {
                    Image(systemName: service.symbol)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 78, height: 78)
                        .background(service.tint, in: RoundedRectangle(cornerRadius: 23, style: .continuous))
                        .shadow(color: service.tint.opacity(0.28), radius: 16, y: 8)

                    Text(service.name)
                        .font(.title2.bold())

                    Text(service.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    ConnectionStatusPill(service: service)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .listRowBackground(Color.clear)

            Section("What Indica Can Use") {
                ForEach(service.capabilities, id: \.self) { capability in
                    Label(capability, systemImage: "checkmark.circle")
                }
            }

            Section("Connection Method") {
                LabeledContent("Security", value: service.connectionKind)
                Text(service.setupRequirement)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section {
                if store.isConnected(service) {
                    if let account = store.account(for: service) {
                        LabeledContent("Account", value: account.displayName)
                        LabeledContent("Details", value: account.detail)
                        LabeledContent("Connected", value: account.connectedAt.formatted(date: .abbreviated, time: .shortened))
                    }

                    Button("Disconnect", role: .destructive) {
                        store.disconnect(service)
                    }
                } else {
                    connectButton
                }

                Button {
                    store.openOfficialAppOrWebsite(service)
                } label: {
                    Label("Open Official App or Website", systemImage: "arrow.up.forward.app")
                }
            }

            if let message {
                Section {
                    Label(message, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            }
        }
        .navigationTitle(service.shortName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingClientSetup) {
            ClientIDSetupSheet(service: service)
        }
        .sheet(isPresented: $showingAPIKey) {
            APIKeySetupSheet(service: service)
        }
    }

    @ViewBuilder
    private var connectButton: some View {
        switch service {
        case .apple:
            Button {
                store.markAppleServicesReady()
            } label: {
                Label("Enable Permission Center", systemImage: "checkmark.shield.fill")
            }
        case .spotify:
            if store.clientID(for: .spotify).isEmpty {
                Button {
                    showingClientSetup = true
                } label: {
                    Label("Add Spotify Client ID", systemImage: "wrench.and.screwdriver.fill")
                }
            } else {
                Button {
                    isConnecting = true
                    message = nil
                    Task {
                        do {
                            try await store.connectSpotify()
                        } catch {
                            message = error.localizedDescription
                        }
                        isConnecting = false
                    }
                } label: {
                    if isConnecting {
                        HStack {
                            ProgressView()
                            Text("Opening Secure Sign-In…")
                        }
                    } else {
                        Label("Connect Spotify", systemImage: "person.badge.key.fill")
                    }
                }
                .disabled(isConnecting)

                Button("Change Client ID") {
                    showingClientSetup = true
                }
                .font(.subheadline)
            }
        case .openAI, .anthropic:
            Button {
                showingAPIKey = true
            } label: {
                Label("Store Developer API Key", systemImage: "key.fill")
            }
        case .google, .microsoft, .notion, .discord:
            Button {
                showingClientSetup = true
            } label: {
                Label("Add Developer Configuration", systemImage: "wrench.and.screwdriver.fill")
            }
        case .telegram:
            Button {
                store.openOfficialAppOrWebsite(.telegram)
            } label: {
                Label("Open Telegram", systemImage: "paperplane.fill")
            }
        }
    }
}

private struct ConnectionStatusPill: View {
    @EnvironmentObject private var store: ConnectionStore
    let service: ConnectedService

    var body: some View {
        Label(
            store.isConnected(service) ? "Connected" : "Not connected",
            systemImage: store.isConnected(service) ? "checkmark.circle.fill" : "circle.dashed"
        )
        .font(.caption.bold())
        .foregroundStyle(store.isConnected(service) ? .green : .secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Color.primary.opacity(0.06), in: Capsule())
    }
}

private struct ClientIDSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ConnectionStore
    let service: ConnectedService
    @State private var clientID = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Developer Configuration") {
                    TextField("\(service.shortName) client ID", text: $clientID)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section {
                    Text(service.setupRequirement)
                    if service != .spotify {
                        Text("Saving this identifies the developer application only. Personal sign-in remains disabled until the official SDK or secure backend for this provider is added.")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Section("Security") {
                    Label("Client IDs are public identifiers", systemImage: "info.circle")
                    Label("Client secrets must never be placed in the iPhone app", systemImage: "lock.shield.fill")
                }
            }
            .navigationTitle("Configure \(service.shortName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.setClientID(clientID, for: service)
                        dismiss()
                    }
                    .disabled(clientID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                clientID = store.clientID(for: service)
            }
        }
    }
}

private struct APIKeySetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ConnectionStore
    let service: ConnectedService
    @State private var key = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Developer API Key") {
                    SecureField("Paste key", text: $key)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section {
                    Text(service.setupRequirement)
                    Text("Indica stores the key in the device Keychain. It is never written to source code or UserDefaults.")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                }
            }
            .navigationTitle(service.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        do {
                            try store.saveAPIKey(key, for: service)
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                    .disabled(key.trimmingCharacters(in: .whitespacesAndNewlines).count < 12)
                }
            }
        }
    }
}

struct ConnectedServiceApp: View {
    @EnvironmentObject private var store: ConnectionStore
    let app: BuiltInApp

    private var service: ConnectedService {
        ConnectedService.service(for: app) ?? .apple
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    serviceHero

                    if service == .spotify, store.isConnected(.spotify) {
                        spotifyContent
                    } else {
                        connectionContent
                    }

                    capabilityCard
                }
                .padding(16)
            }
            .background(
                LinearGradient(
                    colors: [service.tint.opacity(0.12), Color(uiColor: .systemBackground)],
                    startPoint: .top,
                    endPoint: .center
                )
            )
            .navigationTitle(app.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.openOfficialAppOrWebsite(service)
                    } label: {
                        Image(systemName: "arrow.up.forward.app")
                    }
                    .accessibilityLabel("Open official \(service.shortName) app")
                }
            }
        }
    }

    private var serviceHero: some View {
        HStack(spacing: 15) {
            PremiumAppMark(app: app, size: 66)

            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.title2.bold())
                Text(store.account(for: service)?.displayName ?? service.connectionKind)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                ConnectionStatusPill(service: service)
            }
            Spacer()
        }
        .padding(17)
        .liquidGlass(cornerRadius: 28, intensity: 0.9)
    }

    @ViewBuilder
    private var spotifyContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Top Tracks")
                    .font(.headline)
                Spacer()
                Button {
                    Task { await store.loadSpotifyTopTracks() }
                } label: {
                    if store.isLoadingSpotify {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }

            if store.spotifyTracks.isEmpty {
                ContentUnavailableView(
                    "No Music Loaded",
                    systemImage: "music.note.list",
                    description: Text("Refresh after connecting to load Spotify data.")
                )
                .frame(minHeight: 180)
            } else {
                ForEach(Array(store.spotifyTracks.enumerated()), id: \.element.id) { index, track in
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Image(systemName: "music.note")
                            .foregroundStyle(service.tint)
                            .frame(width: 34, height: 34)
                            .background(service.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(track.name)
                                .font(.subheadline.bold())
                                .lineLimit(1)
                            Text(track.artist)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                }
            }

            if let error = store.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(17)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 25, style: .continuous))
    }

    private var connectionContent: some View {
        VStack(spacing: 13) {
            Image(systemName: store.isConnected(service) ? "checkmark.shield.fill" : "person.badge.key.fill")
                .font(.system(size: 32))
                .foregroundStyle(store.isConnected(service) ? .green : service.tint)

            Text(store.isConnected(service) ? "Connection Ready" : "Connect Your Account")
                .font(.headline)

            Text(
                store.isConnected(service)
                ? "Indica can now use only the access you approved."
                : service.setupRequirement
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            NavigationLink {
                ServiceConnectionDetail(service: service)
            } label: {
                Text(store.isConnected(service) ? "Manage Connection" : "Set Up Connection")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(18)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 25, style: .continuous))
    }

    private var capabilityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available Features")
                .font(.headline)
            ForEach(service.capabilities, id: \.self) { capability in
                Label(capability, systemImage: "checkmark.circle")
                    .font(.subheadline)
            }
            Divider()
            Button {
                store.openOfficialAppOrWebsite(service)
            } label: {
                Label("Open \(service.shortName)", systemImage: "arrow.up.forward.app")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(17)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 25, style: .continuous))
    }
}

struct AIAssistantApp: View {
    @EnvironmentObject private var store: ConnectionStore
    let app: BuiltInApp

    @AppStorage("assistant.openAI.model") private var openAIModel = "gpt-5.6-luna"
    @AppStorage("assistant.anthropic.model") private var anthropicModel = "claude-haiku-4-5"
    @State private var messages: [AIConversationMessage] = []
    @State private var prompt = ""
    @State private var isSending = false
    @State private var errorMessage: String?
    @State private var showingAssistantSettings = false
    @FocusState private var composerFocused: Bool

    private var service: ConnectedService {
        app == .claude ? .anthropic : .openAI
    }

    private var model: String {
        service == .anthropic ? anthropicModel : openAIModel
    }

    private var modelBinding: Binding<String> {
        Binding(
            get: { model },
            set: { newValue in
                if service == .anthropic {
                    anthropicModel = newValue
                } else {
                    openAIModel = newValue
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.isConnected(service) {
                    conversation
                } else {
                    setupRequired
                }
            }
            .background(
                LinearGradient(
                    colors: [service.tint.opacity(0.12), Color(uiColor: .systemBackground)],
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()
            )
            .navigationTitle(app.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if store.isConnected(service) {
                        Button {
                            resetConversation()
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .accessibilityLabel("New conversation")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAssistantSettings = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel("Assistant settings")
                }
            }
            .sheet(isPresented: $showingAssistantSettings) {
                AssistantSettingsSheet(
                    service: service,
                    model: modelBinding
                )
            }
            .onAppear {
                if messages.isEmpty {
                    resetConversation()
                }
            }
        }
    }

    private var conversation: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        assistantHeader

                        ForEach(messages) { message in
                            AIAssistantBubble(
                                message: message,
                                tint: service.tint
                            )
                            .id(message.id)
                        }

                        if isSending {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("\(app.name) is thinking…")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 18)
                            .id("thinking")
                        }

                        if let errorMessage {
                            Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 14)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: messages.count) { _, _ in
                    if let id = messages.last?.id {
                        withAnimation(.easeOut(duration: 0.28)) {
                            proxy.scrollTo(id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isSending) { _, sending in
                    if sending {
                        withAnimation(.easeOut(duration: 0.28)) {
                            proxy.scrollTo("thinking", anchor: .bottom)
                        }
                    }
                }
            }

            Divider()
            composer
        }
    }

    private var assistantHeader: some View {
        HStack(spacing: 12) {
            PremiumAppMark(app: app, size: 48)

            VStack(alignment: .leading, spacing: 3) {
                Text("\(app.name) for Indica")
                    .font(.headline)
                Text("\(model) · Developer API")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "lock.fill")
                .font(.caption)
                .foregroundStyle(.green)
        }
        .padding(15)
        .liquidGlass(cornerRadius: 24, intensity: 0.9)
        .padding(.horizontal, 16)
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Message \(app.name)", text: $prompt, axis: .vertical)
                .lineLimit(1...5)
                .focused($composerFocused)
                .textInputAutocapitalization(.sentences)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(
                    Color(uiColor: .secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(service.tint, in: Circle())
            }
            .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            .opacity(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending ? 0.45 : 1)
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }

    private var setupRequired: some View {
        ScrollView {
            VStack(spacing: 18) {
                Spacer(minLength: 54)

                PremiumAppMark(app: app, size: 92)

                Text("Connect \(service.shortName)")
                    .font(.title2.bold())

                Text(service.setupRequirement)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                NavigationLink {
                    ServiceConnectionDetail(service: service)
                } label: {
                    Label("Add Developer API Key", systemImage: "key.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(service.tint)

                Label(
                    "Your key is stored in the iPhone Keychain. This app does not import your consumer chats.",
                    systemImage: "lock.shield.fill"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(24)
            .liquidGlass(cornerRadius: 30, intensity: 0.92)
            .padding(18)
        }
    }

    private func sendMessage() {
        let cleanPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanPrompt.isEmpty, !isSending else { return }

        let userMessage = AIConversationMessage(role: .user, text: cleanPrompt)
        let outboundHistory = messages + [userMessage]
        messages.append(userMessage)
        prompt = ""
        errorMessage = nil
        isSending = true

        Task {
            do {
                let response = try await store.sendAIMessage(
                    history: outboundHistory,
                    service: service,
                    model: model
                )
                messages.append(AIConversationMessage(role: .assistant, text: response))
            } catch {
                errorMessage = error.localizedDescription
            }
            isSending = false
        }
    }

    private func resetConversation() {
        errorMessage = nil
        messages = [
            AIConversationMessage(
                role: .assistant,
                text: service == .anthropic
                    ? "Hey, I’m Claude inside Indica OS. What do you want to work on?"
                    : "Hey, I’m your OpenAI assistant inside Indica OS. What can I help with?"
            )
        ]
    }
}

private struct AIAssistantBubble: View {
    let message: AIConversationMessage
    let tint: Color

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 52)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(message.text)
                    .font(.body)
                    .foregroundStyle(message.role == .user ? .white : .primary)
                    .textSelection(.enabled)

                Text(message.createdAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(message.role == .user ? .white.opacity(0.70) : .secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                message.role == .user ? tint : Color(uiColor: .secondarySystemBackground),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )

            if message.role == .assistant {
                Spacer(minLength: 52)
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct AssistantSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ConnectionStore
    let service: ConnectedService
    @Binding var model: String

    var body: some View {
        NavigationStack {
            Form {
                Section("Model") {
                    TextField("Model ID", text: $model)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Text(
                        service == .anthropic
                            ? "Default: claude-haiku-4-5. You can replace it with another model available to your Anthropic API account."
                            : "Default: gpt-5.6-luna. You can replace it with another model available to your OpenAI API account."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Section("Connection") {
                    LabeledContent("Provider", value: service.name)
                    LabeledContent("Credential", value: store.isConnected(service) ? "Stored in Keychain" : "Not configured")
                    Button("Open API Key Dashboard") {
                        store.openOfficialAppOrWebsite(service)
                    }
                }

                Section("Important") {
                    Label("API usage may create separate provider charges", systemImage: "creditcard")
                    Label("Conversation history stays in this app session", systemImage: "iphone")
                    Label("Do not ship personal API keys inside a public app", systemImage: "exclamationmark.shield")
                }
                .font(.subheadline)
            }
            .navigationTitle("Assistant Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        model = model.trimmingCharacters(in: .whitespacesAndNewlines)
                        dismiss()
                    }
                }
            }
        }
    }
}
