import GiftUI
import GiftUICapabilities
import GiftUISurfaceCore
import Testing

@testable import GiftUIDisplayCore

private func submissionDescriptor(
    realization: RasterRealizationKind = .tiled
) -> RasterSurfaceDescriptor {
    RasterSurfaceDescriptor(
        bounds: Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 4, height: 3)!
        )!,
        encoding: .rgb565BigEndian,
        bytesPerRow: 8,
        realization: realization,
        regionWidth: 4,
        regionHeight: realization == .tiled ? 1 : 3
    )!
}

private func submissionTarget(
    realization: RasterRealizationKind = .tiled,
    lifetime: SubmissionLifetime = .synchronousBorrow,
    handoff: SubmissionHandoff = .synchronous
) -> RecordingDisplayTarget {
    let descriptor = submissionDescriptor(realization: realization)
    return RecordingDisplayTarget(
        descriptor: descriptor,
        payloadCapacityBytes: realization == .tiled ? 8 : 24,
        regionCapacity: 2,
        submissionLifetime: lifetime,
        handoff: handoff,
        maximumInFlightPayloads: 1,
        maximumInFlightBytes: realization == .tiled ? 8 : 24
    )
}

private func reserveSubmission(
    _ target: inout RecordingDisplayTarget
) -> DisplayReservationID? {
    let result = target.reserveFrame(
        descriptor: target.expectedDescriptor,
        payloadCapacityBytes: target.expectedPayloadCapacityBytes,
        regionCapacity: target.expectedRegionCapacity
    )
    guard case .reserved(let id) = result else { return nil }
    return id
}

private func finishOnePixel(
    _ target: inout RecordingDisplayTarget,
    reservation: DisplayReservationID,
    byteSeed: UInt8
) -> Bool? {
    target.withWriter(for: reservation) { writer in
        guard
            writer.beginRegion(
                origin: Point(x: 0, y: 0),
                pixelCount: 1,
                encoding: .rgb565BigEndian
            )
        else { return false }
        guard writer.write(byte: byteSeed),
            writer.write(byte: byteSeed + 1),
            writer.endRegion()
        else { return false }
        return writer.finish()
    }
}

@Test
func synchronousBorrowAndCopyReuseSlotOnlyAfterEachCompletedSubmit() {
    for lifetime in [SubmissionLifetime.synchronousBorrow, .synchronousCopy] {
        var target = submissionTarget(lifetime: lifetime)
        let id = reserveSubmission(&target)!

        #expect(finishOnePixel(&target, reservation: id, byteSeed: 1) == true)
        var writerBeforeSubmitCalls = 0
        #expect(target.withWriter(for: id) { _ in writerBeforeSubmitCalls += 1 } == nil)
        #expect(writerBeforeSubmitCalls == 0)
        #expect(target.submitPayload(id) == .completed)
        #expect(target.writer.writtenBytes == 0)
        #expect(finishOnePixel(&target, reservation: id, byteSeed: 3) == true)
        #expect(target.submitPayload(id) == .completed)
        #expect(target.submittedPayloads.map(\.bytes) == [[1, 2], [3, 4]])
        #expect(target.inFlightPayloadCount == 0)
        #expect(target.finishFrame(id) == .completed)
    }
}

@Test
func submitRequiresExactlyOneSuccessfulWriterFinish() {
    var target = submissionTarget()
    let id = reserveSubmission(&target)!

    #expect(
        target.submitPayload(id)
            == .failureBeforeAcceptance(.invariantViolation)
    )
    #expect(finishOnePixel(&target, reservation: id, byteSeed: 1) == true)
    #expect(target.submitPayload(id) == .completed)
    #expect(
        target.submitPayload(id)
            == .failureBeforeAcceptance(.invariantViolation)
    )
    #expect(target.submittedPayloads.count == 1)
}

@Test
func queuedAndOwnershipTransferAllowOnlyOneFullSurfacePayload() {
    let modes: [(SubmissionLifetime, SubmissionHandoff)] = [
        (.synchronousBorrow, .queued),
        (.ownershipTransfer, .synchronous),
    ]

    for (lifetime, handoff) in modes {
        var target = submissionTarget(
            realization: .fullSurface,
            lifetime: lifetime,
            handoff: handoff
        )
        let id = reserveSubmission(&target)!
        #expect(finishOnePixel(&target, reservation: id, byteSeed: 5) == true)
        #expect(target.submitPayload(id) == .completed)
        #expect(target.inFlightPayloadCount == 1)
        #expect(target.inFlightBytes == 2)
        var secondWriterCalls = 0
        #expect(target.withWriter(for: id) { _ in secondWriterCalls += 1 } == nil)
        #expect(secondWriterCalls == 0)
        #expect(target.finishFrame(id) == .completed)
        #expect(target.inFlightPayloadCount == 0)
        #expect(target.inFlightBytes == 0)
    }
}

@Test
func tiledSessionsRejectQueuedAndOwnershipTransferBeforeAllocation() {
    let modes: [(SubmissionLifetime, SubmissionHandoff)] = [
        (.synchronousBorrow, .queued),
        (.ownershipTransfer, .synchronous),
        (.ownershipTransfer, .queued),
    ]

    for (lifetime, handoff) in modes {
        var target = submissionTarget(lifetime: lifetime, handoff: handoff)
        #expect(
            target.reserveFrame(
                descriptor: target.expectedDescriptor,
                payloadCapacityBytes: target.expectedPayloadCapacityBytes,
                regionCapacity: target.expectedRegionCapacity
            ) == .failure(.invariantViolation)
        )
        #expect(target.reservations.isEmpty)
        #expect(target.activeReservation == nil)
    }
}

@Test
func unfinishedOrFinishedUnsubmittedPayloadCannotFinishFrame() {
    var target = submissionTarget()
    let id = reserveSubmission(&target)!
    #expect(
        target.withWriter(for: id) { writer in
            writer.beginRegion(
                origin: Point(x: 0, y: 0),
                pixelCount: 1,
                encoding: .rgb565BigEndian
            )
        } == true
    )
    #expect(
        target.finishFrame(id)
            == .failureBeforeAcceptance(.invariantViolation)
    )
    target.cancelFrame(id)

    let second = reserveSubmission(&target)!
    #expect(finishOnePixel(&target, reservation: second, byteSeed: 1) == true)
    #expect(
        target.finishFrame(second)
            == .failureBeforeAcceptance(.invariantViolation)
    )
}
