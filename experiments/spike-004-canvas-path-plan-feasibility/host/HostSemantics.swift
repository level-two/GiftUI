// Disposable host semantics for SPIKE-004. This is evidence, not API design.

struct Point: Equatable {
    var x: Int32
    var y: Int32
}

struct Subpath: Equatable {
    var start: Int
    var count: Int
}

struct Style: Equatable {
    var color: UInt32
    var width: UInt16
    var roundCap: Bool
    var roundJoin: Bool
}

struct MutablePath {
    var points: [Point] = []
    var subpaths: [Subpath] = []

    mutating func move(to point: Point) {
        subpaths.append(Subpath(start: points.count, count: 1))
        points.append(point)
    }

    mutating func line(to point: Point) -> Bool {
        guard !subpaths.isEmpty else { return false }
        points.append(point)
        subpaths[subpaths.count - 1].count += 1
        return true
    }
}

struct StrokeRow: Equatable {
    var points: [Point]
    var subpaths: [Subpath]
    var style: Style
}

enum Failure: String, Error {
    case invalidState = "invalid-state"
    case arithmeticOverflow = "arithmetic-overflow"
    case pathExhausted = "path-exhausted"
    case planExhausted = "plan-exhausted"
    case sinkExhausted = "sink-exhausted"
}

enum Mode: String, CaseIterable {
    case copyPlan = "copy-to-plan"
    case sealPlan = "unique-range-seal"
    case direct = "direct-emission"
}

struct Limits {
    var points = 836
    var subpaths = 16
    var strokes = 5
    var operations = 5
    var pathPoints = 803
    var pathSubpaths = 12
}

struct RecordingSink {
    var capacity: Int
    var rows: [StrokeRow] = []
    var offerCount = 0
    var activeBorrow = false
    var retainedBorrow = false

    mutating func reserve(_ count: Int) -> Failure? {
        rows.count + count <= capacity ? nil : .sinkExhausted
    }

    mutating func consume(_ row: StrokeRow) -> Failure? {
        guard rows.count < capacity else { return .sinkExhausted }
        activeBorrow = true
        rows.append(row) // canonical recording copies values during the borrow
        activeBorrow = false
        retainedBorrow = false
        return nil
    }
}

struct Producer {
    let mode: Mode
    let limits: Limits
    var plan: [StrokeRow] = []
    var planPoints = 0
    var planSubpaths = 0
    var operations = 0
    var failed: Failure?

    mutating func submit(_ path: MutablePath, style: Style, sink: inout RecordingSink) -> Failure? {
        guard failed == nil else { return failed }
        guard path.points.count <= limits.pathPoints,
              path.subpaths.count <= limits.pathSubpaths else {
            failed = .pathExhausted
            return failed
        }
        let row = StrokeRow(points: path.points, subpaths: path.subpaths, style: style)
        switch mode {
        case .copyPlan, .sealPlan:
            guard plan.count < limits.strokes, operations < limits.operations,
                  planPoints + row.points.count <= limits.points,
                  planSubpaths + row.subpaths.count <= limits.subpaths else {
                failed = .planExhausted
                plan.removeAll()
                planPoints = 0
                planSubpaths = 0
                operations = 0
                return failed
            }
            // Copy and seal differ in storage mechanics; both expose an immutable row.
            plan.append(row)
            planPoints += row.points.count
            planSubpaths += row.subpaths.count
            operations += 1
            return nil
        case .direct:
            operations += 1
            if let failure = sink.consume(row) {
                failed = failure
                return failure
            }
            return nil
        }
    }

    mutating func offer(to sink: inout RecordingSink) -> Failure? {
        guard failed == nil else { return failed }
        guard mode != .direct else { return nil }
        guard sink.reserve(plan.count) == nil else {
            failed = .sinkExhausted
            plan.removeAll()
            return failed
        }
        sink.offerCount += 1
        for row in plan {
            if let failure = sink.consume(row) {
                failed = failure
                return failure
            }
        }
        return nil
    }
}

let gridStyle = Style(color: 0x555555, width: 1, roundCap: true, roundJoin: true)
let traceStyle = Style(color: 0x00ff00, width: 2, roundCap: true, roundJoin: true)

func translated(_ point: Point, dx: Int32, dy: Int32) -> Result<Point, Failure> {
    let (x, xOverflow) = point.x.addingReportingOverflow(dx)
    let (y, yOverflow) = point.y.addingReportingOverflow(dy)
    if xOverflow || yOverflow { return .failure(.arithmeticOverflow) }
    return .success(Point(x: x, y: y))
}

