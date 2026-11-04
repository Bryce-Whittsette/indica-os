# Shell audit: Swift UI (IndicaOS) against master-brief sections 8, 12, 20, 21, 22, 23

Scope: `IndicaOS/SystemShell.swift` (SS), `SystemModels.swift` (SM), `ContentView.swift` (CV), `IndicaOSApp.swift`, `Haptics.swift`, `Info.plist`. Cross-references to `CoreApps.swift`, `SettingsSystem.swift`, `EverydayApps.swift`, `Connections.swift` only where they show how the shell is used. Source read only; nothing was built or run. Deployment target is iOS 17.0 (`IndicaOS.xcodeproj/project.pbxproj:189,227`). Anything that depends on runtime behaviour is labelled **unverified**.

Severity: P0 = crash, data loss, broken core navigation, or physical-cutout collision. P1 = fake or misleading state, major accessibility or platform violation. P2 = minor. P3 = polish.

## Top findings (ranked)

1. P0 (unverified on device): the app draws its own black Dynamic Island pill and a 270x88 expanded island with a fixed "LIVE" badge and 64% progress bar. It is placed by constants, not safe-area geometry, so it can collide with the real cutout (SS:266-446, SS:231-264).
2. P1: Search is fake. The "Search" pill only jumps to page 1, which holds a non-interactive "Search apps and actions" row. There is no query field and no results (SS:632-657, SS:818-833).
3. P1: the switcher says "Swipe up on a card to close" but has no swipe-dismiss. It has only a nested small X button. The cards are fake skeleton previews, not app snapshots (SS:1420, SS:1394-1404, SS:1433-1481).
4. P1: every app is destroyed when you leave it. `phaseContent` renders one branch, so drafts and navigation state are lost on every home or switcher round trip (SS:37-56, SS:1229-1250). This is unsaved-input loss and contradicts brief section 8 ("App switching") and section 12.
5. P1 (unverified on hardware): there is no system-edge deferral and no `persistentSystemOverlays`. The shell draws its own bottom home-indicator capsules, which will sit under or over the real iOS indicator. The real bottom-edge swipe will exit the host app (SS:23, SS:72-93, SS:1905-1925, IndicaOSApp.swift:6).
6. P1: the status bar and device facts are fabricated: always-full signal and Wi-Fi, a fixed `battery.100percent` glyph (Settings says 82%), and the real status bar is hidden. There is no `UIDevice` or `NWPathMonitor` code anywhere (SS:231-264, SS:34, SettingsSystem.swift:210).
7. P1: Control Center has dead or mislabeled controls. Cellular is `.constant(true)`, the Flashlight, Timer and Screen controls and the transport buttons do nothing, and brightness and volume are never applied anywhere (SS:1526, 1537-1547, 1558, 1564-1565, 1554-1555).
8. P1 (accessibility): Dynamic Type does not reach the shell, because every shell font is a fixed size (69 occurrences). Dock icons and home indicators have no accessible names, and the lock screen has no accessible unlock. The Reduce Motion path may be ineffective (SS, CV:17-21).
9. P1: the page-scrubbing interaction required by brief section 20 does not exist. There are no page-indicator semantics, no accessible next/previous page actions, and no announcements.
10. P0 (unverified): `.ignoresSafeArea()` at the shell root (SS:21) also ignores the keyboard region. The keyboard may cover the bottom nav bar and bottom-anchored composers such as Messages. Confirm on device or in the simulator.

---

## 1. Startup / boot

**Current**
- `IndicaSystem.phase` starts at `.booting` (SM:434). `SystemShell.onAppear` starts a `Task.sleep(for: .seconds(1.25))`, then `finishBoot()` sets `.locked` (SS:24-32, SM:634-638). This is a mandatory artificial delay.
- `BootScreen` shows a black screen, a brand mark, and "INDICA" with a breathing animation (SS:96-121).
- `init()` honours launch arguments `--control`, `--notifications`, `--home` and `--app=` for test harnesses only (SM:617-631).
- There is no restore of phase, `appHistory`, home page, overlay or scroll. No `scenePhase` or `@SceneStorage` is used anywhere. Every cold launch ends at the lock screen. `appHistory` (SM:549) and `notifications` (SM:550) are in memory only, so recent apps vanish on relaunch.
- Persisted settings and content (see item 12) are loaded in `init()`.

**Meets brief?** No. There is a forced 1.25 s delay and no state restore.

**Defects**
- P2 SS:29 (SM:634): the 1.25 s delay is mandatory and not skippable. The sleep Task is not stored or cancelled.
- P2 SS:29 with SS:82-91: race. The root gesture is active during `.booting`. A swipe up from the bottom calls `default: goHome()`, then `finishBoot()` fires 1.25 s later and forces `.locked`, because `finishBoot()` has no `phase == .booting` guard (SM:634). A top-edge drag during boot can also present Control Center over the boot screen (SS:78-81).
- P2 SM:597-632: no restore or recovery path. Launch-argument branches are untested paths shipped in the production binary.
- P3 SS:109, Info.plist:8: brand strings still say "INDICA" and "Indica OS", against the "Swift UI" rename.
- P3 SS:116-118: an infinite breathing animation runs on the boot screen. It is not paused under Reduce Motion (see item 13).

---

## 2. Presentation state model

**Current**: two independent published properties plus scattered flags.
- **Single source of truth, partial**: `phase` (SM:434, `.booting/.locked/.home/.app(BuiltInApp)/.switcher`) and `overlay` (SM:435, `controlCenter/notifications/wallpaper/lockCustomization`). These are two orthogonal values, so the product type `phase x overlay` can represent incompatible pairs. Examples: `(.booting, .controlCenter)`, `(.home, .lockCustomization)`, `(.switcher, .wallpaper)`.
- **Overlay assignments bypass the model**: views write `system.overlay = ...` directly at SS:80, SS:533, SS:1501, SS:1689, SS:1735, SS:1780, SS:1877 and SettingsSystem.swift:879. No transition function guards them.
- **Methods** `unlock/lock/open/goHome/showSwitcher` (SM:640-686) each clear `overlay`. `lock()` also clears `isEditingHome`. `open()` and `goHome()` do not clear `isEditingHome`.
- **Other presentation-related flags in the store**: `isEditingHome` (SM:542), `appHistory` (SM:549), `isFocusEnabled` (SM:543), `wifiEnabled`, `bluetoothEnabled`, `airplaneMode` (SM:544-546), `brightness`, `volume` (SM:547-548).
- **View-local `@State`**:
  - `SystemShell.didStart` (SS:5)
  - `BootScreen.breathing` (SS:97)
  - `IndicaWallpaper.drift` (SS:165)
  - `DynamicIslandControl.isExpanded` and `isPointerInside` (SS:268-269). This is per instance, and a new instance is created for every phase and overlay, so island state resets and duplicates.
  - `LockScreen.dragOffset` (SS:450)
  - `HomeScreen.page` (SS:579). The current page is lost on every leave.
  - `AppIcon.wiggle` (SS:861)
  - `HybridAppNavigationBar.dragLift` and `isHintVisible` (SS:1254-1255)
