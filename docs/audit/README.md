# Baseline audit — Swift UI

The starting point for the overhaul (master brief §5), recorded before any app code changes.

| | |
|---|---|
| Commit | `e9c5f97` on `swift-ui/foundations` (app source identical to `main` @ `bfbbeb7`) |
| Build | Debug, unsigned, Xcode 27.2 (27B52), iOS 27.2 simulator SDK — **build succeeded** |
| Runtime | iPhone 18 Pro simulator, iOS 27.2 (24B8117), light and dark, Large and AX5 text sizes |
| Date | 2026-11-03 |
| Also captured | iPhone 17e simulator (iOS 27.2), lock screen only |
| Not covered | Physical device; iPhone 18 Pro Max (simulator screenshot timed out on first boot; rerun pending); iOS 17 runtime (not installed); VoiceOver walkthrough; frame-rate and memory measurement |

Detail files:

- [app-inventory.md](app-inventory.md): all 50 catalog entries with classification, behavior, data, permissions, defects, proposed release behavior and a completion check. Also covers the device-facts truth table, brand strings to migrate, and compatibility contracts.
- [shell.md](shell.md): the shell measured against brief §8, §12 and §20–23, including a gesture ownership map and a microinteraction inventory.

Evidence labels used here: **observed** (seen in the running simulator build), **source** (confirmed by reading code, with `file:line` in the detail files), **unverified** (needs runtime or hardware confirmation).

## Milestone log

### M1 — P0 data safety and camera cutout (branch `swift-ui/foundations`)

Verified on the iPhone 18 Pro simulator (iOS 27.2) with a Debug build, plus the iPhone 17e simulator for the cutout and keyboard checks. The build had no Swift warnings, and the 13 calculator checks passed. Nothing has been tested on a physical device.

| P0 | Status | Change | Evidence |
|---|---|---|---|
| Demo reset erases personal content | **Fixed** | Notes, reminders, messages and journal entries carry `isSample`. Records saved before the flag decode as personal. A one-time migration (`sampleFlagsVersion`) flags old records only when their text (and sender, for messages) exactly matches text the app shipped. "Remove Sample Content" deletes only flagged items plus the simulated camera count. Editing a note makes it personal. Samples have fixed IDs. The Settings footer and dialog describe exactly this. | An existing install migrated correctly: the welcome note was flagged as a sample and the user note "Audit note 1103" was kept as personal. After Settings → General → Transfer or Reset Indica → Remove Sample Content, only the personal note, the personal journal entry and both strokes remained, and that held after relaunch. |
| Unreadable stored data overwritten (found during M1) | **Fixed** | Unreadable data is copied to `<key>.unreadable.<timestamp>` before the fallback loads. Identical bytes are copied only once. | Corrupting `notes` produced one backup with the original bytes. Corrupting `reminders` and launching twice still left exactly one backup. |
| Journal and Canvas lost on exit | **Fixed** | Journal entries live in the shared store with real creation dates (the hard-coded "July 17, 2026" is gone). Canvas strokes keep their own ink, are thinned to 2 pt spacing, and save as `Application Support/canvas-strokes.json` on a background queue. Clearing asks for confirmation, undo can't crash on an empty drawing, and the controls have labels and 44 pt targets. | A journal entry survived a relaunch. Two strokes kept their own colors after relaunch. Undo removed the last stroke and the file matched. 200 strokes of 150 points measure 0.8 MB of JSON and take 31 ms to encode on this Mac (Apple silicon, optimized build), off the main thread. |
| Drawn island collides with the cutout | **Fixed** | `DynamicIslandControl` (pretend island, static LIVE badge, 64% bar) is removed. The status region's height comes from the device's real top safe-area inset (`shellSafeAreaInsets`). In apps it is a `.safeAreaInset`, so navigation backgrounds extend beneath it. | Device-masked lock screen captures: one hardware island on iPhone 18 Pro, and only the notch on iPhone 17e. App screens show time and glyphs beside the cutout. |
| Keyboard region ignored at the shell root (unverified) | **Not reproduced; remainder moved to P1** | No code change. | With the keyboard up, the fields stayed visible in the Notes editor, Journal and Reminders (18 Pro) and in the Messages composer (18 Pro and 17e). The bottom navigation bar sits under the keyboard, as the iOS home indicator does. The in-app home swipe still can't be used while the keyboard is up (O7). That belongs to the gesture-ownership work (brief §21) and is tracked there as P1. The independent reviewer argued for keeping it P0 until that gesture passes. This log records the disagreement instead of closing it silently. |

