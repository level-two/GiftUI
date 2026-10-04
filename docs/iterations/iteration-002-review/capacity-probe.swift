// Research reproduction over the unchanged InteractionState implementation.
import GiftUI
import GiftUIExecution

private struct CandidateStorage: InteractionCandidateRecordStorage {
    let capacity: UInt16
    var records: [InteractionCandidateRecord<UInt16>] = []
    var count: UInt16 { UInt16(records.count) }
    mutating func reset() { records.removeAll() }
    func record(at index: UInt16) -> InteractionCandidateRecord<UInt16>? {
        records.indices.contains(Int(index)) ? records[Int(index)] : nil
    }
    mutating func append(_ record: consuming InteractionCandidateRecord<UInt16>) -> Bool {
        guard count < capacity else { return false }
        records.append(record)
        return true
    }
    mutating func replace(
        at index: UInt16, with record: consuming InteractionCandidateRecord<UInt16>
    ) -> Bool {
        guard records.indices.contains(Int(index)) else { return false }
        records[Int(index)] = record
        return true
    }
}

private struct CommittedStorage: InteractionCommittedRecordStorage {
    let capacity: UInt16
    var records: [BoundActionRecord<UInt16>] = []
    var count: UInt16 { UInt16(records.count) }
    mutating func reset() { records.removeAll() }
    func record(at index: UInt16) -> BoundActionRecord<UInt16>? {
        records.indices.contains(Int(index)) ? records[Int(index)] : nil
    }
    mutating func append(_ record: consuming BoundActionRecord<UInt16>) -> Bool {
        guard count < capacity else { return false }
        records.append(record)
        return true
    }
    mutating func exchangeContents(with other: inout Self) {
        swap(&records, &other.records)
    }
}

private struct HitStorage: InteractionHitRegionStorage {
    let capacity: UInt16
    var records: [InteractionHitRegion<UInt16>] = []
    var count: UInt16 { UInt16(records.count) }
    mutating func reset() { records.removeAll() }
    func region(at index: UInt16) -> InteractionHitRegion<UInt16>? {
        records.indices.contains(Int(index)) ? records[Int(index)] : nil
    }
    mutating func append(_ record: consuming InteractionHitRegion<UInt16>) -> Bool {
        guard count < capacity else { return false }
        records.append(record)
        return true
    }
    mutating func exchangeContents(with other: inout Self) {
        swap(&records, &other.records)
    }
}

@main
private enum CapacityProbe {
    static func main() {
        var state = InteractionState(
            candidateRecords: CandidateStorage(capacity: 2),
            candidateHitRegions: HitStorage(capacity: 2),
            candidateCommittedRecords: CommittedStorage(capacity: 1),
            committedRecords: CommittedStorage(capacity: 2),
            committedHitRegions: HitStorage(capacity: 2)
        )
        let limits = InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!
        print("begin=\(String(describing: state.beginCandidate(limits: limits)))")
        let bounds = Rect(origin: Point(x: 0, y: 0), size: Size(width: 2, height: 2)!)!
        for identity: UInt16 in 1 ... 2 {
            print(
                "append-\(identity)=\(state.append(identity: identity, isEnabled: true, bounds: bounds, clip: bounds, paintOrder: identity - 1, action: BoundedApplicationAction(code: identity), targetGeneration: ObservableTargetGeneration(rawValue: 1)))"
            )
            print(
                "assign-\(identity)=\(String(describing: state.assignGeneration(ActionGeneration(rawValue: UInt32(identity)), to: identity)))"
            )
        }
        print("finish=\(String(describing: state.finishCandidate()))")
        state.resolveCandidate(.discard)
        print("after-discard=\(String(describing: state.beginCandidate(limits: limits)))")
    }
}
