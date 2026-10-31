import Darwin

// This checks the inout-parameter/function-value shape; the actual42 gate checks production visitors.
@_noAllocation @inline(never)
private func capturedAccumulatorPrefix(_ family: Int, _ bytes: UInt64) -> (UInt64, Bool) {
    var reported = CounterPhysicalReportAccumulator()
    func emitRegions(_ reported: inout CounterPhysicalReportAccumulator) {
        func record(_ family: Int, _ bytes: UInt64) {
            reported.record(family: family, chargedBytes: bytes) { _, _ in }
        }
        func forward(_ visit: (Int, UInt64) -> Void) { visit(family, bytes) }
        forward(record)
    }
    emitRegions(&reported)
    return (reported[family], reported.overflow)
}

@inline(never)
private func referenceLoad(_ values: borrowing InlineArray<26, UInt64>, _ index: Int) -> UInt64 {
    values[index]
}
@inline(never)
private func referenceStore(_ values: inout InlineArray<26, UInt64>, _ index: Int, _ value: UInt64) {
    values[index] = value
}

@main
private struct PhysicalReportAccumulatorQualification {
    static func check(_ condition: Bool, _ checks: inout Int) {
        precondition(condition)
        checks += 1
    }
    static func main() {
        if CommandLine.arguments.count > 1 {
            guard let family = Int(CommandLine.arguments[1]) else { exit(98) }
            var actual = CounterPhysicalReportAccumulator()
            actual.record(family: family, chargedBytes: 1) { _, _ in
                let marker: StaticString = "INVALID_CALLBACK\n"
                _ = write(2, marker.utf8Start, marker.utf8CodeUnitCount)
            }
            exit(97)
        }
        var actual = CounterPhysicalReportAccumulator()
        var expected: InlineArray<26, UInt64> = .init(repeating: 0)
        var expectedOverflow = false
        var checks = 0
        var callbacks = 0
        var updates = 0
        func apply(_ family: Int, _ bytes: UInt64) {
            // Original InlineArray algorithm is the independent reference only.
            let previous = referenceLoad(expected, family)
            let sum = previous.addingReportingOverflow(bytes)
            expectedOverflow = expectedOverflow || sum.overflow
            referenceStore(&expected, family, sum.partialValue)
            let expectedPartial = sum.partialValue
            let expectedOverflowAfter = expectedOverflow
            let before = callbacks
            actual.record(family: family, chargedBytes: bytes) { partial, overflow in
                check(partial == expectedPartial && overflow == expectedOverflowAfter, &checks)
                callbacks += 1
            }
            check(callbacks == before + 1, &checks)
            check(actual.overflow == expectedOverflow, &checks)
            for index in 0..<26 { check(actual[index] == referenceLoad(expected, index), &checks) }
            updates += 1
        }
        check(!actual.overflow, &checks)
        for index in 0..<26 {
            check(actual[index] == 0, &checks)
            let result = capturedAccumulatorPrefix(index, UInt64(index + 1))
            check(result.0 == UInt64(index + 1) && !result.1, &checks)
        }
        for index in 0..<26 { apply(index, UInt64(index + 1)) }
        for round in 0..<4 {
            for index in (0..<26).reversed() { apply(index, UInt64(round * 31 + index)) }
            for index in stride(from: 0, to: 26, by: 2) { apply(index, 0); apply(index + 1, 3) }
        }
        for family in 0..<26 {
            actual = .init()
            expected = .init(repeating: 0)
            expectedOverflow = false
            apply(family, .max)
            apply(family, 0)
            apply(family, 1)
            check(actual[family] == 0 && actual.overflow, &checks)
            // Every subsequent report still runs after the first overflow.
            for index in 0..<26 { apply(index, UInt64(index)) }
            apply(family, .max)
            apply(family, 1)
            apply(family, 0)
            check(actual.overflow, &checks)
        }
        check(callbacks == updates && updates == 1066, &checks)
        check(MemoryLayout<CounterPhysicalReportAccumulator>.size == 209, &checks)
        check(MemoryLayout<CounterPhysicalReportAccumulator>.alignment == MemoryLayout<UInt64>.alignment, &checks)
        print("PHYSICAL_REPORT_ACCUMULATOR checks=\(checks) updates=\(updates) callbacks=\(callbacks) families=26 checked-capture-prefix=PASS wrapped-values-sticky-overflow-report-after-overflow=preserved")
    }
}
