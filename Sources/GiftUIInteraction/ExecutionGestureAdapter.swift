import GiftUI
import GiftUIExecution

@usableFromInline
package enum ExecutionGestureAdapter {
    @inlinable
    package static func down<Resolver>(
        at point: Point,
        capture: inout PointerActionCapture<Resolver.Identity>,
        resolver: borrowing Resolver
    ) -> PointerGestureOutcome<Resolver.Identity>
    where Resolver: InteractionGestureResolver & ~Copyable & ~Escapable {
        capture.cancel()
        let outcome = resolver.resolveDown(at: point)
        if case .captured(let captured) = outcome {
            capture.replace(with: captured)
        }
        return outcome
    }

    @inlinable
    package static func move<Resolver>(
        at point: Point,
        capture: inout PointerActionCapture<Resolver.Identity>,
        resolver: borrowing Resolver
    ) -> PointerGestureOutcome<Resolver.Identity>
    where Resolver: InteractionGestureResolver & ~Copyable & ~Escapable {
        guard let current = capture.current else { return .cancelled }
        let outcome = resolver.resolveMove(current, at: point)
        switch outcome {
        case .continued(let continued) where continued == current:
            capture.replace(with: continued)
        default:
            capture.cancel()
        }
        return outcome
    }

    @inlinable
    package static func up<Resolver>(
        at point: Point,
        capture: inout PointerActionCapture<Resolver.Identity>,
        resolver: borrowing Resolver
    ) -> PointerGestureOutcome<Resolver.Identity>
    where Resolver: InteractionGestureResolver & ~Copyable & ~Escapable {
        guard let current = capture.current else { return .cancelled }
        defer { capture.cancel() }
        return resolver.resolveUp(current, at: point)
    }

    @inlinable
    package static func cancel<Identity>(
        capture: inout PointerActionCapture<Identity>
    ) where Identity: Equatable & Sendable {
        capture.cancel()
    }
}