- **App-owned sheets and navigation** live in each app's own `@State` and are outside the shell model: `.sheet` at CoreApps.swift:189, 537, 774, 1188; EverydayApps.swift:457, 879; Connections.swift:1012, 1015, 1458, plus per-app `NavigationStack`s. System sheets present above the SwiftUI shell, so a shell overlay presented while an app sheet is up would render behind it (**unverified**).

**Meets brief?** Partly. `phase` is a good enum, but `overlay` is a separate optional and there are no valid-transition rules or recovery.

**Defects**
- P1 SM:434-435 and the direct writes listed above: incompatible screens are representable and some are reachable. A drag in `.booting` or `.switcher` opens Control Center or Notifications. `lockCustomization` is only ever set from the lock screen but is not constrained to it.
- P2 SM:657-674: `isEditingHome` survives `open()` and `goHome()`. Entering an app via Control Center camera, a notification or the lock-screen camera while editing leaves the home screen wiggling on return.
- P2 SS:24-32 vs SM:634: `finishBoot()` can overwrite a later phase (see item 1).
- P2 `SystemOverlay.wallpaper` has two entry points (lock customization and Settings, SettingsSystem.swift:879). "Done" always sets `overlay = nil`, so returning from Wallpaper to Lock Customization is not possible. In practice the customization sheet disappears after the picker.
- P3 SS:15-19: a single `if let overlay` swaps overlays without cross-fade logic. Back-to-back overlays use one `.transition`.

---

## 3. Lock screen concept

**Current** (`LockScreen`, SS:448-538)
- Unlock: `DragGesture(minimumDistance: 10)` on the whole lock VStack (SS:517-530). `.onChanged` offsets content only upward (`min(0, translation.height)`). `.onEnded` unlocks when `translation.height < -70` using translation only, no velocity. It then springs `dragOffset` back to 0 whether or not it unlocked. A second path is the root gesture: bottom 172 pt and drag up more than 46 pt while `.locked` also calls `unlock()` (SS:82-87). Both are active at once.
- Cancellation is implicit: releasing before 70 pt springs the content back.
- Customization: `.onLongPressGesture(minimumDuration: 0.55)` presents `.lockCustomization` (SS:531-535). There is no visual progress and no accessibility alternative.
- Flashlight button: `LockActionButton(symbol: "flashlight.on.fill") {}` has an empty action (SS:496).
- Camera button: `system.unlock()`, then a `Task.sleep(320 ms)`, then `system.open(.camera)` (SS:502-508). It is uncancellable.
- `HomeIndicator(color:)` is a `Button` with no action on the lock screen (SS:512, SS:1905-1925), so it is a dead hit target.
- Widgets (SS:474-482): hardcoded "72° Brooklyn", "5,804 steps", "2:30 Review". These are sample values with no label and no data source. The customize preview hardcodes "Friday, July 17" and "9:41" (SS:1854-1857).
- Notifications: `system.notifications.prefix(2)` rendered as `NotificationCard(compact:)`. They are sample items (SM:550-554), not interactive on the lock screen, and not filtered by `notificationPreviews` or `disabledNotificationApps`.
- Clock: `TimelineView(.periodic by 1s)` (SS:463). Date and time use the device clock.
- Copy "Swipe up to open" (SS:498). Nothing states that this is a concept and not device security.

**Meets brief?** Partly. Unlock and cancel work for touch. Accessibility activation, the flashlight, and disclosure are missing.

**Defects**
- P1 SS:496: the flashlight button does nothing. It is not wired to `AVCaptureDevice` torch, and it is not hidden or marked unavailable.
- P1 SS:474-482, SS:550-554, SS:1854-1857: sample widgets and notifications are presented as live data (weather, steps, calendar, message from "Maya") with no "Sample" label. `NotificationCard` is not marked as app-local either.
- P1 (accessibility) SS:448-538: there is no accessible unlock. The only unlock paths are a swipe gesture and the dead `HomeIndicator` button. VoiceOver users have no control that unlocks. There is no `accessibilityAction`, no `accessibilityAdjustableAction`, and the long-press customization has no alternative.
- P2 SS:517-530 + SS:72-93: double unlock. A swipe-up that starts in the bottom 172 pt and exceeds 70 pt triggers both the lock-screen drag and the root gesture. `unlock()` runs twice, with a double haptic and animation.
- P2 SS:502-508: the camera path is a delay chain. Two quick taps queue two `open(.camera)`. A user who navigates during the 320 ms still gets the camera.
- P2 SS:516 + SS:522-529: unlock uses distance only (-70 pt), no velocity. The home screen is not revealed under the lock content as it moves. A phase swap cross-fades instead.
- P2 SS:512: dead `HomeIndicator` button with no label.
- P3 SS:463: the lock clock redraws every second for minute precision.
- P3 SS:498: no disclosure that the lock is a concept and not device security (brief section 8 "Lock concept").

---

## 4. Launcher

**Current** (`HomeScreen`, SS:577-730)
- Pages: `homePages` has 4 pages of 16, 16, 10 and 6 icons (SM:585-593). It renders a `TabView(.page(indexDisplayMode: .never))` (SS:591-630). Page 0 has `HomeWidgetRow` (sample weather and "Design review", SS:758-816). Page 1 has `SearchWidget`. Pages 2 and 3 have `LibraryHeader` ("App Library / Utilities and extras", SS:835-852). Those are just more icon pages, not an app library.
- Icon grid: `LazyVGrid` with 4 columns, or 5 when `homeLayoutDensity == .compact` (SS:605-611, SS:738). `HomeLayoutMetrics` uses `size.height < 860` as a compact test. Icon sizes are 49-60 pt.
- Dock: 4 apps (phone, messages, browser, spotify) in a glass capsule (SS:660-696). `showsLabel: false`, no wiggle, no editing.
- Page indicator + Search pill: a single `Button` (SS:632-657) containing a 9 pt icon, a 10 pt "Search"/"Home" label, and capsule dots. Tap sets `page = (page == 1) ? 0 : 1` (SS:635). So on pages 2 and 3, "Search" jumps to page 1. Dots are not individually interactive.
- Search: `SearchWidget` (SS:818-833) is an HStack with a magnifier, placeholder text and a mic icon. It has no tap handler, no field and no results.
- Page scrubbing: not implemented (no `DragGesture` or long-press on the pill). Native `UIPageControl.allowsContinuousInteraction` is not used.
- Home editing: `.onLongPressGesture(minimumDuration: 0.52)` on the entire `HomeScreen` VStack toggles `isEditingHome` (SS:705-710) with a rigid haptic. Editing shows a "minus" badge (SS:874-882), a ±1.5° wiggle (SS:896-905) and a "Done" button (SS:711-726). The minus is inert. There is no reorder, no removal, no widget editing, and no page management.
- App-icon long press: no `.contextMenu` on `AppIcon`. A long press on the icon itself likely loses to the `Button` (**unverified**), so editing is probably entered from blank areas.
- Accessibility page actions: none (no `accessibilityAdjustableAction`, no `accessibilityValue` such as "page 2 of 4", no announcement on page change).

