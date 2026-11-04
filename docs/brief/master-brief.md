# Swift UI — Master Product, Brand, Design, Engineering, and Release Brief

Act as my lead native SwiftUI engineer, product designer, interaction designer, and integration architect. Take ownership of turning **Swift UI**, formerly Indica OS and briefly described as Swift OS, into a coherent, distinctive, dependable iPhone experience.

This is an existing application with real code, incomplete features, inconsistent design, and bugs. Inspect what exists, make explicit decisions, implement improvements, verify the running result, and deliver the finished release to GitHub. Treat this brief as the durable product direction for the work.

## 1. Decisions already made

- The product name is **Swift UI**, including the space. **SwiftUI** refers to Apple's development framework. Do not reopen the naming decision.
- The implementation stays native SwiftUI. Use UIKit or other native frameworks when needed for a specific capability. Keep web technologies limited to appropriate embedded content or separately scoped portfolio work.
- The first polished release targets iPhone, with a shareable portfolio demonstration. iPad and Mac are later adaptations unless existing support needs preservation.
- This is a full branding overhaul: identity, interface, icons, motion, copy, onboarding, documentation, GitHub presentation, and how the project represents my work.
- The product must be useful at minimal cost. Core functionality must not require a paid AI subscription, a paid external API, or each user becoming a developer.
- My goals are a useful product, an impressive portfolio, a design concept lab, and sustained, meaningful GitHub contributions.
- Upon completion, update the existing GitHub repository and publish an appropriately versioned release with release notes, current screenshots, documentation, and evidence of verification.
- Logo exploration follows this master brief. Develop and select a visual direction before treating any logo as final.
- Match the reference iOS/app experience faithfully, including small interaction details; a vaguely iOS-inspired imitation is insufficient. The original Swift UI brand must coexist with accurate app behavior and layouts.
- Treat page scrubbing, accidental host-app exits, truthful device status, and iPhone 18 Pro safe-area/Dynamic Island behavior as named release requirements, with independent reevaluation after implementation milestones.

Use these decisions as answers. Ask only about unresolved choices that materially change the result.

## 2. Starting context and source of truth

The repository is https://github.com/Bryce-Whittsette/indica-os.

The currently identified local checkout is /Users/brycewhittsette/Documents/Codex/2026-11-03/get-x20/outputs/SwiftOS. Verify its remote, branch, working changes, and current contents before relying on it. Reuse a suitable existing checkout rather than creating a competing copy without a reason.

Historical project names, Xcode identifiers, and some copy still use Indica OS or Swift OS. The latest user decision, Swift UI, governs public branding. Read the repository's instructions, README, build workflow, and release checks; update stale project guidance as part of the overhaul.

On November 3, 2026, Xcode 27.2 and an iOS 27.2 simulator runtime were verified on this Mac. Earlier documentation says Xcode was missing; recheck the current environment. The existing project targets iOS 17 and has availability-guarded newer visual effects. Preserve the deployment target unless a justified change is explicitly agreed.

Existing modules cover the shell, system models, core/everyday apps, settings, haptics, connections, and an extracted calculator engine. Existing integrations include Spotify OAuth code and developer AI request flows; their presence is not proof of live verification.

Before an intentional technical rename, the baseline build uses the existing IndicaOS project and shared IndicaOS scheme, the iPhone simulator SDK, a Debug configuration, and disabled code signing for simulator verification. Keep derived build products outside tracked source. Reuse the existing extracted calculator tests rather than writing a separate substitute engine.

Treat repository claims, screenshots, code, and prior test results as evidence to verify. Keep the difference between observed behavior, intended behavior, and assumptions visible.

## 3. Product strategy and audiences

Design for two primary situations: someone using Swift UI for everyday tasks, and someone evaluating my work through a portfolio demonstration. The concept lab supports exploration without making ordinary use confusing.

Use three clear experiences within one product:

- **Everyday experience:** useful local/native functionality, predictable navigation, and optional connections.
- **Portfolio demonstration:** a curated tour with safe sample content, explanations of design decisions, and reproducible interactions.
- **Concept lab:** clearly identified experiments and capabilities that are not operational integrations.

Do not require three separate applications or duplicate all feature state. Choose a simple way to expose these experiences. Keep experimental and sample data separate from personal data.

A strong evaluation journey is: understand the product, explore the launcher, open an app, complete a real task, switch apps and return without losing work, inspect a connection or native integration, and discover the design story. Optimize that journey while preserving independent everyday use.

