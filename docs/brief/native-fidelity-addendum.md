# Swift UI — Native Fidelity, Device Integration, and Independent Review Addendum

Apply these requirements alongside the master brief. They clarify the user's latest priorities: faithful iOS behavior, small interaction details, continuous smoothness, truthful device information, fewer accidental host-app exits, correct iPhone 18 Pro layout, and independent reevaluation. They supersede any earlier wording that permits a merely iOS-adjacent visual imitation.

## 20. Reference-driven fidelity and small interaction details

The intended standard is faithful reproduction of the selected iOS or provider app's actual iPhone experience within supported capabilities. Do not approximate a familiar app from memory or substitute a generic dashboard. Keep Swift UI's original product identity while matching the specific app being represented.

Before implementing a reproduction, identify the reference app, device, iOS version, app version where known, appearance, text size, and representative content. Use current screenshots and interaction recordings from the selected reference; record missing evidence instead of inventing details. Do not mix layouts from unrelated iOS releases. The user mentioned iOS 18 as a possible introduction date for one interaction, not as a confirmed version requirement.

Compare layout geometry, safe-area placement, content density, type scale and weight, icons, tab/navigation bars, separators, menus, sheets, search, keyboard behavior, scroll behavior, press feedback, and cancellation. Match content and capture dimensions when doing side-by-side or overlay comparisons. Record unavoidable platform limitations as exceptions, not successful reproductions.

Maintain a microinteraction inventory with trigger, recognition threshold, continuous feedback, release outcome, cancellation, interruption, haptics, accessibility alternative, reference evidence, and implementation verification. Include page scrubbing, search entry/dismissal, long-press menus, icon editing, sheet dragging, scroll boundaries, app opening/return, switcher dismissal, and supported interactive back navigation.

Implement the home page-scrubbing interaction described by the user. In the selected reference, verify the relationship between the Search pill and page indicator. A normal tap should perform the reference search action; a hold followed by horizontal dragging should move through all available home pages without repeated individual swipes. Track continuously, clamp at the first/last page, settle predictably on release, preserve the chosen page, and handle cancellation. Reversing direction mid-drag must not jump or queue several delayed animations. Prevent the gesture from triggering home-screen editing or another global long press. Provide accessible previous/next-page actions and announce the selected page.

