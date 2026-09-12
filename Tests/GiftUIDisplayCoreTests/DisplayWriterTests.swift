import GiftUI
import GiftUICapabilities
import GiftUISurfaceCore
import Testing

@testable import GiftUIDisplayCore

private let writerBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 4, height: 3)!
)!
private let writerDamage = Rect(
    origin: Point(x: 1, y: 1),
    size: Size(width: 3, height: 2)!
)!
private let writerDescriptor = RasterSurfaceDescriptor(
    bounds: writerBounds,
    encoding: .rgba8888,
    bytesPerRow: 16,
    realization: .fullSurface,
    regionWidth: 4,
    regionHeight: 3
)!

private func writerTarget(
    capacityBytes: UInt32 = 24,
    regionCapacity: UInt16 = 2
) -> RecordingDisplayTarget {
    RecordingDisplayTarget(
        descriptor: writerDescriptor,
        payloadCapacityBytes: capacityBytes,
        regionCapacity: regionCapacity,
        damageBounds: writerDamage
    )
}

private func writerReservation(
    _ target: inout RecordingDisplayTarget,
    capacityBytes: UInt32 = 24,
    regionCapacity: UInt16 = 2
) -> DisplayReservationID {
    let result = target.reserveFrame(
        descriptor: writerDescriptor,
        payloadCapacityBytes: capacityBytes,
        regionCapacity: regionCapacity
    )
    guard case .reserved(let id) = result else {
        fatalError("expected recording reservation")
    }
    return id
}

@Test
func writerProducesPackedOrderedRegionsAtExactLimits() {
    var target = writerTarget()
    let id = writerReservation(&target)

    let result = target.withWriter(for: id) { writer in
        #expect(writer.stagedBytes.allSatisfy { $0 == 0 })
        let beganFirst = writer.beginRegion(
            origin: Point(x: 1, y: 1),
            pixelCount: 2,
            encoding: .rgba8888
        )
        #expect(beganFirst)
        for byte in UInt8(1) ... UInt8(8) {
            let wrote = writer.write(byte: byte)
            #expect(wrote)
        }
        let endedFirst = writer.endRegion()
        #expect(endedFirst)
        let beganSecond = writer.beginRegion(
            origin: Point(x: 3, y: 2),
            pixelCount: 1,
            encoding: .rgba8888
        )
        #expect(beganSecond)
        for byte in UInt8(9) ... UInt8(12) {
            let wrote = writer.write(byte: byte)
            #expect(wrote)
        }
        let endedSecond = writer.endRegion()
        #expect(endedSecond)
        return writer.finish()
    }

    #expect(result == true)
    #expect(target.writer.writtenBytes == 12)
    #expect(target.writer.writtenRegionCount == 2)
    #expect(Array(target.writer.stagedBytes.prefix(12)) == Array(UInt8(1) ... UInt8(12)))
    #expect(
        target.writer.regions
            == [
                RecordedDisplayRegion(
                    origin: Point(x: 1, y: 1),
                    pixelCount: 2,
                    encoding: .rgba8888,
                    byteOffset: 0,
                    byteCount: 8
                ),
                RecordedDisplayRegion(
                    origin: Point(x: 3, y: 2),
                    pixelCount: 1,
                    encoding: .rgba8888,
                    byteOffset: 8,
                    byteCount: 4
                ),
            ]
    )
    var staleBodyCalls = 0
    #expect(target.withWriter(for: id) { _ in staleBodyCalls += 1 } == nil)
    #expect(staleBodyCalls == 0)
}

@Test
func writerRejectsEmptyNestedOutOfDamageCrossRowAndWrongEncodingRegions() {
    let invalidAttempts: [(inout RecordingDisplayWriter) -> Bool] = [
        { writer in
            writer.beginRegion(
                origin: Point(x: 1, y: 1), pixelCount: 0, encoding: .rgba8888
            )
        },
        { writer in
            writer.beginRegion(
                origin: Point(x: 0, y: 0), pixelCount: 1, encoding: .rgba8888
            )
        },
        { writer in
            writer.beginRegion(
                origin: Point(x: 3, y: 1), pixelCount: 2, encoding: .rgba8888
            )
        },
        { writer in
            writer.beginRegion(
                origin: Point(x: 1, y: 1), pixelCount: 1, encoding: .rgb565BigEndian
            )
        },
        { writer in
            guard
                writer.beginRegion(
                    origin: Point(x: 1, y: 1), pixelCount: 1, encoding: .rgba8888
                )
            else { return false }
            return writer.beginRegion(
                origin: Point(x: 2, y: 1), pixelCount: 1, encoding: .rgba8888
            )
        },
    ]

    for attempt in invalidAttempts {
        var target = writerTarget()
        let id = writerReservation(&target)
        #expect(target.withWriter(for: id, attempt) == false)
        #expect(target.writer.lastError != nil)
    }
}

