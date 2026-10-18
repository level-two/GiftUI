import GiftUI
import P08CounterSchema
private struct Encloser {
@ObservableStateHost
public struct OrdinaryHost<D: _GiftUIReadDomain>: View {
 public typealias Domain = D
 @State<CounterModelSchema>(seed: CounterModelSchemaSeed(value: 0)) private var model: _GiftUIModelKey<CounterModelSchema>?
 public func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>) throws(_GiftUIAccessFailure) -> EmptyView<D> { EmptyView<D>() }
}
}
