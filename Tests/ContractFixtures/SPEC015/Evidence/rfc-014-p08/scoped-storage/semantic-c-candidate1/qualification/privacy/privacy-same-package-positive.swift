import GiftUI
import P08CounterSchema
import P08CounterPresentation
package func read<D: CounterReadDomain>(_ key: _GiftUIModelKey<CounterModelSchema>, read: borrowing _GiftUIFrameRead<D>) throws(_GiftUIAccessFailure) -> UInt8 { try CounterRead<D>(key, read: read).value }
package func visit<D: CounterReadDomain, V: _GiftUIObservableStateDeclarationVisitor & ~Copyable & ~Escapable>(_: D.Type, visitor: inout V) { var screen = CounterScreen<D>(); screen._giftUIVisitObservableStateDeclarations(&visitor) }
