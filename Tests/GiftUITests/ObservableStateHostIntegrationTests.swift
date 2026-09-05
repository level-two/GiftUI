import XCTest

@testable import GiftUI

final class ObservableStateHostIntegrationTests: XCTestCase {
    func testGeneratedHostVisitsPrivateDirectStateInLexicalOrder() {
        var host = MacroGeneratedHost()
        var visitor = OrdinalRecordingVisitor()

        host._giftUIVisitObservableStateDeclarations(&visitor)

        XCTAssertEqual(visitor.ordinals, [0, 1])
    }
}

@ObservableStateHost
private struct MacroGeneratedHost: View {
    @State private var first = MacroObservableModel()
    @State private var second = MacroObservableModel()

    var body: some View {
        MacroLeaf()
    }
}

private final class MacroObservableModel: _GiftUIObservableReference {
    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}

private struct MacroLeaf: View {
    var body: Never {
        fatalError("MacroLeaf.body must remain unevaluated")
    }
}

private struct OrdinalRecordingVisitor: _GiftUIObservableStateDeclarationVisitor {
    var ordinals: [UInt16] = []

    mutating func visit<Value: _GiftUIObservableReference>(
        _ state: inout State<Value>,
        declarationOrdinal: UInt16
    ) {
        ordinals.append(declarationOrdinal)
    }
}
