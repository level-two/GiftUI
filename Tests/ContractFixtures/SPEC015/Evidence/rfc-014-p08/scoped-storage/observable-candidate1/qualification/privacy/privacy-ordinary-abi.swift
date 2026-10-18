import GiftUI
import P08CounterSchema
@ObservableStateHost
public struct OrdinaryHost<D: _GiftUIReadDomain>: View {
 public typealias Domain = D
 @State<CounterModelSchema>(seed: CounterModelSchemaSeed(value: 0)) private var model: _GiftUIModelKey<CounterModelSchema>?
 private var dependency: UInt8 = 0
 public func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>) throws(_GiftUIAccessFailure) -> EmptyView<D> { _ = dependency; return EmptyView<D>() }
}
