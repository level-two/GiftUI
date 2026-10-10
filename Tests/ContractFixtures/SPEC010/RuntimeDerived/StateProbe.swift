import GiftUI
import GiftUIObservableState
import GiftUIRuntimeStatic
import StateSchema
import StatePresentation

// Declaration/storage join, not the production root reconciler or callback exit.
private enum Domain: StateReadDomain {
    typealias Slot = ObservableModelReadSlot<UInt8>
    static func bind(_ key: _GiftUIModelKey<CounterSchema>, slots: Span<Slot>)
        throws(_GiftUIAccessFailure) -> Int {
        guard slots.count == 2 else { throw .invalidPhase }
        return try slots[0].ownership.pointee.bind(key, schema: slots[0].schema)
    }
    static func CounterRead_value(at index: Int, slots: Span<Slot>) -> UInt8 {
        slots[index].model.pointee!
    }
}

private struct Binder: _GiftUIObservableStateDeclarationVisitor {
    let key: _GiftUIModelKey<CounterSchema>
    var count = 0
    var initialCount = 0
    mutating func visit<S: _GiftUIModelSchema>(_ state: inout State<S>, declarationOrdinal: UInt16) {
        precondition(S.self == CounterSchema.self && declarationOrdinal == 0)
        count += 1
        if state._giftUIInitial != nil { initialCount += 1 }
        // Test-only finite schema dispatch; the production reconciler is separate.
        state._giftUIBind(_GiftUIBoundState(
            locationSlot: 1, declarationOrdinal: declarationOrdinal, registrationGeneration: 42,
            key: _GiftUIModelKey<S>(ownerInstance: key._giftUIOwnerInstance,
                allocationGeneration: key._giftUIAllocationGeneration, slot: key._giftUISlot)))
    }
}

package func stateChecks() throws(ObservableStateError) -> UInt32 {
    var checks: UInt32 = 0
    func expect(_ condition: Bool) { precondition(condition); checks += 1 }
    var namespace = ObservableModelOwnerNamespace()
    var storage = StaticObservableModelStorage<UInt8, CounterSchema>(
        identity: try namespace.issue(), schema: 4, needsCapture: false)!
    try storage.withLifetime { (scope) throws(ObservableStateError) in
        var ticket = try scope.materialize(9)
        let key = ticket.key
        var state = State<CounterSchema>(seed: CounterSchemaSeed(value: 3))
        expect(state.wrappedValue == nil)
        do throws(_GiftUIAccessFailure) { _ = try state._giftUIKey(); preconditionFailure() }
        catch { expect(error == .invalidPhase) }
        let binding = _GiftUIBoundState(locationSlot: 1, declarationOrdinal: 2,
            registrationGeneration: 42, key: key)
        if case .seed(let discarded)? = state._giftUIBind(binding) { expect(discarded.value == 3) }
        else { preconditionFailure() }
        expect(state._giftUIInitial == nil)
        expect(state._giftUIBinding?.declarationOrdinal == 2 && state._giftUIBinding?.locationSlot == 1)
        expect(state._giftUIBinding?.registrationGeneration == 42)
        expect(state.wrappedValue == key)
        let other = _GiftUIModelKey<CounterSchema>(ownerInstance: 0, allocationGeneration: 999, slot: 1)
        expect(state._giftUIBind(_GiftUIBoundState(locationSlot: 0, declarationOrdinal: 0,
            registrationGeneration: 0, key: other)) == nil)
        expect(state.wrappedValue == key)
        var candidate = State<CounterSchema>(candidate: key)
        if case .candidate(let initial)? = candidate._giftUIBind(binding) { expect(initial == key) }
        else { preconditionFailure() }
        var freshSeed = State<CounterSchema>(seed: CounterSchemaSeed(value: 255))
        freshSeed._giftUIBind(binding)
        expect(freshSeed.wrappedValue == key && freshSeed._giftUIInitial == nil)
        var root = SeededRoot<Domain>()
        var adopted = CandidateRoot<Domain>(model: key)
        var nested = NestedRoot<Domain>()
        var binder = Binder(key: key)
        root._giftUIVisitObservableStateDeclarations(&binder)
        adopted._giftUIVisitObservableStateDeclarations(&binder)
        nested._giftUIVisitObservableStateDeclarations(&binder)
        expect(binder.count == 3 && binder.initialCount == 3)
        root._giftUIVisitObservableStateDeclarations(&binder)
        expect(binder.count == 4 && binder.initialCount == 3)
        try scope.withFrame { () throws(ObservableStateError) in
            try scope.pin(key)
            do throws(_GiftUIAccessFailure) {
                try scope.withRead(Domain.self) { (read) throws(_GiftUIAccessFailure) in
                    _ = try root._giftUIEvaluate(read: read)
                    _ = try adopted._giftUIEvaluate(read: read)
                    _ = try nested._giftUIEvaluate(read: read)
                    expect(try CounterRead<Domain>(state._giftUIKey(), read: read).value == 9)
                    do throws(_GiftUIAccessFailure) {
                        _ = try SeededRoot<Domain>()._giftUIEvaluate(read: read)
                        preconditionFailure()
                    } catch { expect(error == .invalidPhase) }
                }
            } catch { throw ObservableStateError(accessFailure: error) }
        }
        try scope.release(&ticket)
    }
    return checks
}

@_cdecl("giftui_p03_state")
public func giftuiP03State() -> UInt32 {
    do { return try stateChecks() == 15 ? 0 : 1 } catch { return 2 }
}