**Meets brief?** No for the Search pill, scrubbing and editing. Partly for the grid and dock.

**Defects**
- P1 SS:632-657, SS:818-833: "Search" is a mislabelled page toggle. Search entry, results, empty and no-results states, clear and keyboard dismissal are all absent (see item 11). The magnifier and mic imply capability that does not exist.
- P1 SS:632-657: no hold-and-drag page scrubbing, no tap-versus-hold separation, no clamping or release behaviour, no accessible previous/next actions, no page announcement. Brief section 20 and section 8 ("Page indicator/Search pill") are not met.
- P1 SS:661-670: dock icons use `showsLabel: false` and have no `accessibilityLabel`. With `showAppLabels == false` the whole grid is unnamed as well. VoiceOver cannot identify dock apps (SS:884).
- P2 SS:705-710: the long press toggles, so a second long press exits editing. Editing starts from any blank region, including over the dock and status bar. The Done button sits at a fixed `.padding(.top, 64)` (SS:723) and is not tied to the status bar or safe area. Editing has no accessibility entry point.
- P2 SS:874-882: the minus badge is a static decoration with no action. The dock does not participate. Wiggle (`repeatForever`) is applied to every icon with no Reduce Motion exception (SS:896-905). `wiggle = false` on exit may leave the repeat animation attached (**unverified**).
- P2 SS:593-603: LibraryHeader titled "App Library" on pages that are plain icon pages. The widgets on page 0 are sample data (SS:765-797, "BROOKLYN", "72°", "Design review").
- P2 SS:702-704: a selection haptic fires on every `page` change, including programmatic changes from the pill.
- P3 SS:636-657: the pill text is 9-10 pt fixed, not a text style, with a 28 pt tall target.
- P3 SS:579: `page` is `@State` and resets to 0 whenever HomeScreen is rebuilt after an app round trip. The user returns to page 0, not the page they left.

---

## 5. App opening / closing / return

**Current**
- `open(_:)` (SM:657-666): selection haptic `.light`, moves the app to the front of `appHistory` (cap 6, dedupes), then `withAnimation(.spring(0.48, 0.86)) { overlay = nil; phase = .app(app) }`.
- `phaseContent` (SS:37-56): `.home` transitions with `.scale(0.94)+opacity`, `.app` with `.scale(0.9, anchor: .center)+opacity`. Spatial origin is always the screen centre. There is no `matchedGeometryEffect` and no icon-origin tracking.
- `AppHost` (SS:1229-1250): status bar, `BuiltInAppView`, then `HybridAppNavigationBar`. A new `BuiltInAppView(app:)` is built from scratch each time.
- Return: `goHome()` (SM:668-674), `showSwitcher()` (SM:676-686), or opening another app from the switcher or a notification.
- Launching the same app twice: `phase` is a single enum value, so `.app(a)` set twice is a no-op other than a haptic and `appHistory` churn. There is no duplicate presentation at shell level. App-level sheets are per app and are discarded with the app.
- State preservation: none. `phaseContent` renders only the current phase, so every `@State` in the app is dropped on leave. This includes the Messages draft (CoreApps.swift:277), the Mail composer `bodyText` (CoreApps.swift:785) and `NavigationStack` position. Notes, reminders and messages are persisted at the store level (SM:555-563); unsaved text fields are not. No documented preservation policy exists.

**Meets brief?** No. No spatial origin and no preservation.

**Defects**
- P1 SS:37-56 + SS:1229-1250: all view state is discarded on every home, switcher or notification round trip. Unsaved drafts (Messages, Mail), tab selection, scroll position and navigation depth are lost. No policy is documented.
- P1 SS:1433-1481 + SM:549: `appHistory` implies a running app list, but nothing is suspended. Cards in the switcher are fabricated skeletons, so the "Recent Apps" model is misleading (see item 6).
- P2 SS:48-51: opening and returning use a generic centre scale with no icon-origin or return path, contrary to brief section 8 "Transitions".
- P2 SS:502-508: delay-chained camera open (see item 3).
- P2 SM:661: `prefix(6)` silently evicts the oldest recent.
- P2 SM:657-666: switching directly from `.app(a)` to `.app(b)` re-uses `AppHost`, so the new app appears without the open transition (**unverified**).
- P3 rapid-tap behaviour during transitions (double icon taps, tap during removal transition) is **unverified**.

---

## 6. App switcher

**Current** (`AppSwitcher`, SS:1369-1431)
- Layout: status bar, `Spacer(minLength: 42)`, then a horizontal `ScrollView` of cards with `HStack(spacing: 16)` and `.padding(.horizontal, 48)`. Each card is a `Button` with a fixed `frame(width: 292, height: 535)` and `PressableButtonStyle(scale: 0.98)`. Card content is the app mark, name and an `AppPreviewCard` (a placeholder icon tile plus 4 skeleton rows, SS:1433-1481). No snapshot is taken.
- Close affordance: an `xmark.circle.fill` `Button` nested inside the card `Button` label (SS:1394-1401). It removes the app from `appHistory` with default `withAnimation`. No label or haptic.
- Copy: "Swipe up on a card to close" (SS:1420).
- Swipe-to-dismiss: none (no `DragGesture` on cards).
- Home: `HomeIndicator { goHome() }` tap (SS:1424), plus the root bottom-swipe.
- No paging or snapping (`scrollTargetBehavior` not used). Empty state is `ContentUnavailableView("No Recent Apps")` (SS:1379).

**Meets brief?** No. Brief section 20 names this exact defect.

