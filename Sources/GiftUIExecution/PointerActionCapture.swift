import GiftUI

@usableFromInline
package struct PointerActionCapture<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    // Explicit Optional spelling avoids an implicit generic stored-default thunk.
    // The initializer below initializes the same canonical Optional type directly.
    // swift-format-ignore: UseShorthandTypeNames
    @usableFromInline internal private(set) var captured: Optional<CapturedAction<Identity>>

    @inlinable
    @inline(__always)
    package init() {
        captured = nil
    }

    @inlinable
    package var current: CapturedAction<Identity>? {
        captured
    }

    @inlinable
    package mutating func replace(
        with captured: CapturedAction<Identity>?
    ) {
        self.captured = captured
    }

    @inlinable
    mutating func captureDown<ActionView>(
        at point: Point,
        actionView: borrowing ActionView
    ) -> Bool
    where ActionView: ExecutionActionView, ActionView.Identity == Identity {
        captured = nil
        guard let identity = actionView.hit(at: point),
            let generation = actionView.generation(for: identity),
            actionView.isEnabled(identity) == true
        else {
            return false
        }

        captured = CapturedAction(
            identity: identity,
            generation: generation
        )
        return true
    }

    @inlinable
    mutating func cancelForMovement() {
        captured = nil
    }

    @inlinable
    mutating func release<ActionView>(
        at point: Point,
        provenanceValid: Bool,
        generationUnambiguous: Bool,
        actionView: borrowing ActionView
    ) -> CapturedAction<Identity>?
    where ActionView: ExecutionActionView, ActionView.Identity == Identity {
        defer { captured = nil }
        guard provenanceValid, generationUnambiguous,
            let captured,
            actionView.hit(at: point) == captured.identity,
            actionView.generation(for: captured.identity)
                == captured.generation,
            actionView.isEnabled(captured.identity) == true
        else {
            return nil
        }
        return captured
    }

    @inlinable
    package mutating func cancel() {
        captured = nil
    }
}
