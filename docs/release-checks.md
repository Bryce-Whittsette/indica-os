# Release checks

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
