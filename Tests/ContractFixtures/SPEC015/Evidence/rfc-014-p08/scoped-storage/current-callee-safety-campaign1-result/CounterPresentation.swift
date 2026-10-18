import CounterSchema
import GiftUI
@usableFromInline


package enum CounterAction: UInt16, GiftUIAction {
    case increment, reset
}
@usableFromInline


package func counterText(_ value: UInt8) -> BoundedText {
    switch value {
    case 0: BoundedText("0")!
    case 1: BoundedText("1")!
    case 2: BoundedText("2")!
    case 3: BoundedText("3")!
    case 4: BoundedText("4")!
    case 5: BoundedText("5")!
    case 6: BoundedText("6")!
    case 7: BoundedText("7")!
    case 8: BoundedText("8")!
    default: BoundedText("9")!
    }
}
@usableFromInline


package struct CounterRoot<D:CounterReadDomain>: View {@usableFromInline package typealias Domain = D

    package let model:_GiftUIModelKey<CounterModelSchema>

    package init(model: _GiftUIModelKey<CounterModelSchema>) { self.model = model }
@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    
        try VStack {() throws(_GiftUIAccessFailure) in 
            Text<D>(counterText((try CounterRead<D>(model, read: read)).value))
            try Button(action: CounterAction.increment) { () throws(_GiftUIAccessFailure) in Text<D>("Increment") }
                .disabled((try CounterRead<D>(model, read: read)).value == 9)
            try Button(action: CounterAction.reset) { () throws(_GiftUIAccessFailure) in Text<D>("Reset") }
                .disabled((try CounterRead<D>(model, read: read)).value == 0)
            if (((try CounterRead<D>(model, read: read)).value > 0) ? ((try CounterRead<D>(model, read: read)).value < 9) : false) {
                CounterBadge<D>(value: (try CounterRead<D>(model, read: read)).value)
            }
        }
}
}
@usableFromInline


package struct CounterBadge<D:CounterReadDomain>: View {@usableFromInline package typealias Domain = D

    package let value: UInt8
@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    
        Text<D>(counterText(value)).padding(1).foregroundStyle(.white)
}
}
@usableFromInline


package struct ArityZero<D:CounterReadDomain>: View { @usableFromInline package typealias Domain = D

@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    EmptyView<D>()
}}
@usableFromInline

package struct ArityOne<D:CounterReadDomain>: View { @usableFromInline package typealias Domain = D

@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    Text<D>("1") 
}}
@usableFromInline

package struct ArityTwo<D:CounterReadDomain>: View { @usableFromInline package typealias Domain = D

@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    Text<D>("1"); Text<D>("2") 
}}
@usableFromInline

package struct ArityThree<D:CounterReadDomain>: View { @usableFromInline package typealias Domain = D

@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    Text<D>("1"); Text<D>("2"); Text<D>("3") 
}}
@usableFromInline

package struct ArityFour<D:CounterReadDomain>: View { @usableFromInline package typealias Domain = D

@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    Text<D>("1"); Text<D>("2"); Text<D>("3"); Text<D>("4") 
}}
@usableFromInline

package struct ArityFive<D:CounterReadDomain>: View { @usableFromInline package typealias Domain = D

@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    Text<D>("1"); Text<D>("2"); Text<D>("3"); Text<D>("4"); Text<D>("5") 
}}
@usableFromInline

package struct ArityProbe<D:CounterReadDomain>: View {@usableFromInline package typealias Domain = D

@usableFromInline

    package init() {}
@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    
        try VStack {() throws(_GiftUIAccessFailure) in 
            ArityZero<D>(); ArityOne<D>(); ArityTwo<D>(); ArityThree<D>()
            try VStack { () throws(_GiftUIAccessFailure) in ArityFour<D>(); ArityFive<D>() }
        }
}
}

@ViewBuilder
package func freeLabels<D:CounterReadDomain>(domain:D.Type) throws(_GiftUIAccessFailure)-> some View<D> { Text<D>("a"); Text<D>("b") }
@usableFromInline

package struct HelperProbe<D:CounterReadDomain>: View {@usableFromInline package typealias Domain = D

@usableFromInline

    package init() {}
@ViewBuilder
@inlinable
@inline(__always)
package func _giftUI_caption(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    Text<D>("caption") 
}
    @ViewBuilder package func makeLabel(read:borrowing _GiftUIFrameRead<D>) throws(_GiftUIAccessFailure)-> some View<D> { Text<D>("method") }
@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    (try _giftUI_caption(read: read)); try makeLabel(read: read); try freeLabels(domain: D.self) 
}
}

@ObservableStateHost
@usableFromInline

package struct StateHostWitnessProbe<D:CounterReadDomain>: View {@usableFromInline package typealias Domain = D

@usableFromInline

    package init() {}
@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    Text<D>("state host witness") 
}
}
@usableFromInline


package struct LazyProbe<D:CounterReadDomain>: View {@usableFromInline package typealias Domain = D

    package let model:_GiftUIModelKey<CounterModelSchema>
    package init(model: _GiftUIModelKey<CounterModelSchema>) { self.model = model }
@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    
        let absent: UInt8? = nil
        let present: UInt8? = 7
        Text<D>(counterText(try { () throws(_GiftUIAccessFailure) in if let value = absent { return value }; return (try CounterRead<D>(model, read: read)).value }()))
        Text<D>(counterText(try { () throws(_GiftUIAccessFailure) in if let value = present { return value }; return (try CounterRead<D>(model, read: read)).value }()))
        if (((try CounterRead<D>(model, read: read)).value == 9) ? true : ((try CounterRead<D>(model, read: read)).value > 0)) { Text<D>("or") }
        if !((((try CounterRead<D>(model, read: read)).value == 0) ? ((try CounterRead<D>(model, read: read)).value > 0) : false)) { Text<D>("and") }
}
}
@usableFromInline

package struct SwitchProbe<D:CounterReadDomain>: View {@usableFromInline package typealias Domain = D

    package let model:_GiftUIModelKey<CounterModelSchema>
    package init(model: _GiftUIModelKey<CounterModelSchema>) { self.model = model }
@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    
        switch (try CounterRead<D>(model, read: read)).value {
        case 0: Text<D>("zero")
        case 1...8: Text<D>("middle")
        default: Text<D>("nine")
        }
}
}
@usableFromInline

package struct ArgumentOrderProbe<D:CounterReadDomain>: View {@usableFromInline package typealias Domain = D

    package let first:_GiftUIModelKey<CounterModelSchema>
    package let second:_GiftUIModelKey<CounterModelSchema>
    package init(first: _GiftUIModelKey<CounterModelSchema>, second: _GiftUIModelKey<CounterModelSchema>) { self.first = first; self.second = second }
@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    Text<D>(counterText((try CounterRead<D>(first, read: read)).value + (try CounterRead<D>(second, read: read)).value)) 
}
}
@usableFromInline

package struct SiblingFailureProbe<D:CounterReadDomain>: View {@usableFromInline package typealias Domain = D

    package let first:_GiftUIModelKey<CounterModelSchema>
    package let second:_GiftUIModelKey<CounterModelSchema>
    package init(first: _GiftUIModelKey<CounterModelSchema>, second: _GiftUIModelKey<CounterModelSchema>) { self.first = first; self.second = second }
@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    CounterRoot<D>(model: first); CounterRoot<D>(model: second) 
}
}
