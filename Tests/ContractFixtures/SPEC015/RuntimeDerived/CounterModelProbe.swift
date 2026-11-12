import GiftUI
import GiftUIObservableState
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif
import P08CounterSchema
import P08CounterPresentation

private func counterScopedModel(_ models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>) throws(ObservableStateError) -> Int {
    var checks = 0
    func expect(_ condition: Bool) { checks += 1; precondition(condition) }
    var ticket = try models.materialize(CounterOwnedModel(value: 0))
    let key = ticket.key
    var reports = 0
    func report() -> _GiftUIObservableChangeReportOutcome { reports += 1; return .dirtied }
    let p08ExactCase1: Bool;
    if case .success(.unchanged) = models.mutate(key, mutation: .reset, report: report) {
        p08ExactCase1 = true
    } else {
        p08ExactCase1 = false
    }; expect(p08ExactCase1)
    expect(reports == 0)
    for _ in 0 ..< 9 {
        let p08ExactCase2: Bool;
        if case .success(.dirtied) = models.mutate(key, mutation: .increment, report: report) {
            p08ExactCase2 = true
        } else {
            p08ExactCase2 = false
        }; expect(p08ExactCase2)
    }
    expect(reports == 9)
    let p08ExactCase3: Bool;
    if case .success(.unchanged) = models.mutate(key, mutation: .increment, report: report) {
        p08ExactCase3 = true
    } else {
        p08ExactCase3 = false
    }; expect(p08ExactCase3)
    expect(reports == 9)
    let p08ExactCase4: Bool;
    if case .failure(.invariantViolation) = models.mutate(key, mutation: .fact(10), report: report)
    {
        p08ExactCase4 = true
    } else {
        p08ExactCase4 = false
    }; expect(p08ExactCase4)
    expect(reports == 9)
    let p08ExactCase5: Bool;
    if case .success(.unchanged) = models.mutate(key, mutation: .fact(9), report: report) {
        p08ExactCase5 = true
    } else {
        p08ExactCase5 = false
    }; expect(p08ExactCase5)
    let p08ExactCase6: Bool;
    if case .success(.dirtied) = models.mutate(key, mutation: .reset, report: report) {
        p08ExactCase6 = true
    } else {
        p08ExactCase6 = false
    }; expect(p08ExactCase6)
    expect(reports == 10)
    let p08ExactCase7: Bool;
    if case .success(.unchanged) = models.mutate(key, mutation: .reset, report: report) {
        p08ExactCase7 = true
    } else {
        p08ExactCase7 = false
    }; expect(p08ExactCase7)
    let p08ExactCase8: Bool;
    if case .success(.dirtied) = models.mutate(key, mutation: .fact(7), report: report) {
        p08ExactCase8 = true
    } else {
        p08ExactCase8 = false
    }; expect(p08ExactCase8)
    expect(reports == 11)
    try models.beginFrame()
    let p08ExactCase9: Bool;
    if case .failure(.invalidPhaseContained) = models.mutate(
        key, mutation: .increment, report: report)
    {
        p08ExactCase9 = true
    } else {
        p08ExactCase9 = false
    }; expect(p08ExactCase9)
    expect(reports == 11)
    try models.endFrame()
    try models.release(&ticket)
    let p08ExactCase10: Bool;
    if case .failure(.staleModel) = models.mutate(key, mutation: .reset, report: report) {
        p08ExactCase10 = true
    } else {
        p08ExactCase10 = false
    }; expect(p08ExactCase10)
    expect(reports == 11)
    return checks
}
package func p08CounterModel() -> Int {
    var checks = 0
    do throws(ObservableStateError) {
        for initial: UInt8 in 0...9 {
            var model = CounterOwnedModel.materialize(.init(value: initial))
            let next = try model.preflight(CounterHandler.operation(.increment))
            precondition(next == min(9, initial + 1)); checks += 1
            let changed = model.commit(next)
            precondition(changed == (initial < 9) && model.value == next); checks += 1
            let reset = try model.preflight(CounterHandler.operation(.reset))
            precondition(reset == 0); checks += 1
            precondition(model.commit(reset) == (next != 0) && model.value == 0); checks += 1
        }
        var namespace = ObservableModelOwnerNamespace()
        #if hasFeature(Embedded)
        var fixed = StaticObservableModelStorage<CounterOwnedModel, CounterModelSchema>(identity: try namespace.issue(), schema: 1, needsCapture: false)!
        checks += try fixed.withLifetime { (models) throws(ObservableStateError) in try counterScopedModel(models) }
        #else
        var ownership = ObservableModelOwnership(identity: try namespace.issue(), captureLimit: 0)!
        var backing: InlineArray<2, CounterOwnedModel?> = .init { _ in nil }
        var models = backing.mutableSpan
        checks += try withObservableModelScope(ownership: &ownership, models: &models,
            schema: 1, needsCapture: false) { (models) throws(ObservableStateError) in
            try counterScopedModel(models)
        }
        #endif
        #if !hasFeature(Embedded)
        let dynamic = DynamicObservableModelStorage<CounterOwnedModel, CounterModelSchema>(identity: try namespace.issue(), schema: 1, needsCapture: false)!
        checks += try dynamic.withLifetime { (models) throws(ObservableStateError) in try counterScopedModel(models) }
        #endif
    } catch { preconditionFailure("counter model failed: \(error)") }
    return checks
}