**Defects**
- P1 SS:1420: instruction copy describes a gesture that does not exist.
- P1 SS:1433-1481: previews are generated skeletons, not the app's real or last state. Cards do not reflect drafts or navigation.
- P2 SS:1394-1401: the close button is a nested `Button` in a `Button` (taps may trigger the outer card, **unverified**). It is about 17 pt, has no `accessibilityLabel`, and has no haptic. Closing from the switcher only edits history (state was already destroyed).
- P2 SS:1407: fixed 292x535 card size ignores screen size and Dynamic Type. On shorter phones, 535 + status 63 + Spacer 42 + copy + indicator may not fit (**unverified**).
- P2: no cancellation, no velocity, no partial-dismiss restore, no card ordering or restore semantics (brief section 20 test list).
- P3 SS:1385-1387: opening a card reorders history (MRU) while the visible order changes.
- P3 SS:1395: `withAnimation { }` default animation, not an interruptible tuned spring.

---

## 7. Gestures

**Current**
- The root `simultaneousGesture(DragGesture(minimumDistance: 24))` on the whole shell ZStack (SS:22-23, SS:72-93) acts only in `onEnded`, using start location and final translation. Top zone (`startLocation.y < 82`) and drag down more than 70 pt opens Control Center if `x > 0.53 * width`, otherwise Notifications. Bottom zone (`y > height - 172`) and drag up more than 46 pt: `.app` does nothing, `.locked` unlocks, everything else calls `goHome()`.
- In apps, the internal home gesture lives on `HybridAppNavigationBar` (SS:1344-1357), a pill bar about 70 pt tall (plus 18 pt bottom padding). It is a `highPriorityGesture(DragGesture(minimumDistance: 7))`. `onChanged` sets `dragLift` to at most 18 pt of upward rubber-band (translation x 0.22). `onEnded` goes home at translation of -30 pt or less. The bar also contains Back, Home (the capsule) and Recent Apps buttons.
- Not attached to a tiny indicator view: in non-app phases the zone is the bottom 172 pt. In apps the zone is the nav bar only.
- No `UIHostingController` subclass (none exists; `IndicaOSApp` is a plain `WindowGroup`, IndicaOSApp.swift:6). No `preferredScreenEdgesDeferringSystemGestures`, `defersSystemGestures(on:)` or `persistentSystemOverlays`. `.statusBarHidden(true)` only (SS:34). The real home indicator is not hidden.
- Velocity: not used anywhere (no `predictedEndTranslation` or velocity).
- Interruptible springs: SwiftUI springs retarget by default, but all drags are threshold-on-release; none drive a continuous interactive transition.
- Reduce Motion: `CV:17-21` clears `transaction.animation` when either the custom or the system flag is on (see item 13).
- Scroll conflicts: the root gesture is simultaneous and `onEnded`-only, so it does not block child `ScrollView`/`List`/`TextField`. It can misfire after scroll drags that start in the top 82 pt (the app content starts at about y = 63) or the bottom 172 pt, for example a pull-down starting on a large navigation title or a flick starting at the bottom of a list (**unverified**).

**Meets brief?** No for system-edge coordination and continuous tracking. Partly for scroll conflicts.

**Defects**
- P1 SS:34, SS:1905-1925, SS:1318-1325, IndicaOSApp.swift:6: no system-edge deferral. The app draws its own 134x5 and 106x5 home capsules near the bottom edge, which collide with the real iOS home indicator on device. A swipe from the very bottom edge exits the host app. Brief section 21 requires deferral through the hosting controller and physical-device testing. Not proven here (**unverified**).
- P0 (unverified) SS:21: `.ignoresSafeArea()` with the default regions includes `.keyboard`, so keyboard avoidance is likely disabled for the whole shell. The keyboard may cover the bottom nav bar (and with it the only internal home/switcher gesture while typing) and bottom-anchored composers such as the Messages draft field. Confirm in the simulator.
- P1 SS:72-93: Control Center, Notifications and unlock/home fire only on release, with no continuous finger tracking, no preview of the panel under the finger, and no velocity.
- P1 SS:82-91: in `.app` there is no whole-screen swipe-home gesture (`case .app: break`), only the nav bar. Control Center over an app cannot be dismissed with a swipe up, only by tapping the scrim.
- P2 SS:1344-1357: the visible bar moves at most 18 pt and the app does not move or shrink with the finger.
- P2 SS:1344: a `highPriorityGesture` with `minimumDistance: 7` over three Buttons can steal taps that wobble more than 7 pt.
- P2 SS:75-76: hard-coded zones (82 pt, 172 pt) not derived from safe-area insets.
- P2 SS:88-90: swipe-up on `.home` and `.switcher` triggers `goHome()` again, giving a redundant haptic and animation.
- P3 no velocity-based reversal or interruption handling. Reduce Motion path **unverified**.

---

## 8. Status bar & device facts

**Current** (`SystemStatusBar`, SS:231-264)
- The real status bar is hidden with `.statusBarHidden(true)` (SS:34). A custom one is drawn: a clock, a centred `DynamicIslandControl` and an icon cluster.
- Time: `TimelineView(.periodic(from: .now, by: 30))` with `.dateTime.hour(.defaultDigits(amPM: .omitted)).minute(.twoDigits)` (SS:237-241). It is real device time; AM/PM is dropped.
- Signal, Wi-Fi and battery: three static SF Symbols `cellularbars`, `wifi`, `battery.100percent` (SS:252-256). They are not driven by any state.
- No `UIDevice` battery monitoring, no `NWPathMonitor`, no `CTCarrier` anywhere in the repo (grep).
- Carrier string: none in the status bar. Settings shows "Example Network" for Wi-Fi (SettingsSystem.swift:202, 370) and a hardcoded battery "82%" (SettingsSystem.swift:210). The Wi-Fi settings footer says Wi-Fi is simulated (SettingsSystem.swift:362).
- `wifiEnabled`, `airplaneMode`, `bluetoothEnabled`, `lowPowerMode` and `batteryPercentage` do not affect the bar.

**Meets brief?** No. Brief section 22.

**Defects**
- P1 SS:252-256: signal, Wi-Fi and battery are fabricated constants. Airplane Mode in Control Center does not change them.
- P1 SS:255 vs SettingsSystem.swift:210: two contradictory battery values (100% in the bar, 82% in Settings).
- P1 SS:34: the genuine system status bar (accurate battery, signal, connectivity and carrier) is hidden and replaced by fiction. Brief section 22 prefers the genuine system bar or a neutral state.
- P1 SS: no shared device-state layer. Brief section 22 requires `UIDevice` battery monitoring and `NWPathMonitor`, explicit unknown, unavailable and simulator states, and refresh on foregrounding.
- P2 SS:238: AM/PM omitted. `use24HourTime` is stored in Settings but unused here.
- P3 SS:237: 30-second periodic updates can show a stale minute for up to 30 s.
- P3 SS:239,257: fixed 15/12 pt fonts.

