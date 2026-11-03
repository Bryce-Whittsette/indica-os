# Swift UI

The product is **Swift UI**, with the space (formerly Indica OS, briefly Swift OS). "SwiftUI" without a space means Apple's framework. Upstream: https://github.com/Bryce-Whittsette/indica-os.

The Xcode project, scheme, source directory, bundle ID (`com.indicaos.prototype`), OAuth callback (`indicaos://oauth/spotify`), and persistence/Keychain keys still use `IndicaOS`. They are compatibility contracts: rename only with a migration and verification plan.

## Authority

- `docs/brief/master-brief.md` and `docs/brief/native-fidelity-addendum.md` are the owner's product, brand, engineering and release brief. They govern; do not reopen their settled decisions.
- `PRODUCT.md` is the product record derived from the brief.
- `DESIGN.md` will record the selected design system once the owner picks a brand direction. Until then, the current look is evidence of function, not a binding aesthetic.
- `README.md` and `docs/release-checks.md` describe implementation scope and verification status; update them as behavior changes.

Keep the difference between working local features, provider integrations, external handoffs and concept demonstrations visible in code, UI copy and docs.

## Build and run

Requires Xcode 26 or newer; Xcode 27.2 with the iOS 27.2 simulator runtime was verified on this Mac on 2026-11-03. Deployment target is iOS 17.

```sh
xcodebuild -project IndicaOS.xcodeproj -scheme IndicaOS -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  -derivedDataPath /tmp/swiftui-dd CODE_SIGNING_ALLOWED=NO build
```

Keep derived data outside the repo. Calculator checks:

```sh
swiftc IndicaOS/CalculatorEngine.swift Tests/CalculatorTests.swift -o /tmp/calculator-tests && /tmp/calculator-tests
```

A source parse, a build, a simulator check, a physical-device test and a live provider test are different claims. Report which one produced the evidence.

## Design skills

- `/impeccable` (`~/.claude/skills/impeccable`): use its native references (`reference/ios.md`, `reference/audit.native.md`, `reference/adapt.native.md`). Its `detect` command and browser live mode only inspect web UIs and do not validate this app.
- `/apple-design` (`~/.claude/skills/apple-design`): its examples target the web. Apply the principles through native SwiftUI: immediate press feedback, commit on release, cancellation, continuous drag tracking, velocity-aware interruptible springs, and Reduce Motion, Reduce Transparency, Dynamic Type and VoiceOver support.

## Git

Commits use the owner's GitHub-linked identity from the existing history (`Bryce Whittsette <brycewhitt@icloud.com>`), passed per commit; no git identity is configured on this machine. `main` is unprotected. CI (`.github/workflows/build.yml`) runs the calculator checks and an unsigned simulator build on every push and PR. Work goes on branches and lands through reviewable PRs.