## 4. Authority, questions, and working rhythm

Proceed autonomously on inspection, implementation details, reversible improvements, testing, documentation, commits, and the authorized GitHub delivery. Preserve unrelated work and existing user data.

Bundle genuinely necessary questions into a short decision round. State your recommendation and consequence. Discover answers from the project and official documentation before asking me to supply them. Do not ask me to repeat settled goals or choose low-level spacing, animation, or architecture values.

Creative direction remains a meaningful user choice: present concrete options and make a recommendation. If I delegate that choice, select and document the recommended direction. Silence is not approval of a paid service, a destructive action, or a final brand selection.

Work in reviewable stages. Share brief updates explaining what you found, what changed, what remains uncertain, and how the next step resolves it. If one provider, device, credential, or signing requirement blocks a feature, complete independent work and report that specific limitation.

## 5. Initial audit and release scope

Before redesigning, inspect the working tree, build configuration, dependencies, persistence, state management, permissions, navigation, credentials, and current CI. Build and launch the application. Capture the existing shell and representative apps on current simulators.

Create an inventory covering every catalog entry and system surface. The inspected catalog contains 50 entries; reconcile that count against current source. For each record include: purpose, entry point, primary task, current behavior, defects, data source, supported actions, permissions, cost, proposed release behavior, and verification status.

Classify each entry accurately as operational local/native functionality, verified provider integration, explicit external handoff, or concept demonstration. Record an owner-readable completion check for each. A screen that compiles, an icon that opens, or an API setting that saves is insufficient proof of functionality.

Prioritize crashes, lost data, broken navigation, fake success states, and shared-state inconsistencies. Then address recurring visual and interaction problems across the system.

The default first-release scope is the shell, cohesive branding across all retained screens, dependable local essentials, supported native access, and honest provider entry points. Advanced concepts may remain in the labeled lab. Do not silently remove existing apps or classify unfinished core work as an experiment to make the checklist pass. Record any proposed scope change and its user impact.

## 6. Brand exploration and logo brief

Develop an original identity for Swift UI that communicates a deliberate, responsive, personal computing environment. The app should show that I can design a coherent system and build dependable software.

Present three materially different directions using the same real content and representative surfaces. Each direction must include a concise thesis, typography hierarchy, semantic palette in light/dark appearances, icon approach, material treatment, motion character, sample interface copy, and a shell/app example. Structural and interaction differences should support the thesis; changing an accent color alone is not a new direction.

Use the former interface as evidence of functionality, not an obligation to preserve its aesthetic. Do not assume its existing purple, champagne, rounded typography, glass, or icon gradients are binding.

Apply original branding to the product identity, presentation, and deliberately original surfaces. For an embedded app intended to reproduce an existing iOS app, preserve the observed layout, content density, navigation, controls, and interaction conventions. Do not reskin every app into the same Swift UI dashboard or add decorative chrome that makes a faithful reproduction less accurate. Instagram is an example of the fidelity standard, not an instruction to add an Instagram integration to the current catalog.

After a direction is selected, explore an original symbol and wordmark for Swift UI. Assess recognition at small sizes, monochrome use, light/dark backgrounds, app-icon presentation, documentation, and GitHub avatars or social previews. Keep the full product name legible where text is required. Separate the mark, wordmark, and app-icon container so each has a clear purpose.

Present logo concepts as concepts until selected. Produce editable vector masters and appropriate raster exports for the approved identity. Explain the construction and usage rules. Avoid inventing personal biography, credentials, testimonials, adoption numbers, or product achievements.

## 7. Native design system and visual standards

Define shared semantic tokens for colors, typography, spacing, radii, materials, separators, elevation, icon sizing, hit areas, and motion. Distinguish brand accents from success, warning, error, selection, and focus states.

Establish reusable controls and patterns for navigation bars, lists, toolbars, forms, search, empty states, loading, inline errors, destructive actions, sheets, dialogs, and permission explanations. Give each app a layout suited to its task rather than forcing every app into the same card template.

Use the system font and native controls as the starting point; introduce custom treatments where the selected direction earns them. Prefer semantic text styles and adaptive layouts. Use SF Symbols appropriately for functional controls and the chosen original system for branded identity.

Target at least 44-point touch areas for ordinary primary controls. Preserve legible hierarchy, accessible labels, clear focus, sufficient contrast, and predictable action placement. Test large text rather than relying on fixed screenshots.