---

## 9. Dynamic Island / safe areas

**Current**
- The app draws its own island: `DynamicIslandControl` (SS:266-446). The compact shape is a 116x34 black rounded rectangle (SS:286) with a fake camera dot and pill (SS:371-382). Expanded is 270x88, offset down 27 pt (SS:315-319), with an app title, "System activity", a "LIVE" badge (SS:418-424) and a progress bar fixed at 64% (SS:438). Interactions: tap toggles, long press 0.42 s expands, pointer hover expands (SS:322-352).
- It is placed inside an `HStack` between two `Spacer`s (SS:243-250), so its x-position depends on the clock and icon widths. It is not centred on the screen.
- The island is repeated on every screen that includes `SystemStatusBar`: lock, home, apps, switcher, and again on top in the Control Center and Notification overlays, each with separate `@State`.
- Safe areas: `.ignoresSafeArea()` on the shell root (SS:21), on `AppHost`'s background (SS:1236), and `GeometryReader` sizes are therefore full-screen. There are no `safeAreaInsets`, `safeAreaInset` or `safeAreaPadding` uses. The top region is a fixed `frame(height: 58)` plus `.padding(.top, 5)` (SS:261-262). Other fixed offsets: `.padding(.top, 64)` (SS:723), `Spacer(minLength: 42)` (SS:1376), bottom paddings 7/8/9/18 (SS:700, SS:1428, SS:513, SS:1341), top-gesture zone 82 and bottom zone 172 (SS:75-76).
- No ActivityKit. "LIVE" and progress are decorative.

**Meets brief?** No. Brief section 23.

**Defects**
- P0 (unverified on device) SS:286, SS:243-250, SS:261-262: a second pretend island is drawn near the physical cutout. Its centre is at about y = 34, while real islands sit near y = 11-48. It is offset from true centre by half the difference between clock and icon-cluster widths, roughly 7 pt left (computed, not measured). Brief section 23 forbids a pretend hardware island that collides with the real one.
- P0 (unverified) SS:315-319, SS:388-445: the expanded island spans about y 17-105 and x 61-331 on a 393 pt screen. The title and subtitle (x roughly 124-250) fall behind the real cutout area in the top 30 pt. Expanded bounds, drawn bounds and hit area also differ: the gesture is attached to the 116x34 base view (SS:321), while the 270x88 shape is an overlay (**unverified** hit testing).
- P1 SS:418-424, SS:438: the generic "LIVE" label and the fixed 64% progress bar are not tied to any activity. Brief section 23 forbids both.
- P1 SS:271-282, SS:411: "System activity" and `activeTitle` ("Indica OS", "Indica Locked", "App Switcher") are static strings for a non-activity.
- P1 SS:21, SS:261-262, SS:723, SS:75-76: layout is not derived from safe-area insets. Missing or duplicated padding on devices with different top insets (compact and iPhone 18 Pro profiles) is likely. No ownership of the top, content and bottom regions.
- P1 SS:21: `ignoresSafeArea()` covers the keyboard as well (see item 7).
- P2 SS:243-250 and overlays: duplicated island instances across overlay and underlying bar. State does not persist across phase changes.
- P2 SS:334-352, SS:353-355: pointer-hover behaviour is irrelevant on iPhone. The accessibility hint advertises "Tap or press and hold to expand" for a decorative control.
- P2 SS:1236, SS:1239: `AppHost` has a separate full-bleed `systemBackground` plus status bar; foreground `.primary`; no top inset handling for app content.

---

## 10. Control Center / notification panels

**Current** (SS:1491-1678 Control Center, SS:1680-1771 Notifications)

| Control | Binding / action | Scope it implies | Real effect |
|---|---|---|---|
| Airplane (SS:1525) | `system.airplaneMode` | device airplane mode | Memory only, not persisted (SM:546). Not read by the status bar. |
| Cellular (SS:1526) | `.constant(true)` | cellular data | Nothing. Cannot change state. |
| Wi-Fi (SS:1529) | `system.wifiEnabled` | device Wi-Fi | Memory only. Used for the Settings subtitle. |
| "Bluetooth" (SS:1530, glyph `bolt.horizontal.fill`) | `system.bluetoothEnabled` | device Bluetooth | Memory only. Glyph is not the Bluetooth symbol. |
| "Quiet Hours" tile + back/play/forward (SS:1537-1547) | none | now-playing / media | Plain `Image`s. Not buttons, no state. |
| Brightness (SS:1554) | `system.brightness` | screen brightness | Never applied (no `UIScreen` brightness, no dimming). Only Settings reads it. |
| Volume (SS:1555) | `system.volume` | device volume | Never applied to audio. |
| Focus (SS:1557) | `system.isFocusEnabled` | iOS Focus | In-app flag only (EverydayApps.swift:618 also sets it). |
| "Screen" (SS:1558) | no binding | screen mirroring/lock | `isOn` nil; does nothing. |
| Flashlight (SS:1564) | `SmallControl` default `{}` | torch | Nothing. |
| Timer (SS:1565) | default `{}` | timer | Nothing. |
| Camera (SS:1566) | `open(.camera)` | camera | Opens the in-app Camera. |
| Voice Memos (SS:1567) | `open(.voiceMemos)` | recorder | Opens the in-app app. |
| Lock button (SS:1512) | `system.lock()` | lock | Locks the concept, not the device. |

- Nothing in Control Center states that these are simulated. Only the Wi-Fi settings footer does (SettingsSystem.swift:362).
- Notification panel: header with count and "Clear" button (SS:1695-1713), a list of `NotificationCard`s (SS:1717-1731). Tap opens the source app (SS:1721-1723). Context menu "Dismiss" (SS:1724-1728). The scrim is a blurred second `IndicaWallpaper` (SS:1685-1690). `HomeIndicator` closes the panel (SS:1734).
- The notification data is `SystemNotification` sample items created in `init` with `.now` offsets (SM:550-554). `notificationPreviews` and `disabledNotificationApps` are not consulted by the shell (`notificationsEnabled(for:)` is only used in Settings).

**Meets brief?** No. Brief sections 8 ("Control panels", "Notifications") and 22.

