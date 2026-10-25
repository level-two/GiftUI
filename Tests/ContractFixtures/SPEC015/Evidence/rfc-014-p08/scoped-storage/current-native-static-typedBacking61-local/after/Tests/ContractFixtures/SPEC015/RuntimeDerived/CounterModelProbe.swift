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
    expect(models.mutate(key, mutation: .reset, report: report) == .success(.unchanged))
    expect(reports == 0)
    for _ in 0..<9 { expect(models.mutate(key, mutation: .increment, report: report) == .success(.dirtied)) }
    expect(reports == 9)
    expect(models.mutate(key, mutation: .increment, report: report) == .success(.unchanged))
    expect(reports == 9)
    expect(models.mutate(key, mutation: .fact(10), report: report) == .failure(.invariantViolation))
    expect(reports == 9)
    expect(models.mutate(key, mutation: .fact(9), report: report) == .success(.unchanged))
    expect(models.mutate(key, mutation: .reset, report: report) == .success(.dirtied))
    expect(reports == 10)
    expect(models.mutate(key, mutation: .reset, report: report) == .success(.unchanged))
    expect(models.mutate(key, mutation: .fact(7), report: report) == .success(.dirtied))
    expect(reports == 11)
    try models.beginFrame()
    expect(models.mutate(key, mutation: .increment, report: report) == .failure(.invalidPhaseContained))
    expect(reports == 11)
    try models.endFrame()
    try models.release(&ticket)
    expect(models.mutate(key, mutation: .reset, report: report) == .failure(.staleModel))
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