Independent review (read-only, brief §24): accepted the island removal within the stated evidence. Accepted the data-safety fixes on two conditions, unbounded Canvas storage (F1) and copy that didn't match behavior (F2), and both are addressed above. Lower findings were also addressed: fixed sample IDs, a safe undo, and a documented note that the inset environment's bottom includes the keyboard. Left open: corrupt data gets a backup but no visible notice or recovery screen (P3), and the status glyphs are still fabricated (P1, unchanged from the baseline).

### M2 — truthfulness pass (v0.2.0)

Simulator only (iPhone 18 Pro, iOS 27.2). The build had no Swift warnings, and the 13 calculator checks passed. This milestone had no independent review.

| Finding | Status | Evidence |
|---|---|---|
| Fabricated status glyphs and Settings battery facts (P1) | Fixed: `DeviceStatus` (NWPathMonitor and UIDevice). Values iOS doesn't provide are omitted. | Status bar shows Wi-Fi only on the simulator, which reports no battery level. The cellular bars are gone. |
| Search does nothing (P1) | Fixed: a search sheet for apps and notes | Searching "aud" found the Claude app and the user note. Tapping the note opened Notes. |
| Sample data presented as real (P1) | Labeled: "Concept demo · sample data" in 36 apps | Seen in Weather and Calendar. |
| Calendar fixed to July 2026 (P1) | Fixed: real month and today, with month navigation | Captured November 2026 with Tuesday the 3rd as today. |
| Mail "Send", Phone keypad call, Gmail → YouTube (P1) | Fixed: `mailto:`, `tel:` and per-app handoffs | Source only. Handoffs need a physical device. |
| Switcher, Tips and Weather copy mismatches, and the AI "Connected" label (P1/P2) | Fixed (copy) | Source, plus the Weather capture. |
| Forced 1.25 s boot delay (P2) | Removed | The lock screen follows the first frame. |

New observation: the real iOS home indicator sometimes shows below the app's own bottom bar (seen in Reminders). That's already part of the P1 "custom home indicator" finding.

## Audit health score

| # | Dimension | Score | Key finding |
|---|---|---|---|
| 1 | Accessibility | 1 | Shell uses 69 fixed font sizes, so Dynamic Type never reaches the launcher, lock screen or dock (observed at AX5). About 37 icon-only buttons have no label, and there's no accessible unlock or page navigation. |
| 2 | Performance | 2 | Mandatory 1.25 s boot delay on top of launch, plus 3–4 s of blank screen before the boot mark on a cold simulator start (observed). Nothing measured yet. |
| 3 | Appearance & Theming | 2 | List-based apps adapt to dark mode (observed in Notes). Icon palettes and shell chrome use raw hex and a hand-rolled glass modifier. |
| 4 | Platform Conformance | 1 | The app draws a second island over the real cutout (observed). It has a fabricated status bar and its own home indicator, and real system edge swipes win over the in-app gestures (observed). |
| 5 | Adaptivity | 2 | Lists scale, but the shell doesn't. Shell-root `.ignoresSafeArea()` ignores the keyboard (source). Compact and large iPhones not yet captured. |
| **Total** | | **8/20** | **Poor: major overhaul** |

## Platform conformance verdict