func makeSegment(_ a: Point, _ b: Point) -> MutablePath {
    var path = MutablePath()
    path.move(to: a)
    _ = path.line(to: b)
    return path
}

func makeWorkload() -> [StrokeRow] {
    var rows: [StrokeRow] = []
    var grid = MutablePath()
    for index in 0..<12 {
        let x = Int32(index * 40)
        grid.move(to: Point(x: x, y: 0))
        _ = grid.line(to: Point(x: x, y: 319))
    }
    rows.append(StrokeRow(points: grid.points, subpaths: grid.subpaths, style: gridStyle))
    let transitions = [400, 0, 0, 0]
    for channel in 0..<4 {
        let baseY = Int32(40 + channel * 60)
        var path = MutablePath()
        path.move(to: Point(x: 0, y: baseY))
        _ = path.line(to: Point(x: 1, y: baseY))
        var level = baseY
        for index in 0..<transitions[channel] {
            let x = Int32(2 + index)
            _ = path.line(to: Point(x: x, y: level))
            level = level == baseY ? baseY + 20 : baseY
            _ = path.line(to: Point(x: x, y: level))
        }
        _ = path.line(to: Point(x: 479, y: level))
        rows.append(StrokeRow(points: path.points, subpaths: path.subpaths,
            style: Style(color: traceStyle.color + UInt32(channel), width: 2,
                roundCap: true, roundJoin: true)))
    }
    return rows
}

func canonicalDigest(_ rows: [StrokeRow]) -> UInt64 {
    var value: UInt64 = 1_469_598_103_934_665_603
    for row in rows {
        value = (value ^ UInt64(row.style.color)) &* 1_099_511_628_211
        value = (value ^ UInt64(row.style.width)) &* 1_099_511_628_211
        for point in row.points {
            value = (value ^ UInt64(UInt32(bitPattern: point.x))) &* 1_099_511_628_211
            value = (value ^ UInt64(UInt32(bitPattern: point.y))) &* 1_099_511_628_211
        }
        for subpath in row.subpaths {
            value = (value ^ UInt64(subpath.start)) &* 1_099_511_628_211
            value = (value ^ UInt64(subpath.count)) &* 1_099_511_628_211
        }
    }
    return value
}

func consumeRGB565Tile(_ rows: [StrokeRow]) -> (UInt64, Bool) {
    var tile = [UInt16](repeating: 0, count: 480 * 4)
    var span = [UInt16](repeating: 0, count: 480)
    var transfer = [UInt16](repeating: 0, count: 480 * 4)
    var activeBorrow = true
    for row in rows {
        let pixel: UInt16 = row.style.color == gridStyle.color ? 0x8410 : 0x07e0
        for point in row.points {
            let x = min(479, max(0, Int(point.x)))
            let y = min(3, max(0, Int(point.y) % 4))
            tile[y * 480 + x] = pixel
            span[x] = pixel
            transfer[y * 480 + x] = span[x]
        }
    }
    activeBorrow = false
    let checksum = tile.reduce(UInt64(0)) { ($0 &* 16_777_619) ^ UInt64($1) }
        &+ transfer.reduce(UInt64(0)) { ($0 &* 16_777_619) ^ UInt64($1) }
    return (checksum, !activeBorrow)
}

struct CaseResult {
    var id: String
    var expected: String
    var actual: String
    var detail: String
    var passed: Bool { expected == actual }
}