@Test
func writerFaultsUnderflowOverflowEmptyAndDoubleTransitions() {
    var noRegionTarget = writerTarget()
    let noRegionID = writerReservation(&noRegionTarget)
    #expect(noRegionTarget.withWriter(for: noRegionID) { $0.write(byte: 1) } == false)

    var underflowTarget = writerTarget()
    let underflowID = writerReservation(&underflowTarget)
    #expect(
        underflowTarget.withWriter(for: underflowID) { writer in
            _ = writer.beginRegion(
                origin: Point(x: 1, y: 1), pixelCount: 1, encoding: .rgba8888
            )
            _ = writer.write(byte: 1)
            return writer.endRegion()
        } == false
    )

    var overflowTarget = writerTarget(capacityBytes: 4, regionCapacity: 1)
    let overflowID = writerReservation(
        &overflowTarget,
        capacityBytes: 4,
        regionCapacity: 1
    )
    #expect(
        overflowTarget.withWriter(for: overflowID) { writer in
            guard
                writer.beginRegion(
                    origin: Point(x: 1, y: 1), pixelCount: 1, encoding: .rgba8888
                )
            else { return false }
            for byte in UInt8(0) ..< UInt8(4) {
                _ = writer.write(byte: byte)
            }
            return writer.write(byte: 4)
        } == false
    )

    var emptyTarget = writerTarget()
    let emptyID = writerReservation(&emptyTarget)
    #expect(emptyTarget.withWriter(for: emptyID) { $0.finish() } == false)

    var doubleEndTarget = writerTarget()
    let doubleEndID = writerReservation(&doubleEndTarget)
    #expect(
        doubleEndTarget.withWriter(for: doubleEndID) { writer in
            _ = writer.beginRegion(
                origin: Point(x: 1, y: 1), pixelCount: 1, encoding: .rgba8888
            )
            for byte in UInt8(0) ..< UInt8(4) { _ = writer.write(byte: byte) }
            _ = writer.endRegion()
            return writer.endRegion()
        } == false
    )

    var doubleFinishTarget = writerTarget()
    let doubleFinishID = writerReservation(&doubleFinishTarget)
    #expect(
        doubleFinishTarget.withWriter(for: doubleFinishID) { writer in
            _ = writer.beginRegion(
                origin: Point(x: 1, y: 1), pixelCount: 1, encoding: .rgba8888
            )
            for byte in UInt8(0) ..< UInt8(4) { _ = writer.write(byte: byte) }
            _ = writer.endRegion()
            let first = writer.finish()
            let second = writer.finish()
            return first && !second
        } == true
    )

    var regionOverflowTarget = writerTarget(capacityBytes: 8, regionCapacity: 1)
    let regionOverflowID = writerReservation(
        &regionOverflowTarget,
        capacityBytes: 8,
        regionCapacity: 1
    )
    #expect(
        regionOverflowTarget.withWriter(for: regionOverflowID) { writer in
            _ = writer.beginRegion(
                origin: Point(x: 1, y: 1), pixelCount: 1, encoding: .rgba8888
            )
            for byte in UInt8(0) ..< UInt8(4) { _ = writer.write(byte: byte) }
            _ = writer.endRegion()
            return writer.beginRegion(
                origin: Point(x: 2, y: 1), pixelCount: 1, encoding: .rgba8888
            )
        } == false
    )
}

@Test
func writerDiscardCompletelyZeroesAndResetsFaultedAttempt() {
    var target = writerTarget()
    let id = writerReservation(&target)

    #expect(
        target.withWriter(for: id) { writer in
            _ = writer.beginRegion(
                origin: Point(x: 1, y: 1), pixelCount: 1, encoding: .rgba8888
            )
            _ = writer.write(byte: 99)
            _ = writer.endRegion()
            writer.discard()
            return true
        } == true
    )
    #expect(target.writer.writtenBytes == 0)
    #expect(target.writer.writtenRegionCount == 0)
    #expect(target.writer.regions.isEmpty)
    #expect(target.writer.lastError == nil)
    #expect(target.writer.stagedBytes.allSatisfy { $0 == 0 })
    #expect(
        target.withWriter(for: id) { writer in
            guard
                writer.beginRegion(
                    origin: Point(x: 1, y: 1), pixelCount: 1, encoding: .rgba8888
                )
            else { return false }
            for byte in UInt8(0) ..< UInt8(4) { _ = writer.write(byte: byte) }
            return writer.endRegion() && writer.finish()
        } == true
    )
}
