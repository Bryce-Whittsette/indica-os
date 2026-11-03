# App inventory — baseline audit

Baseline for the Swift UI overhaul (master brief §5). Commit `e9c5f97`, Debug build, Xcode 27.2, iPhone 18 Pro simulator (iOS 27.2), 2026-11-03.

Every entry is classified by what the source actually does today, using the brief's four categories. "Provider integration (code present, unverified)" means a real provider flow exists in code but has never been exercised against a live account, so it does not yet meet the brief's bar for a *verified* integration.

Evidence levels: entries come from a static source read (cited `file:line`). Items marked **unverified** need runtime confirmation. Simulator observations are listed in [README.md](README.md#simulator-observations).

## Summary

Catalog entries: **50** (matches `BuiltInApp`, `IndicaOS/SystemModels.swift:141`).

| Classification today | Apps |
|---|---|
| Operational (local) | 4 |
| Provider integration (code present, unverified) | 4 |
| External handoff | 6 |
| Concept demo | 36 |

| App | Classification today | P0 | P1 | P2 | P3 |
|---|---|---|---|---|---|
| Phone | Concept demo | 0 | 5 | 2 | 1 |
| Messages | Concept demo | 0 | 4 | 2 | 1 |
| Camera | Concept demo | 0 | 4 | 1 | 1 |
| Photos | Concept demo | 0 | 4 | 0 | 1 |
| Browser | Concept demo | 0 | 4 | 4 | 1 |
| Mail | Concept demo | 0 | 3 | 3 | 0 |
| Maps | Concept demo | 0 | 4 | 2 | 0 |
| Weather | Concept demo | 0 | 3 | 2 | 1 |
| Calendar | Concept demo | 0 | 3 | 3 | 1 |
| Clock | Concept demo | 0 | 3 | 2 | 1 |
| Notes | Operational (local) | 1 | 3 | 3 | 1 |
| Reminders | Operational (local) | 1 | 1 | 3 | 0 |
| Files | Concept demo | 0 | 3 | 3 | 0 |
| Music | Concept demo | 0 | 4 | 1 | 1 |
| Calculator | Operational (local) | 0 | 0 | 3 | 2 |
| Voice Memos | Concept demo | 0 | 3 | 2 | 1 |
| Translate | Concept demo | 0 | 4 | 2 | 1 |
| Home | Concept demo | 0 | 5 | 3 | 1 |
| Wallet | Concept demo | 0 | 2 | 3 | 1 |
| Health | Concept demo | 0 | 2 | 2 | 1 |
| Shortcuts | Concept demo | 0 | 3 | 3 | 1 |
| Find | Concept demo | 0 | 2 | 3 | 1 |
| Contacts | Concept demo | 0 | 4 | 2 | 1 |
| TV | Concept demo | 0 | 3 | 2 | 1 |
| Podcasts | Concept demo | 0 | 2 | 1 | 1 |
| News | Concept demo | 0 | 3 | 1 | 0 |
| Books | Concept demo | 0 | 2 | 1 | 0 |
| Store | Concept demo | 0 | 2 | 1 | 0 |
| Compass | Concept demo | 0 | 2 | 2 | 1 |
| Measure | Concept demo | 0 | 2 | 1 | 0 |
| Magnifier | Concept demo | 0 | 1 | 2 | 0 |
| Stocks | Concept demo | 0 | 1 | 2 | 1 |
| Fitness | Concept demo | 0 | 1 | 2 | 1 |
| Tips | Operational (local) | 0 | 1 | 2 | 1 |
| Canvas | Concept demo | 1 | 2 | 3 | 1 |
| Journal | Concept demo | 1 | 2 | 2 | 1 |
| Passwords | Concept demo | 0 | 1 | 2 | 1 |
| Watch | Concept demo | 0 | 2 | 2 | 1 |
| Video | Concept demo | 0 | 2 | 2 | 1 |
| Settings | Concept demo | 0 | 7 | 4 | 1 |
| Connections | Provider integration (code present, unverified) | 4 | 5 | 3 | 1 |
| ChatGPT | Provider integration (code present, unverified) | 4 | 2 | 6 | 1 |
| Claude | Provider integration (code present, unverified) | 4 | 2 | 6 | 1 |
| Spotify | Provider integration (code present, unverified) | 4 | 2 | 4 | 1 |
| YouTube | External handoff | 0 | 2 | 1 | 1 |
| Gmail | External handoff | 0 | 2 | 1 | 0 |
| Outlook | External handoff | 0 | 1 | 1 | 1 |
| Notion | External handoff | 0 | 1 | 1 | 0 |
| Discord | External handoff | 0 | 1 | 1 | 0 |
| Telegram | External handoff | 0 | 1 | 0 | 1 |
| **Total** | | **4** | **128** | **110** | **39** |

ChatGPT and Claude share one view and one detail block; their defects are counted once, under Claude.

---

## Audit group A: 17 apps (Phone ... Translate)

Scope: `IndicaOS/CoreApps.swift`, `IndicaOS/EverydayApps.swift`, `IndicaOS/CalculatorEngine.swift`, `IndicaOS/SystemModels.swift`, `IndicaOS/SystemShell.swift` (AppHost), `IndicaOS/Info.plist`, `Tests/CalculatorTests.swift`. Read-only; nothing built or run, so runtime behavior is "unverified" unless it follows directly from source.

## Shared facts that apply to every app below

- **Imports.** The whole target imports only SwiftUI, MapKit, Foundation, UIKit, AuthenticationServices, CryptoKit and Security (`grep ^import`). There is no AVFoundation, PhotosUI, WebKit, CoreLocation, EventKit, MessageUI, Translation, MusicKit, UserNotifications or fileImporter anywhere. No app in group A calls a native media, permission, or messaging API. Only Maps uses a framework (MapKit rendering).
- **Persistence.** Only `IndicaSystem.notes`, `.reminders`, `.messages` and `.capturedMoments` persist, via UserDefaults JSON keys `notes`, `reminders`, `messages` and the int key `capturedMoments` (`SystemModels.swift:555-571`, `:615`). Everything else is view `@State`.
- **App views are torn down on exit (inferred from source).** `SystemShell.swift:49` switches on `system.phase`, and `.app(let app)` creates `AppHost` (`:1241` calls `BuiltInAppView`). Going Home or to the Switcher changes `phase`, so the app view is removed and its `@State` is lost. This means timers, drafts, unsaved notes, browser history, and calendar events do not survive app switching. Unverified at runtime, but there is no state hoisting anywhere to prevent it.
- **Info.plist (`Info.plist:30-52`).** It declares camera, microphone, photo library (read and add), location when in use, contacts, calendars (full and legacy), reminders (full and legacy) and Apple Music strings. No group A view requests any of these permissions. The strings promise behavior that does not exist (for example "Indica uses the camera when you open the Camera app"). Declaring unused permission strings is a review risk (P2 overall).
- **Notification samples.** `IndicaSystem.notifications` (`SystemModels.swift:550-554, Maya at :551`) are hard-coded fake Messages/Calendar/Weather notifications ("Maya: The concept finally feels like a real phone", "Design review, Today at 2:30 PM", "Rain later"). They are presented as personal and tie to Messages, Calendar and Weather content. These belong to the shell audit but are noted here as data-provenance defects (P1).
- **No accessibility modifiers.** `grep accessibility` over `CoreApps.swift` and `EverydayApps.swift` returns no `.accessibility*` modifier. Every icon-only button below has no explicit label.

---

### Phone — `PhoneApp` (`CoreApps.swift:75`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Place a call from a keypad or a recents list.
- **Current behavior:** The segmented control switches Recents / Keypad / Voicemail (default Keypad, `:76`). The keypad appends digits and the delete key removes the last one (`:138`, `:171`). The green call button presents `CallScreen` with the typed string as the "contact" (`:159-160`, `:189`). `CallScreen` shows the label "calling…" forever (`:214`), with mute/audio toggles that only flip local `@State` (`:199-200`, `:259`). Keypad, add call, video and contacts are toggles/buttons with no effect (`:221`, `:223-225`). Red button dismisses the sheet (`:228`). Voicemail tab shows static "No new voicemail" (`:182`). No call is placed by any path.
- **Data source & persistence:** Recents are a hard-coded array of four fictional entries (Maya Chen, Studio, Jordan Lee, Unknown, `:80-85`). Dialed number and call state are `@State` only.
- **Permissions / cost:** None used. Info.plist has contacts/microphone strings, unused. No network, no cost.
- **Defects:**
  - P1: "calling…" call screen with mute/speaker toggles simulates a call that never connects, with no "simulated" label (`:196-243`).
  - P1: Recents are fabricated call history presented as personal data; tapping a row "calls" a fictional person (`:80-103`).
  - P1: "No new voicemail" is a fabricated status (`:182`); iOS gives apps no voicemail access.
  - P1: The recents info.circle (`:121`) and CallScreen keypad/add call/video/contacts buttons do nothing (`:220-225`). No `tel:` handoff exists.
  - P1: Icon-only buttons (call `:158`, delete `:170`, end call `:228`) have no accessibility labels. Keypad keys' text reads digit plus letters.
  - P2: `String` is made `Identifiable` retroactively (`CoreApps.swift:1485`), so sheet identity is the dialed string. Dialing the same number twice reuses the id (cosmetic, unverified).
  - P2: `Color(hex:)` raw values in `CallScreen` background (`:205`).
  - P3: Hard-coded `.font(.system(size:))` at `:131, :142, :145, :163, :213, :232, :263` do not scale with Dynamic Type.
- **Proposed release behavior:** Brief section 9 row "Phone, Messages, Video calling": verify supported calling and handoff, and never claim completed calls. Make it an **External handoff**: keypad, then `UIApplication.shared.open(tel:)` (system shows its own confirmation), and no in-app "call connected" screen. Remove or relabel Recents and Voicemail (iOS does not expose the call log or voicemail; offer "Open Phone app" instead). Needs no entitlement, only `tel` URL handling. Contacts picker (CNContactPickerViewController) is optional.
- **Completion check:** Type a number on the keypad and press the green button; iOS shows its own call confirmation sheet for that exact number, and the app never shows "calling" itself.

### Messages — `MessagesApp` (`CoreApps.swift:275`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Read and send text messages in a conversation.
- **Current behavior:** Shows a single thread titled "Maya" (hard-coded, `:325`, `:337`). Typing and pressing the arrow appends a blue "sent" bubble to `system.messages` (`:348-355`). Nothing is delivered. There is no reply, no thread list, and no delivery state. The "+" attach button, back chevron, and video button are empty (`:301`, `:329`, `:342`).
- **Data source & persistence:** `system.messages`, persisted to UserDefaults key `messages` (`SystemModels.swift:561`). Seed: "You made it home?" / "Yep, testing Indica OS now." (`:610-611`). Messages the user types persist locally forever as if sent to Maya. `resetDemoData()` wipes them (see Notes).
- **Permissions / cost:** None used (no MessageUI). Info.plist contacts string unused. No cost.
- **Defects:**
  - P1: A blue bubble appears for every "send" with no delivery, and the bubble is stored as a sent message to "Maya"; this is a fake success state (`:348-355`).
  - P1: Fictional contact "Maya" and canned history shown as the user's personal conversation (`:325`, `SystemModels.swift:610-611`).
  - P1: Back, attach, and video buttons are empty actions (`:301`, `:329`, `:342`). Icon-only, no labels.
  - P1: The shell notification "Maya: The concept finally feels like a real phone" (`SystemModels.swift:550-554, Maya at :551`) implies incoming messages.
  - P2: Send and attach controls are 34pt, under 44pt (`:303`, `:316`).
  - P2: No scroll-to-latest after send (unverified; no `ScrollViewReader` in source).
  - P3: `.font(.system(size: 16...))` (`:288`) and `15` (`:314`).
- **Proposed release behavior:** Per brief: do not claim sent messages. Use `MFMessageComposeViewController` (check `canSendText()`; the user presses Send in the system sheet and the result enum is reported honestly) or `sms:` handoff. Keep the in-app thread only as an explicitly labeled sample conversation or remove it. Needs MessageUI (iPhone only; unavailable in the simulator, so show an unavailable state).
- **Completion check:** Tap Compose, enter a recipient and text, and the system composer opens with that text; the app reports "Sent" only when the composer returns `.sent`.

### Camera — `CameraApp` (`CoreApps.swift:358`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Capture photos or video.
- **Current behavior:** The "viewfinder" is a static gradient (`:372-376`). The shutter increments `system.capturedMoments`, flashes an "AE/AF" box for 180 ms, and does nothing else (`:484-491`). Flash toggles an icon only (`:387`). The mode picker (VIDEO/PHOTO/PORTRAIT) changes only a string (`:360`, `:426`). The flip, chevron and filters buttons are empty (`:395`, `:401`, `:465`). The thumbnail opens Photos and shows the count (`:433-444`).
- **Data source & persistence:** No capture. A counter is persisted in UserDefaults `capturedMoments` (`SystemModels.swift:570`).
- **Permissions / cost:** No AVFoundation or permission request. Info.plist `NSCameraUsageDescription` and `NSPhotoLibraryAddUsageDescription` unused. None.
- **Defects:**
  - P1: Shutter produces a counter increment and a "photo" in Photos with no image captured. This is the brief's "fake capture success" (`:484-486`, `PhotosApp :507`).
  - P1: Modes, flash, flip, filters and chevron are non-functional controls presented as working (`:395, :401, :465`).
  - P1: Camera permission string says "when you open the Camera app" but no permission flow exists; there is no denial or unavailable-hardware handling.
  - P1: Icon-only buttons (flash, shutter, thumbnail, flip) have no accessibility labels. The shutter has no name at all.
  - P2: Top buttons are 42pt, under 44pt (`:391`).
  - P3: Raw hex gradient (`:373`) and `.font(.system(size: 22...))` (`:467`).
- **Proposed release behavior:** Per brief: "If operational, capture real supported media with permission." Needs a native framework: `AVCaptureSession` (custom UI) or `UIImagePickerController(.camera)` for the simplest honest capture, then save with `PHPhotoLibrary` (add-only authorization). Simulator has no camera, so show an "unavailable" state; handle denial with a Settings deep link. Otherwise relabel as concept lab.
- **Completion check:** On a physical iPhone, grant camera access, take a photo, and see that same image in the system Photos app; with access denied, a message and a Settings button appear instead of a shutter.

### Photos — `PhotosApp` (`CoreApps.swift:494`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Browse and view photos.
- **Current behavior:** Shows a grid of `24 + capturedMoments` colored-gradient tiles with SF symbols (`:507-523`). The header says "N Items" (`:529`). Tapping opens `PhotoDetail` showing the gradient as "Moment N" (`:544-579`). Favorite toggles `@State` and is lost on dismiss (`:548`, `:567`). Share, trash and "Select" are empty (`:534`, `:572-574`).
- **Data source & persistence:** Generated gradients; count tied to the camera counter. No PhotosUI.
- **Permissions / cost:** None used. Info.plist photo strings unused. None.
- **Defects:**
  - P1: "24 Items" and "Moment N" present generated placeholders as a personal library (`:507`, `:529`, `:559`).
  - P1: Delete (trash), share, Select do nothing (`:534`, `:572-574`). The destructive-looking trash button silently does nothing.
  - P1: Favorite looks saved but is `@State` inside a sheet and resets (`:548`).
  - P1: Grid cells and toolbar icons unlabeled (`:508`, `:566-574`).
  - P3: `.font(.system(size: 26/90...))` (`:518`, `:556`).
- **Proposed release behavior:** Per brief: "Select and display user-chosen media through supported access; distinguish sample images." Use SwiftUI `PhotosPicker` (PhotosUI), which needs no library permission, to import user-chosen images into an app-local store. Display those, with share via `ShareLink`. Sample gradients, if kept, must be labeled "Sample".
- **Completion check:** Tap "Add Photos", pick two images from the system picker, see exactly those two in the grid, and open one full-screen; cancelling the picker changes nothing.

### Browser — `BrowserApp` (`CoreApps.swift:581`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Browse the web.
- **Current behavior:** Not a web view. `load()` pattern-matches the address for "weather", "music", "design", "news", "start", and otherwise renders a text block saying "This offline simulator rendered a local preview" (`:687-713`). Back pops a local history array (`:641-644`). Forward, share, reading-list and tabs buttons are empty (`:649-655`). The address bar has a permanent lock icon (`:661`).
- **Data source & persistence:** Hard-coded strings. `@State` history; lost when leaving.
- **Permissions / cost:** None. No network.
- **Defects:**
  - P1: A lock icon in the address bar implies a secure HTTPS connection to any text typed (`:661`).
  - P1: "Indica blocked 12 trackers in this demo session" is a fabricated privacy claim (`:629`).
  - P1: Entering a real URL such as https://apple.com shows a placeholder page titled by the string; it does not load the site (`:709-710`).
  - P1: Forward, share, reading list and tabs buttons are no-ops and unlabeled (`:649-655`).
  - P2: Matching is case-sensitive on the raw query, so typing "Weather" falls to the generic page (`:693`, only favorites lowercase it).
  - P2: Back history stores `pageTitle.lowercased()` (`:691`); going back from "Now Playing" or "Today" re-queries "now playing"/"today", which match no branch and render the generic page instead of the prior one.
  - P2: Substring match is too loose ("restart" matches "start", `:705`). Address bar text is not updated to the shown page.
  - P2: Clear button and toolbar glyphs have no frame, so the tap target is about 17pt (`:640-657`, `:669`).
  - P3: Hard-coded fonts at `:593, :595, :614, :657`.
- **Proposed release behavior:** Per brief: "Navigate supported URLs with working back/forward, reload, loading/error states, keyboard behavior, and external-open options." Needs `WKWebView` (UIViewRepresentable) with `canGoBack/canGoForward`, `estimatedProgress`, `didFailProvisionalNavigation`, URL normalization (scheme, search fallback), and "Open in Safari" via `openURL`. Remove the fake privacy report or replace it with a true count. Alternatively, `SFSafariViewController` for a minimal honest version.
- **Completion check:** Type `apple.com`, the real page loads with a progress bar, Back and Forward both work after two navigations, and airplane mode shows an error page with Retry.

### Mail — `MailApp` (`CoreApps.swift:716`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Read an inbox and compose mail.
- **Current behavior:** Shows four hard-coded messages (`:720-725`). Tapping a row only clears its unread dot, with no detail view (`:731-733`). "Edit" is empty (`:764`). The composer has To, Subject and Body fields; "Send" just dismisses the sheet (`:803`, enabled when To is non-empty).
- **Data source & persistence:** Hard-coded array; unread set is `@State`.
- **Permissions / cost:** None. No network.
- **Defects:**
  - P1: "Send" dismisses with no message sent and no feedback, a fake success state (`:803`).
  - P1: Sample inbox (Indica Design, Maya, Build System, Community) is presented as personal mail with title "Inbox" (`:720-725`, `:761`); the brief prohibits a sample inbox as personal mail.
  - P1: Closing the composer silently discards the draft with no confirmation (`:800`).
  - P2: "Edit" does nothing (`:764`). Compose icon is unlabeled (`:767`).
  - P2: Rows open nothing, so a message cannot be read beyond its preview.
  - P2: Unread state lost on exit.
- **Proposed release behavior:** Per brief: "Distinguish composing mail, opening a provider, and synchronizing an inbox." Make it an **External handoff**: compose via `MFMailComposeViewController` (check `canSendMail()`) or `mailto:`, plus an "Open Mail" button. No inbox unless a verified provider integration (Gmail/Outlook apps) is implemented. Remove or label the sample inbox "Sample".
- **Completion check:** Tap Compose, fill To/Subject/Body, and the system mail composer opens with those values; the app never claims "sent" unless the composer returns `.sent`.

### Maps — `MapsApp` (`CoreApps.swift:811`)
- **Classification (current):** Concept demo (MapKit renders a real map, but no search, location or navigation workflow exists)
- **Purpose / primary task:** Find places and get directions.
- **Current behavior:** Shows a live MapKit `Map` centered on lower Manhattan (40.7128, -74.0060) with two hard-coded markers (Studio, Coffee, `:823-828`). The search field only replaces the card title (`:836-838`); there is no `MKLocalSearch`. The card always reads "12 min away · Light traffic" (`:849`). The directions and mic controls do nothing (`:839`, `:854`).
- **Data source & persistence:** MapKit tiles (network, by the framework); markers and place text are hard-coded; all `@State`.
- **Permissions / cost:** No CoreLocation. Info.plist location string unused. MapKit tile use is free with no key (SwiftUI Map).
- **Defects:**
  - P1: Fabricated ETA and traffic ("12 min away · Light traffic") shown for any typed text (`:849`).
  - P1: Searching only renames a label; no place is found or shown on the map (`:837`).
  - P1: Directions button is an empty action and unlabeled (`:854`); the mic image is not a button but looks like one (`:839`).
  - P1: Markers "Studio" and "Coffee" are made-up places in NYC.
  - P2: Default `selectedPlace` is "Brooklyn" (`:819`) while the camera centers on lower Manhattan.
  - P2: No location authorization, no "my location" button, no manual-search fallback story.
- **Proposed release behavior:** Per brief: "supported location/search/navigation; keep manual search when location is denied; indicate handoffs." Use `MKLocalSearch` for results, optional `CLLocationManager` when-in-use with `UserAnnotation()`, and `MKMapItem.openInMaps(launchOptions:)` for directions (explicit handoff to Apple Maps). All are native with no key; location permission is needed only for "my location".
- **Completion check:** Search "coffee", and results appear as pins from MapKit; tap Directions and Apple Maps opens with that destination; with location denied, search still works.

### Weather — `WeatherApp` (`CoreApps.swift:869`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Show current conditions and forecast for a place.
- **Current behavior:** A Menu switches among three hard-coded cities (Brooklyn 72, Los Angeles 84, London 61, `:872-876`). Everything else is arithmetic on that single number: hourly `city.1 - index` (`:912`), highs `+3 - day`, lows `-9 - day` (`:932-937`). The icon is a fixed pattern (`:909`, `:929`).
- **Data source & persistence:** Hard-coded; no persistence, no network.
- **Permissions / cost:** None. Info.plist location string unused.
- **Defects:**
  - P1: Fabricated forecast is shown with no "Sample" label, no timestamp and no source (`:872-945`); brief requires sample weather to be identified as sample data.
  - P1: "10-DAY FORECAST" heading but the loop draws 7 rows (`:922`, `:925`), a copy/behavior mismatch.
  - P1: Weekday names come from `weekdaySymbols[(day + 5) % 7]` regardless of the real date (`:927`), so they are wrong on most days.
  - P2: The city picker is the entire header (`:886-902`), with no visible affordance (unverified rendering).
  - P2: Shell notification "Rain later: showers around 7 PM" is unrelated to this data (`SystemModels.swift:553`).
  - P3: Hard-coded fonts (`:893, :895`) and raw hex (`:873-875`); white text on light gradients may fail contrast (unverified).
- **Proposed release behavior:** Per brief: "verified data source for live claims; show location and freshness; manual location or offline recovery; sample stays identified." Needs a real provider: WeatherKit (requires the capability/entitlement and a paid Apple Developer membership; verify current quota) or a keyless provider (for example Open-Meteo; verify terms and attribution before use). Show updated-at time and source, handle offline with cached/last-known data, allow manual city choice, and add `CLLocationManager` only if "current location" is offered. Until then, label as "Sample Weather".
- **Completion check:** Choose a city by name, and conditions load with a visible "Updated hh:mm, source" line; in airplane mode the last result remains with a "Cached" marker.

### Calendar — `CalendarApp` (`CoreApps.swift:954`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** View a month and add events.
- **Current behavior:** Draws days 1...31 in a 7-column grid (`:977`), always titled "July 2026" and "July <day>" (`:998`, `:1022`), with day 17 preselected. Day 1 always sits in the Sunday column because weekday headers are `veryShortWeekdaySymbols` and no first-weekday offset is computed (`:968`, `:976`). "+" opens an alert; "Add" appends a string to an in-memory dictionary (`:1030-1037`). Events cannot be deleted or edited and have no time.
- **Data source & persistence:** Hard-coded sample events on 17 and 21 (`:956-959`); `@State` only; lost on app exit and never saved.
- **Permissions / cost:** No EventKit. Info.plist calendar strings unused. None.
- **Defects:**
  - P1: Events the user adds look saved but are `@State` only and vanish on leaving the app (`:956`).
  - P1: Month and year are hard-coded to July 2026 and ignore the real date (today is 2026-11-03); days are placed in the wrong weekday columns, and there is no today highlight, month navigation, or time zone (`:955`, `:998`, `:1022`).
  - P1: Sample events ("Design review 2:30 PM", "Dinner with Maya 7:00 PM") are shown as the user's schedule; the shell notification repeats "Design review" (`SystemModels.swift:552`).
  - P2: `ForEach(dayEvents, id: \.self)` with duplicate strings gives duplicate ids (`:1001`).
  - P2: Event-add alert accepts whitespace-only titles (`:1034`); no time, edit, or delete.
  - P2: The day circle is 34pt (`:984`); the cell's total hit height is unverified. Plus button is unlabeled (`:1025`).
  - P3: `.font(.system(size: 15...))` (`:983`).
- **Proposed release behavior:** Per brief: "actual dates and time zones; navigate and return to today; a genuine event workflow through an appropriate local model or native integration, with clear data provenance." Build the month grid from `Calendar.current` (`range(of:)`, `firstWeekday`), add month navigation and a "Today" button, and use `EventKit` (`requestFullAccessToEvents`) or `EKEventEditViewController` (no read permission needed to add) for events; otherwise persist a local Codable event model. Info.plist already declares the keys (iOS 17 full-access key present).
- **Completion check:** The app opens on today's actual date, a new event with a time added today still shows after force-quit and relaunch, and "Today" returns from another month.

### Clock — `ClockApp` (`CoreApps.swift:1043`)
- **Classification (current):** Concept demo (timer is genuine but local and without completion)
- **Purpose / primary task:** World clocks, alarms, countdown timer.
- **Current behavior:** World tab shows three cities with times computed as `Date()`, `+5h`, `+13h` (`:1061-1063`), which assumes the device is in New York and ignores DST and the real zone. Alarm tab has two hard-coded alarms with `Toggle(isOn: .constant(...))` (`:1076`, `:1086`), which cannot be changed. Timer tab: slider 1-60 minutes (`:1099`), Start sets `endDate`, and a `TimelineView` shows min:sec remaining from the deadline (`:1093-1095`), so it is deadline-based and correct while the app is alive. At zero nothing happens: no sound, notification, or end state.
- **Data source & persistence:** Hard-coded; `@State` only (`endDate` lost on exit).
- **Permissions / cost:** None used; no UserNotifications. None.
- **Defects:**
  - P1: World clock offsets are hard-coded relative to the device's zone and labelled "Today, -3HRS", "+2HRS", "+11HRS" (`:1061-1063`); they are arithmetically inconsistent with each other and with the displayed times (+5 and +13). No `TimeZone`.
  - P1: Alarms look real but their toggles are constants and no alarm fires (`:1068-1087`).
  - P1: Timer ends silently and the button still says "Cancel" at 00:00; there is no alert or local notification, and the timer is lost if the user leaves (`:1103-1115`, view torn down per `SystemShell.swift:49`).
  - P2: Before Start, the display reads 00:00 while the slider says N minutes (`:1094`: `endDate ?? context.date`).
  - P2: `Toggle("", ...)` has an empty label for VoiceOver (`:1076`).
  - P3: `.font(.system(size:))` at `:1096`, `:1141`; the repeating TimelineView ignores Reduce Motion (not applicable to numbers).
- **Proposed release behavior:** Per brief: "Show real time; implement exposed stopwatch/timer correctly across foreground changes using elapsed time or deadlines; document background notification and alarm limits." Use `TimeZone(identifier:)` with a city list and offset computed per time zone, persist the timer deadline in UserDefaults, schedule a `UNUserNotificationCenter` local notification for timer completion (asks permission at Start), and either implement alarms with local notifications (documented limits: no Do Not Disturb override, silenced by Focus) or remove the Alarm tab. Add a stopwatch only if it is implemented.
- **Completion check:** Set a 1-minute timer, leave the app, and a notification fires at the deadline; the World tab shows New York, London and Tokyo times matching `TimeZone` conversions of the same instant.

### Notes — `NotesApp` (`CoreApps.swift:1147`)
- **Classification (current):** Operational (local/native), with caveats listed in the defects
- **Purpose / primary task:** Create, edit and delete personal notes.
- **Current behavior:** Lists notes sorted by modified date (`:1154`). Tap opens a sheet editor with title and body (`:1195-1232`). "Done" writes `note.modified = .now` and either replaces or appends to `system.notes` (`:1219-1226`), which JSON-saves to UserDefaults `notes` through `didSet` (`SystemModels.swift:555-556`). Swipe-to-delete exists (`:1172-1176`). Compose button creates a blank note (`:1182`).
- **Data source & persistence:** `system.notes`, UserDefaults key `notes` (JSON). Seed note "Welcome to Indica" used only when nothing is stored or decoding fails (`SystemModels.swift:601`).
- **Permissions / cost:** None. None.
- **Defects:**
  - P0: Settings "Erase Demo Content" calls `resetDemoData()`, which replaces all notes (and reminders and messages) with sample data (`SystemModels.swift:755-760`, `SettingsSystem.swift:1326-1328`). That deletes personal notes while the UI calls it "demo content" ("resets only Indica's local sample content", `SettingsSystem.swift:1316`). This is a copy/behavior mismatch that causes data loss.
  - P1: Edits exist only in the sheet's `@State` until Done. Swipe-down dismissal or leaving the app discards the draft; there is no autosave (`:1198`, `:1219`). Brief requires autosave and preserved edits.
  - P1: If stored data fails to decode, `load()` silently returns the welcome note (`SystemModels.swift:767-775`), and the next edit overwrites the corrupt-but-recoverable data with welcome data.
  - P1: No search, which the brief requires; `.searchable` is absent.
  - P2: Pressing Done on an empty new note adds a blank "Untitled" note (`:1182`, `:1224`). There is no Cancel, so no way to abandon a new note.
  - P2: Delete is swipe-only with no confirmation or undo; the compose icon is unlabeled (`:1184`).
  - P2: All notes encoded into one UserDefaults blob on every change; unsuitable for large or many notes.
  - P3: `.font(.system(size: 28...))` title (`:1208`).
- **Proposed release behavior:** Keep as the local essential and fix per brief: autosave on every edit (debounced) to a file (JSON in Application Support) or SwiftData, `.searchable` over title and body, delete with undo, empty-note cleanup, and make `resetDemoData` delete only the seeded sample items by id. No new framework required.
- **Completion check:** Create a note, type text, leave the app by going Home without tapping Done, relaunch, and the text is still there; search finds it by a word in the body; "Erase Demo Content" leaves it intact.

### Reminders — `RemindersApp` (`CoreApps.swift:1234`)
- **Classification (current):** Operational (local/native)
- **Purpose / primary task:** Keep a task list.
- **Current behavior:** Text field plus Add appends a `ReminderItem` (`:1244-1250`). The circle toggles completion both ways (reopen works, `:1259-1263`). Swipe-delete (`:1271`). Each mutation persists immediately because `system.reminders` has a `didSet` save (`SystemModels.swift:558-559`).
- **Data source & persistence:** `system.reminders`, UserDefaults key `reminders`. Seed items "Customize the Lock Screen" and "Try Control Center" (`SystemModels.swift:605`).
- **Permissions / cost:** None. Info.plist reminder strings unused. None.
- **Defects:**
  - P0: Same `resetDemoData()` wipes personal reminders (`SystemModels.swift:757`, `SettingsSystem.swift:1326-1328`).
  - P1: No edit of an existing reminder's title; the brief requires create, edit, complete, reopen, delete.
  - P2: Whitespace-only titles are accepted (`:1245` checks only `isEmpty`); no onSubmit; the check-circle button is unlabeled and only about 22pt (`:1259-1264`).
  - P2: No due date or alert; there is no way to be reminded despite the name.
  - P2: Hard-coded section title "My List"; seed items shown as the user's own tasks.
- **Proposed release behavior:** Keep local, with title editing and optional due date with a `UNUserNotificationCenter` notification (ask permission at that moment). EventKit sync (`requestFullAccessToReminders`) only as an optional later step with identity mapping, per brief.
- **Completion check:** Add "Buy milk", mark it complete, tap again to reopen it, relaunch, and the item and its state are still there; rename it and the new title survives relaunch.

### Files — `FilesApp` (`CoreApps.swift:1281`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Browse and manage files.
- **Current behavior:** Static sections: Locations (Indica Drive, On My iPhone, Recently Deleted, `:1289-1293`), Favorites (a folder list you can add to and swipe-delete, `:1296-1300`), Recent (three fake files, `:1303-1307`). No row is tappable. New Folder adds a string to `@State`.
- **Data source & persistence:** Hard-coded; folder list is `@State` and lost on exit. No FileManager, no document picker.
- **Permissions / cost:** None. None.
- **Defects:**
  - P1: Fake files ("Indica OS brief PDF", "Wallpaper studies", "Motion notes") shown as the user's files; no file is real (`:1304-1306`).
  - P1: "Indica Drive" with an iCloud icon implies a cloud drive that does not exist (`:1290`).
  - P1: "New Folder" creates a list entry only, which is a fake success and is lost on exit (`:1321`).
  - P2: No row has an action; "Recently Deleted" and the locations do nothing. "On My iPhone" appears twice (`:1291`, `:1282`).
  - P2: `ForEach(folders, id: \.self)` with duplicate names gives non-unique ids (`:1296`).
  - P2: Add-folder icon is unlabeled (`:1314`).
- **Proposed release behavior:** Per brief: "Browse app-accessible files; import/export, selection, cancellation, errors; explain storage scope." Use the app's `Documents` via `FileManager` with `fileImporter`/`fileExporter` (or `UIDocumentPickerViewController`) and state "Files inside Swift UI only" plus an "Open Files app" handoff. Needs native document picker APIs, no permission string.
- **Completion check:** Import a text file, see it in the list after relaunch, open its contents, then delete it and confirm it is gone.

### Music — `MusicApp` (`CoreApps.swift:1349`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Play music.
- **Current behavior:** Three fictional tracks (Quiet Hours / Indica Studio, Slow Orbit / Blue Static, Soft Focus / Glass Garden, `:1354-1358`). Play toggles an icon and a waveform symbol animation only; no audio plays. Prev/next change the index. The progress slider never advances (`:1387`). The volume slider is bound to `.constant(0.55)` and cannot be changed (`:1412`). The ellipsis button is empty (`:1384`).
- **Data source & persistence:** Hard-coded; `@State` only; not shared with any mini-player.
- **Permissions / cost:** None. Info.plist `NSAppleMusicUsageDescription` is unused. None.
- **Defects:**
  - P1: Play/pause shows "playing" with an animated waveform though no audio is produced (`:1397`, `:1372`); fake success.
  - P1: Fake tracks/artists look like a library; the progress slider is a decorative control (`:1352`, `:1387`).
  - P1: The volume slider is a constant binding, so it is a dead control (`:1412`).
  - P1: Prev/Play/Next/ellipsis buttons are unlabeled and about 24pt (`:1384-1407`).
  - P2: State is lost on exit; no shared player state (the brief requires the mini-player to match real music state).
  - P3: Hard-coded fonts (`:1370, :1400, :1408`).
- **Proposed release behavior:** Per brief: "Reflect real supported playback/account state; show when a subscription or external player is required." Options: (a) play user-imported audio files with `AVAudioPlayer` via `fileImporter`; (b) hand off to the Music or Spotify app by URL; (c) `MusicKit` with the entitlement and an Apple Music subscription (needs verification of capability and cost). Until then, label as a concept.
- **Completion check:** Import an audio file, press Play and hear it, scrub the slider to seek, and press Pause so it stops; the volume slider changes loudness.

### Calculator — `CalculatorApp` (`EverydayApps.swift:4`, engine `CalculatorEngine.swift:5`)
- **Classification (current):** Operational (local/native)
- **Purpose / primary task:** Arithmetic.
- **Current behavior:** A 4x5 key grid drives `CalculatorEngine.tap` (immediate-execution model). Supports digits, decimal, AC, sign (±), percent (÷100), backspace, + − × ÷, equals, divide-by-zero "Error", and 12-digit input limit (`CalculatorEngine.swift:11-56`). `Tests/CalculatorTests.swift` has 12 listed cases plus a 400-iteration overflow check; the script prints "13 calculator checks passed". It is a standalone `@main` script, not in `IndicaOS.xcodeproj` (grep of `project.pbxproj` finds no reference), so it is not run by Xcode.
- **Data source & persistence:** Pure local logic; `@State` engine; no persistence.
- **Permissions / cost:** None. None.
- **Defects:**
  - P2: Percent is always value / 100 (`CalculatorEngine.swift:34`), so "5 + 50 %" gives 0.5, not the 2.5 that iOS gives. Brief item: percentage.
  - P2: Repeated equals does nothing; this is documented in the engine comment (`:4`) and the test (`5+3===` gives 8). It differs from the iOS convention (unverified against the brief's intent).
  - P2: Key labels "±", "⌫", "−", "×", "÷" have no accessibility labels (`EverydayApps.swift:33`); the display is not announced as a value.
  - P3: Digit limit of 12 counts "-" and "." characters (`CalculatorEngine.swift:18`). AC never becomes C; no active-operator highlight. Large results use `%.10g`, which can print exponent form such as `1e+15` (`:60`).
  - P3: Raw hex (`EverydayApps.swift:51-52`) and hard-coded fonts at `:21`, `:34`.
- **Proposed release behavior:** Per brief: preserve and extend the shared tested engine. Convert `Tests/CalculatorTests.swift` into an XCTest target in the project, add cases for percent in chained operations, operator replacement after ± and repeated equals, and add accessibility labels. No framework needed.
- **Completion check:** Enter `2 + 3 =` to see 5, `9 ÷ 0 =` to see Error and then a digit recovers, and run the test target in Xcode with all cases green.

### Voice Memos — `VoiceMemosApp` (`EverydayApps.swift:60`)
- **Classification (current):** Concept demo (honestly labelled)
- **Purpose / primary task:** Record and play back audio.
- **Current behavior:** A banner says "Recording simulation · no microphone audio is captured" (`:71`). The record button starts a timer display and an animated waveform (`:98-105`, `:136`). Stopping inserts a list row "New Recording N" with the elapsed seconds (`:130-134`). No audio is recorded, rows are not playable, and the waveform bars are static pseudo-random heights. Swipe-delete removes rows (`:93`).
- **Data source & persistence:** Three hard-coded fake recordings (Design thought 0:18, Melody idea 0:42, Street ambience 1:12, `:62-66`); `@State` only; lost on exit.
- **Permissions / cost:** No AVFoundation. Info.plist microphone string unused. None.
- **Defects:**
  - P1: The red record button, running timer and "recording" waveform simulate recording; the only disclosure is a small footnote (`:71`, `:98-120`).
  - P1: Fake recordings with dates look like the user's memos; none can be played (`:62-66`).
  - P1: The record button has no label (`:108`).
  - P2: Duration format `String(format: "0:%02d", duration)` breaks past 59 s (for example "0:75") (`:133`).
  - P2: No rename, playback, or persistence. The waveform repeat animation ignores Reduce Motion (`:156`).
  - P3: `.font(.system(size: 28, design: .monospaced))` (`:102`).
- **Proposed release behavior:** Per brief: "If operational, record actual audio, play it, retain files, rename/delete, handle microphone denial and interruption. Simulated recording belongs in the labeled lab." Needs `AVAudioRecorder`/`AVAudioPlayer`, `AVAudioApplication.requestRecordPermission`, `AVAudioSession` interruption notifications, files stored in the app's Documents folder, and a metadata index. Otherwise move the simulation to the concept lab.
- **Completion check:** Grant microphone access, record 5 seconds, stop, relaunch, press Play on the saved memo and hear the audio; with microphone access denied a message and a Settings button appear.

### Translate — `TranslateApp` (`EverydayApps.swift:164`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Translate text between languages.
- **Current behavior:** A six-entry dictionary maps lowercase English phrases to Spanish (`:170-177`). Translate looks up the exact trimmed lowercase string; on a miss it returns the input wrapped in «…» (English to Spanish) or “…” (Spanish to English) (`:268-277`). Any other language pair (including French, offered as a target at `:200`, or the same language on both sides) returns the source text unchanged (`:275`). Swap exchanges languages and texts (`:189-190`). Speaker, star and copy buttons are empty (`:250-252`).
- **Data source & persistence:** Hard-coded dictionary; `@State` only.
- **Permissions / cost:** None. No network, no Translation framework.
- **Defects:**
  - P1: Any unknown input is echoed back in quotation marks in the "translation" box as if translated (`:271`, `:273`).
  - P1: French (and any same-language) selection shows the source text as the translation (`:275`).
  - P1: Speaker, favorite and copy buttons do nothing (the copy button never touches `UIPasteboard`), unlabeled (`:250-252`).
  - P1: Nothing tells the user that only six phrases are supported.
  - P2: Source menu offers English and Spanish only, so after swapping with a target of French the source label can show a language not in the menu (`:183-186`, `:197-201`). Punctuation or capitalization differences cause a miss.
  - P2: Swap and clear buttons are 42/48pt (`:193`, `:236`).
  - P3: Hard-coded fonts at `:206, :213, :246`.
- **Proposed release behavior:** Per brief: "supported on-device/native options with language and OS availability checks; make optional external processing explicit." Use Apple's `Translation` framework (`LanguageAvailability`, SwiftUI `translationTask`, which requires iOS 18; the project's deployment target is 17.0 per `project.pbxproj:189`, so it needs `#available` gating and a fallback), or the system `translationPresentation` sheet. Show language-pack download state. Mark it as a concept demo on devices without support.
- **Completion check:** On an iOS 18 device, translate a sentence that is not in any list from English to French and receive a real translation; on an unsupported OS the app says translation is unavailable instead of echoing the input.

---

## Cross-cutting

Counts are for the 17 group A views only (`CoreApps.swift:75-1424`, `EverydayApps.swift:4-278`, plus the shared engine).

- **Hard-coded font sizes (`.font(.system(size:`):** 31 occurrences. CoreApps has 25: Phone 4 (`:131, :142, :145, :163`), CallScreen 3 (`:213, :232, :263`), Messages 2 (`:288, :314`), Camera 1 (`:467`), Photos 2 (`:518, :556`), Browser 4 (`:593, :595, :614, :657`), Weather 2 (`:893, :895`), Calendar 1 (`:983`), Clock 2 (`:1096, :1141`), Notes 1 (`:1208`), Music 3 (`:1370, :1400, :1408`). EverydayApps has 6: Calculator 2 (`:21, :34`), Voice Memos 1 (`:102`), Translate 3 (`:206, :213, :246`). Mail, Maps, Reminders and Files use text styles only. These do not scale with Dynamic Type (the app's own `dynamicTypeSize` mapping is `SystemModels.swift:575`, but `.system(size:)` ignores it; unverified at runtime).
- **Raw hex colors (`Color(hex:)`):** 13 in group A. CoreApps has 11: CallScreen gradient 2 (`:205`), Camera gradient 3 (`:373`), Weather 6 (`:873-875`). Calculator has 2 (`EverydayApps.swift:51-52`).
- **Accessibility labels:** zero `.accessibility*` modifiers exist in `CoreApps.swift` and `EverydayApps.swift`. Roughly 37 icon-only buttons in group A have no label, for example Phone call/delete/end (`:158, :170, :228`), Messages plus/send/back/video (`:301, :310, :329, :342`), Camera flash/chevron/filters/thumbnail/shutter/flip (`:386-465`), Photos toolbar and cells (`:508, :566-574`), Browser nav bar and clear (`:640-669`), Mail compose (`:767`), Maps directions (`:854`), Calendar plus (`:1025`), Notes compose (`:1181`), Reminders check (`:1259`), Files add folder (`:1312`), Music transport and ellipsis (`:1384-1405`), Translate swap/clear/speaker/star/copy (`:188, :231, :250-252`), Voice Memos record (`:108`). Empty-label toggles in Clock alarms (`:1076, :1086`).
- **Tap targets clearly under 44pt:** Messages plus and send 34pt (`:303`, `:316`); Camera top buttons 42pt (`:391`); Translate swap 42pt (`:193`); Calendar day circle 34pt (`:984`; cell height unverified); Browser toolbar glyphs and clear button with no frame, about 17pt (`:640-657`, `:669`); Reminders completion circle, `title3` glyph (`:1262`); Music transport glyphs, no frame (`:1394-1405`).
- **Fake or no-op controls (empty `Button {}` or constant bindings):** Messages 3, Camera 3, Photos 3 (including Select), Browser 4, Mail 1 (Edit), Maps 1 (plus a non-button mic), Music 1 plus the constant volume slider, Translate 3, Phone CallScreen 4, Clock constant toggles 2.
- **Permission strings declared but never requested by any group A view:** Camera, Microphone, Photos (read and add), Location, Contacts, Calendars, Reminders, Apple Music.
- **Persistence reality:** Four real stores (notes, reminders, messages, capturedMoments) in UserDefaults; everything else resets on leaving the app because the app view is destroyed on every phase change (`SystemShell.swift:49`, inferred).
- **Classification totals for group A:** Operational (local/native): Notes, Reminders, Calculator (3). Provider integration (code present, unverified): 0. External handoff: 0 (none implemented, though Phone and Mail are proposed to become handoffs). Concept demo: Phone, Messages, Camera, Photos, Browser, Mail, Maps, Weather, Calendar, Clock, Files, Music, Voice Memos, Translate (14).
- **Shared data-loss defect:** `resetDemoData()` (`SystemModels.swift:755-760`) deletes personal notes, reminders and messages, while Settings copy describes it as sample-only (`SettingsSystem.swift:1316`, `:1325-1328`). This is the most severe issue in group A.


---

## App inventory audit, group B (22 apps)

Source: `IndicaOS/EverydayApps.swift` (all group-B views), routing at `IndicaOS/CoreApps.swift:55-62`, `BuiltInApp` at `IndicaOS/SystemModels.swift:141`, shared store `IndicaSystem` at `SystemModels.swift:433`. Read-only, no build or run; behavior is inferred from source and anything visual is marked "unverified".

Facts that apply to every app below (stated once, referenced as "G-n"):
- G-1: Every group-B view except Home and Shortcuts keeps all state in view-local `@State`. The app view is replaced when `system.phase` leaves `.app` (`SystemShell.swift:46-51`), so this state is reset every time the user returns to Home or the switcher and on relaunch (inference from view structure, not run-tested).
- G-2: None of these views read or write UserDefaults, Keychain, files, or any Apple framework other than SwiftUI and MapKit (`EverydayApps.swift:1-2`; MapKit is used only by Find). The only `IndicaSystem` fields they touch are `homeAccessories`, `isFocusEnabled`, `brightness`; none of those three is persisted (`SystemModels.swift:543,547,564-569`; only `notes`, `reminders`, `messages`, `capturedMoments` and settings keys persist).
- G-3: `IndicaSystem.brightness` and `isFocusEnabled` are only read by sliders/toggles (Control Center `SystemShell.swift:1554,1557`; Settings `SettingsSystem.swift:611,660`). Nothing dims the screen, sets `UIScreen.brightness`, or alters notification delivery. They are display-only flags.
- G-4: `EverydayApps.swift` contains zero `.accessibility*` modifiers (grep: no matches) and does not read `reduceMotion` or `HapticEngine`.
- G-5: Info.plist (`IndicaOS/Info.plist`) declares usage strings for Apple Music, Calendars, Camera, Contacts, Location When-In-Use, Microphone, Photos, Reminders. None of the group-B views calls the corresponding framework. No HealthKit, HomeKit, NFC, Motion, or LocalAuthentication keys exist. `CFBundleDisplayName` is still "Indica OS".
- G-6: None of these 22 apps labels its sample content as sample/demo to the user, except Passwords (`:1252`), Video (`:1371`), and the Find marker/name "Demo iPhone" (`:644`). Everything else is presented as if it were the user's own data.

---

### Home — `SmartHomeApp` (`EverydayApps.swift:280`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Control smart-home accessories and run scenes (as presented).
- **Current behavior:** Four accessory tiles (Living Room, Desk Lamp, Studio, Front Door) toggle on/off with an animation; two scene buttons flip a local "Scene Set" checkmark; a hard-coded "72° Inside / Comfortable" climate card. The toolbar "+" does nothing. No accessory is real and no scene changes any accessory.
- **Data source & persistence:** Hard-coded dictionary in `IndicaSystem.homeAccessories` (`SystemModels.swift:564-569`), in memory only, no `didSet`, lost on relaunch. Scene state is `@State` (`:344`). Header and climate text are literals (`:290`, `:316-323`).
- **Permissions / cost:** None used. No HomeKit entitlement or `NSHomeKitUsageDescription`. No network. No cost.
- **Defects:**
  - P1: "4 accessories · All secure" is a hard-coded literal (`:290`) and stays "All secure" when Front Door is toggled off. Fake status claim.
  - P1: Front Door renders "Locked"/"Off" with a lock icon (`:373,379`). Toggling off reads "Off" rather than "Unlocked", and the control implies it operates a real lock.
  - P1: Scene buttons show "Scene Set" with a checkmark (`:352`) but change nothing (`:347-349`); tapping again reverts the label. Fake success.
  - P1: Climate card "72° · Comfortable" is presented as live sensor data (`:316-323`).
  - P1: No sample/demo labeling anywhere in the app (G-6).
  - P2: Toolbar "+" button has an empty action (`:334`) and no accessibility label.
  - P2: Tile order comes from `keys.sorted()` (`:303`), so alphabetical, not user-ordered; icon and "Locked" text are chosen by `name.contains("Door")` (`:373,379`).
  - P2: Toggle tiles have no accessibility value/trait for on/off state (G-4); VoiceOver would read the name and "On/Off" text only as combined label (unverified).
  - P3: `.font(.system(size: 33/48 ...))` at `:289,317` ignore Dynamic Type.
- **Proposed release behavior:** Brief section 9 row "Home, Find, Watch": unsupported system experiences stay explicit concepts. Move to the labeled concept lab with a persistent "Sample home, no accessories are connected" banner and remove "All secure"/"Locked" claims. A genuine version needs the HomeKit framework, the HomeKit capability, `NSHomeKitUsageDescription`, a real `HMHomeManager`, and device testing. Not feasible on Simulator alone.
- **Completion check:** Open Home with no HomeKit setup and see a clearly labeled sample banner; toggling a tile says it only changes the sample, and no text claims a door is locked or the home is secure.

### Wallet — `WalletApp` (`EverydayApps.swift:393`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** View payment/transit cards and present a card (as presented).
- **Current behavior:** Paging carousel of three hard-coded cards ("Indica Cash $842.16", "Metro Pass Unlimited", "Studio Card •• 4802"), a "Present Card" button that opens a half sheet with a pulsing NFC symbol and "Hold near reader" (`:457-471`), and three hard-coded transactions (`:449-451`). Nothing can be added, edited, or removed. No payment occurs.
- **Data source & persistence:** Literals (`:397-401`, `:449-451`), selection in `@State`. No persistence.
- **Permissions / cost:** None. No PassKit, no NFC entitlement, no `NSFaceIDUsageDescription`. No network.
- **Defects:**
  - P1: A balance ("$842.16"), card-like suffix ("•• 4802") and transaction history are shown as personal financial data with no sample label (`:398-400`, `:449-451`).
  - P1: "Present Card" opens "Hold near reader" with a pulsing contactless symbol (`:462-466`), implying a working tap-to-pay. Nothing is transmitted. Copy/behavior mismatch.
  - P2: The demo does not request card or payment details, so there is no data-solicitation risk today; any future "Add Card" must not be added to this simulated view (brief section 9).
  - P2: `.page(indexDisplayMode: .always)` (`:432`) page dots are white by default, so they are likely low-contrast on a light background (unverified visually).
  - P2: The sheet has a hand-drawn grabber but no Done/close button (`:459`); relies on swipe.
  - P3: Fixed carousel height 245 (`:433`) and fixed 94pt icon (`:463`) do not scale with Dynamic Type; raw hex `0x3D4050` (`:398`).
- **Proposed release behavior:** Brief: "Keep demonstration assets unmistakable; do not solicit real payment details." Move to the labeled concept lab with a visible "Demo cards, not real" badge on every card and sheet, and rename "Indica Cash" to something unmistakably fictional. Optional real alternative: an explicit handoff that opens the system Wallet app (scheme unverified; confirm the supported URL before shipping). Real card provisioning needs PassKit plus Apple-approved entitlements and is out of scope for this release.
- **Completion check:** Every card and the Present sheet visibly say "Demo", the balance and transactions are marked sample, and no field accepts a card number.

### Health — `HealthApp` (`EverydayApps.swift:496`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Show personal health metrics (steps, sleep, heart rate).
- **Current behavior:** Three metric cards with hard-coded values ("5,804 steps", "7 hr 24 min", "68 BPM") and hard-coded bar charts, plus a "walking steadiness is strong" highlight. The D/W/M/6M/Y segmented picker changes a `@State` value that nothing reads.
- **Data source & persistence:** Literals (`:508-510`, `:514`). `period` is `@State` (`:497`) and is not used by any view.
- **Permissions / cost:** None used. No HealthKit entitlement, no `NSHealthShareUsageDescription`. No network.
- **Defects:**
  - P1: Fabricated personal health data and an interpretive health claim ("walking steadiness is strong this week", `:514`) with no sample marking. Brief says to show only authorized data or clearly marked samples.
  - P1: Period picker has no effect (`:503-506`); fake interactivity.
  - P2: Bar charts have no accessibility description or values (G-4); height is `value * 5` with arbitrary data (`:549`).
  - P2: "42 min more than last week" and "Resting range 62 to 74" are invented comparisons (`:509-510`).
  - P3: `.font(.system(size: 31 ...))` (`:540`); raw tint colors only (no hex).
- **Proposed release behavior:** Brief row "Health, Fitness": show only genuinely authorized data or clearly marked samples; handle denied/unavailable. Rebuild with HealthKit (`HKHealthStore`, read-only step count and sleep, `NSHealthShareUsageDescription`, HealthKit capability), request at first use, show an explicit empty/denied/unavailable state, and make the period picker re-query. Until then, label the current screen "Sample data" or move it to the concept lab. HealthKit is not available on iPad/some simulators; check `HKHealthStore.isHealthDataAvailable()`.
- **Completion check:** On a device with Health data, granting access shows the user's real step count for the selected period, and denying access shows an explanatory empty state with a Settings link and no numbers.

### Shortcuts — `ShortcutsApp` (`EverydayApps.swift:559`)
- **Classification (current):** Concept demo (3 of 6 tiles change a local flag; none runs a real action)
- **Purpose / primary task:** Run named automations.
- **Current behavior:** Six tiles. "Morning Mode" sets `isFocusEnabled=false` and `brightness=0.85`; "Focus Studio" sets `isFocusEnabled=true`; "Battery Check" sets `brightness=0.55`; "Play Quiet Hours", "Heading Home", "Capture Idea" do nothing. Every tile shows a "<name> completed" capsule with a checkmark for 2 seconds (`:601-611`, `:615-629`). The state they change is display-only (G-3) and not persisted (G-2).
- **Data source & persistence:** Hard-coded array (`:563-570`); effects go to non-persisted `IndicaSystem` fields.
- **Permissions / cost:** None. No App Intents or Shortcuts framework.
- **Defects:**
  - P1: Fake success: all six tiles report "completed" (`:603`) while three do nothing at all and the other three only flip an in-app flag.
  - P1: "Battery Check" sets brightness to 0.55 (`:623`) and never reports battery level; name/behavior mismatch. "Play Quiet Hours" does not play anything.
  - P1: Copy implies system automation; brief forbids implying unrestricted automation of other apps.
  - P2: Name matching by `name.contains("Focus")` etc. (`:618-623`) is brittle string logic.
  - P2: Overlapping runs: the 2-second `Task` (`:625-628`) is never cancelled, so a second tap within 2s gets its label cleared early.
  - P2: Completion capsule is not announced to VoiceOver (G-4).
  - P3: No way to add, edit, or delete a shortcut.
- **Proposed release behavior:** Brief row "Shortcuts": implement defined Swift UI actions or supported system handoffs; no unrestricted automation. Define a small set of real in-app actions (for example create a note, add a reminder, open an app, toggle the in-app Focus flag with truthful "applied to Swift UI only" text) with a result that names exactly what changed, and add an "Open Shortcuts app" handoff (`shortcuts://`, a documented scheme). Remove tiles with no implementation.
- **Completion check:** Tapping each tile produces a real, visible change in the named place (for example a new note exists in Notes) and a tile with no action does not exist.

### Find — `FindApp` (`EverydayApps.swift:632`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Locate devices and people on a map.
- **Current behavior:** MapKit `Map` centered on hard-coded New York coordinates with two markers ("Demo iPhone" at `:644`, "Maya" at `:646`). A bottom card says "Demo iPhone, With You · Now". The speaker button, "Directions" and "Play Sound" buttons have empty actions (`:668,675,677`). `selected` never changes (`:633`).
- **Data source & persistence:** Literal coordinates; no persistence. Map tiles load over the network via MapKit (system-managed).
- **Permissions / cost:** No location permission or `UserAnnotation` used even though `NSLocationWhenInUseUsageDescription` exists. MapKit map tiles require network. No paid service.
- **Defects:**
  - P1: Three buttons are inert (`:668,675,677`) but styled as primary actions; "Play Sound" implies a device would ring.
  - P1: "With You · Now" (`:663`) and a person marker "Maya" imply live tracking of a person; no location source exists. Brief: unsupported experiences must not claim tracking.
  - P2: The first marker is labeled "Demo" but the card text and green status look like a real device-tracking UI.
  - P2: The icon-only speaker button has no accessibility label; its frame is 42x42pt (`:670`), below 44pt.
  - P2: `Map` is not inside a NavigationStack and has no title/close affordance other than the host bar; markers are not selectable.
  - P3: Hard-coded center near New York ignores the user's region.
- **Proposed release behavior:** Brief row "Home, Find, Watch": explicit concept. Replace with a truthful "Show my location" using CoreLocation (`CLLocationManager.requestWhenInUseAuthorization`, `UserAnnotation()`), labeled "This device only". "Find My" device/people tracking is not available to third-party apps without Apple's Find My network accessory program; offer an "Open Find My" handoff (scheme unverified) and keep the current multi-device UI only in the labeled lab.
- **Completion check:** The map shows the user's current position after granting permission, shows a denied-state message otherwise, and no button or text claims to track another person or ring a device.

### Contacts — `ContactsApp` (`EverydayApps.swift:689`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Browse and manage contacts.
- **Current behavior:** A list of six hard-coded names plus a "Demo User / My Card" header; "+" opens an alert to add a name; swipe to delete; tapping opens a detail with four action circles (message, call, video, mail) that do nothing, and three rows of fabricated fields (same phone "(555) 013-2048" and birthday "September 12" for everyone, email generated from the name). The search field is inert.
- **Data source & persistence:** `@State` string array (`:690`), no persistence (G-1). Added or deleted contacts reset on every reopen. No Contacts framework.
- **Permissions / cost:** `NSContactsUsageDescription` is declared in Info.plist (copy claims use for "calls, messages, mail, and contact cards") but no Contacts/ContactsUI API is used. This is a permission string with no corresponding feature. No cost.
- **Defects:**
  - P1: Search is `.searchable(text: .constant(""))` (`:725`); typing does nothing.
  - P1: The four action buttons have empty actions (`:781`).
  - P1: Fabricated phone, email and birthday shown for every contact (`:765-767`) as if real data; the header avatar letter "B" and "My Card" imply a personal card (`:702-707`).
  - P1: User-added contacts are silently lost on dismiss (G-1) although the UI behaves like a contact manager (data-loss class; no persistence, `:735`).
  - P2: `ForEach(contacts, id: \.self)` (`:714`) has duplicate-ID behavior when a name is added twice; whitespace-only names are accepted (`:735`).
  - P2: Unused contacts permission string is an App Review risk and a copy mismatch (G-5).
  - P3: `.font(.system(size: 48 ...))` (`:753`).
- **Proposed release behavior:** Brief row "Contacts": request only necessary access; support the actual selection task; do not imply sync after a picker. Replace with a `CNContactPickerViewController`/`ContactAccessButton` flow (no blanket permission needed for picker), show the chosen contact's real fields, and wire Call/Message/Mail to `tel:`/`sms:`/`mailto:` handoffs (or `MFMessageComposeViewController`/`MFMailComposeViewController`). Remove the fake address book or label it sample.
- **Completion check:** Tap Add, pick a real contact in the system picker, see its real name and number, tap Call and the system dial confirmation appears; no fabricated fields are visible.

### TV — `MediaCatalogApp` branch `.video` (`EverydayApps.swift:793`, items at `:800-801`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Browse and play video titles.
- **Current behavior:** Featured card (not tappable) plus three fictional titles ("Afterlight", "Soft Machines", "The Long Way"). Tapping a row opens a half sheet; the "Play" button only inserts the title into a local `saved` set (`:890-892`). A "+" circle toggles the same set. No video plays.
- **Data source & persistence:** Hard-coded tuples; `saved` is `@State` (`:796`), lost on dismiss (G-1).
- **Permissions / cost:** None. No AVKit/AVPlayer. No network.
- **Defects:**
  - P1: Sheet copy "This is a functional local catalog detail. Save the item, start playback, or return to browse." (`:887`) is false: nothing plays.
  - P1: Button labeled "Play" saves instead of playing (`:890-892`); fake success path with no state change visible after tapping.
  - P1: Saved state is never shown anywhere other than the "+"/check glyph and is lost on exit.
  - P2: The "+" button (`:864-869`) is nested inside the row `Button` (`:843-872`), so tap routing between save and open is unverified. It is icon-only, unlabeled, and about 22pt tall (below 44pt).
  - P2: The featured card is not interactive (`:821-836`).
  - P3: `.font(.system(size: 31 ...))` (`:828`, `:883`).
- **Proposed release behavior:** Brief row "TV, YouTube, Podcasts, Books, News": user-provided content, attributed feeds, supported playback, or official handoffs, with honest controls. For TV: a local "Videos" player using `AVPlayer`/`VideoPlayer` with `PhotosPicker` or Files import of user-provided video, or an explicit handoff to the Apple TV app. Remove fictional titles or move them to the lab.
- **Completion check:** Pick a video file from Photos/Files and it plays with pause and scrub; with none picked, an empty state with an Add button is shown instead of fake titles.

### Podcasts — `MediaCatalogApp` branch `.podcasts` (`EverydayApps.swift:793`, items at `:802-803`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Listen to podcast episodes.
- **Current behavior:** Three fictional shows ("Design Details", "City Signals", "Quiet Systems") with fake episode lengths. Same sheet and "Play"-saves behavior as TV; no audio.
- **Data source & persistence:** Literals; `saved` is `@State` (G-1). No feed, no network.
- **Permissions / cost:** None. No AVFoundation.
- **Defects:**
  - P1: "New episode · 42m" etc. implies a subscription feed with episodes; none exists.
  - P1: False "start playback" copy (`:887`) and "Play" button that saves (`:890-892`).
  - P2: Same nested icon-only unlabeled Save button (`:864`).
  - P3: Hard-coded font sizes (G-4 table).
- **Proposed release behavior:** Real RSS feed parsing for user-supplied feed URLs (documented, free) with `AVPlayer` playback and last-position persistence, or an explicit "Open Apple Podcasts" handoff. Keep the fictional list only in the lab.
- **Completion check:** Paste a podcast RSS URL, the episode list loads from it, and tapping an episode plays audio that resumes at the same position after relaunch.

### News — `MediaCatalogApp` branch `.news` (`EverydayApps.swift:793`, items at `:804-805`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Read news headlines.
- **Current behavior:** Three fictional headlines with relative timestamps ("12m ago", "1h ago", "2h ago"). Tapping opens the same sheet (no article text) with a "Play" button that saves the headline.
- **Data source & persistence:** Literals; `saved` is `@State`. No network.
- **Permissions / cost:** None.
- **Defects:**
  - P1: Fake freshness: static "12m ago" labels (`:805`) never change, presenting stale text as live news.
  - P1: "Play" on a headline is a copy mismatch; detail has no article content (`:887-892`).
  - P1: One headline ("Indica OS becomes interactive") is self-promotional text posing as news.
  - P2: Same unlabeled nested Save button (`:864`).
- **Proposed release behavior:** Attributed RSS/Atom feeds the user adds (publisher name, link, fetched-at timestamp), opened with `SFSafariViewController` or the Browser app; offline cache with "Last updated" text. No fictional items outside the lab.
- **Completion check:** Add a feed URL, headlines load with source and fetch time, tapping one opens the real article, and airplane mode shows cached items marked "Updated <time>".

### Books — `MediaCatalogApp` branch `.books` (`EverydayApps.swift:793`, items at `:806-807`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Read books and track progress.
- **Current behavior:** Three fictional books with fabricated reading progress ("38%", "72%", "New"). Tapping opens the same sheet; "Play" saves. No reading view.
- **Data source & persistence:** Literals; `saved` is `@State`. No file access.
- **Permissions / cost:** None.
- **Defects:**
  - P1: Fabricated reading progress presented as the user's own library (`:807`).
  - P1: "Play" on a book (`:890`) and "start playback" copy (`:887`) are wrong for the domain.
  - P2: Same unlabeled nested Save button (`:864`).
- **Proposed release behavior:** Import user-owned EPUB/PDF via Files, render PDFs with `PDFKit`, store reading position (UserDefaults or app database); or hand off to Apple Books. EPUB rendering would need a new dependency or `WKWebView`; decide before promising it.
- **Completion check:** Import a PDF, read it, quit and reopen, and the book opens at the last-read page with a correct progress percentage.

### Store — `MediaCatalogApp` branch `.store` (`EverydayApps.swift:793`, items at `:808-809`, "Get" at `:890`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Discover and install apps.
- **Current behavior:** Header "Apps We Love" with three fictional apps, one priced ("Paper Studio, Creativity · $4.99"). The sheet button reads "Get" and only adds the item to the local `saved` set; the row "+" turns into a checkmark.
- **Data source & persistence:** Literals; `saved` is `@State` (lost on exit, G-1).
- **Permissions / cost:** None. No StoreKit.
- **Defects:**
  - P1: "Get" plus a checkmark implies installation/purchase (`:890-892`, `:867`) but nothing is installed or bought; the "$4.99" price implies a payment flow. Brief: Store copy must match what occurs.
  - P1: The listed apps do not exist and are not among the 50 catalog entries; the Store does not describe actual Swift UI features.
  - P2: Same unlabeled nested Save button (`:864`).
- **Proposed release behavior:** Brief row "Store, Tips": describe actual available Swift UI features. Rebuild as a read-only "App Directory" generated from `BuiltInApp.allCases` with each app's honest classification (Operational / Provider / Handoff / Concept) and an "Open" button; no prices, no "Get". Keep fictional storefront only in the lab.
- **Completion check:** The Store lists exactly the apps in the catalog with their true status badge, and "Open" launches the app; no price or Get button exists.

### Compass — `SensorUtilityApp` branch `.compass` (`EverydayApps.swift:903`, `:913-917`, `CompassFace` `:965`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Show the device heading.
- **Current behavior:** A drawn compass face whose arrow and ticks rotate with a manual slider (0-359). A text label always says "<n>° NE" regardless of the angle (`:916`). No sensor is read.
- **Data source & persistence:** `@State angle = 28` (`:905`). No CoreLocation/CoreMotion.
- **Permissions / cost:** None used (Info.plist has location when-in-use, unused here). No cost.
- **Defects:**
  - P1: A slider-driven fake heading presented as a compass; "NE" is hard-coded and wrong for 90° (E), 180° (S), etc. (`:916`).
  - P1: Initial value 28 looks like a measured reading with no "sample" label.
  - P2: The slider has no accessibility label or value description (G-4).
  - P2: Fixed 280pt face (`:989`) inside a non-scrolling VStack; clips at larger Dynamic Type (unverified).
  - P3: `.font(.system(size: 33/72 ...))` (`:917`, `:985`).
- **Proposed release behavior:** Brief row "Compass, Measure, Magnifier": use the supported sensor where operational and handle missing hardware, calibration, permissions, simulator limits. Implement with CoreLocation heading (`CLLocationManager.startUpdatingHeading`, `headingAvailable()`, `headingAccuracy`), compute the cardinal from the real heading, show "Calibrate" when accuracy is negative or poor, and show a "Compass unavailable on this device/simulator" state otherwise. Remove the slider.
- **Completion check:** On a physical iPhone, rotating the phone moves the needle, the cardinal label matches the degrees, and the Simulator shows an explicit "unavailable" state with no slider.

### Measure — `SensorUtilityApp` branch `.measure` (`EverydayApps.swift:903`, `:918-935`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Measure real-world distances with the camera.
- **Current behavior:** A static dark panel with a yellow line between two dots, a "12.4 in" capsule, and a slider (1-48) that changes only the number. No camera or tracking.
- **Data source & persistence:** `@State measure = 12.4` (`:907`).
- **Permissions / cost:** None used (camera string exists in Info.plist, unused here). No cost.
- **Defects:**
  - P1: Displays a measurement with a unit as if measured; the user sets it with a slider (`:927`, `:935`).
  - P1: The panel looks like an AR measuring view but has no camera feed.
  - P2: Slider has no accessibility label (G-4); hex `0x33363B` (`:920`).
- **Proposed release behavior:** Brief: sensor/camera capability where operational, with tracking limitations handled. Use ARKit (`ARWorldTrackingConfiguration`, raycast between two placed points, camera permission, `ARWorldTrackingConfiguration.isSupported` check) with an unsupported-device message, or place in the concept lab as a labeled mock. Manual "known length" calibration is a lower-cost fallback.
- **Completion check:** On a supported iPhone, tapping two points on a real object shows a distance within a stated tolerance; on unsupported hardware it shows an explicit "AR measurement unavailable" screen with no slider.

### Magnifier — `SensorUtilityApp` branch `.magnifier` (`EverydayApps.swift:903`, `:936-948`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Magnify real-world objects with the camera.
- **Current behavior:** A cyan-indigo gradient with a "textformat.size.larger" symbol whose font size scales with a zoom slider (1-4). No camera.
- **Data source & persistence:** `@State zoom = 2.0` (`:906`).
- **Permissions / cost:** None used (camera string unused here). No cost.
- **Defects:**
  - P1: Named and styled as a magnifier but shows no camera feed; zoom only scales an icon (`:940`).
  - P2: Unbounded icon size `38 * zoom` up to 152pt in a fixed-size container (`:940`).
  - P2: Slider and the two icons lack accessibility labels (G-4, `:945-947`).
- **Proposed release behavior:** `AVCaptureSession` live preview with `videoZoomFactor`, torch toggle, freeze-frame, camera permission request at first open with a denied state, and simulator "No camera" state. Magnifier is a plain capture use-case with no extra entitlement.
- **Completion check:** On device, the live camera preview fills the screen, the slider magnifies the real scene, and freeze keeps a still image; on Simulator a "No camera available" message appears.

### Stocks — `SensorUtilityApp` branch `.stocks` (`EverydayApps.swift:903`, `:949-950`; `StocksBoard` `:993`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Track stock prices.
- **Current behavior:** Four fictional tickers (INDC, AURA, TIDE, BLOM) with fixed prices and percentage changes and static sparklines (`:994`, `:1026`). No refresh, no detail, no add/remove.
- **Data source & persistence:** Hard-coded array (`:994`). No network, no persistence.
- **Permissions / cost:** None. No cost today. A real quote source may carry cost and licensing limits (unverified, must be researched).
- **Defects:**
  - P1: Prices and percent moves with no source, market context, timestamp or "sample" label (`:994-1011`); brief requires these.
  - P2: Up/down shown by color plus a +/- prefix; the minus is the U+2212 character and color logic uses `hasPrefix("+")` (`:1004,1007`). Sparklines are fixed arrays unrelated to the price (`:1026`) and have no a11y description.
  - P2: Rows have no accessibility grouping (G-4).
  - P3: Monospaced fixed 72pt price column (`:1011`).
- **Proposed release behavior:** Brief row "Stocks": identify source, market context, timestamp, delayed/cached status; keep demonstration values separate. Either ship an honest "Sample market data" board in the lab, or a user-editable watchlist backed by a verified, documented free-tier delayed quote API (provider and terms unverified; investigate per brief section 10) with "Delayed, as of <time>" and a cached fallback.
- **Completion check:** Every quote row shows a source name and an "as of" time, and sample rows carry a visible "Sample" tag; with the network off, cached values show their original timestamp.

### Fitness — `SensorUtilityApp` branch `.fitness` (`EverydayApps.swift:903`, `:951-952`; `FitnessBoard` `:1037`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Show daily activity rings.
- **Current behavior:** Three concentric rings with fixed progress (0.82, 0.66, 0.54) and rows "410 / 500 CAL", "20 / 30 MIN", "7 / 12 HRS". No interaction.
- **Data source & persistence:** Literals (`:1041-1043`, `:1048-1050`). None.
- **Permissions / cost:** None. No HealthKit.
- **Defects:**
  - P1: Fabricated activity data presented as the user's own with no sample label; imitates Apple's Move/Exercise/Stand rings.
  - P2: Ring fractions disagree with the text for Stand: 7/12 = 0.58 but ring is 0.54 (`:1043`, `:1050`).
  - P2: Rings have no accessibility value (G-4); fixed 250pt ring in a non-scrolling VStack may clip at large text (unverified).
  - P3: `.font(.system(size: 35))` (`:1045`).
- **Proposed release behavior:** Brief row "Health, Fitness": show only authorized data or clearly marked samples. Use HealthKit activity summary queries (`HKActivitySummaryQuery`), compute ring progress from the real values, and show a denied/unavailable state with no invented numbers. Until then, a "Sample" badge or lab placement.
- **Completion check:** With Health access granted, ring values equal the Health app's Activity summary for today; when denied, the screen shows an empty state with no numbers.

### Tips — `EverydayApp` branch `.tips` → `TipsApp` (`EverydayApps.swift:1092,1115`)
- **Classification (current):** Operational (local/native) as a static help screen, with one inaccurate tip
- **Purpose / primary task:** Teach the user how to use Swift UI gestures.
- **Current behavior:** A three-page swipeable carousel of tips. Tip 1 (top-right Control Center, top-left notifications) matches `systemGesture` (`SystemShell.swift:72-81`). Tip 2 (long-press Lock Screen or Home Screen to customize) matches `SystemShell.swift:531` and `:705`. Tip 3 ("Swipe up from the bottom inside an app to reach the app switcher", `:1120`) does not match: in-app swipe-up returns Home (`SystemShell.swift:1345-1355`), and the switcher is opened with the "Recent Apps" button (`SystemShell.swift:1297-1299`).
- **Data source & persistence:** Hard-coded array (`:1117-1121`); page index in `@State`. Static help text is appropriate to be hard-coded.
- **Permissions / cost:** None.
- **Defects:**
  - P1: Tip 3 is wrong about how to reach the app switcher (`:1120`).
  - P2: Page dots from `.tabViewStyle(.page)` (`:1146`) are white by default and likely low-contrast on a light background (unverified visually).
  - P2: Only 3 tips; nothing explains that many apps are samples or concepts (brief: Tips explain verified behavior in this release).
  - P3: `.font(.system(size: 74/31 ...))` (`:1129,1134`); no Dynamic Type scaling for the 160pt tile.
- **Proposed release behavior:** Brief row "Store, Tips": Tips explain verified behavior in this release. Correct tip 3, add a "What is real vs. sample" page driven by the same classification used by Store, and add a Back/Next control for non-gesture users.
- **Completion check:** Every tip, followed literally in the running app, produces exactly the described result, and one page lists which apps are sample or concept.

### Canvas — `EverydayApp` branch `.canvas` → `CanvasApp` (`EverydayApps.swift:1092,1152`)
- **Classification (current):** Concept demo (draws and undoes in-session; cannot erase, save or export; nothing persists)
- **Purpose / primary task:** Freehand drawing.
- **Current behavior:** A SwiftUI `Canvas` records drag points into polylines; four color swatches; undo (removes last stroke); trash (clears all). No eraser, no export, no save, no restore.
- **Data source & persistence:** `@State lines/currentLine/color` (`:1153-1155`). Lost on dismiss (G-1).
- **Permissions / cost:** None. No PencilKit, no Photos write.
- **Defects:**
  - P0: Data loss: all drawings are lost whenever the app is left (G-1); there is no save or export, and the brief requires "save or export as labeled" plus restoration.
  - P1: Changing color recolors every existing stroke, because a single `color` is used for all lines at draw time (`:1165`).
  - P1: Clear (trash) has no confirmation and is not undoable (`:1192`).
  - P2: A tap adds a one-point stroke that renders nothing (`:1161` requires `count > 1`) but still consumes an undo step (`:1171-1174`).
  - P2: Swatches are 29x29pt (`:1183`), undo/trash have no frame (`:1190,1192`), all icon-only with no labels (G-4); swatch selection is color-only plus a ring.
  - P2: Fixed stroke width 5, no width/eraser control.
  - P3: Raw hex background `0xF8F4EC` (`:1168`).
- **Proposed release behavior:** Brief row "Canvas": exposed controls must draw, erase, undo, save or export; handle empty work and restoration. Implement with PencilKit (`PKCanvasView` in `UIViewRepresentable`, `PKToolPicker`, built-in eraser/undo, finger drawing allowed), persist `PKDrawing.dataRepresentation()` to the app documents directory, export PNG through `ShareLink` or `PHPhotoLibrary` (existing add-only photo string), and handle the empty state.
- **Completion check:** Draw three strokes in two colors, erase one, quit and reopen the app, and the drawing returns with colors intact; Export produces a PNG in Photos or the share sheet.

### Journal — `EverydayApp` branch `.journal` → `JournalApp` (`EverydayApps.swift:1092,1203`)
- **Classification (current):** Concept demo (entries are session-only)
- **Purpose / primary task:** Write dated journal entries.
- **Current behavior:** A text field with "Save Entry" inserts a string at the top of a list; swipe to delete. One pre-seeded sample entry. No editing or entry detail. Every entry shows the same literal date "July 17, 2026".
- **Data source & persistence:** `@State entries` seeded with a sample string (`:1204-1205`). No UserDefaults/file persistence (G-1); entries vanish when the user leaves the app.
- **Permissions / cost:** None.
- **Defects:**
  - P0: Data loss: "Save Entry" (`:1213-1217`) only mutates `@State`; the saved entry is lost when the app view is dismissed. Brief requires "dependable storage".
  - P1: Every entry displays hard-coded date "July 17, 2026" (`:1224`), not the real date; entries carry no timestamp.
  - P1: The seeded entry "Today I started rebuilding Indica OS ..." (`:1205`) is shown as the user's own journal text, and it reappears on every open.
  - P2: Entries are strings with `ForEach(entries, id: \.self)` (`:1221`), so duplicate text would collide IDs; no stable identifier, no edit, no detail.
  - P2: No draft preservation across app switching (brief section 12).
  - P3: Mentions the old brand "Indica OS".
- **Proposed release behavior:** Brief row "Journal": create and edit dated entries with dependable storage and clear entry-to-entry navigation. Add a Codable `JournalEntry` (UUID, createdAt, updatedAt, body), persist it the same way as notes (`IndicaSystem.save/load`), list sorted by date with real formatted dates, an editor view with autosave, and no seeded entry (or a clearly labeled welcome entry that can be deleted without affecting personal ones).
- **Completion check:** Write an entry, force-quit and relaunch, and the entry is present with today's actual date; editing it updates the same entry in place.

### Passwords — `EverydayApp` branch `.passwords` → `PasswordsApp` (`EverydayApps.swift:1092,1237`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Store and reveal passwords (as presented).
- **Current behavior:** A lock screen with honest copy ("Example entries for a UI demonstration. No authentication or real passwords.", `:1252`) and an "Unlock Demo Vault" button that unlocks with no authentication (`:1254`). Three sample entries reveal placeholder strings ("sample-only", "example-entry", "demo-password") on tap. There is no input field, no add/edit, and nothing is stored.
- **Data source & persistence:** Hard-coded array (`:1240`), `@State` for unlocked and revealed. No Keychain, no LocalAuthentication.
- **Permissions / cost:** None; no `NSFaceIDUsageDescription`. No cost.
- **Defects:**
  - P1: "Unlock" succeeds with no authentication, so the vault metaphor (key icon, lock screen, reveal toggles) can lead a user to trust it for real secrets; the honest copy is a single caption line (`:1252`). Risk of soliciting real secrets is low today because there is no input field, but any future "Add Password" on this view would violate the brief.
  - P2: `.navigationTitle("Passwords")` is attached outside the `NavigationStack` (`:1285`), so the title does not display in either state (unverified visually).
  - P2: Reveal rows are buttons whose state is shown by icon only (`eye`/`eye.slash`), no accessibility value (G-4).
  - P3: `.font(.system(size: 64))` (`:1248`).
- **Proposed release behavior:** Brief row "Wallet, Passwords": keep demonstration assets unmistakable; no real secret solicitation; a genuine vault needs a separately defined, verified implementation (Keychain, `LocalAuthentication`, and likely an AutoFill credential-provider extension). For this release: move to the labeled concept lab with a persistent "DEMO ONLY, do not enter real passwords" banner, rename to "Passwords (Demo)", and offer an optional handoff to the system Passwords app or Settings > Passwords (supported URL unverified, confirm before shipping).
- **Completion check:** The screen always shows "Demo only" text, has no field that accepts text, and the Unlock button is labeled as a demo action that makes no security claim.

### Watch — `EverydayApp` branch `.watch` → `WatchApp` (`EverydayApps.swift:1092,1289`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Manage a paired Apple Watch (as presented).
- **Current behavior:** A form with a black watch-face mock showing hard-coded "10:09" and "72°", status text "Connected" in green when "Paired" is on, two toggles ("Paired", "Mirror Notifications"), and a "Faces" list of three non-interactive labels. Toggles change local state only.
- **Data source & persistence:** `@State paired = true`, `notifications = true` (`:1290-1291`). No persistence; no WatchConnectivity.
- **Permissions / cost:** None. No watchOS target (project is iPhone-only per Info.plist/scene config).
- **Defects:**
  - P1: States "Connected" in green by default (`:1315`) and offers a "Paired" switch, claiming a device connection that does not exist. Brief: do not claim device control.
  - P1: "Mirror Notifications" toggle has no effect (`:1323`).
  - P2: "Faces" rows are inert and look tappable; time "10:09" is a static literal (`:1303`), not the real time.
  - P2: Uses the product name "Indica Watch" (`:1313`) (brand cleanup).
  - P3: No accessibility label on the mock watch face.
- **Proposed release behavior:** Brief row "Home, Find, Watch": unsupported system experiences remain explicit concepts. Move to the lab with "Concept, no watch is connected" banner and default `paired=false`. Real support would need a watchOS app target and WatchConnectivity (a separate project); a handoff to the system Watch app is the only supported entry (scheme unverified).
- **Completion check:** The screen says in text that no watch is connected, and no toggle or "Connected" status claims otherwise.

### Video — `EverydayApp` branch `.videoCall` → `VideoCallApp` (`EverydayApps.swift:1092,1336`)
- **Classification (current):** Concept demo
- **Purpose / primary task:** Place a video call.
- **Current behavior:** Start screen with "Call Maya" (hard-coded, no contact choice). Starting shows a gradient placeholder with mic/camera toggles that only swap icons, and a red hang-up button that returns to the start screen. No camera or microphone is used, no timer, and Maya's name is not shown in-call. Copy says "This demo call remains entirely on-device." (`:1371`).
- **Data source & persistence:** `@State` flags (`:1337-1339`). None.
- **Permissions / cost:** None used (camera/microphone strings exist but unused by this view). No network.
- **Defects:**
  - P1: A full in-call UI (mute, camera, hang up) simulates a call; "Start a Video Call" / "Call Maya" (`:1369,1373`) read as real despite the small caption at `:1371`. Brief: do not claim completed calls.
  - P1: Mute and camera controls toggle icons only (`:1358-1359`).
  - P2: Icon-only `CallControl` buttons have no accessibility labels (`:1387-1402`, G-4).
  - P2: Hard-coded contact; no way to choose a person.
  - P3: `.font(.system(size: 62/74/22 ...))` (`:1352,1368,1396`).
- **Proposed release behavior:** Brief row "Phone, Messages, Video calling": verify supported handoff; distinguish sample from real. Replace with a contact/number input that opens FaceTime via the documented `facetime://` / `facetime-audio://` URL (external handoff) with text that says it hands off to FaceTime. Keep the simulated call UI only in the lab, labeled "Simulated call".
- **Completion check:** Entering a real number or email and tapping Video opens the FaceTime call sheet; the app never shows an in-call screen unless it is in the labeled lab.

---

## Cross-cutting (group-B views, `EverydayApps.swift:280-1403`)

- Hard-coded `.font(.system(size:` instances in these views: 17 (lines 289, 317, 463, 540, 753, 828, 883, 917, 940, 985, 1045, 1129, 1134, 1248, 1352, 1368, 1396). Fixed-size fonts do not follow Dynamic Type; the rest of the views use text styles. `SystemShell.swift` also has hard-coded sizes but is outside this audit.
- Raw hex colors in these views: 3 (`0x3D4050` Wallet `:398`, `0x33363B` Measure `:920`, `0xF8F4EC` Canvas `:1168`). Per-app gradients come from `BuiltInApp.palette` in `SystemModels.swift` (hex-based, outside this audit). Other colors are system colors.
- Accessibility modifiers in the file: 0 occurrences of `.accessibilityLabel`, `.accessibilityHint`, `.accessibilityValue`, or `accessibilityElement`.
- Icon-only buttons with no label (13 instances, 9 source sites): Home "+" (`:334`), Find speaker (`:668`), Contacts "+" (`:729`), Media Save "+/check" (`:864`), Canvas color swatches x4 (`:1180`), Canvas undo (`:1190`), Canvas trash (`:1192`), Video `CallControl` x3 (`:1358-1360`, defined `:1387`). Text-only-labeled controls (for example `ContactAction`, `:776`) are fine because they include a caption.
- Tap targets clearly under 44pt: Canvas swatches 29x29 (`:1183`); Canvas undo/trash (`:1190,1192`, no frame); Media Save (`:864`, about 22pt); Find speaker 42x42 (`:670`). Toolbar "+" buttons in Home/Contacts rely on system toolbar sizing (not a defect).
- No view reads `reduceMotion`; `withAnimation` springs are used in Home, Shortcuts, SceneButton (`:348,370`, `:616`). System-level Reduce Motion is respected by SwiftUI only partially (unverified).
- Persistence: of 22 apps, 0 persist user data. Only Home's `homeAccessories` and Shortcuts' flags go through shared `IndicaSystem`, and those are not persisted (G-2).
- Fake-success patterns: Shortcuts "completed" capsule, Home "Scene Set", Media "Play"/"Get" saving, Passwords "Unlock Demo Vault", Watch "Connected", Wallet "Hold near reader", Find buttons with empty actions, Contacts action buttons and search.
- Classification tally: Operational 1 (Tips, static, with an incorrect tip), Provider integration (code present, unverified) 0, External handoff 0, Concept demo 21.
- Unused Info.plist permission strings relevant to this group: Contacts, Location, Camera, Microphone (declared, no group-B code uses them). Unverified whether other groups' apps use them.


---

## Audit apps-c: Settings, Connections, ChatGPT, Claude, Spotify, YouTube, Notion, Discord, Telegram, Gmail, Outlook

Scope: `IndicaOS/SettingsSystem.swift`, `IndicaOS/Connections.swift`, `IndicaOS/Info.plist`, plus `SystemModels.swift`, `SystemShell.swift` and `ContentView.swift` where they supply state. Read-only static audit. Nothing was built, run, or sent over the network. Every provider flow below is unexercised against a live account, and anything that needs a live call is marked "unverified".

Paths are relative to `IndicaOS/`. Routing is in `CoreApps.swift:64-70` (`.accounts` -> `ConnectionsApp`; `.chatGPT, .claude` -> `AIAssistantApp`; `.spotify .youtube .notion .discord .telegram .gmail .outlook` -> `ConnectedServiceApp`; `.settings` -> `SettingsApp` -> `IndicaSettingsApp`, `CoreApps.swift:1426-1429`).

## Cross-cutting findings (affect several apps)

- **There is no brief §11 state model.** `ConnectionStore.isConnected` (`Connections.swift:341-361`) returns one Bool. `ConnectionStatusPill` (`Connections.swift:1087-1102`) shows only "Connected" or "Not connected". The states the brief requires are not modelled: available, permission requested/granted, credentials configured, authenticated, data verified, stale, disconnected, unavailable.
  - Apple: tapping "Enable Permission Center" writes an account record, so the app shows "Connected" with no permission requested (`Connections.swift:404-411`, `:1024-1028`, `:356-357`).
  - OpenAI/Anthropic: saving any string of 12 or more characters shows "Connected", with no validation call (`Connections.swift:376-387`, `:352-353`). That is the exact "saving a key = connected" anti-pattern.
  - Spotify: "Connected" needs a profile record plus an access token in Keychain (`:350`, `:354-355`). Token expiry and refresh failure are not reflected. A failed refresh leaves the green check (`:567-592`).
- **Only 4 of 9 `ConnectedService` cases can ever reach "connected".**
  - Those are `apple`, `spotify`, `openAI` and `anthropic`.
  - `google`, `microsoft`, `notion` and `discord` only offer "Add Developer Configuration", which saves a client ID that nothing consumes (`Connections.swift:1071-1076`, `:1104-1152`; `setClientID` at `:371-374`).
  - `telegram` only opens the official app (`:1077-1082`).
  - No account record is ever written for those five, so YouTube, Gmail, Outlook, Notion, Discord and Telegram are effectively External handoffs. The UI presents them as pending connections ("Connect Your Account", "Set Up Connection", `Connections.swift:1337-1352`) and lists capabilities with checkmarks that do not exist (`:1363-1369`, `:108-127`).
- **Normal use requires developer registration.** Spotify needs the end user to create a Spotify developer app and paste a client ID (`Connections.swift:133-134`, `:1030-1035`). Google, Microsoft, Notion and Discord copy asks the user to register apps (`:135-143`). This conflicts with the brief's rule that core use must not require a developer key or developer registration. It is tolerable only if clearly confined to an optional "Advanced" path.
- **Spotify, YouTube and Gmail all share the name "Google".** YouTube and Gmail map to one `.google` service (`Connections.swift:180-192`). Both show "Google Sign-In" and use `youtube://` as the deep link (`:170`). So Gmail's "Open Gmail" and its toolbar button open the YouTube app (see the Gmail block).

---

### Settings — `SettingsApp` -> `IndicaSettingsApp` (`SettingsSystem.swift:107`; wrapper `CoreApps.swift:1426`)
- **Classification (current):** Concept demo. A subset is Operational (local/native), scoped to Swift UI only: appearance, accent, glass, wallpaper, icon style, bold text, text size, reduce motion, reduce transparency, labels and layout. Everything about device, network, battery, storage, carrier, VPN, Focus and software update is fabricated or non-functional.
- **Purpose / primary task:** Configure Swift UI's own look and behavior, view account and connection state, and manage permissions.
- **Current behavior:** About 19 routes (`SettingsSystem.swift:3-22`).
  - Real, app-scoped effects, applied in `ContentView.swift:10-20` and `SystemShell.swift:868,943,1010,1950`:
    - Appearance -> `preferredColorScheme`.
    - Bold text.
    - Reduce Motion and Reduce Transparency.
    - Text size -> `dynamicTypeSize`.
    - Accent, wallpaper, icon appearance, app labels and glass intensity.
  - Persisted but unused toggles (write-only, no consumer anywhere):
    - True Tone (`:637`) and Auto-Lock (`:638`).
    - Increase Contrast and Button Shapes (`:972-973`).
    - Ask to Join, Auto-Join Hotspot, Mobile Data, Roaming, Low Data Mode, per-app Mobile Data (`:354-355`, `:427-429`, `:1366`).
    - Focus share, Quiet Hours (`:605-606`).
    - Lockdown Mode and Private Relay (`:1003-1004`).
    - Date & Time (`:1260-1261`).
    - Language and Region pickers (`:1279-1280`).
    - Location Services, Tracking, Analytics (`:1009-1011`), Automatic Updates, Private Wi-Fi Address, Low Power Mode and Battery Percentage.
  - Non-persisted state: Wi-Fi, Bluetooth, Airplane, Focus, brightness and volume are plain `@Published` with no `didSet` (`SystemModels.swift:544-548`), so they reset on relaunch. VPN and Bluetooth "headphones" are `@State` (`SettingsSystem.swift:394,450-451`).
  - Nothing in the codebase uses `UIDevice`, `UIScreen.brightness`, `NWPathMonitor`, `UNUserNotificationCenter`, `CLLocationManager` or `ProcessInfo.isLowPowerModeEnabled` (grep over `IndicaOS/*.swift`).
- **Data source & persistence:**
  - `IndicaSystem` writes UserDefaults keys in `didSet` (`SystemModels.swift:436-541`).
  - Settings screens use ad-hoc `@AppStorage` keys (list under "Compatibility contracts").
  - Device facts are hard-coded literals (see truth table).
- **Permissions / cost:** No permission prompts are issued from Settings. `PermissionExplanationView` (`:1036-1053`) is a local `@State` toggle labelled Photos, Contacts and so on. It does not read real authorization and does not link to iOS Settings. No cost.
- **Defects:**
  - **P1** Fabricated battery data: level history chart (`:1058-1075`), "Maximum Capacity 98%", "Cycle Count 112", "Charging Optimization On" (`:1087-1091`). The brief forbids fabricating battery health or cycles. The root row shows a hard-coded "82%" (`:210`).
  - **P1** Fabricated About and Storage: "Indica Phone Pro", "IND-A284", "SIM-INDICA-001", "256 GB", "198.4 GB" (`:1131-1139`); "57.6 GB of 256 GB used" and fixed category bars (`:1182-1204`); other apps' sizes via `Int.random(in: 45...820)` (`:1222`), which re-rolls on every render. The brief forbids other-app storage fabrication.
  - **P1** Software Update says "Indica OS is up to date" / "0.4" after a fake 1 s spinner (`:1157-1172`). "0.4" conflicts with `MARKETING_VERSION = 0.1` (`IndicaOS.xcodeproj/project.pbxproj:194,232`).
  - **P1** Fake network facts: SSID "Example Network" (`:202,370`); "Indica Mobile" carrier-like row, "6.8 GB" and "0 KB" (`:440-442`); VPN "Indica Private / WireGuard / Connected" (`:461-463`); Bluetooth "Demo Headphones", "Studio Speaker", "Controller" (`:406-413`). Only the Wi-Fi footer (`:362`) discloses simulation. Bluetooth, Mobile Service and VPN have no disclosure.
  - **P1** Security and privacy toggles imply protection that does not exist: "Private Relay", "Lockdown Mode" (`:1003-1004,1015-1016`), "Location Services" (`:1009`), "Allow Apps to Request to Track" (`:1010`), "Share Indica Analytics" (`:1011`). They are stored booleans with no effect.
  - **P1** "Erase Local Demo Content" calls `resetDemoData()` (`SettingsSystem.swift:1312-1329`; `SystemModels.swift:755-760`). It overwrites the same `notes`, `reminders` and `messages` stores that hold the user's real data with welcome stubs. The footer (`:1316`) says only "sample content". Silent loss of personal notes violates brief §9, §12 and "never overwrite personal notes with welcome data".
  - **P1** Controls whose label implies device scope act on nothing, not even app state: Brightness slider (`:660`) and Volume slider (`:582`) change a published value nothing reads (only Shortcuts sets brightness, `EverydayApps.swift:621-623`). Airplane Mode does not change Wi-Fi or Bluetooth (`:135`). Focus (`:611`) does not filter anything. "Play Test Sound" is an empty closure (`:595`). Lock Screen shows a fixed "Friday, July 17", "9:41", "72°", "2:30" (`:843-850`).
  - **P2** Text Size slider spans 0.82-1.25 (`:670`, `:983`), but `ContentView.swift:12` uses `max(system.dynamicTypeSize, preferredTextSize)`. It can only enlarge, never shrink, and it does not follow the device setting up or down. The label does not say it is app-only.
  - **P2** Sliders have no accessibility label or value (`:582,660,670,917,983`). The Settings root card uses hard-coded "Demo User" with initial "B" (`:264,267`) and claims "N services · Keychain protected" (`:269`) even when N counts the fake Apple "ready" state.
  - **P2** `PermissionExplanationView` toggles default to off and never read real authorization (`:1039-1048`).
  - **P2** Date & Time shows fixed "New York / United States" (`:1270-1271`). Language and Region are not applied; "Fahrenheit" and "US" are hard-coded (`:1294-1295`).
  - **P3** The `.connections` row detail is "N ready" (`:211`), conflating states. "Developer Integrations" shows the same binary check for all providers (`:1445`).
- **Proposed release behavior:** Keep and relabel a "Swift UI" settings scope.
  - Keep appearance, accent, wallpaper, icon style, glass, motion, transparency, labels and text size, with footers such as "Applies inside Swift UI only".
  - Replace the fabricated device pages with real, supported readouts: `UIDevice` (model, systemName, systemVersion, battery with monitoring enabled), `NWPathMonitor` (path status, interface type, "constrained/expensive"), `ProcessInfo` low-power state, and `URLResourceValues` volume capacity.
  - Mark each readout unknown or unavailable explicitly, and label any fixed value "Demo".
  - Remove or hide non-functional toggles (True Tone, Auto-Lock, Contrast, Button Shapes, Lockdown, Private Relay, Tracking, Location, Analytics, Roaming, VPN).
  - Where a global setting is relevant, offer an "Open iOS Settings" handoff via `UIApplication.openSettingsURLString`.
  - Rename "Erase Local Demo Content" to "Reset Sample Data" and only touch records flagged as sample, or require typed confirmation naming the notes that will be replaced.
  - Persist or drop the unpersisted toggles.
  - Replace "Demo User" with a neutral label.
- **Completion check:** On a real iPhone, every value on Battery, About, Storage and Mobile Service either matches iOS Settings/Control Center or reads "Unavailable"; toggling Wi-Fi/Brightness/Volume either does nothing visible outside the app and says "Swift UI only" or is gone; and "Reset" never overwrites a note I created.

---

### Connections — `ConnectionsApp` (`Connections.swift:794`; BuiltInApp `.accounts`)
- **Classification (current):** Provider integration (code present, unverified), hub only. Spotify OAuth and the OpenAI/Anthropic BYO-key flows are implemented. The other rows are non-functional configuration or handoff, and the Apple row is fake.
- **Purpose / primary task:** One place to see provider status, connect, and disconnect.
- **Current behavior:**
  - Summary card "Indica Account Center / N services ready / Private by default" (`:858-895`).
  - "On this iPhone" row (Apple) (`:806-812`); "Daily Apps": Spotify, Google, Microsoft, Notion, Discord, Telegram (`:814-829`); "Developer Assistants": OpenAI and Anthropic (`:831-843`).
  - Each row leads to `ServiceConnectionDetail` (`:933-1085`): status pill, capability list, setup requirement, Connect/Disconnect, "Open Official App or Website".
  - Footer privacy claims (`:845-849`).
- **Data source & persistence:**
  - Account records: UserDefaults `connectedAccounts` (JSON `[String: ConnectedAccountRecord]`, `:313`, `:324-328`, `:728-732`).
  - Client IDs: UserDefaults `integrationClientIDs` (`:329-334`, `:734-738`).
  - Tokens and API keys: Keychain via `CredentialVault` (`:258-309`). The Spotify account record also stores the Spotify display name and e-mail in plaintext UserDefaults (`:485-489`).
- **Permissions / cost:**
  - No iOS permission prompts.
  - Spotify needs a user-created Spotify developer client ID.
  - OpenAI and Anthropic need a paid developer API key; the summary correctly says consumer subscriptions are separate (`:101-104`, `:145-148`).
- **Defects:**
  - **P1** Single boolean "Connected" state (see cross-cutting).
  - **P1** Apple row: `markAppleServicesReady()` creates "This iPhone / Permission is requested feature by feature" (`:404-411`), so Apple shows "Connected" and counts as "ready" with nothing granted. The Disconnect button for `.apple` only deletes that fake record (`:389-402`).
  - **P1** API key accepted with `count >= 12` and shown as "Connected" with no verification or status (`:376-387`).
  - **P1** Dead-end provider configuration: Google, Microsoft, Notion and Discord "Add Developer Configuration" saves an ID, but nothing consumes it, and the sheet admits this only in small print for non-Spotify (`:1121-1123`). The row never becomes connected.
  - **P1** "Disconnect deletes the local credential" (`:848`) is true for Spotify tokens and API keys. It does not say that provider-side revocation did not occur (Spotify token and app grant remain at the provider). Client ID is not cleared. No "disconnect result" message is shown (`:989-991`).
  - **P2** Keychain items survive app deletion, while `connectedAccounts` in UserDefaults does not. After a reinstall, `isConnected` is false, so the UI offers no Disconnect and the old Keychain credentials are invisible. A new key save then silently overwrites them (`:268`).
  - **P2** `connectSpotify` stores tokens before the profile fetch (`:479-484`). If that fetch fails, the Keychain holds orphan tokens with no account record, so the UI shows "Not connected" without a way to delete them.
  - **P2** Spotify auth cancellation surfaces the raw `ASWebAuthenticationSessionError` text as an orange warning (`:1044`). It should be silent.
  - **P3** Row check icon has no accessibility label (`:921-922`); status is communicated by color and icon only.
- **Proposed release behavior:** Replace the Bool with a per-service state enum matching brief §11 (unavailable, available, permission granted, credentials configured, authenticated, data verified, stale, disconnected).
  - Apple row: read real EventKit/Contacts/Photos/Music authorization and show each state separately, with an "Open iOS Settings" handoff; remove "Enable Permission Center".
  - API keys: show "Credential saved (not verified)" until a test call succeeds, then "Verified <date>", and "Rejected" on 401.
  - Hide the dead-end developer-config rows (Google/Microsoft/Notion/Discord) behind an Advanced section, or convert them to labeled External Handoff rows.
  - State plainly what Disconnect did locally and what it did not do at the provider, and purge orphan Keychain items on launch or reconnect.
- **Completion check:** Fresh install shows no "Connected" row; saving a bogus 12-character key shows "Credential saved, not verified" and then "Rejected" after a test; Disconnect on Spotify removes tokens and says the grant must also be removed at spotify.com/account/apps.

---

### ChatGPT — `AIAssistantApp(app: .chatGPT)` (`Connections.swift:1384`)
### Claude — `AIAssistantApp(app: .claude)` (`Connections.swift:1384`)
*(One view serves both; the details below apply to both unless marked.)*
- **Classification (current):** Provider integration (code present, unverified) (optional BYO developer API key; unexercised). Neither app offers an official-app handoff on its main screen.
- **Purpose / primary task:** In-app chat with the provider's model through the user's developer API key.
- **Current behavior:**
  - Not connected: `setupRequired` screen with an "Add Developer API Key" link to the detail screen (`:1586-1623`).
  - Connected: chat UI with composer, "thinking" indicator, error banner, "new conversation" button, and a model settings sheet (`:1472-1531`, `:1625-1661`, `:1699-1749`).
  - A canned greeting "Hey, I’m Claude inside Indica OS…" or "Hey, I’m your OpenAI assistant inside Indica OS…" is inserted as the first assistant message (`:1653-1660`) and is then sent to the API as history (`:1630`).
  - Conversation is `@State` only, so it is lost on app switch or relaunch; the settings sheet says so (`:1732`).
- **Data source & persistence:**
  - Key: Keychain `openAI.apiKey` / `anthropic.apiKey` (`:380`, `:548`).
  - Model IDs: `@AppStorage("assistant.openAI.model")` and `("assistant.anthropic.model")` (`:1388-1389`).
  - No transcript persistence.
- **Permissions / cost:** The user must have a paid developer API account. Developer billing is separate from consumer ChatGPT/Claude plans (stated at `:146`, `:148`, `:1731`). Core Swift UI use must not depend on this.
- **Request format and defaults (verified against code; provider behavior unverified):**
  - **OpenAI** (`Connections.swift:634-673`): `POST https://api.openai.com/v1/responses`. Headers `Authorization: Bearer <key>` and `Content-Type: application/json`. Body `{model, instructions, input:[{role,content}], max_output_tokens:1200}`. Parses `output[].content[].text`, joined (`:664-669`). The format matches the Responses API shape, from memory only; the OpenAI docs were not consulted (no network).
  - **Anthropic** (`:675-713`): `POST https://api.anthropic.com/v1/messages`. Headers `x-api-key`, `anthropic-version: 2023-06-01`, `Content-Type`. Body `{model, system, messages, max_tokens:1200}`. Parses `content[].text`. This matches the Messages API (checked against the bundled `claude-api` skill reference).
  - **Default model IDs, exact strings:**
    - OpenAI: `"gpt-5.6-luna"` (`:1388`, repeated in UI copy `:1716`). **Cannot be confirmed here and looks non-standard. Treat as unverified; the brief requires re-verification.**
    - Anthropic: `"claude-haiku-4-5"` (`:1389`, copy `:1715`). This is a valid current ID per the bundled skill's model table (cached 2026-10-06). It is a prior generation; the table lists `claude-haiku-5-5` as the current Haiku. Re-verify with `GET /v1/models` rather than trusting a hard-coded default.
  - **Timeouts and errors:** No explicit `timeoutInterval` on either request (`:640`, `:681`; only the Spotify refresh sets 30 s at `:573`), so the system default of 60 s applies. No streaming, retry, `Retry-After`, 401 or 429 handling. `validateAIResponse` returns the provider's `error.message` or the HTTP status text (`:715-726`). It also reads the Anthropic error shape because both use `error.message`.
  - **Key handling:** The key is read from the Keychain only at send time (`:548`) and placed in headers. No `print`, `NSLog`, `os_log` or `Logger` exists anywhere in `IndicaOS/*.swift`. Keys are not written to UserDefaults (explicitly stated at `:1172`; `ConnectedAccountRecord` stores only a static string, `:381-385`). Provider error messages shown in the UI can echo a masked key fragment (e.g. an OpenAI "incorrect API key" message), but only in the on-screen banner.
- **Defects:**
  - **P1** Default OpenAI model `gpt-5.6-luna` is an unverified default that ships as the out-of-box choice and is displayed in the header (`:1540`). With an unrecognized default, first send fails with a provider error. The brief says not to preserve unverified defaults.
  - **P1** Misleading state: "Connected/lock" header (`:1546`) and the gate `store.isConnected(service)` (`:1421`) trust a saved string. A bad key is only discovered at first send.
  - **P2** The canned greeting is sent as an `assistant` turn at the head of the history. Anthropic's history starts with an assistant message; whether the API accepts that is unverified. Strip it from outbound history for both providers.
  - **P2** OpenAI Responses requests omit `store`. The API default is to retain responses server-side (unverified from memory), while the UI says history "stays in this app session" (`:1732`). Send `store:false` or disclose.
  - **P2** `max_output_tokens: 1200` is a fixed cap. With reasoning-capable OpenAI models the cap can be consumed before any `output_text` is produced. `status:"incomplete"` and `stop_reason:"max_tokens"` are not surfaced, so the user sees only "The assistant returned an empty response" (`:233-234`, `:671`, `:711`).
  - **P2** In-flight request is not cancelled by "New conversation" (`:1625-1661`, `:1636-1648`). A late reply is appended to the fresh conversation.
  - **P2** A failed send leaves the user's message in the transcript and clears the composer with no retry (`:1631-1634`, `:1645`).
  - **P2** "Open API Key Dashboard" in Assistant Settings calls `openOfficialAppOrWebsite`, which tries `chatgpt://` / `claude://` first (`:1725-1727`, `:175-176`, `:528-538`). The label promises a web key dashboard and the action opens the consumer app. `claude://` and `chatgpt://` are unverified as registered schemes.
  - **P3** The model text field has no picker or validation (`:1709`). The composer and the settings sheet text carry the Indica brand (`:1538`, `:1657-1658`, `:645`, `:687`).
- **Proposed release behavior:** Main entry point is an "Open ChatGPT / Open Claude" handoff, with a clear one-line note that official-app access is separate from developer API billing. The built-in chat stays as an optional "Bring your own API key" section.
  - Re-verify default models against current provider docs, or fetch `/v1/models` after the key is saved and let the user pick. Never ship a hard-coded unverified default.
  - Set explicit timeouts, handle 401/429/incomplete states, drop the synthetic greeting from outbound history, set `store:false` (OpenAI), and cancel in-flight work on reset or disappear.
  - Gate the "Connected" label behind a successful test call.
- **Completion check:** With no key saved, the app offers working "Open ChatGPT/Claude" buttons; with a valid key, the first message gets a real reply from a model chosen from a live list; with a bad key, the status says "Rejected" before anything is sent.

---

### Spotify — `ConnectedServiceApp(app: .spotify)` (`Connections.swift:1206`; OAuth in `ConnectionStore.connectSpotify`, `:413`)
- **Classification (current):** Provider integration (code present, unverified) (code implements a real OAuth 2.0 + PKCE flow plus one read endpoint; unexercised against a live account). Requires a user-supplied developer client ID, so for normal users it is effectively an External handoff.
- **Purpose / primary task:** Show the user's top Spotify tracks. (The brief expects real playback/account state; none is implemented.)
- **Current behavior:** When connected, shows "Your Top Tracks" (6 short-term tracks) with a refresh button (`:1272-1329`). When not connected, a generic "Connect Your Account" card routes to detail (`:1331-1361`).
- **PKCE correctness, with citations:**
  - Verifier: 48 random bytes from `SecRandomCopyBytes`, base64url without padding (64 chars), within the 43-128 range (`:420`, `:740-747`, `:786-791`). Correct.
  - Challenge: `SHA256(verifier UTF-8)` -> base64url, `code_challenge_method=S256` (`:422`, `:431-432`). Correct.
  - State: 24 random bytes (`:421`), sent (`:433`), compared on return (`:466-467`) -> `stateMismatch`. Correct.
  - Redirect URI: `indicaos://oauth/spotify` (`:423`), matched at `callbackURLScheme: "indicaos"` (`:443`) and verified by scheme/host/path (`:461-464`). The scheme is also declared in `Info.plist:30-34`. Which redirect URI a user registered at Spotify is unverified.
  - Code exchange: form-encoded POST, no client secret, includes `code_verifier` (`:594-620`). The `+` -> `%2B` workaround (`:611`) is needed because `URLComponents` leaves `+` unescaped. Correct for base64url/alphanumeric values.
  - Token storage: Keychain, `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` on insert (`:258-281`, `:479-482`). Keys are `spotify.accessToken` and `spotify.refreshToken`. No token in UserDefaults or logs.
  - Refresh: `grant_type=refresh_token` with `client_id` (`:567-592`). It stores a rotated refresh token if returned (`:588-590`). It is only attempted after a 401 in `loadSpotifyTopTracks` (`:506-510`). The expiry (`expires_in`) is not stored. Profile fetch has no refresh path (`:622-632`).
  - Disconnect: deletes both Keychain items, clears tracks and the account record (`:389-402`). No provider-side revocation; none is implemented, and the UI does not say so. The client ID is retained.
  - Scopes requested: `user-read-private user-read-email user-read-currently-playing user-top-read user-library-read` (`:430`). Only `user-top-read` and profile are used. `user-read-email` is stored in plaintext UserDefaults (`:485-489`).
- **Data source & persistence:** Spotify Web API (`/v1/me`, `/v1/me/top/tracks?limit=6&time_range=short_term`, `:503`, `:623`). Tracks live in memory only (`@Published spotifyTracks`, `:314`). The account record is in UserDefaults. The Keychain holds the tokens.
- **Permissions / cost:** The user must create a Spotify developer app and register `indicaos://oauth/spotify` (`:134`). Any Spotify account works for top tracks (Premium requirement for playback is not relevant because there is no playback; development-mode user limits are unverified). No cost.
- **Defects:**
  - **P1** The end user must register a Spotify developer app and paste a client ID to use the app (`:1030-1036`). That conflicts with brief §10/§11 and "core use must never require developer registration". Needs a project-owned public PKCE client ID (no secret), or a clearly labeled Advanced path.
  - **P1** Status is not truthful when refresh fails: "Connected" stays green and tracks remain stale after "Spotify authorization expired" (`:582`); no stale or reconnect state; no last-updated timestamp.
  - **P2** No playback or currently-playing implementation despite the scope and capability text "Currently playing" / "Library" (`:113`). The capability card lists unimplemented features with checkmarks (`:1363-1369`).
  - **P2** Orphan tokens on profile-fetch failure (`:479-484`) and Keychain/UserDefaults divergence after reinstall (see Connections).
  - **P2** Over-requested scopes (`user-read-email`, `user-library-read`, `user-read-currently-playing`).
  - **P2** Cancel shows a raw error. A disconnect during an in-flight `loadSpotifyTopTracks` can repopulate tracks after tokens are deleted (no cancellation, `:494-526`).
  - **P3** Refresh button lacks an accessibility label (`:1278-1286`). A 429 from Spotify is not handled.
- **Proposed release behavior:** Ship a project-registered public client ID (PKCE needs no secret). Request only `user-top-read` (plus profile if needed).
  - Persist `expires_in`, refresh proactively, and show distinct "Connected / Needs reconnect / Stale (as of <time>)" states.
  - Implement only what is real (top tracks, optionally currently-playing) and label anything else as an official-app handoff (`spotify://`).
  - Disconnect explains that the grant remains at Spotify until removed at spotify.com/account/apps.
- **Completion check:** On a real device a tester taps Connect Spotify without entering any developer ID, sees their top tracks with an "as of" time, and after Disconnect the Keychain items are gone and the screen says the Spotify-side grant remains.

---

### YouTube — `ConnectedServiceApp(app: .youtube)` (`Connections.swift:1206`)
- **Classification (current):** External handoff. The only working action is "Open Google" / the toolbar button (`youtube://`, fallback `myaccount.google.com`).
- **Purpose / primary task:** Intended as a YouTube profile and playlists connector. Nothing is implemented.
- **Current behavior:** Hero shows "Google Sign-In", pill "Not connected". "Set Up Connection" leads to the Google detail screen, whose only action is "Add Developer Configuration" (a dead-end client-ID field). The capability card lists "YouTube profile and playlists", "Gmail inbox" and "Google account identity" with checkmarks (`:108-115`, `:1363-1369`).
- **Data source & persistence:** None (client ID stored but unused).
- **Permissions / cost:** None implemented. The setup text asks the user to create a Google OAuth client and enable APIs (`:136`).
- **Defects:**
  - **P1** Capability checklist claims features that do not exist and shows Gmail items on the YouTube screen.
  - **P1** "Google Sign-In" connection method is displayed, but no Google SDK or flow exists (`:76`, `:1071-1076`).
  - **P2** The accessibility label "Open official Google app" (`:1246`) and the "Open Google" button text (`:1375`) name the wrong product. Hero title shows connection kind instead of any real status.
  - **P3** The `youtube://` handoff is not guarded by a `canOpenURL` check (it falls back to the website, which is acceptable).
- **Proposed release behavior:** Present as "YouTube — opens the YouTube app" with a working open button and a web fallback (`https://www.youtube.com`). Remove sign-in copy and capability checkmarks. Treat any later playlist feature as separate and verified.
- **Completion check:** Tapping the main button opens the YouTube app (or youtube.com if not installed), and the screen makes no claim of account access.

---

### Gmail — `ConnectedServiceApp(app: .gmail)` (`Connections.swift:1206`)
- **Classification (current):** External handoff, with a defective handoff target.
- **Purpose / primary task:** Intended as Gmail inbox access. Nothing is implemented; no inbox, no composer.
- **Current behavior:** Same as YouTube (shared `.google` service). The toolbar button and "Open Google" use `youtube://` (`:170`), so Gmail opens the YouTube app, and the fallback is `myaccount.google.com` rather than Gmail (`:156`).
- **Data source & persistence:** None.
- **Permissions / cost:** None implemented.
- **Defects:**
  - **P1** Wrong handoff: "Open Gmail" launches the YouTube app (`:166-178`, `:180-192`). The cause is a shared `ConnectedService.google` with one `deepLinkURL`.
  - **P1** Capability checklist lists "Gmail inbox" with a checkmark although nothing connects (`:114-115`, `:1363-1369`).
  - **P2** Brief §9 asks Mail/Gmail to distinguish composing mail, opening a provider and syncing an inbox. This screen does none of them. A `mailto:` or `googlegmail://` composer handoff does not exist.
- **Proposed release behavior:** Separate Gmail and YouTube handoff targets (`googlegmail://` with web fallback `https://mail.google.com`, plus `mailto:` compose via system composer). State "Opens Gmail app; inbox is not shown here."
- **Completion check:** Tapping Gmail's open button opens Gmail (or mail.google.com), never YouTube.

---

### Outlook — `ConnectedServiceApp(app: .outlook)` (`Connections.swift:1206`)
- **Classification (current):** External handoff (`ms-outlook://`, fallback `https://outlook.live.com`, `:171`, `:157`).
- **Purpose / primary task:** Intended as Outlook mail and calendar via Microsoft Graph. Nothing is implemented.
- **Current behavior:** "Microsoft identity" connection kind; setup text asks for a Microsoft Entra registration plus an MSAL package (`:137-138`); capability card lists "Outlook inbox", "Calendar", "Microsoft account identity" with checkmarks (`:116-117`). The dead-end "Add Developer Configuration" button leads nowhere.
- **Data source & persistence:** None.
- **Permissions / cost:** None implemented. A Microsoft app registration would be developer-owned.
- **Defects:**
  - **P1** Same false capability checklist and dead-end config as the other Google/Microsoft rows.
  - **P2** The page title says "Outlook" but the hero service is "Microsoft", and the button reads "Open Microsoft".
  - **P3** Connection method wording ("Microsoft identity") promises a sign-in that does not exist.
- **Proposed release behavior:** "Opens the Outlook app" handoff only. Remove sign-in and capability claims.
- **Completion check:** The button opens Outlook (or outlook.live.com); no checkmarked feature exists that I cannot use.

---

### Notion — `ConnectedServiceApp(app: .notion)` (`Connections.swift:1206`)
- **Classification (current):** External handoff (`notion://`, fallback `https://www.notion.so`, `:172`, `:158`).
- **Purpose / primary task:** Intended for pages and databases through OAuth. Not implemented.
- **Current behavior:** Says "OAuth + secure backend" and "A small secure backend is required because Notion’s token exchange uses a client secret" (`:78`, `:139-140`). That is honest as a requirement but the screen still offers "Set Up Connection" and the capability checklist "Selected pages / Databases / Search / Create and update content" (`:118-119`).
- **Data source & persistence:** None.
- **Permissions / cost:** A backend (hosting cost) is a prerequisite and violates the "no mandatory recurring cloud cost" default unless the owner decides otherwise.
- **Defects:**
  - **P1** Capability list shows unimplemented features with checkmarks.
  - **P2** Dead-end developer configuration entry point.
- **Proposed release behavior:** "Opens Notion" handoff. If an integration is wanted later, document the backend cost and decision in the integration matrix first.
- **Completion check:** The screen's only action opens Notion, and nothing implies page access.

---

### Discord — `ConnectedServiceApp(app: .discord)` (`Connections.swift:1206`)
- **Classification (current):** External handoff (`discord://`, fallback `https://discord.com/app`, `:173`, `:159`).
- **Purpose / primary task:** Intended for identity, servers and linked connections. Not implemented.
- **Current behavior:** Setup text says to create a Discord developer application and enable a public client (`:141-142`). The capability list claims "Identity / Servers / Linked connections" (`:120-121`).
- **Data source & persistence:** None.
- **Permissions / cost:** A developer registration is required for any future flow.
- **Defects:**
  - **P1** False capability checklist.
  - **P2** The summary says "Private messages are not exposed" (`:98`), correct but irrelevant because nothing is exposed. Dead-end config.
- **Proposed release behavior:** "Opens Discord" handoff only, with the same wording as the others.
- **Completion check:** The screen opens Discord and contains no claims about servers or identity.

---

### Telegram — `ConnectedServiceApp(app: .telegram)` (`Connections.swift:1206`)
- **Classification (current):** External handoff (`tg://`, fallback `https://web.telegram.org`, `:174`, `:160`). This is the most honest screen: setup text states that a personal account requires TDLib and a Telegram `api_id` (`:99-100`, `:143-144`) and the detail screen's button is simply "Open Telegram" (`:1077-1082`).
- **Purpose / primary task:** Open Telegram.
- **Current behavior:** Hero/pill show "Telegram client authorization / Not connected". The capability card still lists "Personal chats with native client setup / Contacts / Channels" with checkmarks (`:122-123`).
- **Data source & persistence:** None.
- **Permissions / cost:** None implemented.
- **Defects:**
  - **P1** Capability checklist implies chat and contacts access.
  - **P3** "Not connected" pill is perpetual because there is no connection path (`:1093`).
- **Proposed release behavior:** "Opens Telegram" handoff; no pill, no capability checkmarks.
- **Completion check:** The button opens Telegram or web.telegram.org and nothing on the screen suggests a synced chat history.

---

## Device facts and controls truth table

Every row is static analysis. No device or API was exercised. "Real API" means the code calls a supported framework; nothing in the audited scope does.

| Label | Source API or fabricated | file:line | Verdict |
|---|---|---|---|
| Status-bar time | `Date` via `TimelineView` | `SystemShell.swift:237-241` | Real (system clock). |
| Status-bar signal bars | Fixed SF Symbol `cellularbars` | `SystemShell.swift:253` | Fabricated (constant, no carrier or signal source). |
| Status-bar Wi-Fi icon | Fixed SF Symbol `wifi` | `SystemShell.swift:254` | Fabricated (ignores `wifiEnabled`). |
| Status-bar battery | Fixed `battery.100percent` | `SystemShell.swift:255` | Fabricated (no `UIDevice` monitoring). |
| Wi-Fi toggle | `@Published wifiEnabled` (not persisted), no `NWPathMonitor` | `SystemModels.swift:545`; `SettingsSystem.swift:360`; `SystemShell.swift:1529` | App-state only; no effect on the device; footer discloses simulation (`:362`). |
| Wi-Fi network "Example Network" | Literal | `SettingsSystem.swift:202,370` | Fabricated. |
| Private Wi-Fi Address | `@Published` bool | `SettingsSystem.swift:384` | Dead toggle. |
| Bluetooth toggle | `@Published bluetoothEnabled` (not persisted) | `SettingsSystem.swift:399`; `SystemShell.swift:1530` | App-state only; no CoreBluetooth; no disclosure. |
| Bluetooth devices ("Demo Headphones", "Controller", "Studio Speaker"; "Discoverable as") | Literals / `@State` | `SettingsSystem.swift:394,406-417` | Fabricated. |
| Airplane Mode | `@Published airplaneMode` | `SettingsSystem.swift:135`; `SystemShell.swift:1525` | Dead; does not affect Wi-Fi or Bluetooth. |
| Mobile Data, Roaming, Low Data Mode | `@AppStorage`, no consumer | `SettingsSystem.swift:427-429` | Dead toggles. |
| Cellular "Network: Indica Mobile" (carrier-like) | Literal | `SettingsSystem.swift:440` | Fabricated. Closest to a carrier string; no CoreTelephony or CTCarrier. |
| "Current Period 6.8 GB", "Roaming 0 KB" | Literals | `SettingsSystem.swift:441-442` | Fabricated. |
| VPN "Indica Private / WireGuard / Connected" | `@State` + literals | `SettingsSystem.swift:450-463` | Fabricated. |
| Brightness slider | `@Published brightness` (0.78); never applied to `UIScreen` | `SystemModels.swift:547`; `SettingsSystem.swift:660`; `SystemShell.swift:1554` | App-state only; not even visible. Label implies device scope. |
| Volume slider | `@Published volume` (0.46); no `AVAudioSession`/`MPVolumeView` | `SystemModels.swift:548`; `SettingsSystem.swift:582`; `SystemShell.swift:1555` | App-state only; label implies device scope. |
| Focus Status | `@Published isFocusEnabled` (not persisted); no consumer | `SystemModels.swift:543`; `SettingsSystem.swift:611`; `SystemShell.swift:1557` | App-state only; does not filter notifications. |
| "Quiet Hours · 10 PM to 7 AM", Share Across Devices | `@AppStorage`, no consumer | `SettingsSystem.swift:605-606,616` | Dead. |
| Notifications list, per-app toggles | Sample data, `disabledNotificationApps`; no `UNUserNotificationCenter` | `SystemModels.swift:550-554,527-533`; `SettingsSystem.swift:470-571` | App-state only (sample notifications). |
| Sounds / Haptics, "Lock Sound", "Play Test Sound" | Published bools; button is `{}` | `SettingsSystem.swift:585-596` | Haptics real in-app; sound toggles dead; test sound no-op. |
| Appearance (Light/Dark/Auto) | `preferredColorScheme` | `ContentView.swift:11`; `SystemModels.swift:436-439` | Real, scoped to Swift UI. |
| True Tone | `@AppStorage` | `SettingsSystem.swift:637,663` | Dead. |
| Auto-Lock | `@AppStorage` | `SettingsSystem.swift:638,675` | Dead (no timer reads it). |
| Bold Text | `.fontWeight` | `ContentView.swift:15` | Real, scoped to Swift UI. |
| Text Size | `dynamicTypeSize` mapped from `textScale`, then `max()` with device | `SystemModels.swift:575-584`; `ContentView.swift:12` | Real but enlarge-only; app-only. |
| Reduce Motion / Reduce Transparency | `ContentView.swift:16-20`; `SystemShell.swift:1950` | — | Real, scoped to Swift UI. |
| Increase Contrast, Button Shapes | `@AppStorage`, no consumer | `SettingsSystem.swift:972-973` | Dead. |
| Wallpaper, Accent, Icon appearance, Glass intensity, density, labels | Published/UserDefaults; used in shell | `SystemShell.swift:868,884,943,1010`; `SettingsSystem.swift:795-968` | Real, scoped to Swift UI (the "wallpaper" is the app's own). |
| Lock Screen preview ("Friday, July 17", "9:41", "72°", "2:30") | Literals | `SettingsSystem.swift:843-850` | Fabricated sample. |
| Low Power Mode | `@Published` bool; not `ProcessInfo.isLowPowerModeEnabled` | `SettingsSystem.swift:1063`; `SystemModels.swift:501` | App-state only; row detail "82%" literal (`:210`). |
| Battery percentage "82%" | Literal | `SettingsSystem.swift:210` | Fabricated. |
| Battery level history bars | Literal array | `SettingsSystem.swift:1058,1069-1075` | Fabricated. |
| Maximum Capacity 98%, Cycle Count 112, Charging Optimization | Literals | `SettingsSystem.swift:1088-1090` | Fabricated (forbidden by brief §22). |
| Private Relay, Lockdown Mode | `@AppStorage`, no effect | `SettingsSystem.swift:1003-1004,1015-1016` | Fabricated security claims. |
| Location Services, Tracking, Analytics | `@Published` bools, no consumer | `SettingsSystem.swift:1009-1011`; `SystemModels.swift:507-514` | Dead; do not read real authorization. |
| Photos/Contacts/Calendars/Mic-Camera permission toggles | `@State` | `SettingsSystem.swift:1036-1053` | Fabricated state (footer discloses). |
| Device name "My Indica" | UserDefaults `deviceName` | `SystemModels.swift:525` | App-only label, not `UIDevice.name`. |
| About: "Indica OS Version 0.4 (Prototype)" | Literal; build is `MARKETING_VERSION = 0.1` | `SettingsSystem.swift:1131`; `project.pbxproj:194,232` | Fabricated and inconsistent. |
| About: Model Name / Model Number / Serial Number | Literals | `SettingsSystem.swift:1132-1134` | Fabricated. |
| About: Apps count | `BuiltInApp.allCases.count` | `SettingsSystem.swift:1137` | Real (app catalog count). |
| About/Storage: Capacity 256 GB, Available 198.4 GB, "57.6 GB of 256 GB used" | Literals | `SettingsSystem.swift:1138-1139,1182-1204` | Fabricated. |
| Storage per-app sizes | `Int.random(in: 45...820)` | `SettingsSystem.swift:1222` | Fabricated, re-rolls each render. |
| Software Update "up to date" | Literal + `Task.sleep` | `SettingsSystem.swift:1157-1172` | Fabricated. |
| Date & Time zone "New York"/"United States"; Language & Region | Literals / unused `@AppStorage` | `SettingsSystem.swift:1270-1271,1279-1295` | Fabricated / dead. |
| "Care"-like or AppleCare string | Not found. A case-insensitive search for "care" in `IndicaOS/*.swift` hits only `indicaRegion` (`SettingsSystem.swift:1280`). The nearest carrier-like text is "Indica Mobile" (`:440`). | — | Brief §22's "care" is not present in this build. Unconfirmed which string the owner means. |

## Brand strings to migrate
All user-facing "Indica", "Indica OS" and "Swift OS" strings. "Swift OS" does not occur. Identifier-only uses (type names such as `IndicaSystem`) are excluded. Files outside the audit scope are listed for completeness only.

**Info.plist and project**
- `Info.plist:8` CFBundleDisplayName "Indica OS"; also `project.pbxproj:183,221` (`INFOPLIST_KEY_CFBundleDisplayName`)
- `Info.plist:29` URL name "Indica OAuth" (identifier-ish, not shown to users)
- Permission strings (all begin "Indica"): `Info.plist:42,44,46,48,50,52,54,56,58,60,62`

**Settings (`SettingsSystem.swift`)**
- `:165` "Lock Indica OS"
- `:171` "Indica OS 0.4"
- `:173` Description text (no brand name) ("An original interactive iPhone-style simulator...")
- `:362` "Wi-Fi is simulated inside Indica OS…"
- `:440` "Indica Mobile"
- `:461` "Indica Private"
- `:948` "Indica’s material fallback"
- `:993` "Indica OS adapts…"
- `:1011` "Share Indica Analytics"
- `:1027` "Indica never extracts passwords…"
- `:1105` "Indica Storage"
- `:1115` "Transfer or Reset Indica"
- `:1131` "Indica OS Version"
- `:1132` "Indica Phone Pro"
- `:1134` "SIM-INDICA-001"
- `:1157` "Indica OS is up to date"
- `:1228` "Indica Storage" (nav title)
- `:1316` "Indica’s local sample content"
- `:1320` "Reset every Indica setting?"
- `:1390` "Indica system app"
- `:1453` "Indica" (redirect label for `indicaos://oauth`)

**Connections (`Connections.swift`)**
- `:102` "an Indica assistant"
- `:125` "Indica assistant"
- `:132` "Indica asks for each iPhone permission…"
- `:645` OpenAI system prompt "assistant inside Indica OS"
- `:687` Anthropic system prompt, same wording
- `:879` "Indica Account Center"
- `:968` "What Indica Can Use"
- `:1172` "Indica stores the key…"
- `:1342` "Indica can now use only the access you approved."
- `:1538` "\(app.name) for Indica"
- `:1657` "Claude inside Indica OS"
- `:1658` "OpenAI assistant inside Indica OS"

**Other files, outside this audit's scope (for the migration list)**
- `SystemModels.swift:525` "My Indica", `:601` "Welcome to Indica", `:611` "testing Indica OS now", `:756` "Welcome to Indica"
- `SystemShell.swift:109` "INDICA", `:276` "Indica Locked", `:280` "Indica OS", `:364` "Indica", `:1296` hint "Indica Home Screen", `:1311` "Swipe up for Indica Home"
- `CoreApps.swift:582,691` "indica://start", `:629`, `:698`, `:700`, `:704`, `:721`, `:1282`, `:1290`, `:1304`, `:1355`
- `EverydayApps.swift:398` "Indica Cash", `:805`, `:1205`, `:1313` "Indica Watch"

## Compatibility contracts (keys, schemes, bundle ID)

**Bundle and project**
- Bundle ID `com.indicaos.prototype` (`project.pbxproj:195,233`). Target and scheme names are `IndicaOS`.
- Display name "Indica OS" (`Info.plist:8`, `project.pbxproj:183,221`).
- `MARKETING_VERSION = 0.1` (`project.pbxproj:194,232`).

**URL schemes and redirects**
- `CFBundleURLSchemes`: `indicaos` and `com.indicaos.prototype` (`Info.plist:31-34`). No `onOpenURL` handler exists; `ASWebAuthenticationSession` captures the callback directly. `com.indicaos.prototype` is referenced only in copy text (`Connections.swift:136`), and whether any provider has it registered is unverified.
- Spotify redirect `indicaos://oauth/spotify` (`Connections.swift:134,423,443,461-464`). Developer page shows `indicaos://oauth` and `indicaos://oauth/spotify` (`SettingsSystem.swift:1453-1454`). Users who registered this redirect at Spotify would break on a scheme rename.
- Outbound deep links: `spotify://`, `youtube://` (used for Google and Gmail), `ms-outlook://`, `notion://`, `discord://`, `tg://`, `chatgpt://`, `claude://` (`Connections.swift:166-178`). `LSApplicationQueriesSchemes` is not declared; the code uses `open` with a web fallback, not `canOpenURL`. Whether `chatgpt://` and `claude://` are registered by those apps is unverified.
- Internal `indica://start` (browser start page, `CoreApps.swift:582,691`).

**Keychain**
- Service `com.indicaos.prototype.credentials` (`Connections.swift:259`).
- Accounts: `spotify.accessToken`, `spotify.refreshToken` (`:392-393`, `:479-481`); `openAI.apiKey`, `anthropic.apiKey` (`"\(rawValue).apiKey"`, `:353`, `:380`, `:396`).
- Accessibility: `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` on insert only (`:275`).

**UserDefaults, written by the Connections code**
- `connectedAccounts` (JSON `[String: ConnectedAccountRecord]`, keyed by `ConnectedService.rawValue`: `apple`, `spotify`, `google`, `microsoft`, `notion`, `discord`, `telegram`, `openAI`, `anthropic`) (`:324`, `:730`).
- `integrationClientIDs` (`:330`, `:735`).
- `assistant.openAI.model` and `assistant.anthropic.model` (`:1388-1389`).

**UserDefaults, `IndicaSystem`** (`SystemModels.swift:436-541, 571`, plus `notes`, `reminders`, `messages` via `save(key:)` at `:764-769`)
- `appearance`, `wallpaper`, `accentStyle`, `iconAppearance`, `homeLayoutDensity`, `lockClockStyle`, `notificationPreviews`
- `glassIntensity`, `reduceTransparency`, `reduceMotion`, `boldText`, `textScale`
- `showAppLabels`, `showLockWidgets`, `soundsEnabled`, `hapticsEnabled`, `keyboardClicks`
- `lowPowerMode`, `batteryPercentage`, `locationServices`, `analyticsSharing`, `allowTrackingRequests`
- `automaticUpdates`, `backgroundRefresh`, `privateWiFiAddress`, `deviceName`
- `disabledNotificationApps`, `disabledBackgroundApps`, `capturedMoments`
- `notes`, `reminders`, `messages`
- `Codable` enum raw values also persist: `BuiltInApp`, `ConnectedService`.

**`@AppStorage` keys, `SettingsSystem.swift`**
- `askToJoinNetworks` (`:354`), `autoJoinHotspot` (`:355`), `cellularDataEnabled` (`:427`), `dataRoaming` (`:428`), `lowDataMode` (`:429`)
- `focusShareAcrossDevices` (`:605`), `focusScheduleEnabled` (`:606`), `trueTone` (`:637`), `autoLockMinutes` (`:638`)
- `increaseContrast` (`:972`), `buttonShapes` (`:973`), `lockdownMode` (`:1003`), `privateRelay` (`:1004`)
- `setTimeAutomatically` (`:1260`), `use24HourTime` (`:1261`), `indicaLanguage` (`:1279`), `indicaRegion` (`:1280`), `appCellularDefault` (`:1366`)

**Launch arguments** (`SystemModels.swift:617-625`; `Connections.swift:344`)
- `--control`, `--notifications`, `--home`, `--app=<rawValue>`; `--assistant-preview` (DEBUG only, forces OpenAI and Anthropic "connected" without a key).

