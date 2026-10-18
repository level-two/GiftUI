import GiftUI
import P08CounterSchema
import P08CounterPresentation
package func reject<D: CounterReadDomain>(_ declaration: borrowing CounterScreen<D>) throws(_GiftUIAccessFailure) { _ = declaration._giftUIStateStorage_model; _ = try declaration._giftUIStateKey_model() }
