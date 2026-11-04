import QuartzCore
import SwiftUI

/// The live page position. It's separate from `HomePager` so only the views that
/// move with it update on every frame; app icons don't.
@MainActor
final class HomePagerMotion: ObservableObject {
    @Published fileprivate(set) var position: CGFloat = 0
}

/// One continuous page position for the Home Screen, driven by finger swipes and
/// Search pill scrubbing alike. `motion.position` is always what's on screen, so
/// touching the pages mid-settle continues from there instead of jumping. It lives
/// above `HomeScreen`, which is destroyed when an app opens, so the page survives.
@MainActor
final class HomePager: ObservableObject {
    private enum Interaction {
        case none
        case undecided
        case ignored
        case swiping(anchor: CGFloat, translationAtStart: CGFloat, startPage: Int)
        case scrubbing(anchor: CGFloat, translationAtStart: CGFloat)
    }

    /// The nearest page.
    @Published private(set) var page = 0
    /// True while a finger swipe owns the pages, which cancels icon press feedback.
    @Published private(set) var isSwiping = false

    let motion = HomePagerMotion()
    var pageCount = 1
    var reducesMotion = false

    /// Set when a touch moved the pages or stopped them moving, so the release
    /// doesn't also count as a tap.
    private(set) var suppressesTap = false

    private var interaction = Interaction.none
    private var velocity: CGFloat = 0
    private var target: CGFloat = 0
    private var displayLink: CADisplayLink?
    private var lastFrameTime: CFTimeInterval = 0

    private static let hysteresis: CGFloat = 10
    private static let swipeEdgeDimension: CGFloat = 1
    private static let scrubEdgeDimension: CGFloat = 0.2
    private static let maximumSwipeVelocity: CGFloat = 4
    private static let maximumScrubVelocity: CGFloat = 2
    static let scrubPointsPerPage: CGFloat = 44

    private var isSettling: Bool { displayLink != nil }

    // MARK: Finger swipes

    func swipeChanged(translation: CGSize, pageWidth: CGFloat) {
        switch interaction {
        case .none:
            // A finger landed on the pages: stop wherever they are right now.
            suppressesTap = isSettling
            stopSpring()
            interaction = .undecided
        case .undecided:
            guard hypot(translation.width, translation.height) >= Self.hysteresis else { return }
            if abs(translation.width) > abs(translation.height) {
                interaction = .swiping(
                    anchor: PagerPhysics.unclamped(
                        motion.position, pageCount: pageCount, dimension: Self.swipeEdgeDimension
                    ),
                    translationAtStart: translation.width,
                    startPage: page
                )
                suppressesTap = true
                isSwiping = true
            } else {
                // Not a page swipe. If this touch stopped the pages mid-settle, let them finish.
                interaction = .ignored
                settleIfBetweenPages()
            }
        case .swiping(let anchor, let translationAtStart, _):
            let raw = anchor - (translation.width - translationAtStart) / pageWidth
            setPosition(PagerPhysics.softClamped(raw, pageCount: pageCount, dimension: Self.swipeEdgeDimension))
        default:
            break
        }
    }

    func swipeEnded(velocity gestureVelocity: CGFloat, pageWidth: CGFloat) {
        // A second finger on the Search pill owns the pages until it lifts.
        if case .scrubbing = interaction { return }
        if case .swiping(_, _, let startPage) = interaction {
            let pagesPerSecond = limit(-gestureVelocity / pageWidth, to: Self.maximumSwipeVelocity)
            let landing = PagerPhysics.swipeTarget(
                position: motion.position,
                velocity: pagesPerSecond,
                startPage: startPage,
                pageCount: pageCount
            )
            settle(to: landing, velocity: pagesPerSecond)
        } else {
            settleIfBetweenPages()
        }
        interaction = .none
        isSwiping = false
        clearTapSuppressionAfterRelease()
    }

    /// The system took the touch away, so no end event arrives. Go to the nearest page.
    func touchCancelled() {
        switch interaction {
        case .none, .scrubbing:
            return
        default:
            interaction = .none
            isSwiping = false
            settleIfBetweenPages()
            clearTapSuppressionAfterRelease()
        }
    }

