# Product

<!-- impeccable:product-schema 1 -->

Source: the owner's master brief and native-fidelity addendum, stored in `docs/brief/`. This record summarizes durable product truth from those documents; where they differ, the brief governs.

## Platform

ios

## Users

- **Everyday user:** someone using Swift UI on an iPhone for ordinary tasks (notes, reminders, calendar, clock, calculator, journal, files, browsing) who expects predictable navigation and optional connections.
- **Portfolio evaluator:** someone judging the owner's design and engineering work through a guided demonstration. A strong evaluation journey: understand the product, explore the launcher, open an app, complete a real task, switch apps and return without losing work, inspect a connection or native integration, then discover the design story.
- **The owner, as concept lab:** a place to explore phone-interface ideas without making everyday use confusing.

## Product Purpose

Swift UI is a native iPhone app that hosts a complete phone-interface environment: lock concept, launcher, dock, app switching, notification and control panels, search, settings, and 50 embedded apps. It should be useful at minimal cost and demonstrate that the owner can design a coherent system and build dependable software.

Success: agreed functional scenarios pass, every catalog entry carries an accurate status, public branding is consistent, persistence and migration hold, accessibility and recovery states are verified, CI passes, documentation matches behavior, and a versioned GitHub release ships from the verified commit.

## Positioning

A full, faithful phone environment inside one ordinary iOS app, with an original Swift UI identity on the product's own surfaces. It is not a vaguely iOS-inspired imitation: embedded reproductions match the reference app's real layout, density, navigation and small interactions, and every surface tells the truth about what is working, connected, sample, or concept.

## Operating Context

Three experiences inside one product, sharing state rather than duplicating it:

- **Everyday:** local/native functionality and optional connections.
- **Portfolio demonstration:** a curated tour with safe sample content and explanations of design decisions.
- **Concept lab:** clearly identified experiments that are not operational integrations.

Experimental and sample data stay separate from personal data. The app runs inside the real iOS system; it does not replace the OS and must never trap the user.

## Capabilities and Constraints

- Native SwiftUI, with UIKit or other Apple frameworks where a capability needs them. No web front end, new backend, third-party package, or wholesale rewrite without a stated reason.
- First polished release targets iPhone. iPad and Mac are later adaptations. Deployment target stays iOS 17; newer effects remain availability-guarded.
- Core functionality needs no paid AI subscription, paid external API, developer registration, or pasted API key. Bring-your-own-key tools may remain optional. No mandatory recurring cloud cost.
- Each catalog entry is classified as operational local/native, verified provider integration, explicit external handoff, or concept demonstration, with an owner-readable completion check. Unfinished core work is not reclassified as an experiment.
- Controls affect exactly the scope they name. Device facts (battery, connectivity, carrier, storage) come from supported APIs or are shown honestly as unknown, unavailable, or sample.
- iPhone 18 Pro (Dynamic Island) is a named verification target alongside compact and large iPhones. No pretend hardware island; layout derives from safe areas.
- Named release requirements: Search-pill page scrubbing, fewer accidental host-app exits, truthful device status, and correct iPhone 18 Pro safe-area/Dynamic Island behavior, each with independent reevaluation.
- Technical identifiers (`IndicaOS` project, scheme, bundle ID `com.indicaos.prototype`, `indicaos://oauth/spotify` callback, persistence and Keychain keys) are compatibility contracts. Rename only with a migration and verification plan.
- Existing extracted calculator engine and its tests are reused and extended.

## Brand Commitments

- Product name: **Swift UI**, with the space. "SwiftUI" means Apple's framework. Formerly Indica OS, briefly Swift OS. Settled; not to be reopened.
- Full branding overhaul: identity, interface, icons, motion, copy, onboarding, documentation, GitHub presentation.
- The former look (purple, champagne, rounded type, glass, icon gradients) is evidence of function, not a binding aesthetic.
- Brand direction is the owner's choice from three materially different presented directions; logo exploration follows that selection.
- Original branding applies to product identity and deliberately original surfaces. Embedded reproductions of existing apps keep the reference app's conventions instead of being reskinned.

## Evidence on Hand

- Repository: https://github.com/Bryce-Whittsette/indica-os, two "Initial release" commits, no tags or releases, one CI workflow (`.github/workflows/build.yml`: calculator checks plus unsigned simulator build; last run passed 2026-09-10).
- Baseline: on 2026-11-03 the Debug build succeeded with Xcode 27.2 and ran on the iPhone 18 Pro simulator (iOS 27.2). Lock and home screens were captured; no other surfaces verified yet.
- `docs/images/home.png` is a historical capture, not current evidence.
- Spotify OAuth and developer AI request code exist but have not been exercised against live accounts.
- None exist and none may be invented: testimonials, adoption numbers, press, biography, credentials, or product achievements.

## Product Principles

1. **Truth over theater.** Every status, control, notification and device value reflects what actually happened or is labeled as sample or concept.
2. **Faithful where reproducing, original where owning.** Match the reference app's real behavior; express the Swift UI brand on its own surfaces.
3. **Useful for free.** Local and native capabilities first, official handoffs next, optional provider connections last.
4. **Work survives movement.** Drafts and state persist across app switching, relaunch and interruption.
5. **Evidence before claims.** A source parse, a build, a simulator check, a device test and a live provider test are different claims, and are reported as such.

## Accessibility & Inclusion

Respect Dynamic Type through the largest sizes, VoiceOver focus and actions, sufficient contrast, Reduce Motion, and Reduce Transparency. Provide 44-point minimum targets for primary controls, and an accessible alternative wherever a gesture is the primary shortcut (for example previous/next-page actions with page announcements for scrubbing).