Materials should clarify depth and hierarchy. Motion should explain causality and spatial relationships. Avoid ornamental blur layers, arbitrary gradients, repeated bouncy entrances, placeholder dashboards, oversized empty headers, and status badges that convey no useful state.

## 8. Interaction and shell acceptance criteria

| Surface | Required behavior and verification |
|---|---|
| Startup | Enter a useful state promptly. Avoid a mandatory artificial boot delay. Restore intended state safely after relaunch. |
| Lock concept | Distinguish the in-app concept from device security. Validate unlock, cancellation, customization, and accessibility activation. |
| Launcher and dock | Icons and labels remain legible; page changes and search are reliable; launching the same app cannot corrupt navigation or duplicate presentation. |
| Page indicator/Search pill | Distinguish tap-to-search from press-and-drag page scrubbing. Reach every page continuously, provide stable release/cancellation, and avoid activating home editing accidentally. |
| App switching | Open, switch, return, and dismiss predictably. Preserve drafts and feature state according to a documented policy. |
| Gestures | Track movement continuously, preserve grab position, resolve scrolling/dragging conflicts, and allow interruption or cancellation where appropriate. |
| Transitions | Preserve spatial origin and return path; avoid jumps, frozen input, duplicate sheets, and conflicting animations during rapid input. |
| Search | Search actual supported local content and apps. Handle empty queries, no matches, clearing, keyboard dismissal, and navigation to results. |
| Control panels | Every toggle or slider affects the scope it names. Label app-only appearance, volume, or other simulated controls accurately. |
| Notifications | Separate Swift UI's own activity and sample notifications from claims of access to other apps' notification history. Verify supported notification actions. |
| Hardware and Dynamic Island | Respect the actual device safe areas and camera cutout in every shell state. Keep any app-owned activity UI independent of wallpaper customization, and verify compact/expanded layouts and hit targets on iPhone 18 Pro. |
| Host-app exit handling | Coordinate internal home/switch gestures with supported system-edge deferral, preserving deliberate system exit. Test on physical hardware; hiding a home indicator alone is insufficient evidence. |
| Customization | Appearance, wallpaper, icon settings, and accessibility preferences persist and update all affected surfaces consistently. |
| Navigation | Back, close, home, and modal dismissal have consistent meanings. Test rapid taps, interrupted drags, repeated open/close, and navigation with the keyboard visible. |
| Feedback | Show immediate press feedback, commit at the appropriate activation event, preserve cancellation, and coordinate purposeful haptics with the actual result. |

Use a single clear source of truth for shell presentation. Define valid transitions and recovery behavior rather than allowing unrelated booleans to present incompatible screens simultaneously.

## 9. App-by-app minimum behavior

Reconcile this table with the actual catalog. It defines expected release behavior and investigation requirements, not a claim that any item already works.