**Defects**
- P1 SS:1526: the cellular toggle is `.constant(true)`. It looks interactive, shows press feedback and press animation, and can never change.
- P1 SS:1537-1547, SS:1558, SS:1564-1565: the transport buttons, "Quiet Hours" tile, "Screen", Flashlight and Timer are inert but styled as buttons. Brief section 22: "Custom ... controls must affect exactly the scope they claim."
- P1 SS:1554-1555, SM:547-548: brightness and volume sliders change a number nobody consumes. The icons imply device scope.
- P1 SS:1525, 1529-1530, 1557: Airplane/Wi-Fi/Bluetooth/Focus labels imply device-level scope with no disclosure, and the state is not persisted (SM:544-546).
- P1 SS:1680-1771, SM:550-554: sample notifications are not labelled as such. The "Clear" action is not persisted, so cleared items reappear on relaunch. No supported notification actions are verified (brief section 8 "Notifications").
- P1 (accessibility) SS:1581-1600, SS:1602-1632, SS:1664-1678: icon-only controls with no `accessibilityLabel` or `accessibilityValue`. Sliders are not adjustable and have no accessible value (SS:1622-1627).
- P2 SS:1573: the Control Center `HomeIndicator()` has no action; it is a dead button.
- P2 SS:1622-1627: slider `DragGesture(minimumDistance: 0)` sets the absolute position from the touch location, so it does not preserve the grab offset. A fill minimum of 48 pt (SS:1614) means value 0 draws a 48 pt fill.
- P2 SS:1496-1503, SS:1688-1690: the scrim tap is the only dismissal. There is no escape action and no "Close" accessibility element. Swipe-up works only outside `.app` (see item 7).
- P2 SS:1704-1708: "Clear" removes everything without confirmation and without a haptic.
- P2 SS:1721-1728: notification cards are `onTapGesture` + `contextMenu` with no button trait or combined accessibility element (**unverified** VoiceOver behaviour).
- P3 SS:1506,1693: each panel embeds its own `SystemStatusBar` and island.

---

## 11. Search

**Current**
- Shell: no search implementation. `SearchWidget` (SS:818-833) is a static row. The "Search" pill (SS:632-657) only changes page. There is no `TextField`, no index of apps, notes or settings, no keyboard handling.
- In-app search exists only inside individual apps: `.searchable("Search Settings")` (SettingsSystem.swift:181), `"Search Apps"` (SettingsSystem.swift:1359), Maps search field (CoreApps.swift:834), Browser address field (CoreApps.swift:663). Contacts has a dead `.searchable(text: .constant(""))` (EverydayApps.swift:725).

**Meets brief?** No. Brief section 8 "Search" requires searching actual local content and apps.

**Defects**
- P1 SS:818-833, SS:632-657: fake search entry point.
- P1 SS:826: the mic icon implies voice search that does not exist.
- P2 EverydayApps.swift:725: `.searchable(text: .constant(""))` accepts text that is immediately discarded.
- P2: no cross-app index (notes, reminders, messages, apps), so brief section 12's example "a note updated in its app should match search" cannot hold.
- P3: no empty query, no results, no clear, no keyboard dismissal states to evaluate.

---

## 12. Persistence

**Current** (all in `IndicaSystem`, SM:432-776 unless noted)
- UserDefaults string/enum keys: `appearance`, `wallpaper`, `accentStyle`, `iconAppearance`, `homeLayoutDensity`, `lockClockStyle`, `notificationPreviews`, `deviceName`.
- UserDefaults numeric/bool keys: `glassIntensity`, `reduceTransparency`, `reduceMotion`, `boldText`, `textScale`, `showAppLabels`, `showLockWidgets`, `soundsEnabled`, `hapticsEnabled`, `keyboardClicks`, `lowPowerMode`, `batteryPercentage`, `locationServices`, `analyticsSharing`, `allowTrackingRequests`, `automaticUpdates`, `backgroundRefresh`, `privateWiFiAddress`, `capturedMoments`.
- Set keys: `disabledNotificationApps`, `disabledBackgroundApps` (stored as sorted arrays).
- Codable JSON blobs in UserDefaults: `notes` ([NoteItem]), `reminders` ([ReminderItem]), `messages` ([MessageItem]) via `save`/`load` (SM:762-775), written in `didSet` on every mutation.
- Elsewhere: `connectedAccounts`, `integrationClientIDs` (Connections.swift:324-330, 730-736); `@AppStorage` keys `assistant.openAI.model`, `assistant.anthropic.model` (Connections.swift:1388-1389), `askToJoinNetworks`, `autoJoinHotspot`, `cellularDataEnabled`, `dataRoaming`, `lowDataMode`, `focusShareAcrossDevices`, `focusScheduleEnabled`, `trueTone`, `autoLockMinutes`, `increaseContrast`, `buttonShapes`, `lockdownMode`, `privateRelay`, `setTimeAutomatically`, `use24HourTime`, `indicaLanguage`, `indicaRegion`, `appCellularDefault` (SettingsSystem.swift). Many have no consumer.
- Not persisted: `phase`, `overlay`, `isEditingHome`, `isFocusEnabled`, `wifiEnabled`, `bluetoothEnabled`, `airplaneMode`, `brightness`, `volume`, `appHistory`, `notifications`, `homeAccessories`, current page.
- Schema/versioning: none. No key for version, no migration. Model structs are plain Codable.
- Corruption handling: `load` returns the fallback sample when the data is missing or fails to decode (SM:767-775). `save` silently ignores encode failures (`try?`, SM:762-765).
- Sample/welcome data: first-run fallbacks are "Welcome to Indica" note, two reminders and two messages (SM:600-614). The note body says "relaunch the simulator". `resetDemoData` replaces all notes, reminders and messages with a new sample set (SM:755-760).

**Meets brief?** Partly. Brief section 12 requires versioned schemas, corruption handling and separating demo data from personal data.

**Defects**
- P1 SM:600-614, SM:767-775: a decode failure (schema change or corrupt blob) silently returns the sample fallback. Property observers do not fire in `init`, so the fallback is not saved yet, but the next edit overwrites the stored personal data with the sample plus the edit. There is no backup, no error surface and no logging.
- P1 SM:755-760, SettingsSystem.swift:1312-1328: "Erase Demo Content" wipes the user's actual notes, reminders and messages and replaces them with new sample items. Demo data and personal data are one collection with no marker. First-run sample items become personal data on first edit.
- P2 SM:555-563, SM:762-765: whole-array JSON written to UserDefaults on every mutation (large payloads in a plist-backed store, no file protection). The `try?` hides failures.
- P2 SM:471-485: `didSet` writes `glassIntensity` and `textScale` on every slider tick.
- P2 SM:550-554: `notifications` is rebuilt from constants each launch with fresh `.now` dates, so dismissals don't persist and timestamps always look recent.
- P2 SM:441-445, SM:598-599: `appearance` and `wallpaper` use `didSet` plus `init` assignments; mixed init patterns with the other properties make ordering fragile.
- P3 SM:474-479 duplicates `reduceTransparency`/`reduceMotion` as app flags in addition to the system accessibility settings.

---

