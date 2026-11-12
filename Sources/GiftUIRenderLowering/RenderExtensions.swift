import GiftUI
import GiftUILayout
import GiftUIRenderCore
import GiftUISemanticCore

@usableFromInline
package struct RenderExtensionVisit: Equatable, Sendable {
    @usableFromInline
    package let operationCount: UInt16

    @inlinable
    @inline(__always)
    package init(operationCount: UInt16) {
        self.operationCount = operationCount
    }
}

@usableFromInline
package enum RenderExtensionVisitResult: Equatable, Sendable {
    case success(RenderExtensionVisit)
    case failure(RenderProductionError)
}

@usableFromInline
package enum RenderExtensionCompletionResult: Equatable, Sendable {
    case success
    case failure(RenderProductionError)
}

@usableFromInline
package protocol RenderPreflightExtension {
    associatedtype Identity: Equatable, Sendable

    mutating func visit(
        scope: SemanticRenderScope,
        identity: Identity,
        bounds: Rect,
        clip: Rect
    ) -> RenderExtensionVisitResult

    mutating func complete() -> RenderExtensionCompletionResult
}

@usableFromInline
package protocol RenderStreamingExtension {
    associatedtype Identity: Equatable, Sendable
    associatedtype Sink: RenderOperationSink

    mutating func visit(
        scope: SemanticRenderScope,
        identity: Identity,
        bounds: Rect,
        clip: Rect,
        sink: inout Sink
    ) -> RenderExtensionVisitResult

    mutating func complete() -> RenderExtensionCompletionResult
}
