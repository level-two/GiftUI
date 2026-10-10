import GiftUI
import GiftUIObservableState
import GiftUIRuntimeDynamic

private enum ProbeSchema {}
private struct ProbeModel: ~Copyable { var value: UInt8 }
private enum ProbeDomain: _GiftUIReadDomain {
    typealias Slot = ObservableModelReadSlot<ProbeModel>
    static func value(_ key: _GiftUIModelKey<ProbeSchema>, read: borrowing _GiftUIFrameRead<Self>)
        throws(_GiftUIAccessFailure) -> UInt8 {
        let index = try read.slots[0].ownership.pointee.bind(key, schema: 7)
        switch read.slots[index].model.pointee {
        case .some(let model): return model.value
        case .none: throw .invalidPhase
        }
    }
}

@_cdecl("giftui_p03_backing")
public func giftuiP03Backing() -> UInt32 {
    do throws(ObservableStateError) {
        var namespace = ObservableModelOwnerNamespace()
        guard let storage = DynamicObservableModelStorage<ProbeModel, ProbeSchema>(identity: try namespace.issue(), schema: 7, needsCapture: false) else { return 1 }
        return try storage.withLifetime { (scope) throws(ObservableStateError) in
            var ticket = try scope.materialize(ProbeModel(value: 9))
            var retained = try scope.retain(ticket.key)
            let key = ticket.key
            try scope.register(ticket)
            try scope.release(&ticket)
            try scope.unregister(key)
            let value: UInt8 = try scope.withFrame { () throws(ObservableStateError) in
                try scope.pin(key)
                do throws(_GiftUIAccessFailure) {
                    return try scope.withRead(ProbeDomain.self) { (read) throws(_GiftUIAccessFailure) in
                        try ProbeDomain.value(key, read: read)
                    }
                } catch { throw ObservableStateError(accessFailure: error) }
            }
            try scope.release(&retained)
            return value == 9 ? 0 : 2
        }
    } catch { return UInt32(error.rawValue) + 10 }
}
