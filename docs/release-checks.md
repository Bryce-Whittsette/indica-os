# Release checks

## Unreleased: App-wide audit

Simulator, iOS 27.2, Debug build, scripted touches:

- [x] Calendar: add, edit, all-day, multi-day across three days, delete with its confirmation.
- [x] Clock: an alarm saves (it never had before). A one-time alarm fired on time with a banner while Clock was open, and its switch turned off. Stopwatch runs and laps. A finished timer shows Timer done on return.
- [x] Home: hold to edit, minus removes an app, Done, the removal survives a relaunch, Add Back restores it. Search pill scrub lands on a page with the ruler.
- [x] Switcher: a full swipe closes one card, with the new motion.
- [x] Appearance: with no in-app setting, the app rendered dark after the simulator was set to dark. The simulator can take minutes to apply a change, so the switch itself wasn't timed.
- [x] Reduce Motion: a released page had fully landed in the first frame captured after release. One frame, so this is weak evidence.
- [x] Independent read-only review of this batch. No blockers. It found that a swipe starting on a minus could remove the app, fixed and re-run here.
- [x] Calculator, Canvas, Weather, Reminders, Connections, Notes, Journal, Settings, Contacts and Browser read by eye after the fixes.
- [x] iPhone 17e and iPhone 18 Pro Max: Home, Lock Screen and Control Center, in light.
- [x] Tide, Bloom, Dusk and Graphite wallpapers on the Lock Screen, in dark.

Still required:

- [ ] The flashlight on a physical iPhone, including its on state. The simulator has none, so only the dimmed state has been seen. An App Store upload may also want a camera usage string for it.
- [ ] Play Test Sound, audibly.
- [ ] A full pass for other simulated Settings rows. Settings' opening footer covers them in general, but only the ones named in the changelog carry their own note.
- [ ] Calculator results after the layout change, beyond the 13 engine checks.
- [ ] Timed multi-day events in the Calendar list. All-day ones were run; the bare-time fix was only read in source.

## Unreleased: Logo

- [x] Build: the asset catalog compiles the mark and wordmark layers and three icon variants.
- [x] Exports: the app icons, avatar and social preview are opaque PNGs at their stated sizes, read back with `sips`.
- [x] Masters read by eye from 16 to 96 px in color, dark and one color. This caught the bracket reading as an underscore at small sizes, which set the 28 pt rule.
- [x] Simulator, iPhone 18 Pro: the iOS Home Screen shows the new icon. The boot screen shows the mark and wordmark in light and dark, seen by holding it in a temporary build that wasn't committed. In normal use it leaves as soon as it appears, so a launch is mostly the plain ground color.
- [ ] iOS's dark and tinted Home Screen icon styles, which need the system setting.
- [ ] The icon on a physical iPhone.
- [ ] A trademark search on the marks and the name. None has been run.

## Unreleased: Instrument

Source-level, also in CI:

- [x] Calculator, pager physics and local logic checks pass.
- [x] Token contrast passes in both appearances: 4.5:1 for text, 3:1 for marks and outlines (`Tests/InstrumentTokenTests.swift`).

Simulator, iOS 27.2, Debug build. Screenshots read by eye, with scripted touches where noted:

- [x] iPhone 18 Pro, light and dark: Home, Lock Screen, Calendar, Control Center. Notifications and the switcher in light only.
- [x] iPhone 17e, light: Home, Lock Screen, Calendar, Control Center.
- [x] iPhone 17e at the largest non-accessibility and largest accessibility text sizes: Home and Lock Screen hold their layout at their cap, and Calendar days stay on one line, without overlap.
- [x] All four Home pages' icons drawn from the SVG masters, including monograms. The ruler's signal tick moves as pages settle.
- [x] Icon appearances: Light, Dark, Clear and Tinted on Home, and their Settings previews. Compact density. Aura and Daylight wallpapers on Home, Aura on the Lock Screen.
- [x] Scripted touches: page swipe, opening a dock app, Search opening from a tap on the pill, swipe up to unlock, the app bar's Recents button, leaving the switcher.
- [x] Independent read-only review of the branch. No blockers. Its findings were fixed here.
- [x] Scripted touches: a pull from y=30 opens Notifications on the left and Control Center on the right. Before the fix, gesture logging showed touches above the safe area never reached the shell's gesture. It's from a fresh launch each time, since a quick second swipe goes to iOS by design.

Still required:

- [ ] Everything on a physical iPhone: how it looks and feels, hairline weight, and the pull from the status bar with real edge deferral.
- [ ] Press feedback and wiggle judged by feel on a physical iPhone.
- [ ] iPhone 18 Pro Max and the iOS 17 runtime, including SVG template rendering there.
- [ ] VoiceOver walkthrough of the ledger, ruler, dock, Calendar and Control Center, including the escape gesture and adjustable sliders. These are source-reviewed and built, not run with VoiceOver. Reduce Motion across the shell.
- [ ] Whether iOS's home bar stays visible on Home and the Lock Screen on a physical iPhone, now that the shell doesn't draw its own.

