import GiftUI

package enum SemanticLayoutPrimitive: Equatable, Sendable {
    case proxy
    case vStack(alignment: HorizontalAlignment, spacing: GeometryScalar)
    case hStack(alignment: VerticalAlignment, spacing: GeometryScalar)
    case zStack(alignment: Alignment)
    case spacer(minLength: GeometryScalar)
    case text
    case canvas

    package init<Payload>(
        payload: borrowing Payload
    ) where Payload: _GiftUISemanticPrimitivePayload {
        let payloadCopy = copy payload
        if let stack = payloadCopy as? _GiftUIVStackPayload {
            self = .vStack(alignment: stack.alignment, spacing: stack.spacing)
        } else if let stack = payloadCopy as? _GiftUIHStackPayload {
            self = .hStack(alignment: stack.alignment, spacing: stack.spacing)
        } else if let stack = payloadCopy as? _GiftUIZStackPayload {
            self = .zStack(alignment: stack.alignment)
        } else if let spacer = payloadCopy as? _GiftUISpacerPayload {
            self = .spacer(minLength: spacer.minLength)
        } else if payloadCopy is _GiftUITextPayload {
            self = .text
        } else if payloadCopy is Canvas {
            self = .canvas
        } else {
            self = .proxy
        }
    }
}

package enum SemanticLayoutModifier: Equatable, Sendable {
    case passthrough
    case padding(edges: EdgeSet, length: GeometryScalar)
    case paddingInsets(EdgeInsets)
    case fixedFrame(
        width: GeometryScalar?,
        height: GeometryScalar?,
        alignment: Alignment
    )
    case flexibleFrame(
        minWidth: GeometryScalar?,
        maxWidth: FrameLimit?,
        minHeight: GeometryScalar?,
        maxHeight: FrameLimit?,
        alignment: Alignment
    )

    package init?<Payload>(
        payload: borrowing Payload
    ) where Payload: _GiftUISemanticModifierPayload {
        let payloadCopy = copy payload
        if payloadCopy is _GiftUIForegroundStylePayload
            || payloadCopy is _GiftUIBackgroundPayload
        {
            self = .passthrough
        } else if let padding = payloadCopy as? _GiftUIPaddingPayload {
            self = .padding(edges: padding.edges, length: padding.length)
        } else if let padding = payloadCopy as? _GiftUIPaddingInsetsPayload {
            self = .paddingInsets(padding.insets)
        } else if let frame = payloadCopy as? _GiftUIFixedFramePayload {
            self = .fixedFrame(
                width: frame.width,
                height: frame.height,
                alignment: frame.alignment
            )
        } else if let frame = payloadCopy as? _GiftUIFlexibleFramePayload {
            self = .flexibleFrame(
                minWidth: frame.minWidth,
                maxWidth: frame.maxWidth,
                minHeight: frame.minHeight,
                maxHeight: frame.maxHeight,
                alignment: frame.alignment
            )
        } else {
            return nil
        }
    }
}

package protocol SemanticLayoutView {
    associatedtype Identity: Equatable, Sendable

    var rootIdentity: Identity { get }
    var scopeCount: UInt16 { get }

    func primitive(at identity: Identity) -> SemanticLayoutPrimitive?
    func childCount(of identity: Identity) -> UInt16?
    func child(of identity: Identity, at index: UInt16) -> Identity?

    func modifierCount(of identity: Identity) -> UInt16?
    func modifierScope(of identity: Identity, at index: UInt16) -> Identity?
    func modifier(
        of identity: Identity,
        at index: UInt16
    ) -> SemanticLayoutModifier?

    func textScalarCount(of identity: Identity) -> UInt16?
    func textScalar(of identity: Identity, at index: UInt16) -> UInt32?
}

package protocol SemanticLayoutResultStorage: SemanticLayoutView {
    var maximumStructuralOccurrences: UInt16 { get }
    var maximumBodyEvaluations: UInt16 { get }
    var maximumSemanticOccurrences: UInt16 { get }
    var maximumModifierApplications: UInt16 { get }
    var maximumActionOccurrences: UInt16 { get }

    mutating func beginSemanticResult() -> Bool
    mutating func stageStructuralOccurrence(identity: borrowing Identity) -> Bool
    mutating func stageBodyEvaluation(identity: borrowing Identity) -> Bool
    mutating func stagePrimitive<Payload>(
        identity: borrowing Identity,
        primitive: SemanticLayoutPrimitive,
        payload: borrowing Payload
    ) -> Bool where Payload: _GiftUISemanticPrimitivePayload
    mutating func stageModifier<Payload>(
        identity: borrowing Identity,
        modifier: SemanticLayoutModifier,
        payload: borrowing Payload,
        chainIndex: UInt16
    ) -> Bool where Payload: _GiftUISemanticModifierPayload
    mutating func stageActionOccurrence(identity: borrowing Identity) -> Bool
    mutating func publishSemanticResult(_ summary: SemanticExpansionSummary) -> Bool
    mutating func discardSemanticResult()
    mutating func resetSemanticResult()
}