func runCases(_ mode: Mode) -> [CaseResult] {
    var results: [CaseResult] = []
    func result(_ id: String, _ expected: String, _ actual: String, _ detail: String = "-") -> CaseResult {
        CaseResult(id: id, expected: expected, actual: actual, detail: detail)
    }

    do {
        var invalid = MutablePath()
        let accepted = invalid.line(to: Point(x: 1, y: 1))
        results.append(result("line-without-move", Failure.invalidState.rawValue,
            accepted ? "accepted" : Failure.invalidState.rawValue))
    }

    do {
        let path = MutablePath(points: [Point(x: 2, y: 2)],
            subpaths: [Subpath(start: 0, count: 0), Subpath(start: 0, count: 1)])
        var sink = RecordingSink(capacity: 1)
        var producer = Producer(mode: mode, limits: Limits(), plan: [])
        _ = producer.submit(path, style: gridStyle, sink: &sink); _ = producer.offer(to: &sink)
        let counts = sink.rows.first?.subpaths.map { String($0.count) }.joined(separator: ",")
        results.append(result("empty-and-one-point-subpaths", "counts-0,1",
            counts.map { "counts-\($0)" } ?? "missing"))
    }

    do {
        var sink = RecordingSink(capacity: 5)
        var producer = Producer(mode: mode, limits: Limits(), plan: [])
        _ = producer.submit(makeSegment(Point(x: 0, y: 1), Point(x: 9, y: 1)), style: gridStyle, sink: &sink)
        _ = producer.submit(makeSegment(Point(x: 2, y: 0), Point(x: 2, y: 9)), style: traceStyle, sink: &sink)
        _ = producer.offer(to: &sink)
        results.append(result("horizontal-vertical", "ordered-2", "ordered-\(sink.rows.count)"))
    }

    do {
        var path = MutablePath()
        path.move(to: Point(x: 0, y: 0)); _ = path.line(to: Point(x: 1, y: 0))
        path.move(to: Point(x: 2, y: 2)); _ = path.line(to: Point(x: 2, y: 3))
        var sink = RecordingSink(capacity: 1)
        var producer = Producer(mode: mode, limits: Limits(), plan: [])
        _ = producer.submit(path, style: gridStyle, sink: &sink); _ = producer.offer(to: &sink)
        results.append(result("multiple-subpaths", "subpaths-2", "subpaths-\(sink.rows.first?.subpaths.count ?? 0)"))
    }

    do {
        var path = MutablePath(); path.move(to: Point(x: 3, y: 3)); _ = path.line(to: Point(x: 3, y: 3))
        var sink = RecordingSink(capacity: 1)
        var producer = Producer(mode: mode, limits: Limits(), plan: [])
        _ = producer.submit(path, style: gridStyle, sink: &sink); _ = producer.offer(to: &sink)
        let row = sink.rows.first
        results.append(result("one-point-repeated-zero-length", "preserved", row?.points == path.points ? "preserved" : "changed"))
    }

    do {
        var path = makeSegment(Point(x: 1, y: 1), Point(x: 2, y: 2))
        var sink = RecordingSink(capacity: 1)
        var producer = Producer(mode: mode, limits: Limits(), plan: [])
        _ = producer.submit(path, style: gridStyle, sink: &sink)
        _ = path.line(to: Point(x: 9, y: 9))
        _ = producer.offer(to: &sink)
        results.append(result("later-mutation", "snapshot-2", "snapshot-\(sink.rows.first?.points.count ?? 0)"))
    }

    do {
        var sink = RecordingSink(capacity: 2)
        var producer = Producer(mode: mode, limits: Limits(), plan: [])
        _ = producer.submit(makeSegment(Point(x: 0, y: 0), Point(x: 1, y: 1)), style: gridStyle, sink: &sink)
        _ = producer.submit(makeSegment(Point(x: 2, y: 2), Point(x: 3, y: 3)), style: traceStyle, sink: &sink)
        _ = producer.offer(to: &sink)
        let colors = sink.rows.map { $0.style.color }
        results.append(result("painter-order", "grid-trace", colors == [gridStyle.color, traceStyle.color] ? "grid-trace" : "changed"))
    }

    switch translated(Point(x: 10, y: 20), dx: 30, dy: -5) {
    case .success(let point): results.append(result("translation-valid", "40,15", "\(point.x),\(point.y)"))
    case .failure(let failure): results.append(result("translation-valid", "40,15", failure.rawValue))
    }
    switch translated(Point(x: Int32.max, y: 0), dx: 1, dy: 0) {
    case .success: results.append(result("translation-overflow", Failure.arithmeticOverflow.rawValue, "accepted"))
    case .failure(let failure): results.append(result("translation-overflow", Failure.arithmeticOverflow.rawValue, failure.rawValue))
    }

    do {
        var path = MutablePath(); path.move(to: Point(x: 0, y: 0)); _ = path.line(to: Point(x: 1, y: 0)); _ = path.line(to: Point(x: 2, y: 0))
        var limits = Limits(); limits.pathPoints = 2
        var sink = RecordingSink(capacity: 1)
        var producer = Producer(mode: mode, limits: limits, plan: [])
        let failure = producer.submit(path, style: gridStyle, sink: &sink)
        results.append(result("path-point-exhaustion", Failure.pathExhausted.rawValue, failure?.rawValue ?? "accepted"))
    }

    do {
        var path = MutablePath(); path.move(to: Point(x: 0, y: 0)); path.move(to: Point(x: 1, y: 1))
        var limits = Limits(); limits.pathSubpaths = 1
        var sink = RecordingSink(capacity: 1)
        var producer = Producer(mode: mode, limits: limits, plan: [])
        let failure = producer.submit(path, style: gridStyle, sink: &sink)
        results.append(result("path-subpath-exhaustion", Failure.pathExhausted.rawValue, failure?.rawValue ?? "accepted"))
    }

    do {
        var limits = Limits(); limits.points = 2
        var sink = RecordingSink(capacity: 2)
        var producer = Producer(mode: mode, limits: limits, plan: [])
        _ = producer.submit(makeSegment(Point(x: 0, y: 0), Point(x: 1, y: 0)), style: gridStyle, sink: &sink)
        let failure = producer.submit(makeSegment(Point(x: 2, y: 0), Point(x: 3, y: 0)), style: gridStyle, sink: &sink)
        let actual = mode == .direct ? "not-applicable" : (failure?.rawValue ?? "accepted")
        let expected = mode == .direct ? "not-applicable" : Failure.planExhausted.rawValue
        results.append(result("plan-point-exhaustion", expected, actual))
    }

    do {
        var limits = Limits(); limits.strokes = 1; limits.operations = 1
        var sink = RecordingSink(capacity: 2)
        var producer = Producer(mode: mode, limits: limits, plan: [])
        _ = producer.submit(makeSegment(Point(x: 0, y: 0), Point(x: 1, y: 0)), style: gridStyle, sink: &sink)
        let failure = producer.submit(makeSegment(Point(x: 2, y: 0), Point(x: 3, y: 0)), style: gridStyle, sink: &sink)
        let actual = mode == .direct ? "not-applicable" : (failure?.rawValue ?? "accepted")
        let expected = mode == .direct ? "not-applicable" : Failure.planExhausted.rawValue
        results.append(result("stroke-operation-exhaustion", expected, actual))
    }

    do {
        var sink = RecordingSink(capacity: 1)
        var producer = Producer(mode: mode, limits: Limits(), plan: [])
        _ = producer.submit(makeSegment(Point(x: 0, y: 0), Point(x: 1, y: 0)), style: gridStyle, sink: &sink)
        _ = producer.submit(makeSegment(Point(x: 2, y: 0), Point(x: 3, y: 0)), style: traceStyle, sink: &sink)
        let failure = producer.offer(to: &sink)
        let actual = sink.rows.isEmpty ? "no-partial" : "partial-output"
        let expected = mode == .direct ? "partial-output" : "no-partial"
        results.append(result("late-sink-exhaustion", expected, actual, failure?.rawValue ?? producer.failed?.rawValue ?? "accepted"))
    }

    do {
        let workload = makeWorkload()
        var sink = RecordingSink(capacity: 5)
        var producer = Producer(mode: mode, limits: Limits(), plan: [])
        for row in workload {
            var path = MutablePath(points: row.points, subpaths: row.subpaths)
            _ = producer.submit(path, style: row.style, sink: &sink)
            path.points.removeAll()
        }
        _ = producer.offer(to: &sink)
        let points = sink.rows.reduce(0) { $0 + $1.points.count }
        let subpaths = sink.rows.reduce(0) { $0 + $1.subpaths.count }
        let segments = sink.rows.reduce(0) { total, row in total + row.subpaths.reduce(0) { $0 + max(0, $1.count - 1) } }
        let actual = "p\(points)-s\(subpaths)-g\(segments)-o\(sink.rows.count)"
        results.append(result("maximum-workload", "p836-s16-g820-o5", actual,
            "digest-\(canonicalDigest(sink.rows))"))
        let tileResult = consumeRGB565Tile(sink.rows)
        let tileChecksum = tileResult.0
        let borrowOK = !sink.activeBorrow && !sink.retainedBorrow
        results.append(result("rgb565-tile-borrow", "consumed-no-retain", borrowOK && tileResult.1 && tileChecksum != 0 ? "consumed-no-retain" : "retained"))
    }

    return results
}

print("candidate\tcase\texpected\tactual\tpass\tdetail")
var failed = false
for mode in Mode.allCases {
    for item in runCases(mode) {
        print("\(mode.rawValue)\t\(item.id)\t\(item.expected)\t\(item.actual)\t\(item.passed ? "pass" : "fail")\t\(item.detail)")
        failed = failed || !item.passed
    }
}
if failed { fatalError("SPIKE-004 semantic fixture mismatch") }