**Fail.** A fluent iPhone user would hesitate within seconds. The top of the screen shows two overlapping islands. The signal bars are always full, even when the real simulator status bar shows no service. Swiping down from the top right opens the real iOS Control Center, not the app's own panel. "Search" doesn't search. The switcher tells you to swipe a card away, and doing so opens the app instead. Embedded apps are mostly well-made SwiftUI `List`/`NavigationStack` screens, which is a good base. But 36 of 50 entries present sample data or simulated results as if they were real.

## Executive summary

- Health score **8/20 (Poor)**.
- Catalog: **4 operational** (Notes, Reminders, Calculator, Tips), **4 with real provider code that has never run against a live account** (Connections hub, ChatGPT/Claude via your own API key, Spotify), **6 external handoffs** (YouTube, Gmail, Outlook, Notion, Discord, Telegram), **36 concept demos**.
- Defects in app entries: **4 P0, 128 P1, 110 P2, 39 P3**. The shell adds 2 P0 and 8 P1 headline findings.
- What blocks a release:
  1. **Personal data is wiped under a "demo" label.** Settings → Transfer or Reset → "Erase Local Demo Content" replaces all notes, reminders and messages with welcome stubs. Its footer says it resets "only Indica's local sample content" (source, `SystemModels.swift:755`, `SettingsSystem.swift:1316`).
  2. **Second island collides with the camera cutout.** The shell draws its own island pill by fixed offsets, about 7 pt left of the hardware cutout, and the two overlap on the lock screen (observed). It also has a static "LIVE" badge and 64% progress (source).
  3. **Leaving an app destroys it.** Only one phase branch renders, so drafts and navigation state are lost on every trip home or to the switcher. Journal entries and Canvas drawings are never saved at all (source).
  4. **Device facts and controls are fabricated.** These include signal, Wi-Fi, battery (100% glyph in the status bar, 82% in Settings), battery health and cycles, storage, serial, carrier "Indica Mobile", and Software Update. Brightness, volume and Focus change nothing. None of it uses `UIDevice` or `NWPathMonitor` (source; the signal mismatch was observed).
  5. **Fake success states across communication and capture.** Camera "captures" a gradient tile, Mail "Send" just closes, Messages "sends" to a fictional contact, and Browser shows a padlock and "12 trackers blocked" without ever loading a page. AI keys show "Connected" once any 12 characters are saved. "Open Gmail" opens YouTube.

## Simulator observations

iPhone 18 Pro, iOS 27.2, build from `e9c5f97`:

| # | Scenario | Result |
|---|---|---|
| O1 | Cold launch | Blank dark screen with the real system status bar for about 3–4 s, then the "INDICA" boot mark, then the lock screen. Timing is approximate (screenshot cadence about 1 s). |
| O2 | Lock screen top region | The drawn island and the hardware cutout overlap, visibly offset (device-masked capture). |
| O3 | Status bar | The custom bar shows full cellular bars, while the real system status bar at launch showed no service. |
| O4 | Lock flashlight button | Tap produced no visible change. |
| O5 | First tap after unlock or app open | Ignored twice (the Notes icon after unlock, Recent Apps after opening Notes). The second tap worked. Input appears to be blocked during transitions. |
| O6 | New note | The title field isn't focused, so typed text went nowhere until the field was tapped. |
| O7 | Internal home swipe with keyboard up in the note sheet | No effect. Only Done exits. The custom bottom bar is under the keyboard. |
| O8 | Internal home swipe after closing the sheet | First attempt ignored, second went Home. |
| O9 | Note persistence | A note saved with Done survived a terminate-and-relaunch. It's stored as JSON in UserDefaults under `notes`. |
| O10 | Search pill: tap, then hold and drag right | Jumped to page 2 (which shows a non-interactive search row). There's no scrubbing, and the pill label changed to "Home". |
| O11 | Swipe down from top right (y = 14 pt and 45 pt) | Opened the **real iOS Control Center** both times. The app's own panel opened only when the swipe started at y ≈ 72 pt. |
| O12 | App switcher | Reachable only through a small Recent Apps button. The card shows a skeleton placeholder, not the app. |
| O13 | Swipe up on a switcher card ("Swipe up on a card to close") | Reopened the app instead of closing it. |
| O14 | AX5 text size | Notes list scales cleanly in light and dark. The launcher, widgets, dock, Search pill and bottom bar don't change. |
| O15 | iPhone 17e (notch device), lock screen | The drawn island, with painted speaker and camera details, hangs below the real notch (device-masked capture). The pretend hardware is drawn on a device that has none. |