## v0.3.0 (2026-11-03)

Simulator, iPhone 18 Pro, iOS 27.2, scripted touches, Debug build:

- [x] Pager physics checks pass (source-level, also in CI).
- [x] Slow drag follows the finger; a short release returns to the page; a flick moves one page and doesn't open the icon under the finger; a later tap opens the app.
- [x] Search pill scrub stops between pages under the finger and settles on the nearest page.
- [x] Leaving an app returns to the same Home Screen page.
- [x] Switcher: partial and full swipes from the card's lower area stay in the switcher; a full swipe closes that card only.
- [x] Notes: a new note typed and cleared leaves no blank note.
- [x] Calendar: add a timed event; it shows on the day, in the Up Next widget and after relaunch.
- [x] Clock: world clocks match their zones. A 1-minute timer delivered its notification while outside the app, and the prompt appeared when starting it.
- [x] Files: lists real contents; a text file previews; an invalid name shows an error; a folder is created on disk; an import from On My iPhone copies under a new name without overwriting.
- [x] Voice Memos: first use asks for the microphone; records from the Mac's input with live levels; saves; survives relaunch; playback progress moves; delete removes the file. Nobody listened to the audio.
- [x] Local logic checks pass, including time zones, daylight saving and state round-trips (source-level, also in CI).
- [x] Rename: iOS Home Screen shows Swift UI. An old-name sample note updates once, and a personal note with the same words stays as written.

Still required:

- [ ] Alarm firing with the app closed, and repeating alarms.
- [ ] Timer returning to the app after it finishes; relaunching mid-timer; Stopwatch and Alarm tabs in use.
- [ ] Calendar edit, delete, all-day and multi-day in the app. The date rules have logic checks only.
- [ ] Files: rename, delete, share, nested folders, large imports. Voice Memos: rename, share, denied access, a phone call interrupting, audible playback, and how long capture takes to start on a real iPhone.
- [x] Voice Memos: a recording stopped normally saves the audio file's real duration (15.65 s in both).
- [ ] Review fixes that have only been built, not run: Voice Memos interruption keeps the recording and doesn't crash; alarms and timers saved with notifications off get scheduled once allowed; no stray notification after a quick Cancel, Pause or delete; pager recovers when an app opens mid-gesture; VoiceOver scroll direction on the pager and switcher.
- [ ] Two flicks within 220 ms in the switcher. Scripted touches can't send them that fast, so this rests on source review.
- [ ] Edge deferral: the §21 repeated-gesture run on a physical iPhone (`docs/interactions.md`). The simulator's scripted edge swipe can't test it.
- [ ] A system-cancelled gesture on the pager, pill and switcher, on a physical iPhone.
- [ ] Catching a settle mid-flight, and how all of it feels and how smooth it is, on a physical iPhone.
- [ ] Frame pacing on a physical iPhone. The simulator's rate isn't evidence either way.
- [ ] Reduce Motion and VoiceOver walkthroughs of the pager.

## v0.2.0 (2026-11-03)

Done (simulator unless stated):

- [x] Shared scheme builds with Xcode 27.2 (local) and Xcode 26 (CI).
- [x] Calculator regression checks: 13/13.
- [x] iPhone 18 Pro and iPhone 17e: safe areas and camera cutout (device-masked captures), keyboard with text fields in Notes, Journal, Reminders and Messages.
- [x] Notes, reminders and journal entries: create, then relaunch to confirm they persist. Canvas strokes persist with their own colors.
- [x] Remove Sample Content keeps personal content, including after relaunch. Migration of an existing install. Unreadable data is backed up.
- [x] Search finds apps and notes and opens results.
- [x] Fresh screenshots from this build (`docs/images/v0.2.0/`).
- [x] Independent review of the data-safety and cutout milestone (`docs/audit/README.md`).

Still required:

- [ ] Physical iPhone: host-app exit with in-app gestures, the real cutout, battery and network values, `tel:` and `mailto:` handoffs.
- [ ] iPhone 18 Pro Max simulator and the iOS 17 runtime.
- [ ] VoiceOver walkthrough, largest Dynamic Type across the shell, Reduce Motion and Reduce Transparency.
- [ ] Spotify sign-in, cancel, reconnect, token expiry and disconnect against a real account.
- [ ] Keychain save/update/delete with a test credential; confirm no secret reaches logs or preferences.
- [ ] Assistant success, timeout, invalid credential and empty response with a dedicated API test account. Re-verify the default model identifiers.
- [ ] Startup, frame pacing and memory measurements.

Concept demos stay labeled until real implementations and tests replace them.