## 13. Theming / accessibility cross-cut

**Current** (counts are from grep on each file)

| Metric | SystemShell.swift | SystemModels.swift | ContentView.swift |
|---|---|---|---|
| `.font(.system(size:` | 69 | 0 | 0 |
| Text-style fonts (`.title`, `.body`, ...) | 0 | 0 | 0 |
| `Color(hex:` | 50 | 63 | 0 |
| `.accessibilityLabel` | 4 | 0 | 0 |

For context, the rest of the repo: `font(.system(size:` appears 4 times in SettingsSystem, 26 in CoreApps, 5 in Connections, 23 in EverydayApps. `Color(hex:` appears 2, 5, 9 and 5 times in the same files.

- Accessibility labels in the shell: Dynamic Island (SS:353-355, with a hint), "Back to Home" (SS:1268), "Home" (SS:1295-1296), "Recent Apps" (SS:1306). No `ScaledMetric` anywhere (grep).
- Unlabelled icon-only controls: both `LockActionButton`s (SS:562-575), lock-screen `HomeIndicator` (SS:512), dock `AppIcon`s (SS:661-670), switcher close (SS:1394-1401), `ControlToggle` x4 (SS:1581-1600), `VerticalSlider` x2 (SS:1602-1632), `SmallControl` x4 (SS:1664-1678), the Control Center lock button (SS:1512-1518), the shuffle button (SS:1886-1893), every `HomeIndicator` instance (SS:1905-1925), and the Search pill's dots/page value (SS:645-651).
- Reduce Motion: only `@Environment(\.accessibilityReduceMotion)` in `CV:4`. `CV:17-21` sets `transaction.animation = nil` when either the custom or system flag is on. This removes all animation, including press feedback, instead of substituting simpler transitions. Because `.transaction` is applied on an ancestor of the state owners, it may not intercept `withAnimation` transactions started by descendants (**unverified**). Infinite animations (wallpaper drift SS:222-226, boot breathing SS:115-119, icon wiggle SS:896-905) start via `withAnimation` in `onAppear`/`onChange` and are not conditioned on Reduce Motion.
- Reduce Transparency: `LiquidGlassModifier` reads `accessibilityReduceTransparency` and the custom flag (SS:1939, 1950). Plain `.ultraThinMaterial`/`.regularMaterial` uses are not guarded: SS:1012, SS:1497, SS:1826, SS:1898.
- Dynamic Type: `CV:14` raises the environment size to `max(system.dynamicTypeSize, preferredTextSize)`, but fixed-size system fonts do not scale. The shell's text (status bar, lock clock, labels, island, switcher, control and notification panels) ignores both the custom Text Size setting and the system setting. `boldText` is applied via `.fontWeight` at root (CV:15), and explicit weights in fixed fonts may override it (**unverified**). `legibilityWeight` is never read.
- Glass: `LiquidGlassModifier` (SS:1938-2046) has three branches. Reduce-transparency: an opaque `secondarySystemBackground`. iOS 26: real `.glassEffect(.regular, in:)` (SS:1961-1966) wrapped in `#available(iOS 26.0, *)`, then layered with a hand-rolled specular sheen (`GlassSpecularSheen`, SS:2048-2077), gradient strokes, an accent shadow and a black shadow. Pre-26: `.ultraThinMaterial` plus a hand-built gradient. It is used 19 times in the shell. Wallpapers use blur radii of 82 and 92 (SS:181, 188) in an infinite `repeatForever` animation. Each `IndicaWallpaper` instance animates separately, including 6 picker previews (SS:1808).
- No `GlassEffectContainer`; adjacent glass elements are not grouped.

**Meets brief?** No. Brief section 7 and the Dynamic Type and Reduce Motion expectations in sections 8 and 21.

**Defects**
- P1 SS (69 fixed fonts): Dynamic Type and the custom Text Size setting have no effect on shell text. Large-text users get unscaled 8-15 pt labels (SS:419 is 8 pt, SS:1312 is 8 pt).
- P1 SS:661-670, SS:884: dock icons and all icons when labels are off have no accessible name. The switcher close, Control Center controls and lock buttons have no labels or values.
- P1 SS:496-512 and item 3: no accessible way to unlock.
- P2 CV:17-21: Reduce Motion removes all animation rather than providing an alternative; effectiveness on descendant-owned state is unverified. Looping animations are unconditional.
- P2 SS:1012, SS:1497, SS:1826, SS:1898: materials ignore Reduce Transparency.
- P2 SS:1961-2043: hand-rolled sheen, strokes and shadows layered on top of system glass. The result is not the system look and costs rendering time (19 uses, 2 shadows each, blur 82/92 under animation).
- P2 SS: 50 `Color(hex:` uses in the shell, plus 63 in the model. There are no semantic or asset colours and no high-contrast variants.
- P3 SM:31,119-139: `WallpaperStyle.foreground` is the only adaptation of text colour to wallpaper; icon labels are always white with a shadow (SS:889) and unreadable on `.daylight`.

---

## Gesture ownership map