package struct SemanticLayoutResultSink<Storage>: SemanticExpansionSink,
    SemanticLayoutView
where Storage: SemanticLayoutResultStorage {
    package var storage: Storage

    package init(storage: Storage) {
        self.storage = storage
    }

    package var maximumStructuralOccurrences: UInt16 {
        storage.maximumStructuralOccurrences
    }

    package var maximumBodyEvaluations: UInt16 {
        storage.maximumBodyEvaluations
    }

    package var maximumSemanticOccurrences: UInt16 {
        storage.maximumSemanticOccurrences
    }

    package var maximumModifierApplications: UInt16 {
        storage.maximumModifierApplications
    }

    package var maximumActionOccurrences: UInt16 {
        storage.maximumActionOccurrences
    }

    package mutating func beginExpansion() -> Bool {
        storage.beginSemanticResult()
    }

    package mutating func stageStructuralOccurrence(
        identity: borrowing Storage.Identity
    ) -> Bool {
        storage.stageStructuralOccurrence(identity: identity)
    }

    package mutating func stageBodyEvaluation(
        identity: borrowing Storage.Identity
    ) -> Bool {
        storage.stageBodyEvaluation(identity: identity)
    }

    package mutating func stageSemanticOccurrence<Payload>(
        identity: borrowing Storage.Identity,
        payload: borrowing Payload
    ) -> Bool where Payload: _GiftUISemanticPrimitivePayload {
        storage.stagePrimitive(
            identity: identity,
            primitive: SemanticLayoutPrimitive(payload: payload),
            payload: payload
        )
    }

    package mutating func stageModifierApplication<Payload>(
        identity: borrowing Storage.Identity,
        payload: borrowing Payload,
        chainIndex: UInt16
    ) -> Bool where Payload: _GiftUISemanticModifierPayload {
        guard let modifier = SemanticLayoutModifier(payload: payload) else {
            return false
        }
        return storage.stageModifier(
            identity: identity,
            modifier: modifier,
            payload: payload,
            chainIndex: chainIndex
        )
    }

    package mutating func stageActionOccurrence<Action>(
        identity: borrowing Storage.Identity,
        action: borrowing Action
    ) -> Bool where Action: GiftUIAction {
        _ = action
        return storage.stageActionOccurrence(identity: identity)
    }

    package mutating func publishExpansion(
        _ summary: SemanticExpansionSummary
    ) -> Bool {
        storage.publishSemanticResult(summary)
    }

    package mutating func discardExpansion() {
        storage.discardSemanticResult()
    }

    package mutating func resetExpansion() {
        storage.resetSemanticResult()
    }

    package var rootIdentity: Storage.Identity {
        storage.rootIdentity
    }

    package var scopeCount: UInt16 {
        storage.scopeCount
    }

    package func primitive(
        at identity: Storage.Identity
    ) -> SemanticLayoutPrimitive? {
        storage.primitive(at: identity)
    }

    package func childCount(of identity: Storage.Identity) -> UInt16? {
        storage.childCount(of: identity)
    }

    package func child(
        of identity: Storage.Identity,
        at index: UInt16
    ) -> Storage.Identity? {
        storage.child(of: identity, at: index)
    }

    package func modifierCount(of identity: Storage.Identity) -> UInt16? {
        storage.modifierCount(of: identity)
    }

    package func modifierScope(
        of identity: Storage.Identity,
        at index: UInt16
    ) -> Storage.Identity? {
        storage.modifierScope(of: identity, at: index)
    }

    package func modifier(
        of identity: Storage.Identity,
        at index: UInt16
    ) -> SemanticLayoutModifier? {
        storage.modifier(of: identity, at: index)
    }

    package func textScalarCount(of identity: Storage.Identity) -> UInt16? {
        storage.textScalarCount(of: identity)
    }

    package func textScalar(
        of identity: Storage.Identity,
        at index: UInt16
    ) -> UInt32? {
        storage.textScalar(of: identity, at: index)
    }
}

package extension SemanticLayoutResultSink where Storage: SemanticRenderResultStorage {
    var renderView: Storage.RenderView {
        storage.renderView
    }
}
