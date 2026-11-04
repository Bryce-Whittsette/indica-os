import CoreGraphics

/// The arithmetic behind the Home Screen pager, in page units: position 1.5 is
/// halfway between the second and third pages. It has no UI dependencies so the
/// checks in `Tests/PagerPhysicsTests.swift` can run it directly.
enum PagerPhysics {
    static let rubberbandConstant: CGFloat = 0.55

    /// How far past a boundary content moves for a given overshoot. The further
    /// past, the less it follows, and it never reaches `dimension`.
    static func rubberband(_ overshoot: CGFloat, dimension: CGFloat) -> CGFloat {
        let c = rubberbandConstant
        return (overshoot * dimension * c) / (dimension + c * abs(overshoot))
    }

    /// The inverse of `rubberband`, for grabbing content that is already past a
    /// boundary without it jumping.
    static func inverseRubberband(_ displaced: CGFloat, dimension: CGFloat) -> CGFloat {
        let limited = min(abs(displaced), dimension * 0.999)
        let overshoot = (limited * dimension) / (rubberbandConstant * (dimension - limited))
        return displaced < 0 ? -overshoot : overshoot
    }

    /// Maps a finger-driven position to a displayed one: unchanged between the
    /// first and last page, rubber-banded beyond them.
    static func softClamped(_ raw: CGFloat, pageCount: Int, dimension: CGFloat) -> CGFloat {
        let last = CGFloat(max(pageCount - 1, 0))
        if raw < 0 { return rubberband(raw, dimension: dimension) }
        if raw > last { return last + rubberband(raw - last, dimension: dimension) }
        return raw
    }

    /// The inverse of `softClamped`.
    static func unclamped(_ position: CGFloat, pageCount: Int, dimension: CGFloat) -> CGFloat {
        let last = CGFloat(max(pageCount - 1, 0))
        if position < 0 { return inverseRubberband(position, dimension: dimension) }
        if position > last { return last + inverseRubberband(position - last, dimension: dimension) }
        return position
    }

    /// Where a gesture is heading: the distance it would travel if it decayed
    /// like a scroll view at normal deceleration.
    static func projectedDistance(velocity: CGFloat, deceleration: CGFloat = 0.998) -> CGFloat {
        (velocity / 1000) * deceleration / (1 - deceleration)
    }

    /// The page a finger swipe lands on: the nearest to where it's heading, at
    /// most one page from the page it started on.
    static func swipeTarget(position: CGFloat, velocity: CGFloat, startPage: Int, pageCount: Int) -> Int {
        let projected = position + projectedDistance(velocity: velocity)
        let nearest = Int(projected.rounded())
        let neighbor = min(max(nearest, startPage - 1), startPage + 1)
        return clampedPage(neighbor, pageCount: pageCount)
    }

    static func clampedPage(_ page: Int, pageCount: Int) -> Int {
        min(max(page, 0), max(pageCount - 1, 0))
    }

    /// Advances a critically damped spring by `elapsed` seconds. This is the exact
    /// solution rather than a numerical step, so a dropped frame can't destabilize
    /// it, and position and velocity stay continuous when the target changes.
    /// `response` is Apple's definition: `2π / ω`, in seconds.
    static func springStep(
        position: CGFloat,
        velocity: CGFloat,
        target: CGFloat,
        response: CGFloat,
        elapsed: CGFloat
    ) -> (position: CGFloat, velocity: CGFloat) {
        let omega = 2 * .pi / response
        let a = position - target
        let b = velocity + omega * a
        let decay = exp(-omega * elapsed)
        let displacement = (a + b * elapsed) * decay
        return (target + displacement, (b - omega * (a + b * elapsed)) * decay)
    }
}