| Region / state | Recognizer | File:line | Conflicts / notes |
|---|---|---|---|
| Whole shell, all phases | `simultaneousGesture(DragGesture(minimumDistance: 24))`, `onEnded` only | SS:23, SS:72-93 | Runs together with every child gesture. Fires during `.booting`. Top zone 82 pt overlaps the first ~19 pt of app content. |
| Top 82 pt, down more than 70 pt | same: sets `.controlCenter` (x > 53%) or `.notifications` | SS:78-81 | Release-only, no tracking. Can open over `.booting`/`.switcher`. |
| Bottom 172 pt, up more than 46 pt, `.locked` | same: `unlock()` | SS:82-87 | Double-fires with the lock-screen drag. |
| Bottom 172 pt, up more than 46 pt, `.app` | same: `break` (nothing) | SS:84-85 | No whole-screen home gesture in apps; control panels cannot be swipe-dismissed in apps. |
| Bottom 172 pt, up more than 46 pt, home/switcher/else | same: `goHome()` | SS:88-90 | Redundant on `.home`. Any horizontal travel is allowed. |
| Lock screen content | `DragGesture(minimumDistance: 10)` via `.gesture` | SS:517-530 | Competes with the root gesture and with the long press. |
| Lock screen content | `onLongPressGesture(0.55)` | SS:531-535 | Same view as the drag. No accessible alternative. |
| Home pages | `TabView(.page)` native paging | SS:591-630 | System horizontal scroll. Vertical drags pass to root gesture. |
| Home (whole VStack) | `onLongPressGesture(0.52)` toggles editing | SS:705-710 | Includes status bar, pill and dock. May lose to child Buttons (**unverified**). Would collide with a future pill-scrub. |
| Search pill / dots | `Button` tap | SS:632-657 | No hold, no drag, no scrub. |
| App icons / dock | `Button` + `PressableButtonStyle` | SS:863-895, SS:660-670 | No context menu, no drag/reorder. |
| App nav bar | `highPriorityGesture(DragGesture(minimumDistance: 7))` | SS:1344-1357 | Higher priority than its three child Buttons. |
| App content | native `NavigationStack` pop, sheets, `ScrollView`/`List`, `TextField` | per app | Shell root gesture also sees these touches. Keyboard covers the nav bar (**unverified**). |
| Switcher cards | horizontal `ScrollView` + card `Button` + nested close `Button` | SS:1382-1415 | No vertical dismiss. Nested buttons. |
| Switcher home indicator | `Button` tap | SS:1424 | Tap only. Bottom-swipe is root gesture. |
| Control Center | scrim `onTapGesture`; sliders `DragGesture(minimumDistance: 0)` | SS:1499, SS:1622-1627 | Sliders set position by absolute touch location. Home indicator is inert (SS:1573). |
| Notification panel | scrim `onTapGesture`; card `onTapGesture`, `contextMenu`; vertical `ScrollView` | SS:1688, SS:1721-1728, SS:1717 | HomeIndicator closes (SS:1734). |
| Wallpaper / lock customization | scrim `onTapGesture`; horizontal `ScrollView` | SS:1779, SS:1838, SS:1799 | No drag-to-dismiss. |
| Dynamic island | `onTapGesture`, `onLongPressGesture(0.42)`, `onHover` | SS:322-352 | Attached to a 116x34 frame; expanded overlay hit area **unverified**. |
| Real system bottom edge | none | n/a (no deferral) | Host exit not managed; **unverified on hardware**. |

## Microinteraction inventory

| Interaction | Trigger | Threshold | Feedback | Release | Cancellation | Haptic | A11y alternative | File:line |
|---|---|---|---|---|---|---|---|---|
| Page swipe | Horizontal drag on `TabView(.page)` | System paging | Native page curl-less scroll; dots in pill update | Settles on page; `page` state updated | System | Selection on page change, after commit (SS:702-704) | None custom (**unverified** whether UIKit paging exposes VO page actions) | SS:591-630, SS:702 |
| Page scrubbing | Hold + drag on pill / indicator | Not implemented | None | None | None | None | None. Brief section 20 requires previous/next actions and announcements | SS:632-657 (absent) |
| Search entry | Tap pill | Tap | `PressableButtonStyle` scale 0.95; page spring 0.38/0.84 | Jumps to page 1 (or back to 0 when on 1) | Cancel by moving finger off the button (SwiftUI default) | Selection | Button named "Search" or "Home" | SS:632-657 |
| Search dismissal | None | n/a | None | n/a | n/a | n/a | n/a | SS:818-833 (no field) |
| Long-press menus | None on icons | n/a | n/a | n/a | n/a | n/a | n/a | SS (no `.contextMenu` on `AppIcon`); only notification "Dismiss" SS:1724 |
| Island long press | Hold on island | 0.42 s | Spring expand | Stays expanded until tap/hover-out | None | Rigid | Hint text only (SS:353-355) | SS:328-333 |
| Icon editing entry | Long press on home VStack | 0.52 s | Wiggle ±1.5° (0.13 s repeat), minus badge, Done | Toggles `isEditingHome` | Release before 0.52 s; moving more than default max distance | Rigid | None | SS:705-710, SS:874-905 |
| Icon editing exit | Done button, or second long press, or `lock()` | tap / 0.52 s | Spring 0.36/0.82 | `isEditingHome = false` | n/a | Selection (Done) | Button text "Done" | SS:713-717 |
| Icon editing actions | minus, reorder, remove | Not implemented | Static badge | n/a | n/a | n/a | None | SS:874-882 |
| App open | Tap icon | Tap-up commit | Scale 0.92 and brightness press (SS:1927-1936); spring 0.48/0.86; centre scale 0.9 with opacity | `phase = .app(app)` | Move off the button | `.light` at commit | Icon button; dock unnamed | SS:863-895, SM:657-666 |
| App return (home) | Back chevron tap, home capsule tap, nav-bar swipe up, bottom-zone swipe in other phases | Tap, or 30 pt up (bar), or 46 pt up (root) | Bar lifts up to 18 pt; scale 0.94 crossfade into home | `goHome()` | Bar springs back if under 30 pt | Selection (also when already home) | "Back to Home", "Home" labels | SS:1260-1307, SS:1344-1357, SM:668-674 |
| App switcher entry | Recent Apps button | Tap | Spring 0.44/0.84, card strip slides from bottom | `phase = .switcher` | n/a | Medium | "Recent Apps" label. No swipe-up-and-hold entry | SS:1298-1306, SM:676-686 |
| Switcher dismissal | X button on card | Tap | Default `withAnimation` removal | History entry removed | None | None | No label | SS:1394-1401 |
| Switcher "swipe up to close" | Swipe on card | Not implemented | n/a | n/a | n/a | n/a | n/a | SS:1420 (copy only) |
| Back navigation | Shell chevron "Back to Home", or app's own `NavigationStack` back | Tap, or system edge pop | Press scale 0.91 | Goes home (shell) or pops one level (app) | Move off | Selection | Labels present for shell controls | SS:1260-1269 |
| Lock unlock | Drag up | 10 pt to begin, 70 pt to commit (also 46 pt in the bottom 172 pt via root) | Content follows finger upward only | `unlock()` then spring-back of offset | Release under 70 pt springs back | Success on commit | None | SS:517-530, SS:82-87 |
| Control Center / Notifications pull | Drag down from top 82 pt | 24 pt begin, 70 pt commit | None during drag; panel springs in on release | Overlay set | Release under 70 pt: no effect | None | None | SS:78-81 |
| Control sliders | Drag on slider | 0 pt | Fill follows absolute touch position | Value stays | None | None | None | SS:1622-1627 |
| Sheet drag | Drag on app system sheets | System | System | System | System | System | System | per app `.sheet` |
| Shell overlay "sheets" (wallpaper, lock customization) | Tap scrim, "Done" | Tap | Opacity + move-from-top transition | `overlay = nil` | None | None | Button "Done" | SS:1779-1795, SS:1838-1847 |
| Hint text | App open | 2.8 s timer | "Swipe up for Indica Home" fades | n/a | Not cancelled on disappear | None | n/a | SS:1358-1365 |

Evidence for any of the above on a physical iPhone 18 Pro, with Reduce Motion on, with the keyboard open, or at larger text sizes was not available from source reading and is **unverified**.