#if GIFTUI_PHYSICAL_FACTS_QUALIFICATION && !hasFeature(Embedded)
// Ordinary controls for the actual Native owner. These do not instrument model
// destruction or establish allocation eligibility of its complete caller.
package func p08CounterRootInitializationQualification() -> Int {
    var checks = 0
    do throws(ObservableStateError) {
        var namespace = ObservableModelOwnerNamespace()
        let identity = try namespace.issue()
        let invalid: InlineArray<7, InlineArray<4, UInt16>> = [
            [0, 4, 2, 0], [3, 4, 2, 0], [2, 0, 2, 0], [2, 5, 2, 0],
            [2, 4, 0, 0], [2, 4, 3, 0], [2, 4, 2, 2],
        ]
        for index in 0..<7 {
            let limits = invalid[index]
            switch CounterStaticRootStorage(identity: identity, schema: 1, needsCapture: false,
                modelLimit: limits[0], claimLimit: limits[1], pinLimit: limits[2], captureLimit: limits[3]) {
            case .none: checks += 1
            case .some: preconditionFailure("invalid root construction accepted")
            }
        }
        var owner = CounterStaticRootStorage(identity: identity, schema: 1, needsCapture: false)!
        let original = owner.storageLayout
        for _ in 0..<2 {
            checks += try owner.withLifetime { (models, _) throws(ObservableStateError) in
                try counterScopedModel(models)
            }
            precondition(owner.storageLayout.owner == original.owner)
            precondition(owner.storageLayout.modelBytes == original.modelBytes)
            checks += 2
        }
        var stale: _GiftUIModelKey<CounterModelSchema>?
        try owner.withLifetime { (models, _) throws(ObservableStateError) in
            let ticket = try models.materialize(CounterOwnedModel(value: 7))
            stale = ticket.key
            // Leave the initialized model and its independent claim to the
            // existing scope cleanup, then reuse this same physical owner.
        }
        try owner.withLifetime { (models, _) throws(ObservableStateError) in
            if case .failure(.staleModel) = models.mutate(stale!, mutation: .reset, report: { .dirtied }) {
                checks += 1
            } else { preconditionFailure("previous activation key accepted") }
            var first = try models.materialize(CounterOwnedModel(value: 1))
            var second = try models.materialize(CounterOwnedModel(value: 2))
            try models.release(&second)
            try models.release(&first)
            checks += 2
        }
    } catch { preconditionFailure("counter root initialization failed: \(error)") }
    return checks
}
#endif