| App or group | Specific requirement |
|---|---|
| Notes | Create, edit, autosave, search, delete, and reopen notes. Preserve edits across app switching and relaunch; never overwrite personal notes with welcome data. |
| Reminders | Create, edit, complete, reopen, and delete tasks. Keep local tasks useful without permission; if system synchronization is added, map identities and avoid duplicates or silent data loss. |
| Calendar | Use actual dates and time zones; navigate and return to today. Support a genuine event workflow through an appropriate local model or native integration, with clear data provenance. |
| Clock | Show real time. Implement exposed stopwatch/timer functions correctly across foreground changes using elapsed time or deadlines. Document background notification and alarm limits. |
| Calculator | Preserve and extend the shared tested engine. Verify decimals, sign, percentage, chained operations, operator replacement, repeated equals, clear, and recovery from invalid operations. |
| Journal | Create and edit dated entries with dependable storage and clear navigation between entries. |
| Canvas | Exposed drawing controls must actually draw, erase, undo, save, or export as labeled. Handle empty work and restoration. |
| Files | Browse app-accessible files and support appropriate import/export, selection, cancellation, errors, and persistence. Explain the actual storage scope. |
| Camera | If operational, capture real supported media with permission and a clear save/preview flow. Handle unavailable hardware and denial without fake capture success. |
| Photos | Select and display user-chosen media through supported access. Respect limited access and cancellation; distinguish sample images from personal selections. |
| Voice Memos | If operational, record actual audio, play it, retain files, rename/delete, and handle microphone denial and interruption. Simulated recording belongs in the labeled lab. |
| Browser | Navigate supported URLs with working back/forward, reload, loading/error states, keyboard behavior, and external-open options. Preserve appropriate browsing state. |
| Maps | Provide a supported location/search/navigation workflow. Keep useful manual search when location is denied. Clearly indicate handoffs to another map app. |
| Weather | Use a verified data source for live claims, show location and freshness, and support manual location or offline recovery. Sample weather stays identified as sample data. |
| Contacts | Request only necessary access and support the actual selection or contact-management task. Do not imply an address book has synced after showing a picker. |
| Phone, Messages, Video calling | Verify supported calling/composition/handoff behavior. Distinguish internal sample conversations from personal message history; do not claim completed calls or sent messages without evidence. |
| Mail, Gmail, Outlook | Distinguish composing mail, opening a provider, and synchronizing an inbox. Use real provider authentication only for supported implemented actions; no sample inbox presented as personal mail. |
| Music, Spotify | Reuse existing OAuth code where correct, after verification. Reflect real supported playback/account state. Show when a subscription, account eligibility, or external player is required. |
| TV, YouTube, Podcasts, Books, News | Use user-provided content, suitable attributed feeds, supported playback, or official handoffs. Every exposed playback and navigation control must have an honest effect. |
| Translate | Use supported on-device/native options where feasible, with language and OS availability checks. Make optional external processing explicit. |
| Shortcuts | Implement defined Swift UI actions or supported system handoffs. Do not imply unrestricted automation of other apps. |
| Store, Tips | The catalog describes actual available Swift UI features; installation/enablement language matches what occurs. Tips explain verified behavior in this release. |
| Settings, Connections | Settings affect the named scope and persist. Show actual account, permission, credential, verification, and disconnection states separately. |
| Compass, Measure, Magnifier | Use the appropriate supported sensor/camera capability where operational. Handle missing hardware, calibration/tracking limitations, permissions, and simulator limitations. |
| Stocks | Identify source, market context, timestamp, and delayed/cached status where applicable. Keep demonstration values separate from live quotes. |
| Health, Fitness | Show only genuinely authorized data or clearly marked samples. Handle unavailable data and denied access without inventing activity. |
| Home, Find, Watch | Verify the exact supported device/accessory capabilities and entitlements. Unsupported system experiences remain explicit concepts, not claims of device control or tracking. |
| Wallet, Passwords | Keep demonstration assets unmistakable. Do not solicit real payment details or secrets through simulated storage or authentication. A genuine vault/payment capability requires a separately defined, verified implementation. |
| Notion, Discord, Telegram | Use a supported integration or an explicit official-app/web handoff. Verify scopes and actions before claiming account access or history synchronization. |
| ChatGPT, Claude | Provide useful optional entry points. Separate official-app access from developer API functionality and billing. Core use never depends on paid AI or access to a consumer chat subscription. |

If an app cannot meet operational criteria within this release, state what it genuinely provides, give the best supported alternative, and place only the experimental portion in the concept lab. Keep personal and demonstration content clearly separated.

## 10. Low-cost integration strategy

Prefer persistent local functionality, supported Apple frameworks, system pickers and composers, official app handoffs, and then optional provider connections. Use APIs only where they provide necessary value; do not treat every app as a reason to add a cloud service.

Create an integration matrix with provider, read/write actions, official documentation, authentication, scopes, entitlements, end-user subscription requirements, developer costs, rate limits, update strategy, fallback, and verification date. Investigate current official documentation instead of inventing capabilities or free tiers.

Treat no mandatory recurring cloud cost for the core product as the default budget. Document separate distribution, hosting, provider, or account costs before introducing them. Keep caching and refresh behavior economical. Do not claim polling is real-time synchronization or promise background execution the platform cannot provide.

Normal users should not need to register developer applications or paste API keys to use the core product. Advanced bring-your-own-key tools may remain optional. A development-chat connection or installed connector is not automatically an integration available inside Swift UI.

For retained AI functionality, verify model identifiers and request/response formats against current provider documentation and account availability. Explain developer API billing separately from consumer subscriptions. Do not preserve an unverified model default merely because it already appears in source.

## 11. Permissions, authentication, and connection truth

Request access at the relevant task, explain the benefit in plain language, and keep a useful fallback after denial. Support system settings changes, limited access, cancellation, revoked access, and reconnection.

Separate these states: available on device, permission requested, permission granted, credentials configured, authenticated, data verified, stale, disconnected, and unavailable. Saving a key or enabling a preference must not label every Apple service or provider as connected.

