// Deterministic host-only semantics for SPIKE-007. No spelling is production API.

struct Capture: Equatable {
    var identity: UInt16
    var generation: UInt16
}

enum GeneratedAction {
    case start(Int)
    case stop(Int)
    case clear(Int)
    case selectWindow(Int)

    func invoke(_ transcript: inout [String]) {
        switch self {
        case .start(let value): transcript.append("start:\(value)")
        case .stop(let value): transcript.append("stop:\(value)")
        case .clear(let value): transcript.append("clear:\(value)")
        case .selectWindow(let value): transcript.append("window:\(value)")
        }
    }
}

struct Record {
    var identity: UInt16
    var generation: UInt16
    var enabled: Bool
    var action: GeneratedAction
}

struct FixedTable {
    static let capacity = 32
    var records: [Record] = []

    mutating func append(_ record: Record) -> Bool {
        guard records.count < Self.capacity else { return false }
        records.append(record)
        return true
    }

    mutating func replace(_ record: Record) {
        if let index = records.firstIndex(where: { $0.identity == record.identity }) {
            records[index] = record
        }
    }

    func dispatch(_ capture: Capture, transcript: inout [String]) -> Bool {
        guard let record = records.first(where: { $0.identity == capture.identity }),
              record.enabled,
              record.generation == capture.generation else { return false }
        record.action.invoke(&transcript)
        return true
    }
}

func emit(_ name: String, _ passed: Bool, _ detail: String) {
    print("\(name)\t\(passed ? "pass" : "fail")\t\(detail)")
}

var table = FixedTable()
var transcript: [String] = []
let first = Record(identity: 1, generation: 10, enabled: true, action: .start(7))
emit("append-first", table.append(first), "first record admitted")
emit("exact-once", table.dispatch(Capture(identity: 1, generation: 10), transcript: &transcript) && transcript == ["start:7"], transcript.joined(separator: ","))

table.replace(Record(identity: 1, generation: 11, enabled: true, action: .start(8)))
let staleCount = transcript.count
emit("stale-generation", !table.dispatch(Capture(identity: 1, generation: 10), transcript: &transcript) && transcript.count == staleCount, "old generation rejected")
emit("replacement", table.dispatch(Capture(identity: 1, generation: 11), transcript: &transcript) && transcript.last == "start:8", transcript.joined(separator: ","))

table.replace(Record(identity: 1, generation: 12, enabled: false, action: .start(9)))
let disabledCount = transcript.count
emit("disabled", !table.dispatch(Capture(identity: 1, generation: 12), transcript: &transcript) && transcript.count == disabledCount, "disabled record rejected")

for index in 2...32 {
    _ = table.append(Record(identity: UInt16(index), generation: 1, enabled: true, action: .selectWindow(index)))
}
let beforeOverflow = table.records.count
let overflowRejected = !table.append(Record(identity: 33, generation: 1, enabled: true, action: .clear(0)))
emit("exact-capacity", beforeOverflow == 32, "count=\(beforeOverflow)")
emit("overflow", overflowRejected && table.records.count == 32, "count=\(table.records.count)")
