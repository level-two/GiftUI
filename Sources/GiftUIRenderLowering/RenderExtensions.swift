import GiftUI
import GiftUILayout
import GiftUIRenderCore
import GiftUISemanticCore

package struct RenderExtensionVisit: Equatable, Sendable {
    package let operationCount: UInt16

    package init(operationCount: UInt16) {
        self.operationCount = operationCount
    }
}

package enum RenderExtensionVisitResult: Equatable, Sendable {
    case success(RenderExtensionVisit)
    case failure(RenderProductionError)
}

package protocol RenderPreflightExtension {
    associatedtype Identity: Equatable, Sendable

    mutating func visit(
        scope: SemanticRenderScope,
        identity: Identity,
        bounds: Rect,
        clip: Rect
    ) -> RenderExtensionVisitResult
}

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
}
