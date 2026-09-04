import GiftUITextResources
import GiftUIReferenceTextResources

private let intervalLimitNanoseconds: UInt64 = 250_000_000
private let sampleCount = 9

@inline(never)
private func resourceWork(scalarCount: Int, worstCaseMapping: Bool) -> UInt64 {
    let resourcePackage = GiftUIReferenceTextResources.targetPackage
    let instance = resourcePackage.metrics.instance(at: 0)!
    let realization = RasterRealizationID(rawValue: 0)
    var checksum: UInt64 = 0
    for index in 0 ..< scalarCount {
        let scalar = worstCaseMapping ? UInt32(0x00b0) : UInt32(0x20 + (index % 95))
        guard let mapping = resourcePackage.metrics.mapScalar(scalar, in: instance.id) else {
            fatalError("admitted scalar did not map")
        }
        let glyph: GlyphID
        switch mapping {
        case let .exact(value), let .replacement(value): glyph = value
        }
        guard
            let metrics = resourcePackage.metrics.metrics(for: glyph, in: instance.id),
            let record = resourcePackage.raster.record(for: glyph, realization: realization),
            let borrowed = resourcePackage.raster.withPayload(
                for: record,
                realization: realization,
                { UInt64($0.count) }
            )
        else { fatalError("validated resource lookup failed") }
        checksum &+= UInt64(glyph.rawValue) &+ UInt64(metrics.advanceX) &+ borrowed
    }
    return checksum
}

private func nanoseconds(_ duration: Duration) -> UInt64 {
    let components = duration.components
    return UInt64(components.seconds) * 1_000_000_000
        + UInt64(components.attoseconds / 1_000_000_000)
}

private func measure(scalarCount: Int, iterations: Int, worstCaseMapping: Bool) -> (UInt64, UInt64) {
    let clock = ContinuousClock()
    var worst: UInt64 = 0
    var checksum: UInt64 = 0
    for _ in 0 ..< sampleCount {
        let start = clock.now
        for _ in 0 ..< iterations {
            checksum &+= resourceWork(scalarCount: scalarCount, worstCaseMapping: worstCaseMapping)
        }
        let average = nanoseconds(start.duration(to: clock.now)) / UInt64(iterations)
        worst = max(worst, average)
    }
    return (worst, checksum)
}

_ = resourceWork(scalarCount: 103, worstCaseMapping: false)
_ = resourceWork(scalarCount: 4_096, worstCaseMapping: true)
let representative = measure(scalarCount: 103, iterations: 1_000, worstCaseMapping: false)
let maximum = measure(scalarCount: 4_096, iterations: 100, worstCaseMapping: true)

print("schema_version=1")
print("evidence=host-executed")
print("representative_scalar_count=103")
print("maximum_scalar_count=4096")
print("sample_count=\(sampleCount)")
print("representative_worst_ns=\(representative.0)")
print("maximum_worst_ns=\(maximum.0)")
print("interval_limit_ns=\(intervalLimitNanoseconds)")
print("layout_ns=not_measured_owned_by_SPEC-007")
print("raster_ns=not_measured_owned_by_SPEC-014")
print("cache_ns=not_measured_owned_by_SPEC-014")
print("transfer_ns=not_measured_owned_by_SPEC-014")
print("checksum=\(representative.1 &+ maximum.1)")
if representative.0 >= intervalLimitNanoseconds || maximum.0 >= intervalLimitNanoseconds {
    fatalError("SPEC-005 resource-only timing exceeded the presentation interval")
}
