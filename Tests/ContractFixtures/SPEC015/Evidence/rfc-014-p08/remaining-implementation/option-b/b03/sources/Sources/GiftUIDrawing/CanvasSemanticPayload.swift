import GiftUI
import GiftUISemanticCore

/// Owned only during candidate expansion. Transfer replaces every concrete
/// value with a marker before any Layout/Render borrow or semantic publication.
package enum CanvasSemanticPayload<Value>: SemanticRecordConsumerPayload {
    case standard(SemanticStandardPayload)
    case canvas(Value?)

    package var layoutPrimitive: SemanticLayoutPrimitive? {
        switch self {
        case .standard(let value): value.layoutPrimitive
        case .canvas: .canvas
        }
    }
    package var layoutModifier: SemanticLayoutModifier? {
        switch self {
        case .standard(let value): value.layoutModifier
        case .canvas: nil
        }
    }
    package var renderScope: SemanticRenderScope {
        switch self {
        case .standard(let value): value.renderScope
        case .canvas: .canvas
        }
    }
}

package enum CanvasSemanticPayloadCodec<Roles: SemanticDeclarationRoles, Table: CanvasValueTable>:
    SemanticRecordPayloadCodec
{
    package typealias Payload = CanvasSemanticPayload<Table.CaptureStorage>
    package static func primitive<Value: _GiftUISemanticPrimitivePayload>(
        _ value: borrowing Value, writer: borrowing SemanticPayloadWriter<Payload>
    ) -> SemanticExpansionError? {
        if let canvas = Table.payload(value) {
            return writer.store(.canvas(canvas), kind: .pendingCanvas)
        }
        return SemanticStandardPayloadCodec<Roles>.primitive(
            value, writer: writer, wrapping: { .standard($0) })
    }
    package static func modifier<Value: _GiftUISemanticModifierPayload>(
        _ value: borrowing Value, chainIndex: UInt16,
        writer: borrowing SemanticPayloadWriter<Payload>
    ) -> SemanticExpansionError? {
        SemanticStandardPayloadCodec<Roles>.modifier(
            value, chainIndex: chainIndex, writer: writer, wrapping: { .standard($0) })
    }
    package static func action<Value: GiftUIAction>(
        _ value: borrowing Value, writer: borrowing SemanticPayloadWriter<Payload>
    ) -> SemanticExpansionError? {
        SemanticStandardPayloadCodec<Roles>.action(
            value, writer: writer, wrapping: { .standard($0) })
    }
}

package enum CanvasSemanticTransfer {
    package static func stage<Table: CanvasValueTable>(
        from semantic: borrowing SemanticRecordStore<CanvasSemanticPayload<Table.CaptureStorage>>,
        into values: borrowing CanvasStagedValues<SemanticRecordReference, Table>,
        table: borrowing Table
    ) throws(DrawingError) {
        guard values.count == 0 else { throw .invariantViolation }
        let table = copy table
        do throws(SemanticExpansionError) {
            try semantic.takePendingCanvas { (identity, payload) throws(SemanticExpansionError) in
                guard case .canvas(.some(let value)) = payload else { throw .invariantViolation }
                do throws(DrawingError) {
                    try values.stage(identity: identity, value: value, table: table)
                } catch {
                    throw error == .capacityExhausted ? .capacityExhausted : .invariantViolation
                }
                payload = .canvas(nil)
            }
        } catch {
            values.discard()
            try? semantic.discardCandidate()
            throw error == .capacityExhausted ? .capacityExhausted : .invariantViolation
        }
    }
}
