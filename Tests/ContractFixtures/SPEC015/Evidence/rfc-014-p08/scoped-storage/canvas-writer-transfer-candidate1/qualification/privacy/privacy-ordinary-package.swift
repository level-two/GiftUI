import GiftUI
import P08CounterSchema
@ObservableStateHost
package struct OrdinaryHost<D: CounterReadDomain>: View {
 package typealias Domain = D
 @State<CounterModelSchema>(seed: CounterModelSchemaSeed(value: 0)) private var model: _GiftUIModelKey<CounterModelSchema>?
 package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>) throws(_GiftUIAccessFailure) -> EmptyView<D> { EmptyView<D>() }
}
