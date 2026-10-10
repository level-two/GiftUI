import GiftUI

// Deliberately adversarial public conformance. Compilation must currently
// succeed: the approved SPI permits copying Visitor into an escaping closure.
// Never execute a saved visitor whose root activation may have ended.
nonisolated(unsafe) var escapedVisitor: (() -> Void)?
private enum EscapingSchema: _GiftUIModelSchema { typealias Seed = UInt8 }
private struct EscapingHost: _GiftUIObservableStateHost {
    mutating func _giftUIVisitObservableStateDeclarations<
        Visitor: _GiftUIObservableStateDeclarationVisitor
    >(_ visitor: inout Visitor) {
        let saved = visitor
        escapedVisitor = {
            var later = saved
            var state = State<EscapingSchema>(seed: 0)
            later.visit(&state, declarationOrdinal: 0)
        }
    }
}
