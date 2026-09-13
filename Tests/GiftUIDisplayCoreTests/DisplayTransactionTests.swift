import GiftUI
import GiftUICapabilities
import GiftUISurfaceCore
import Testing

@testable import GiftUIDisplayCore

private let transactionDescriptor = RasterSurfaceDescriptor(
    bounds: Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 2, height: 2)!
    )!,
    encoding: .rgba8888,
    bytesPerRow: 8,
    realization: .fullSurface,
    regionWidth: 2,
    regionHeight: 2
)!

private func transactionTarget(
    submissionLifetime: SubmissionLifetime = .synchronousBorrow,
    handoff: SubmissionHandoff = .synchronous,
    finishResults: [DisplayTransferResult] = []
) -> RecordingDisplayTarget {
    RecordingDisplayTarget(
        descriptor: transactionDescriptor,
        payloadCapacityBytes: 16,
        regionCapacity: 2,
        submissionLifetime: submissionLifetime,
        handoff: handoff,
        maximumInFlightBytes: 16,
        finishResults: finishResults
    )
}

private func reserveTransaction(
    _ target: inout RecordingDisplayTarget
) -> DisplayReservationID {
    guard
        case .reserved(let id) = target.reserveFrame(
            descriptor: transactionDescriptor,
            payloadCapacityBytes: 16,
            regionCapacity: 2
        )
    else {
        fatalError("expected reservation")
    }
    return id
}

private func stageTransactionPixel(
    _ target: inout RecordingDisplayTarget,
    id: DisplayReservationID,
    x: Int32,
    y: Int32,
    byte: UInt8
) {
    let result = target.withWriter(for: id) { writer in
        guard
            writer.beginRegion(
                origin: Point(x: x, y: y),
                pixelCount: 1,
                encoding: .rgba8888
            )
        else { return false }
        return writer.write(byte: byte)
            && writer.write(byte: 2)
            && writer.write(byte: 3)
            && writer.write(byte: 255)
            && writer.endRegion()
            && writer.finish()
    }
    #expect(result == true)
}

@Test
func zeroDamageCompletesWithoutWriterOrPayloadAndResetsSession() {
    var target = transactionTarget()
    let id = reserveTransaction(&target)

    #expect(target.finishFrame(id) == .completed)
    #expect(target.submittedPayloads.isEmpty)
    #expect(target.responsibilityTransferCount == 0)
    #expect(target.activeReservation == nil)
    #expect(target.writer.writtenBytes == 0)
    #expect(target.writer.writtenRegionCount == 0)
}

@Test
func synchronousSessionSubmitsMultiplePayloadsThenResetsAllCounters() {
    var target = transactionTarget(submissionLifetime: .synchronousCopy)
    let id = reserveTransaction(&target)
    stageTransactionPixel(&target, id: id, x: 0, y: 0, byte: 1)
    #expect(target.submitPayload(id) == .completed)
    stageTransactionPixel(&target, id: id, x: 1, y: 1, byte: 4)
    #expect(target.submitPayload(id) == .completed)

    #expect(target.submittedPayloads.count == 2)
    #expect(target.responsibilityTransferCount == 1)
    #expect(target.finishFrame(id) == .completed)
    #expect(target.inFlightPayloadCount == 0)
    #expect(target.inFlightBytes == 0)
    #expect(target.writer.writtenBytes == 0)
    #expect(target.writer.writtenRegionCount == 0)
}

@Test
func failedWriterBodyDiscardsAttemptAndRemainsCancellable() {
    var target = transactionTarget()
    let id = reserveTransaction(&target)

    let bodyResult = target.withWriter(for: id) { writer in
        let began = writer.beginRegion(
            origin: Point(x: 0, y: 0),
            pixelCount: 1,
            encoding: .rgba8888
        )
        let wrote = writer.write(byte: 1)
        #expect(began)
        #expect(wrote)
        writer.discard()
        return false
    }

    #expect(bodyResult == false)
    #expect(target.writer.writtenBytes == 0)
    #expect(target.writer.writtenRegionCount == 0)
    #expect(target.submittedPayloads.isEmpty)
    target.cancelFrame(id)
    #expect(target.cancelledReservations == [id])
}

@Test
func retainedDisplayPayloadIsReleasedOnlyByTerminalTeardown() {
    var target = transactionTarget(
        submissionLifetime: .ownershipTransfer,
        handoff: .queued
    )
    let id = reserveTransaction(&target)
    stageTransactionPixel(&target, id: id, x: 0, y: 0, byte: 1)

    #expect(target.submitPayload(id) == .completed)
    #expect(target.inFlightPayloadCount == 1)
    #expect(target.inFlightBytes == 4)
    #expect(target.finishFrame(id) == .completed)
    #expect(target.inFlightPayloadCount == 0)
    #expect(target.inFlightBytes == 0)
}

@Test
func cancelResetsWriterAndNextReservationStartsAtSuccessorIdentity() {
    var target = transactionTarget()
    let first = reserveTransaction(&target)
    let staged = target.withWriter(for: first) { writer in
        writer.beginRegion(
            origin: Point(x: 0, y: 0),
            pixelCount: 1,
            encoding: .rgba8888
        ) && writer.write(byte: 1)
    }
    #expect(staged == true)
    target.cancelFrame(first)

    let second = reserveTransaction(&target)
    #expect(first.rawValue == 0)
    #expect(second.rawValue == 1)
    #expect(target.writer.writtenBytes == 0)
    #expect(target.writer.writtenRegionCount == 0)
    #expect(target.finishFrame(second) == .completed)
}

@Test
func zeroPayloadFrameEndFailureBeforeAcceptanceEndsWithoutHealthChange() {
    var target = transactionTarget(
        finishResults: [.failureBeforeAcceptance(.transportUnavailable)]
    )
    let id = reserveTransaction(&target)

    #expect(
        target.finishFrame(id)
            == .failureBeforeAcceptance(.transportUnavailable)
    )
    #expect(target.activeReservation == nil)
    #expect(target.responsibilityTransferCount == 0)
    #expect(target.health().state == .available)
    #expect(target.health().failureCount == 0)
}
