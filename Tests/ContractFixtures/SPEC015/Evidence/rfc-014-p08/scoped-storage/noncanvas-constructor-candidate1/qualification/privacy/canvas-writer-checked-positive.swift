import GiftUI
import GiftUIDrawing
import GiftUISemanticCore
package func forward<Payload>(_ writer: borrowing SemanticPayloadWriter<Payload>, value: consuming Payload, kind: SemanticRuntimeRecord.Kind) -> SemanticExpansionError? { writer.store(consume value, kind: kind) }
