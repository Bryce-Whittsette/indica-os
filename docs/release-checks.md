# Release checks

Completed locally: Swift syntax parse, project/plist validation, and calculator regression checks.

Still required before describing the app as a tested iOS release:

- Build the shared scheme using Xcode 26 or newer.
- Run on compact and large iPhone simulators. Check home navigation, app switching, keyboard dismissal, landscape restrictions, and safe areas.
- Check VoiceOver focus, the largest Dynamic Type sizes, Reduce Motion, and Reduce Transparency.
- Create/edit/delete a note and reminder, then relaunch to verify persistence.
- Run Spotify sign-in, cancel sign-in, reconnect, expire an access token, and disconnect. Verify that revocation and failure messages are understandable.
- Verify Keychain save/update/delete with a test credential and confirm no secret is written to logs or preferences.
- Test assistant success, timeout, invalid credential, and empty response using a dedicated API test account.
- Replace the historical screenshot with captures from this build.

Sample-only apps should remain labeled as demonstrations until real implementations and tests replace them.
