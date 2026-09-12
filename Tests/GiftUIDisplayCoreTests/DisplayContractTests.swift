import GiftUI
import GiftUICapabilities
import GiftUIFailureCore
import GiftUISurfaceCore
import Testing

@testable import GiftUIDisplayCore

@Test
func displayReservationIdentityAndErrorsHaveExactRawLayouts() {
    let identity = DisplayReservationID(rawValue: 42)

    #expect(identity.rawValue == 42)
    #expect(identity == DisplayReservationID(rawValue: 42))
    #expect(MemoryLayout<DisplayReservationID>.size == 4)
    #expect(MemoryLayout<DisplayReservationID>.stride == 4)
    #expect(DisplayTargetError.invalidDescriptor.rawValue == 0)
    #expect(DisplayTargetError.invalidReservation.rawValue == 1)
    #expect(DisplayTargetError.capacityExhausted.rawValue == 2)
    #expect(DisplayTargetError.arithmeticOverflow.rawValue == 3)
    #expect(DisplayTargetError.transportUnavailable.rawValue == 4)
    #expect(DisplayTargetError.reentrancyViolation.rawValue == 5)
    #expect(DisplayTargetError.invariantViolation.rawValue == 6)
    #expect(MemoryLayout<DisplayTargetError>.size == 1)
    #expect(MemoryLayout<DisplayTargetError>.stride == 1)
}

@Test
func displayResultValuesPreserveCasesAndPayloads() {
    let reservation = DisplayReservationID(rawValue: 7)

    #expect(DisplayReservationResult.reserved(reservation) == .reserved(reservation))
    #expect(DisplayReservationResult.backpressured == .backpressured)
    #expect(DisplayReservationResult.retryableRefusal == .retryableRefusal)
    #expect(DisplayReservationResult.nonRetryableRefusal == .nonRetryableRefusal)
    #expect(
        DisplayReservationResult.failure(.capacityExhausted)
            == .failure(.capacityExhausted)
    )
    #expect(DisplayTransferResult.completed == .completed)
    #expect(
        DisplayTransferResult.failureBeforeAcceptance(.invalidReservation)
            == .failureBeforeAcceptance(.invalidReservation)
    )
    #expect(
        DisplayTransferResult.failureAfterAcceptance(.transportUnavailable)
            == .failureAfterAcceptance(.transportUnavailable)
    )
}

@Test
func displayTargetUsesItsAssociatedWriterThroughExclusiveBorrow() {
    var target = CompileProbeDisplayTarget()
    let reservation = DisplayReservationID(rawValue: 0)
    let result = target.withWriter(for: reservation) { writer in
        writer.marker = 9
        return writer.marker
    }

    #expect(result == 9)
    #expect(target.writer.marker == 9)
    #expect(target.submissionLifetime == .synchronousBorrow)
    #expect(target.handoff == .synchronous)
    #expect(target.maximumInFlightPayloads == 1)
    #expect(target.maximumInFlightBytes == 64)
    #expect(target.health().state == .available)
}

private struct CompileProbeWriter: DisplayPayloadWriter {
    let capacityBytes: UInt32 = 64
    var writtenBytes: UInt32 = 0
    let regionCapacity: UInt16 = 4
    var writtenRegionCount: UInt16 = 0
    var marker: UInt8 = 0

    mutating func beginRegion(
        origin: Point,
        pixelCount: UInt16,
        encoding: CanonicalPixelEncoding
    ) -> Bool {
        origin.x >= 0 && pixelCount > 0 && encoding == .rgba8888
    }

    mutating func write(byte: UInt8) -> Bool {
        writtenBytes += 1
        marker = byte
        return writtenBytes <= capacityBytes
    }

    mutating func endRegion() -> Bool {
        writtenRegionCount += 1
        return writtenRegionCount <= regionCapacity
    }

    mutating func finish() -> Bool {
        writtenRegionCount > 0
    }

    mutating func discard() {
        writtenBytes = 0
        writtenRegionCount = 0
    }
}

private struct CompileProbeDisplayTarget: DisplayTarget {
    let submissionLifetime = SubmissionLifetime.synchronousBorrow
    let handoff = SubmissionHandoff.synchronous
    let maximumInFlightPayloads: UInt8 = 1
    let maximumInFlightBytes: UInt32 = 64
    var writer = CompileProbeWriter()
    var currentHealth = GiftUIOperationalHealth()

    mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult {
        .reserved(DisplayReservationID(rawValue: 0))
    }

    mutating func withWriter<Result>(
        for reservation: DisplayReservationID,
        _ body: (inout CompileProbeWriter) -> Result
    ) -> Result? {
        guard reservation.rawValue == 0 else { return nil }
        return body(&writer)
    }

    mutating func submitPayload(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        .completed
    }

    mutating func finishFrame(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        .completed
    }

    mutating func cancelFrame(_ reservation: DisplayReservationID) {}

    borrowing func health() -> GiftUIOperationalHealth {
        currentHealth
    }
}