Inspect whether a native UIPageControl with continuous interaction can satisfy the reference before introducing custom gesture infrastructure. Match observed behavior rather than treating one implementation mechanism as mandatory. Apple documents [continuous page-control interaction](https://developer.apple.com/documentation/uikit/uipagecontrol/allowscontinuousinteraction).

Fix behavior/copy mismatches. For example, a switcher instruction to swipe up on a card to close requires an actual swipe-dismiss interaction. Test selecting a card, cancelling a partial dismissal, closing the intended card, restoring the remaining order, and preserving saved content. Do not leave a misleading instruction after adding a different control.

## 21. Smoothness and prevention of accidental host-app exits

Distinguish Swift UI's internal home/switcher navigation from the real iOS Home gesture. Internal gestures must work across relevant app screens, scroll views, overlays, and keyboard states; they must not depend on touching a tiny decorative home-indicator view.

Investigate supported system-edge gesture deferral through the real hosting/controller hierarchy, including preferredScreenEdgesDeferringSystemGestures and the appropriate update/child-controller behavior. Apply it narrowly to immersive shell interactions where justified and validate the resulting behavior. A SwiftUI high-priority gesture or hidden home indicator is not a system-exit policy. Apple documents this mechanism in [system-edge gesture coordination](https://developer.apple.com/documentation/uikit/uiviewcontroller/preferredscreenedgesdeferringsystemgestures).

Preserve intentional access to iOS navigation. A normal application must not promise permanent confinement or silently trap the user. If a user explicitly wants a single-app demonstration session, offer optional setup guidance for [Guided Access](https://support.apple.com/en-us/111795). Keep that optional; it is not a substitute for fixing internal gesture conflicts. Do not treat managed-device-only capabilities as available to every user.

Record gesture ownership by region and state: paging, app content scroll, back navigation, sheet drag, internal home/switcher, and real system edge. Define recognition, precedence, simultaneous recognition, cancellation, and fallback. Preserve normal scrolling, text selection, native keyboard interaction, and accessible activation while resolving conflicts.

Smoothness means immediate visible response, movement that follows the finger, continuous position and velocity on interruption, predictable settling, and stable frame pacing. Avoid blanket implicit animations, stacked delays, expensive work during a drag, and bounce applied to every transition. Honor reduced-motion preferences with an understandable alternative.

Verify internal navigation and deliberate system exit separately on physical hardware. Run a documented repeated-gesture scenario across several core apps with the keyboard open and closed. Count unexpected exits, wrong transitions, lost input, and stuck states; attach a recording and the exact device/OS/build. A simulator recording or source inspection alone must not be described as proof that physical iOS Home-gesture competition is resolved.

## 22. Actual device information and truthful controls

Audit every device/status label and value, including carrier-like placeholders, time, battery, charging, connectivity, device/OS details, storage, permissions, and service availability. The user's spoken reference to “care” is ambiguous; locate the displayed field in the actual build rather than guessing which string it means.

Prefer genuine system status presentation where it supplies accurate information that a custom bar cannot access. For custom device information, build a small shared observable device-state layer using supported APIs. Source battery level/charging from UIDevice monitoring, connectivity from appropriate Network framework observations, and other properties only where publicly supported and relevant. Handle unknown, unavailable, simulator, denied, and stale states explicitly. Battery monitoring and network-path observation are documented in [UIDevice battery monitoring](https://developer.apple.com/documentation/uikit/uidevice/isbatterymonitoringenabled) and [NWPathMonitor](https://developer.apple.com/documentation/network/nwpathmonitor).

A usable network path, its interface type, internet reachability, signal bars, Wi-Fi name, and cellular carrier are different facts. Do not infer one from another. Treat unavailable details honestly; the deprecated CTCarrier interface is not a reliable foundation for a promise to display every person's carrier. Verify current supported access and prefer the genuine system bar or a useful neutral state. See [CTCarrier](https://developer.apple.com/documentation/coretelephony/ctcarrier).

Do not fabricate battery health/cycles, other apps' storage usage, active system settings, or an inventory of installed applications. Investigate the public capability for each requested field. Supported URL-handler checks for specific declared services do not establish a complete installed-app list or account connection; see [canOpenURL](https://developer.apple.com/documentation/uikit/uiapplication/canopenurl(_:)).

Custom Wi-Fi, Bluetooth, cellular, brightness, volume, Focus, and similar controls must affect exactly the scope they claim. If they change only Swift UI's own state, say so. Unsupported global settings should use an appropriate supported handoff or an explicitly labeled concept. A preference changing in memory is not proof of a device-level change.

Real device values must refresh appropriately after foregrounding and relevant system changes, without wasteful polling. Demonstration mode may use fixed sample values; ordinary operational mode must not quietly fall back to fictional device facts.

## 23. iPhone 18 Pro, safe areas, and Dynamic Island ownership

Use iPhone 18 Pro as a named verification target, alongside a compact and larger iPhone profile. Record the actual OS, display configuration, text size, and appearance. Derive layout from current window/container geometry, safe-area insets, and supported layout guides; do not solve one device by adding another arbitrary fixed offset.

Keep wallpaper/background full bleed where appropriate while laying out interactive content within the correct guides. Centralize ownership of the top/status region, content region, bottom chrome, keyboard avoidance, and overlays. Prevent both missing and duplicated safe-area padding. Apple explains these layout requirements in [Layout](https://developer.apple.com/design/human-interface-guidelines/layout).

The physical camera cutout is already present on a real device. Do not draw a second pretend hardware island that collides with it. Distinguish actual system Live Activities from an app-owned foreground activity surface. Where a real Live Activity is appropriate, evaluate ActivityKit and its supported presentations; an ordinary overlay is not system-wide Dynamic Island integration. See [ActivityKit](https://developer.apple.com/documentation/activitykit) and [Live Activities](https://developer.apple.com/design/human-interface-guidelines/live-activities).

If an app-owned activity surface is retained, anchor it in a safe, deliberate location, derive content from a genuine activity model, and keep sample activities labeled. Make expanded bounds and hit areas agree. Do not display generic LIVE status or fixed progress unless tied to an actual activity or explicitly demonstrated.

Verify idle, compact, expanded, interrupted, and dismissed activity states across lock concept, home, embedded apps, switcher, search, settings, wallpaper customization, control/notification overlays, and keyboard transitions. Changing wallpaper must not reposition or recreate the activity state unexpectedly. Prevent clipping, overlap, phantom touch regions, duplicate indicators, invisible buttons, and content drawn under the physical cutout. Use recordings and hit testing as well as still captures.

## 24. Independent review, correction, and reevaluation

Use one implementation owner and, by default, one independent reviewer after meaningful milestones. This is permission to delegate bounded review work, not a request for an endlessly running monitor. Keep development usage economical by reviewing changed work and relevant shared regressions, rather than rereading the entire repository after every edit.

The reviewer should not edit implementation files, make commits, publish, or expand scope. Give it the master brief, selected references, exact commit/build, relevant diff, test results, current captures/recordings, and a short list of claimed completed behaviors. A code-only reviewer must not approve visual fidelity, motion, or physical-device interaction without the corresponding evidence.

Use three review lenses in the review task: native visual fidelity; interaction/gesture and state correctness; and device information/safe-area/API truthfulness. Add separate specialist agents only when the work benefits from a clear additional boundary. Allow only one owner to operate a shared simulator/device at a time, and do not compare captures from different uncontrolled builds.

Every finding must include severity, surface, reproduction or source evidence, expected/actual behavior, device/OS/build, and an acceptance check. Label it as observed, source-confirmed, suspected, platform-limited, or unverified. Require references for claims of one-to-one fidelity. The implementation owner fixes actionable defects, rebuilds, reruns affected flows, supplies new evidence, and sends the result for focused reevaluation.

Use checkpoint reviews after shared shell/gesture changes, the brand migration, core app work, integration/device-state work, and the final release candidate. Do not accept a milestone with known crashes, lost data, materially misleading functionality, broken core navigation, or unaddressed physical-cutout collisions. Record lower-priority issues and explicit limitations in the release checklist.

Avoid endless review loops. If the same finding survives repeated attempts, isolate the cause, gather targeted evidence, and revise the approach. Stop only the dependent feature when an external capability or required physical-device check is unavailable, and state what remains unverified. An “agent reviewed it” statement alone is not a quality result.

Configure an independent project reviewer using the review tools available in the current environment. Suggested review brief: “Assess this milestone against Sections 20–24. Review the current build evidence and diff, report reproducible findings, and make no source edits.”