Captures are kept outside the repository (session scratch) until the brand pass replaces them. Fresh release screenshots will come from the release build (§17).

## Detailed findings by severity

Only headline findings are listed. Every entry has `file:line` evidence in the detail files.

### P0 — blocking

Status after M1 is in the [milestone log](#milestone-log). The entries below describe the baseline.

- **[P0] Demo reset erases personal content.** Settings → Transfer or Reset. *Category:* data integrity. *Impact:* irreversible loss of the user's notes, reminders and messages behind copy that promises otherwise. *Recommendation:* separate sample stores from personal stores, and make the reset touch only sample data. *Command:* `/impeccable harden`.
- **[P0] Drawn island collides with the hardware cutout.** Shell status region, every phase. Observed on iPhone 18 Pro (offset overlap, O2) and iPhone 17e (painted island below the notch, O15). *Category:* conformance. *Guideline:* HIG Layout. Don't draw under or imitate the camera housing. *Recommendation:* remove the pretend island. Derive the top region from safe-area insets. Keep an app-owned activity surface only if it's tied to a real activity model and placed safely (brief §23). *Command:* `/impeccable adapt`.
- **[P0] Journal entries and Canvas drawings are lost on exit.** Both are `@State` only. *Category:* data integrity. *Recommendation:* persist with stable IDs, and add Canvas save/export. *Command:* `/impeccable harden`.
- **[P0, unverified] Keyboard region ignored at the shell root.** `.ignoresSafeArea()` on the root container. *Category:* adaptivity. *Impact:* the keyboard covers bottom chrome and composers (partly observed in O7). *Command:* `/impeccable adapt`.

### P1 — major

- **[P1] Unsaved work lost on app switching.** No documented preservation policy, so drafts are lost on every round trip. *Command:* `/impeccable harden`.
- **[P1] Fabricated device facts and dead controls.** Status bar, Settings → Battery, About and Storage, and Control Center. *Recommendation:* add a small device-state layer (UIDevice battery monitoring, NWPathMonitor) with unknown, unavailable and simulator states. Prefer the real status bar. Label app-scope controls as app-scope. *Command:* `/impeccable harden`, `/impeccable clarify`.
- **[P1] Fake success states.** Camera, Mail, Messages, Phone calls, Browser, Translate, Shortcuts, Store "Get", and media "Play". *Recommendation:* make each one real (PhotosPicker, AVFoundation, WKWebView, MFMailCompose handoff, and so on) or label it in the concept lab. *Command:* `/impeccable harden`.
- **[P1] Connection state collapses into "Connected".** It doesn't separate available, configured, authenticated, verified, stale and disconnected (brief §11). The Gmail handoff opens YouTube. The OpenAI default model `gpt-5.6-luna` is unverified. *Command:* `/impeccable clarify`.
- **[P1] Search, page scrubbing and switcher dismissal are missing or mislabeled.** (O10, O12, O13.) *Command:* `/impeccable shape` (microinteraction brief), then `/impeccable animate`.
- **[P1] System-edge conflicts.** No edge-gesture deferral. In-app gestures fire only on release (`onEnded`) with no continuous tracking (O11). *Command:* `/impeccable animate`. Proof on hardware is required.
- **[P1] Sample personal data shown unlabeled.** Health metrics, the Wallet balance and card suffix, Contacts, Stocks and Mail inbox. *Command:* `/impeccable clarify`.
- **[P1] Calendar and Weather ignore the real date.** Calendar is hard-coded to July 2026; Weather's "10-DAY" heading sits over 7 rows. *Command:* `/impeccable harden`.
- **[P1] Shell accessibility.** Fixed fonts, unlabeled dock and indicator controls, no accessible unlock, no page actions. *Command:* `/impeccable typeset`, `/impeccable adapt`.
- **[P1] Core use requires developer registration.** Spotify needs each user's own developer client ID (brief §10). *Recommendation:* make it optional BYO, with the official-app handoff as the default. *Command:* `/impeccable clarify`.

### P2 / P3

110 P2 and 39 P3 items live in the detail files. Recurring ones: brand strings ("Indica", "INDICA", "Indica Mobile", "Swipe up for Indica Home"), 8–10 pt fixed captions, unused permission strings (Contacts), a forced boot delay, a boot-gesture race, and the Tips copy describing the wrong gesture.

## Patterns and systemic issues

- **No truth layer.** Device facts, connections and app results are written as literals in views. A shared, observable model for device state, connection state and sample-vs-personal provenance would fix whole classes of P1s at once.
- **Presentation is two independent values plus scattered flags.** `phase` × `overlay` can represent incompatible combinations, and eight call sites write `overlay` directly. A single presentation state machine with guarded transitions is the fix the brief asks for (§8).
- **Apps are rebuilt on every visit.** View-local `@State` is the only store for most apps, and the shell tears views down, so preservation must be designed rather than patched per app.
- **Fixed type in the shell, text styles in the apps.** The shell is the part that ignores Dynamic Type.
- **Copy describes behavior that doesn't exist.** This shows up in the switcher hint, Tips, the demo reset footer, "Play", "Get" and "Connected". Every copy change should ship with its behavior.

## Positive findings

- The project builds on Xcode 27.2 without source changes (warnings not yet reviewed), and CI already runs an unsigned simulator build.
- The calculator engine is extracted and tested (13 checks). Notes and Reminders persist correctly across relaunch (O9).
- Spotify's OAuth implementation is correct PKCE with a state check and Keychain token storage. API keys stay in the Keychain, and there's no logging of secrets anywhere in the source.
- Embedded apps mostly use native `List`, `NavigationStack`, `Form` and segmented controls, which adapt to dark mode and Dynamic Type (O14).
- The baseline has no third-party dependencies.

## Recommended actions

Ordered by the brief's execution sequence (§18). Brand direction (§6) comes before visual changes, but P0 data-safety fixes don't depend on it.

1. **[P0] `/impeccable harden`:** separate sample and personal stores, fix the demo reset, and persist Journal and Canvas.
2. **[P0] `/impeccable adapt`:** remove the drawn island and own the top region by safe area. Fix keyboard avoidance at the shell root.
3. **[P1] `/impeccable shape`:** write a shell interaction brief covering the presentation state machine, preservation policy, search, page scrubbing, switcher dismissal and gesture ownership, as one decision.
4. **[P1] `/impeccable harden`:** add a truthful device-state and connection-state layer, and label sample data.
5. **[P1] `/impeccable clarify`:** make copy match behavior across the catalog, and do the brand string migration once the identity is chosen.
6. **[P1] `/impeccable animate`:** continuous, interruptible shell gestures with velocity, plus a Reduce Motion alternative. Validate on hardware.
7. **[P1] `/impeccable typeset`:** Dynamic Type through the shell, as part of the selected design system.
8. **[P2] `/impeccable polish`:** final pass after each milestone.

You can ask me to run these one at a time, all at once, or in any order you prefer.

Re-run `/impeccable audit` after fixes to see your score improve.
