import GiftUI
import P08CounterSchema
@ObservableStateHost
 struct OrdinaryHost<D: CounterReadDomain>: View {
 typealias Domain = D
 @State<CounterModelSchema>(seed: CounterModelSchemaSeed(value: 0)) private var model: _GiftUIModelKey<CounterModelSchema>?
 func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>) throws(_GiftUIAccessFailure) -> EmptyView<D> { EmptyView<D>() }
}
