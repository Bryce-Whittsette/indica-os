# Changelog

## Unreleased

### Changed
- **The Instrument design is built.** The shell has a new look: matte surfaces, ruled lines and one signal color, in light and dark. Home has a ruled ledger with your next event and the labeled sample weather, a Search pill with a ruler that tracks the page, and solid dock tiles. The Lock Screen, app switcher, Control Center, Notifications and app bar match. Calendar is a ruled grid.
- 41 apps have new original line icons, and Calendar and Clock icons show the real date and time. Third-party services show a plain letter instead of an imitated logo.
- Numerals and small labels use the system monospaced face, standing in for IBM Plex Mono, which isn't bundled.
- The Instrument wallpaper and Signal accent are the defaults. If you already picked a wallpaper or accent, it stays, and the earlier ones are still in Settings.
- Springs in the shell no longer overshoot.
- The Lock Screen shows your real next event, in place of a made-up event and step count.
- The concept demo label has its own strip above the app bar.

### Added
- Published a GitHub wiki with setup instructions, app and navigation guides, connection setup, storage and privacy details, a development guide, and troubleshooting.

### Removed
- Removed the secondary assistant app, its provider API client, connection settings, model preference, and outbound links. The catalog now contains 49 apps; the OpenAI assistant and other services remain available.
- Removed Liquid Glass and its Intensity slider from Settings, because nothing is glass now. "Glass, Color & Motion" is now "Color & Motion".
- Removed the in-app Reduce Transparency switches, because nothing depends on them now. Weather's material still follows the iOS setting.
- Removed the "Swipe up for Home" hint in apps. It disappeared after a few seconds and resized the screen when it did.
- Removed the shell's own bar from Home, the Lock Screen and Control Center, where it did nothing and doubled up with the iOS home bar.
- Removed tool-specific project branding and external tooling links. Development instructions now live in `DEVELOPMENT.md`.

### Fixed
- Pulling down from the status bar now opens Notifications or Control Center. The top of the screen ignored touches, so the pull only worked from just below it.
- The concept demo label no longer covers the Messages composer.
- The Apps row in Settings has its icon back.
- Calendar days no longer wrap or run together at the largest text sizes.
- Dock icons have VoiceOver labels.

## v0.3.0 — 2026-11-03

The Home Screen now follows your finger, the app is named Swift UI, and Calendar, Clock, Files and Voice Memos work for real. The Instrument visual design is selected but not built, so the look is unchanged.

### Added
- The Home Screen pages now follow your finger. Swiping and scrubbing share one position, so the pages move continuously, resist past the first and last page, carry your release speed into a settle, and can be caught mid-settle without jumping.
- Hold the Search pill and move sideways to move through pages. A tap still opens search, and the hold no longer starts Home Screen editing. Page changes are announced to VoiceOver, and off-screen pages are out of the VoiceOver order.
- Swipe a card up in the app switcher to close it. The card follows your finger and springs back if you let go early. Closing the last card goes Home. VoiceOver users get a Close action on each card.
- Notes search, and an empty state when there are no notes.
- **Calendar is real.** Add, edit and delete events, including all-day and multi-day ones. They're saved on this iPhone and follow time-zone changes correctly. They don't sync with the iOS Calendar, and the app says so. The sample events are gone.
- **Clock is real.** World clocks use real time zones and you can add cities. The timer runs from a deadline, so it stays right across switching apps and relaunching, and it notifies you when it's done. There's a new stopwatch with laps. Alarms arrive as notifications, which Silent mode and Focus can silence; the app says so.
- **Files is real.** It shows Swift UI's own storage on this iPhone. Create folders, import files, preview, share, rename and delete. An import never overwrites a file. The invented files and "Drive" location are gone.
- **Voice Memos is real.** It records from the microphone, with live levels, and plays back, renames, shares and deletes. If you turn microphone access off, it explains and links to Settings. Leaving the app stops and saves the recording. The simulated recordings are gone.
- Calendar, Clock, Files and Voice Memos no longer carry the concept demo label, so 29 of 50 apps have it now.
- The Home Screen's Up Next widget shows your real next event instead of a made-up one.
- Pager physics and local logic checks (`Tests/PagerPhysicsTests.swift`, `Tests/LocalLogicTests.swift`), run in CI alongside the calculator checks.

### Changed
- The app is now named **Swift UI** on the Home Screen, in the microphone prompt, in Settings, in sample content and in the assistant's prompts. Sample notes, messages and journal entries saved under the old name are updated once; anything you wrote is left alone. The bundle ID, URL scheme, Spotify callback and stored data keys are unchanged.
- With Reduce Motion on, a released page changes in place instead of sliding.
- The Home Screen weather widget says "Sample weather". It still shows a made-up forecast.
- The first swipe from the top or bottom screen edge now asks to go to Swift UI's own gesture, and a second reaches iOS. This uses `defersSystemGestures` and hasn't been tested on a physical iPhone.

### Fixed
- Coming back from an app returns to the Home Screen page you left. It always went back to the first page.
- Pressing an icon no longer stays pressed once the touch becomes a page swipe.
- Notes save as you type, so swiping the editor away or leaving the app keeps your text. They only saved on Done before.
- A new note starts with the cursor in the title, so typing no longer goes nowhere.
- Typing into a new note and clearing it leaves nothing behind. Typing into an existing note and undoing it keeps its date and sample status.
- The app switcher's cards can be dragged sideways reliably, and releasing a partial swipe no longer opens the app.
- A swipe up on the lower part of a switcher card no longer also leaves the switcher.
- Two quick flicks in the switcher should close two cards, and closing an earlier card should keep the focused one in place. These come from source review and haven't been exercised.
- A gesture interrupted by the system should no longer leave the Search pill, pager or switcher stuck. This also comes from source review and hasn't been exercised.
- The Home indicator has a larger touch target.

### Stored data
- New: `sampleBrandingVersion` in user defaults.
- New: `calendarEvents`, `clockCities`, `clockAlarms`, `clockTimer`, `clockStopwatch` and `clockTimerMinutes` in user defaults; `Documents/` for Files; `Application Support/VoiceMemos/` for recordings. Sample calendar events and recordings were never saved, so nothing needs migrating.

### Known limitations
- Alarms can't ring through Silent mode or Focus, because they're notifications. Recording stops when you leave the app. Calendar has no invitations, reminders or repeating events.
- In the simulator, recording took 5 to 8 seconds to start capturing, and the app can be unresponsive during that time. If a real iPhone does the same, the first seconds would be lost.
- With the keyboard up, the bottom-edge swipe can't start because that area belongs to the keyboard.
- Switcher cards are still placeholders, not snapshots of the app.
- Frame rate isn't established. On the iPhone 18 Pro simulator a settle drew about 7 to 10 frames, with the app's main thread mostly waiting on the simulator's renderer. It needs measuring on a physical iPhone.
- Control Center's notification list still has sample Messages and Weather entries with no sample label.
- A one-time alarm that goes off while Clock stays open keeps its switch on until you return to the app.
- An unreadable Voice Memos index empties the list without a backup, and a crash mid-recording leaves a file that isn't listed.
- Every keystroke in Notes re-encodes all notes. It hasn't been profiled with long notes on a device.

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
