import GiftUI
import GiftUIObservableState
import GiftUIRuntimeStatic
import GiftUIRuntimeDynamic

private enum Schema {}
private struct Model: ~Copyable {
    var value: UInt8
    let destructions: UnsafeMutablePointer<Int>
    deinit { destructions.pointee += 1 }
}
private enum Domain: _GiftUIReadDomain {
    typealias Slot = ObservableModelReadSlot<Model>
    static func value(_ key: _GiftUIModelKey<Schema>, read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> UInt8 {
        let index = try read.slots[0].ownership.pointee.bind(key, schema: 7)
        switch read.slots[index].model.pointee {
        case .some(let model): return model.value
        case .none: throw .invalidPhase
        }
    }
}

@main struct BackingChecks {
    static func main() throws {
        var checks = 0
        func expect(_ value: Bool) { checks += 1; precondition(value) }
        var namespace = ObservableModelOwnerNamespace()
        guard var storage = StaticObservableModelStorage<Model, Schema>(identity: try namespace.issue(), schema: 7, needsCapture: false) else { fatalError() }
        try withUnsafeTemporaryAllocation(of: Int.self, capacity: 1) { (deaths) throws(ObservableStateError) in
            deaths.initialize(repeating: 0)
            defer { deaths.deinitialize() }
            let former = try storage.withLifetime { (scope) throws(ObservableStateError) in
                var a = try scope.materialize(Model(value: 4, destructions: deaths.baseAddress!))
                let key = a.key
                try scope.register(a)
                var retained = try scope.retain(key)
                try scope.release(&a)
                try scope.unregister(key)
                expect(deaths[0] == 0)
                try scope.withFrame { () throws(ObservableStateError) in
                    try scope.pin(key)
                    do throws(_GiftUIAccessFailure) {
                        let value = try scope.withRead(Domain.self) { (read) throws(_GiftUIAccessFailure) in
                            try Domain.value(key, read: read)
                        }
                        expect(value == 4)
                    } catch { throw ObservableStateError(accessFailure: error) }
                    do throws(ObservableStateError) { try scope.release(&retained); expect(false) }
                    catch { expect(error == .invalidPhaseContained) }
                }
                expect(deaths[0] == 0)
                try scope.release(&retained)
                expect(deaths[0] == 1)
                do throws(ObservableStateError) { try scope.release(&retained); expect(false) }
                catch { expect(error == .staleModel) }
                return key
            }
            try storage.withLifetime { (scope) throws(ObservableStateError) in
                var b = try scope.materialize(Model(value: 9, destructions: deaths.baseAddress!))
                expect(b.key != former)
                try scope.withFrame { () throws(ObservableStateError) in
                    try scope.pin(b.key)
                    do throws(_GiftUIAccessFailure) {
                        try scope.withRead(Domain.self) { (read) throws(_GiftUIAccessFailure) in
                            _ = try Domain.value(former, read: read)
                        }
                        expect(false)
                    } catch { expect(error == .staleModel) }
                    do throws(_GiftUIAccessFailure) {
                        let value = try scope.withRead(Domain.self) { (read) throws(_GiftUIAccessFailure) in
                            try Domain.value(b.key, read: read)
                        }
                        expect(value == 9)
                    } catch { throw ObservableStateError(accessFailure: error) }
                }
                try scope.release(&b)
                expect(deaths[0] == 2)
            }
        }
        guard let dynamic = DynamicObservableModelStorage<Model, Schema>(identity: try namespace.issue(), schema: 7, needsCapture: false) else { fatalError() }
        try withUnsafeTemporaryAllocation(of: Int.self, capacity: 1) { (deaths) throws(ObservableStateError) in
            deaths.initialize(repeating: 0)
            defer { deaths.deinitialize() }
            try dynamic.withLifetime { (scope) throws(ObservableStateError) in
                var ticket = try scope.materialize(Model(value: 4, destructions: deaths.baseAddress!))
                var retained = try scope.retain(ticket.key)
                let key = ticket.key
                try scope.register(ticket)
                try scope.release(&ticket)
                try scope.unregister(key)
                expect(deaths[0] == 0)
                do throws(ObservableStateError) {
                    try dynamic.withLifetime { _ in () }
                    expect(false)
                } catch { expect(error == .reentrancyViolation) }
                try scope.withFrame { () throws(ObservableStateError) in
                    try scope.pin(key)
                    do throws(_GiftUIAccessFailure) {
                        let value = try scope.withRead(Domain.self) { (read) throws(_GiftUIAccessFailure) in
                            try Domain.value(key, read: read)
                        }
                        expect(value == 4)
                    } catch { throw ObservableStateError(accessFailure: error) }
                }
                try scope.release(&retained)
                expect(deaths[0] == 1)
            }
        }
        try withUnsafeTemporaryAllocation(of: Int.self, capacity: 1) { (deaths) throws(ObservableStateError) in
            deaths.initialize(repeating: 0)
            defer { deaths.deinitialize() }
            let abandoned = try dynamic.withLifetime { (scope) throws(ObservableStateError) in
                let ticket = try scope.materialize(Model(value: 5, destructions: deaths.baseAddress!))
                return ticket.key
            }
            expect(deaths[0] == 1)
            try dynamic.withLifetime { (scope) throws(ObservableStateError) in
                do throws(ObservableStateError) { _ = try scope.retain(abandoned); expect(false) }
                catch { expect(error == .staleModel) }
            }
        }
        expect(giftuiP03Backing() == 0)
        print("P03 actual static/dynamic backing checks=\(checks) failures=0")
    }
}
