import GiftUI
import P08CounterSchema
import P08CounterPresentation
package func reject<D: CounterReadDomain>(_ declaration: borrowing CounterScreen<D>) { _ = declaration._model }