    /// The button's action and this gesture's end arrive in no guaranteed order, so
    /// this outlasts the release instead of clearing at it. A quick tap right after a
    /// swipe, whose touch-down may not have reached this gesture yet, still counts.
    private func clearTapSuppressionAfterRelease() {
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(80))
            if case .none = interaction { suppressesTap = false }
        }
    }

    /// HomeScreen was destroyed mid-gesture, say when a second finger opened an app, so
    /// no end event arrived. Called when it comes back.
    func homeDidAppear() {
        switch interaction {
        case .none:
            break
        default:
            interaction = .none
            isSwiping = false
            suppressesTap = false
            settleIfBetweenPages()
        }
    }

    /// A long press took this touch, so its release shouldn't also open an app.
    func consumeTouchAsLongPress() {
        suppressesTap = true
    }

    // MARK: Search pill scrubbing

    /// The hold completed. `translation` is where the finger is now, so any slight
    /// movement during the hold doesn't jump the pages when scrubbing starts.
    func beginScrub(translation: CGFloat) {
        stopSpring()
        interaction = .scrubbing(
            anchor: PagerPhysics.unclamped(
                motion.position, pageCount: pageCount, dimension: Self.scrubEdgeDimension
            ),
            translationAtStart: translation
        )
    }

    func scrubChanged(translation: CGFloat) {
        guard case .scrubbing(let anchor, let translationAtStart) = interaction else { return }
        let raw = anchor + (translation - translationAtStart) / Self.scrubPointsPerPage
        setPosition(PagerPhysics.softClamped(raw, pageCount: pageCount, dimension: Self.scrubEdgeDimension))
    }

    /// Releases on the nearest page: scrubbing is deliberate, so it doesn't project.
    func scrubEnded(velocity gestureVelocity: CGFloat = 0) {
        guard case .scrubbing = interaction else { return }
        interaction = .none
        let pagesPerSecond = limit(gestureVelocity / Self.scrubPointsPerPage, to: Self.maximumScrubVelocity)
        settle(
            to: PagerPhysics.clampedPage(Int(motion.position.rounded()), pageCount: pageCount),
            velocity: pagesPerSecond
        )
    }

    // MARK: Direct moves

    /// VoiceOver actions and other non-gesture page changes.
    func go(to newPage: Int) {
        settle(to: PagerPhysics.clampedPage(newPage, pageCount: pageCount), velocity: 0)
    }

    // MARK: Motion

    private func settleIfBetweenPages() {
        let nearest = PagerPhysics.clampedPage(Int(motion.position.rounded()), pageCount: pageCount)
        guard motion.position != CGFloat(nearest) else { return }
        settle(to: nearest, velocity: 0)
    }

    private func settle(to page: Int, velocity initialVelocity: CGFloat) {
        target = CGFloat(page)
        // Reduce Motion: no slide. The page changes in place.
        guard !reducesMotion else {
            stopSpring()
            setPosition(target)
            return
        }
        velocity = initialVelocity
        startSpring()
    }

    private func startSpring() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: DisplayLinkTarget { [weak self] link in
            MainActor.assumeIsolated { self?.advance(link) }
        }, selector: #selector(DisplayLinkTarget.tick(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
        lastFrameTime = 0
    }

    private func stopSpring() {
        displayLink?.invalidate()
        displayLink = nil
        velocity = 0
    }

    private func advance(_ link: CADisplayLink) {
        let elapsed = lastFrameTime == 0 ? link.duration : link.timestamp - lastFrameTime
        lastFrameTime = link.timestamp

        let next = PagerPhysics.springStep(
            position: motion.position,
            velocity: velocity,
            target: target,
            response: 0.34,
            // The exact solution stays stable across any gap. Capping a long gap
            // only keeps a stall from skipping the whole settle in one frame.
            elapsed: CGFloat(min(elapsed, 0.1))
        )
        velocity = next.velocity

        if abs(next.position - target) < 0.0005, abs(next.velocity) < 0.01 {
            stopSpring()
            setPosition(target)
        } else {
            setPosition(next.position)
        }
    }

    private func setPosition(_ position: CGFloat) {
        motion.position = position
        let nearest = PagerPhysics.clampedPage(Int(position.rounded()), pageCount: pageCount)
        if nearest != page {
            page = nearest
        }
    }

    private func limit(_ value: CGFloat, to maximum: CGFloat) -> CGFloat {
        min(max(value, -maximum), maximum)
    }
}

/// `CADisplayLink` retains its target, so this keeps the link from retaining the pager.
private final class DisplayLinkTarget: NSObject {
    private let onFrame: (CADisplayLink) -> Void

    init(onFrame: @escaping (CADisplayLink) -> Void) {
        self.onFrame = onFrame
    }

    @objc func tick(_ link: CADisplayLink) {
        onFrame(link)
    }
}

/// A modifier so that a position change only moves the pages. Its `content` is a
/// reference to the views below, which don't rebuild, so no icon updates per frame.
private struct PagerOffset: ViewModifier {
    @ObservedObject var motion: HomePagerMotion
    let pageWidth: CGFloat

    func body(content: Content) -> some View {
        content.offset(x: -motion.position * pageWidth)
    }
}

/// Lays the pages side by side and moves them with the shared position. A plain
/// drag runs alongside the icons' buttons, so a press shows instantly and a swipe
/// that turns out to be a page move cancels it.
struct HomePagerTrack<Content: View>: View {
    let motion: HomePagerMotion
    let pager: HomePager
    let pageCount: Int
    let pageWidth: CGFloat
    let onLongPress: () -> Void
    @ViewBuilder let content: () -> Content

    /// Resets by itself if the system cancels the touch, when `onEnded` doesn't run.
    @GestureState private var isTouching = false

    var body: some View {
        content()
            .frame(width: pageWidth * CGFloat(pageCount), alignment: .leading)
            .modifier(PagerOffset(motion: motion, pageWidth: pageWidth))
            .frame(width: pageWidth, alignment: .leading)
            .frame(maxHeight: .infinity, alignment: .top)
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isTouching) { _, state, _ in state = true }
                    .onChanged { value in
                        pager.swipeChanged(translation: value.translation, pageWidth: pageWidth)
                    }
                    .onEnded { value in
                        pager.swipeEnded(velocity: value.velocity.width, pageWidth: pageWidth)
                    }
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.52).onEnded { _ in
                    pager.consumeTouchAsLongPress()
                    onLongPress()
                }
            )
            .onChange(of: isTouching) { _, touching in
                if !touching { pager.touchCancelled() }
            }
            .accessibilityScrollAction { edge in
                switch edge {
                case .trailing: pager.go(to: pager.page + 1)
                case .leading: pager.go(to: pager.page - 1)
                default: break
                }
            }
    }
}