Use provider-supported authentication, PKCE and public-client patterns where applicable, and appropriate token storage. Preserve valid existing callbacks during rebranding or migrate them deliberately. Never ship a shared provider secret in the app. If a confidential server component is necessary, explain its purpose and operating cost before adding it.

Keep credentials and personal content out of logs, screenshots, fixtures, release assets, and repository history. Disconnect should remove the corresponding local credentials and explain whether provider-side revocation occurred. Account switching must not expose the previous account's cached content.

## 12. Shared state, persistence, and engineering structure

Maintain coherent shared data: a note updated in its app should match search; appearance changes should match all surfaces; actual music state should match supported mini-player views; app switching should preserve drafts.

Define ownership and update rules for each data model. Keep view-local interaction state separate from persisted content and service sessions. Use stable identifiers, explicit schema/version migrations where needed, and predictable handling of missing or corrupt records. Distinguish deleting demonstration data from deleting personal content.

Keep rendering responsive. Move file/network work off the UI execution path, handle cancellation, prevent outdated responses from overwriting newer selections, avoid duplicate requests, and stop unnecessary work when surfaces disappear.

Refactor enough to make changes testable and understandable. Do not introduce a new framework, backend, package, or wholesale rewrite merely to impose a preferred architecture. Evaluate the current code first and document consequential choices.

## 13. Rebranding and migration

Find all user-facing Indica OS, Indica, and Swift OS references: app display name, welcome content, settings, accessibility labels, permission explanations, exported names, errors, documentation, screenshots, and release metadata. Replace product branding consistently with Swift UI.

Treat technical identifiers separately. Bundle IDs, persistent keys, Keychain services, URL schemes, OAuth registrations, targets, and project/scheme names may be compatibility contracts. Rename them only with a reason and migration/verification plan. A branded display-name update does not require breaking stored data or registered callbacks.

Update project guidance to remove stale naming and environment assumptions. Preserve historical release references where they help explain migration. Keep the existing GitHub repository address unless I separately choose a repository rename.

## 14. Verification and measurable quality

Verify a clean build with the intended project/scheme and supported toolchain, then launch and exercise the real app. Run existing calculator checks and targeted new tests for critical state, persistence, authentication parsing, and reproduced regressions. Do not add tests that merely repeat implementation details.

Use the iPhone 18 Pro target plus compact and large available iPhone simulators. Record exact device and OS versions. Test the minimum supported OS when an appropriate runtime is available and the current OS; do not claim coverage for unavailable runtimes. Use a physical device for capabilities simulators cannot establish, particularly host-app gesture conflicts and hardware-cutout interaction.

Cover first run, empty content, realistic content, long text, large lists, offline mode, slow/failing requests, denied/revoked permissions, invalid/expired credentials, relaunch, background/foreground, keyboard presentation, repeated taps, interrupted gestures, and rapid app switching.

Check light/dark appearance, large Dynamic Type, VoiceOver focus/actions, contrast, Reduce Motion, and Reduce Transparency. Provide accessible alternatives where a gesture is the primary shortcut.

Measure startup, frame pacing on the main shell transitions, and memory across repeated app open/close. Set realistic performance budgets after measuring the baseline. Report measured results and the device/runtime; do not invent frame rates or claim smoothness from a screenshot.

For each defect, record reproduction, expected/actual behavior, fix, and verification. For each milestone, record commit/build identity, device/OS, actions checked, evidence, and limitations. A source parse, a passing build, a simulator check, a physical-device test, and a live provider test are different claims.

## 15. Durable project documents

Maintain one authoritative product record, one selected design system, and a concise active backlog. Reuse the skill's existing documents rather than creating contradictory authorities.

Record: confirmed goals and audiences; native platform; chosen brand direction and tokens; all-app inventory; integration capabilities/costs; important architecture/migration decisions; completed and remaining work; current validation; and release readiness.

Keep the master brief available in the repository and update project instructions to reference it. Distinguish requirements, decisions, and observed implementation status. At session end or context handoff, leave a short continuation record with the exact next action and current blockers.

## 16. GitHub contribution and release workflow

Make substantive improvements visible through appropriately sized commits: reproduced bug fixes, functional workflows, native integrations, design-system work, regression checks, documentation, and release materials.

Inspect the configured remote, branch protection/workflow, existing release/tag conventions, CI, and configured author identity. Confirm commits can be attributed to my linked GitHub identity without inventing an address or changing account settings. Avoid empty commits or unnecessarily fragmenting one change to inflate activity.

