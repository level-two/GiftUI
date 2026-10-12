import GiftUI
import GiftUIDrawing
import GiftUISemanticCore
import P08CounterSchema
import P08CounterPresentation

package typealias CounterPayload = CanvasSemanticPayload<CounterValueTable.CaptureStorage>

// Finite type metadata only. These inert samples expose the existing API's
// opaque modifier types; no sample is expanded, bound, stored or used as input.
// All occurrence paths and child positions come from actual traversal.
package enum CounterRoles: SemanticDeclarationRoles {
    private static func matches<V, Sample>(_ type: V.Type, _ sample: Sample) -> Bool { V.self == Sample.self }
    package static func role<V>(of type: V.Type) -> SemanticRecordingRole? {
        if V.self == CounterScreen<CounterDomain>.self { return .init(rawValue: 1) }
        if V.self == CounterScreen<CounterDomain>.Body.self { return .init(rawValue: 2) }
        if V.self == Text<CounterDomain>.self { return .init(rawValue: 3) }
        if V.self == Button<CounterAction, Text<CounterDomain>>.self { return .init(rawValue: 4) }
        if V.self == CounterCanvas<CounterDomain>.self { return .init(rawValue: 5) }
        if V.self == CounterAction.self { return .init(rawValue: 6) }
        let label = Text<CounterDomain>("")
        let button = try! Button(action: CounterAction.increment) { Text<CounterDomain>("") }
        let disabled = button.disabled(false)
        // The key is used solely to select the generic opaque frame type.
        let canvas = CounterCanvas<CounterDomain>(model: .init(ownerInstance: 0, allocationGeneration: 0, slot: 0)).frame(width: 48, height: 16)
        if matches(type, disabled) { return .init(rawValue: 7) }
        if matches(type, canvas) { return .init(rawValue: 8) }
        if matches(type, TupleView5(label, label, disabled, disabled, canvas)) { return .init(rawValue: 9) }
        return nil
    }
    package static func modifierDiscriminator<V>(of type: V.Type) -> UInt16 { 0 }
}
