# Changelog

## v0.2.0 — 2026-11-03

The first release of the Swift UI overhaul (formerly Indica OS). It fixes data loss, removes misleading system UI, and makes several surfaces truthful. The visual redesign and brand migration come in a later release.

### Fixed
- **Personal data is no longer erased by the reset.** "Erase Local Demo Content" overwrote every note, reminder and message. It's replaced by **Remove Sample Content**, which removes only the examples the app added. Existing installs are migrated, and records whose text matches what the app originally added are treated as samples.
- Unreadable stored data is backed up instead of being overwritten on the next save.
- Journal entries are saved, with their real dates. They were lost on leaving the app and always showed July 17, 2026.
- Canvas drawings are saved, and each stroke keeps its own color. Clear asks for confirmation.
- The app no longer draws its own Dynamic Island next to the real camera cutout. That overlapped the cutout on iPhone 18 Pro and was painted below the notch on iPhone 17e. The status region now follows the device's safe area.
- The status bar no longer shows fake full signal or a fixed 100% battery. It shows the real network type and battery level when iOS provides them. Settings no longer invents battery health, cycle count or battery percentage.
- Settings › About, Storage, Software Update, Battery, Wi-Fi and Cellular no longer invent the model name, serial number, capacity, per-app sizes, battery history, network name, carrier, data usage or "up to date" status. They show the app version, iOS version, real device storage, Swift UI's own data size, the real battery level and the active connection. Where iOS doesn't share a value, they say so. The Wi-Fi and Cellular switches that remain are labeled as simulated.
- The mandatory 1.25-second boot delay is removed.
- "Open Gmail" opened YouTube. Each app now opens its own official app.
- Mail's "Send" only closed the sheet. "Open in Mail" now hands the draft to the system mail app.
- The Phone keypad's call button showed a fake call. It now dials through the Phone app, or says the device can't place calls.
- Calendar shows the real month and today, with previous, next and Today controls, instead of a fixed July 2026.
- Copy now matches behavior in the app switcher, Tips, the Weather forecast heading, and the AI key status ("Key saved, not verified" rather than "Connected").

### Added
- Search from the Search pill or the page-two search row finds apps and notes.
- A **Concept demo · sample data** label in the 33 apps built on sample data or simulated results.
- VoiceOver next/previous page actions on the Search pill, plus labels on the Canvas and Calendar controls.
- Project documentation: the product brief (`docs/brief/`), `PRODUCT.md`, and a baseline audit of all 50 apps and the shell (`docs/audit/`).

### Stored data
- New: `journalEntries` and `sampleFlagsVersion` in user defaults, and `Application Support/canvas-strokes.json`.
- `notes`, `reminders` and `messages` gain an optional `isSample` field. Older data still loads.
- The bundle ID, URL scheme, Spotify callback and Keychain entries are unchanged.

### Verification
Debug build with Xcode 27.2. Exercised on iPhone 18 Pro and iPhone 17e simulators (iOS 27.2). The 13 calculator checks pass, and CI builds on Xcode 26. Details are in `docs/audit/README.md`. **Not yet tested:** a physical iPhone, the iOS 17 runtime, iPhone 18 Pro Max, and live provider accounts.

### Known limitations
- 33 of 50 apps are still concept demos, and each one is labeled. Some Settings and Control Center toggles still change only the app's own state.
- During launch, the real iOS status bar and the app's own bar briefly overlap while fading.
- The in-app home swipe can't be used while the keyboard is up. Top-edge swipes can trigger the real iOS Control Center.
- Calendar events are sample data and are not saved. Phone's Recents still simulate a call; only the keypad dials.
- The visual design and in-app "Indica" branding are unchanged pending the brand direction.

## v0.1 — 2026-09-10

The initial Indica OS prototype.