Preserve unrelated changes and repository history. Follow the established branch/review process. Where changes require a pull request, create a clear reviewable PR with the problem, resulting behavior, screenshots, tests, and limitations. Use the repository's allowed merge process; do not bypass protections.

On completing the agreed release, stage only intended files, commit, push, check the relevant CI, and resolve failures caused by the work. Ensure the release commit is on the intended release/default branch through the permitted workflow. Choose a version consistent with project history, create the corresponding tag, and publish a GitHub Release referencing the verified commit.

These completion steps are authorized. Do not stop at a local build or a promise to upload later. If permissions, protection, account access, or unavailable credentials prevent a required step, report the exact state and needed action, provide the reviewable result, and avoid calling the publication complete.

## 17. Release notes, portfolio, and distribution

Publish release notes covering: the Swift UI rebrand, user-visible improvements, repaired workflows, supported local/native/provider capabilities, setup and compatibility, changes affecting stored data or callbacks, verification performed, and remaining limitations.

Update the README, changelog, release checks, and setup guidance to describe the shipped state. Include fresh screenshots from the release build and a short demonstration recording. Use demonstration content and safe accounts in public assets. Make historical captures distinguishable from current ones.

Create a concise portfolio case study: problem, audience, constraints, design exploration, selected direction, interaction details, engineering tradeoffs, accessibility, testing, and lessons. Show actual before/after evidence and explain my work accurately. Avoid unsupported success claims.

The default shareable portfolio package is the GitHub release, readable case study, current images, and a native-app demo video. If TestFlight, a hosted preview, or a companion website would add value, explain the requirements and cost. A native iPhone app is not automatically a browser-playable demo. Do not create a separate web implementation unless it is selected as a separate deliverable.

## 18. Definition of done and execution order

Follow this sequence: verify baseline; inventory and prioritize; capture product context; explore and select the brand/logo direction; establish shared foundations; implement the shell and core workflows; resolve the remaining catalog entries honestly; harden; verify; prepare portfolio/release materials; publish and verify GitHub delivery. Include independent review and fix/retest cycles at the meaningful implementation milestones, following Section 24.

A release is complete when its agreed functional scenarios pass, all catalog entries have accurate statuses, public branding is consistent, persistence/migration checks pass, accessibility and recovery states are verified, relevant CI passes, documentation matches behavior, and the GitHub release is published from the intended commit.

Report the finished user-visible changes, commit and tag, release/PR links, actual verification, and remaining external setup. Separate completed work from anything blocked or deliberately deferred.

In your first response, summarize the decisions already settled, verify the repository and tool state, identify the first concrete audit/build actions, and name only genuinely missing decisions. Then begin the work. Produce a staged result that people can use and I can confidently show in my portfolio.

## 19. Installed skills and slash-command usage

Read the installed skill instructions before applying their workflows. The confirmed local skills are Apple Design at /Users/brycewhittsette/.claude/skills/apple-design/SKILL.md and Impeccable at /Users/brycewhittsette/.claude/skills/impeccable/SKILL.md. Impeccable includes native iOS references.

Use `/impeccable init` to establish durable product context, `/impeccable critique` for experience/design findings, `/impeccable audit` with its native guidance for quality checks, `/impeccable shape` when a discrete brief needs resolution, and scoped animation, hardening, optimization, and polish workflows at the appropriate milestones.

Treat this master brief as context for those workflows. Use a compact confirmation when a skill requires an answer; do not repeat settled questions. `/impeccable shape` intentionally stops after a brief—implementation resumes with an instruction to build the accepted brief. Invoking a slash command is not evidence that its checks passed.

Give `/apple-design` a specific native SwiftUI interaction task. Its examples target web interfaces; translate the principles rather than importing a web stack. Its bare invocation may only return a readiness message.

Impeccable's browser live mode, browser variant generation, and HTML/CSS detector do not validate native SwiftUI screens. Use native guidance, simulator/device interaction, and current captures for this application. Use full `/impeccable ...` commands unless standalone shortcuts have actually been installed.

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

Claude Code supports custom project subagents; configure a project reviewer using the current documented mechanism and version. The /agents command's interface varies by Claude Code version, so ask Claude to create the reviewer definition if necessary. See [Claude Code subagents](https://code.claude.com/docs/en/sub-agents). Suggested delegation: “Use the Swift UI reviewer to assess this milestone against Sections 20–24. Review the current build evidence and diff, report reproducible findings, and make no source edits.”
