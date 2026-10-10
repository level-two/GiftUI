import GiftUI
import GiftUIObservableState
import GiftUIRuntimeStatic

private enum Schema {}
private struct Model: ~Copyable, ObservableModelMutation {
    enum Mutation { case set(UInt8); case append(UInt8); case fail }
    struct Prepared { let scalar: UInt8; let appended: UInt8? }
    var scalar: UInt8
    var count = 0
    var values: InlineArray<2, UInt8> = .init(repeating: 0)
    borrowing func preflight(_ mutation: Mutation) throws(ObservableStateError) -> Prepared {
        switch mutation {
        case .set(let value): return Prepared(scalar: value, appended: nil)
        case .append(let value):
            guard count < 2 else { throw .modelCapacityExhausted }
            return Prepared(scalar: value, appended: value)
        case .fail: throw .incompatibleAssociation
        }
    }
    mutating func commit(_ prepared: Prepared) -> Bool {
        let changed = scalar != prepared.scalar || prepared.appended != nil
        scalar = prepared.scalar
        if let appended = prepared.appended { values[count] = appended; count += 1 }
        return changed
    }
}
private enum Domain: _GiftUIReadDomain {
    typealias Slot = ObservableModelReadSlot<Model>
    static func snapshot(_ key: _GiftUIModelKey<Schema>, _ read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> (UInt8, Int, UInt8, UInt8) {
        let i = try read.slots[0].ownership.pointee.bind(key, schema: 1)
        switch read.slots[i].model.pointee {
        case .some(let model): return (model.scalar, model.count, model.values[0], model.values[1])
        case .none: throw .staleModel
        }
    }
}
package func mutationChecks() throws(ObservableStateError) -> UInt32 {
    var checks: UInt32 = 0
    func expect(_ yes: Bool) { precondition(yes); checks += 1 }
    var namespace = ObservableModelOwnerNamespace()
    var storage = StaticObservableModelStorage<Model, Schema>(identity: try namespace.issue(), schema: 1, needsCapture: false)!
    try storage.withLifetime { (scope) throws(ObservableStateError) in
        var ticket = try scope.materialize(Model(scalar: 3))
        let key = ticket.key
        var reports = 0
        func report() -> _GiftUIObservableChangeReportOutcome { reports += 1; return reports == 1 ? .dirtied : .coalesced }
        expect(scope.mutate(key, mutation: .set(3), report: report) == .success(.unchanged))
        expect(reports == 0)
        expect(scope.mutate(key, mutation: .fail, report: report) == .failure(.incompatibleAssociation))
        expect(reports == 0)
        expect(scope.mutate(key, mutation: .append(5), report: report) == .success(.dirtied))
        expect(scope.mutate(key, mutation: .append(7), report: report) == .success(.coalesced))
        expect(scope.mutate(key, mutation: .append(9), report: report) == .failure(.modelCapacityExhausted))
        expect(reports == 2)
        expect(scope.mutate(key, mutation: .set(11), report: {
            expect(scope.mutate(key, mutation: .set(99), report: report) == .failure(.reentrancyViolation))
            do throws(ObservableStateError) { _ = try scope.retain(key); expect(false) }
            catch { expect(error == .reentrancyViolation) }
            return .invariantViolation
        }) == .failure(.invariantViolation))
        try scope.withFrame { () throws(ObservableStateError) in
            try scope.pin(key)
            do throws(_GiftUIAccessFailure) {
                try scope.withRead(Domain.self) { (read) throws(_GiftUIAccessFailure) in
                    let snapshot = try Domain.snapshot(key, read)
                    expect(snapshot.0 == 11 && snapshot.1 == 2 && snapshot.2 == 5 && snapshot.3 == 7)
                    expect(scope.mutate(key, mutation: .set(12), report: report) == .failure(.invalidPhaseSafetyNotProven))
                    do throws(ObservableStateError) { try scope.withDiscovery { () }; expect(false) }
                    catch { expect(error == .invalidPhaseSafetyNotProven) }
                }
            } catch { throw ObservableStateError(accessFailure: error) }
            try scope.withDiscovery { () throws(ObservableStateError) in
                var nested = try scope.materialize(Model(scalar: 4))
                try scope.pin(nested.key)
                expect(scope.mutate(key, mutation: .set(12), report: report) == .failure(.invalidPhaseContained))
                try scope.release(&nested)
            }
            // Ending discovery restores reads, while the frame still pins both models.
            do throws(_GiftUIAccessFailure) {
                try scope.withRead(Domain.self) { (read) throws(_GiftUIAccessFailure) in
                    expect(try Domain.snapshot(key, read).0 == 11)
                }
            } catch { throw ObservableStateError(accessFailure: error) }
        }
        expect(scope.mutate(key, mutation: .set(13), report: report) == .success(.coalesced))
        try scope.release(&ticket)
        expect(scope.mutate(key, mutation: .set(14), report: report) == .failure(.staleModel))
        expect(reports == 3)
    }
    return checks
}
@_cdecl("giftui_p03_mutation")
public func giftuiP03Mutation() -> UInt32 {
    do { return try mutationChecks() == 19 ? 0 : 1 } catch { return 2 }
}
