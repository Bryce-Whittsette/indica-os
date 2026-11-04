import CoreGraphics
import Foundation

@main
enum PagerPhysicsTests {
    static func near(_ a: CGFloat, _ b: CGFloat, _ tolerance: CGFloat = 0.0001) -> Bool {
        abs(a - b) <= tolerance
    }

    static func settle(from start: CGFloat, velocity: CGFloat, target: CGFloat, frame: CGFloat) -> (CGFloat, CGFloat, CGFloat) {
        var position = start
        var speed = velocity
        var farthest = start
        for _ in 0..<Int(2 / frame) {
            (position, speed) = PagerPhysics.springStep(
                position: position, velocity: speed, target: target, response: 0.34, elapsed: frame
            )
            farthest = max(farthest, position)
        }
        return (position, speed, farthest)
    }

    static func main() {
        // Inside the pages, position passes through untouched.
        precondition(PagerPhysics.softClamped(1.25, pageCount: 3, dimension: 1) == 1.25)

        // Past either end it resists more the further it goes, and never reaches the limit.
        let small = PagerPhysics.softClamped(-0.1, pageCount: 3, dimension: 1)
        let large = PagerPhysics.softClamped(-10, pageCount: 3, dimension: 1)
        precondition(small < 0 && small > -0.1)
        precondition(large < small && large > -1)
        precondition(PagerPhysics.softClamped(2.1, pageCount: 3, dimension: 1) > 2)
        precondition(PagerPhysics.softClamped(2.1, pageCount: 3, dimension: 1) < 2.1)

        // Grabbing content already past an edge must not move it.
        for raw in [CGFloat(-3), -0.4, 0, 1.3, 2, 2.7, 9] {
            for dimension in [CGFloat(1), 0.2] {
                let shown = PagerPhysics.softClamped(raw, pageCount: 3, dimension: dimension)
                let recovered = PagerPhysics.unclamped(shown, pageCount: 3, dimension: dimension)
                precondition(near(recovered, raw, 0.001), "round trip \(raw): \(recovered)")
            }
        }

        // A slow release stays on the nearest page; a flick reaches the next one.
        precondition(PagerPhysics.swipeTarget(position: 0.3, velocity: 0, startPage: 0, pageCount: 3) == 0)
        precondition(PagerPhysics.swipeTarget(position: 0.6, velocity: 0, startPage: 0, pageCount: 3) == 1)
        precondition(PagerPhysics.swipeTarget(position: 0.1, velocity: 1.5, startPage: 0, pageCount: 3) == 1)
        // A flick against the drag goes back.
        precondition(PagerPhysics.swipeTarget(position: 0.6, velocity: -1.5, startPage: 0, pageCount: 3) == 0)
        // However hard the flick, a swipe moves one page, and never past the ends.
        precondition(PagerPhysics.swipeTarget(position: 0.2, velocity: 20, startPage: 0, pageCount: 3) == 1)
        precondition(PagerPhysics.swipeTarget(position: 2.1, velocity: 20, startPage: 2, pageCount: 3) == 2)
        precondition(PagerPhysics.swipeTarget(position: -0.1, velocity: -20, startPage: 0, pageCount: 3) == 0)

        // The spring lands on target at any frame rate, within a settled tolerance.
        for frame: CGFloat in [1.0 / 120, 1.0 / 60, 1.0 / 20] {
            let (position, speed, _) = settle(from: 0.2, velocity: 3, target: 1, frame: frame)
            precondition(near(position, 1) && near(speed, 0), "frame \(frame): \(position), \(speed)")
        }

        // Zero velocity from below never overshoots: critically damped.
        let (_, _, farthest) = settle(from: 0, velocity: 0, target: 1, frame: 1 / 120)
        precondition(farthest <= 1.0001, "overshoot \(farthest)")

        // Velocity carries into the spring: the first frame moves at the release speed.
        let first = PagerPhysics.springStep(position: 0.5, velocity: 2, target: 1, response: 0.34, elapsed: 0.0001)
        precondition(near(first.velocity, 2, 0.05), "handoff \(first.velocity)")
        precondition(near(first.position, 0.5 + 2 * 0.0001, 0.0001))

        // Two short steps equal one long step, so frame timing can't change the path.
        let once = PagerPhysics.springStep(position: 0, velocity: 1, target: 1, response: 0.34, elapsed: 0.2)
        let half = PagerPhysics.springStep(position: 0, velocity: 1, target: 1, response: 0.34, elapsed: 0.1)
        let twice = PagerPhysics.springStep(position: half.position, velocity: half.velocity, target: 1, response: 0.34, elapsed: 0.1)
        precondition(near(once.position, twice.position) && near(once.velocity, twice.velocity))

        print("Pager physics checks passed")
    }
}
