import GiftUI
import GiftUICapabilities
import GiftUISurfaceCore
import Testing

@testable import GiftUIDisplayCore

private let responsibilityDescriptor = RasterSurfaceDescriptor(
    bounds: Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 2, height: 1)!
    )!,
    encoding: .rgb565BigEndian,
    bytesPerRow: 4,
    realization: .fullSurface,
    regionWidth: 2,
    regionHeight: 1
)!

private func responsibilityTarget(
    submitResults: [DisplayTransferResult] = [],
    finishResults: [DisplayTransferResult] = []
) -> RecordingDisplayTarget {
    RecordingDisplayTarget(
        descriptor: responsibilityDescriptor,
        payloadCapacityBytes: 4,
        regionCapacity: 1,
        submitResults: submitResults,
        finishResults: finishResults
    )
}

private func reserveResponsibility(
    _ target: inout RecordingDisplayTarget
) -> DisplayReservationID {
    guard
        case .reserved(let id) = target.reserveFrame(
            descriptor: responsibilityDescriptor,
            payloadCapacityBytes: 4,
            regionCapacity: 1
        )
    else {
        fatalError("expected reservation")
    }
    return id
}

private func finishResponsibilityPayload(
    _ target: inout RecordingDisplayTarget,
    id: DisplayReservationID
) {
    let finished = target.withWriter(for: id) { writer in
        guard
            writer.beginRegion(
                origin: Point(x: 0, y: 0),
                pixelCount: 1,
                encoding: .rgb565BigEndian
            )
        else { return false }
        return writer.write(byte: 1)
            && writer.write(byte: 2)
            && writer.endRegion()
            && writer.finish()
    }
    #expect(finished == true)
}

@Test
func completedSubmitTransfersResponsibilityExactlyOncePerFrame() {
    var target = responsibilityTarget()
    let id = reserveResponsibility(&target)
    finishResponsibilityPayload(&target, id: id)

    #expect(target.submitPayload(id) == .completed)
    #expect(target.presentationResponsibilityAccepted)
    #expect(target.responsibilityTransferCount == 1)
    finishResponsibilityPayload(&target, id: id)
    #expect(target.submitPayload(id) == .completed)
    #expect(target.responsibilityTransferCount == 1)
    target.cancelFrame(id)
    #expect(target.activeReservation == id)
    #expect(target.finishFrame(id) == .completed)
    #expect(target.activeReservation == nil)
}

@Test
func failureBeforeFirstAcceptanceRemainsReversibleAndHealthy() {
    var target = responsibilityTarget(
        submitResults: [.failureBeforeAcceptance(.transportUnavailable)]
    )
    let id = reserveResponsibility(&target)
    finishResponsibilityPayload(&target, id: id)

    #expect(
        target.submitPayload(id)
            == .failureBeforeAcceptance(.transportUnavailable)
    )
    #expect(!target.presentationResponsibilityAccepted)
    #expect(target.responsibilityTransferCount == 0)
    #expect(target.submittedPayloads.isEmpty)
    #expect(target.health().state == .available)
    target.cancelFrame(id)
    #expect(target.cancelledReservations == [id])
    #expect(target.activeReservation == nil)
}

@Test
func failureAfterAcceptanceTransfersDrainsAndUpdatesHealthOnce() {
    var target = responsibilityTarget(
        submitResults: [.failureAfterAcceptance(.transportUnavailable)]
    )
    let id = reserveResponsibility(&target)
    finishResponsibilityPayload(&target, id: id)

    #expect(
        target.submitPayload(id)
            == .failureAfterAcceptance(.transportUnavailable)
    )
    #expect(target.presentationResponsibilityAccepted)
    #expect(target.isDraining)
    #expect(target.responsibilityTransferCount == 1)
    #expect(target.health().state == .unavailable)
    #expect(target.health().failureCount == 1)
    var writerCalls = 0
    #expect(target.withWriter(for: id) { _ in writerCalls += 1 } == nil)
    #expect(
        target.submitPayload(id)
            == .failureAfterAcceptance(.transportUnavailable)
    )
    #expect(target.health().failureCount == 1)
    #expect(target.finishFrame(id) == .completed)
    #expect(writerCalls == 0)
}

@Test
func illegalFailureBeforeAcceptanceAfterCompletedPayloadBecomesAfterInvariant() {
    var target = responsibilityTarget(
        submitResults: [
            .completed,
            .failureBeforeAcceptance(.transportUnavailable),
        ]
    )
    let id = reserveResponsibility(&target)
    finishResponsibilityPayload(&target, id: id)
    #expect(target.submitPayload(id) == .completed)
    finishResponsibilityPayload(&target, id: id)

    #expect(
        target.submitPayload(id)
            == .failureAfterAcceptance(.invariantViolation)
    )
    #expect(target.isDraining)
    #expect(target.submittedPayloads.count == 1)
    #expect(target.health().state == .quiesced)
    #expect(target.health().failureCount == 1)
    #expect(target.finishFrame(id) == .completed)
}

@Test
func zeroPayloadFinishFailureAfterAcceptanceTransfersAndEndsSession() {
    var target = responsibilityTarget(
        finishResults: [.failureAfterAcceptance(.transportUnavailable)]
    )
    let id = reserveResponsibility(&target)

    #expect(
        target.finishFrame(id)
            == .failureAfterAcceptance(.transportUnavailable)
    )
    #expect(target.responsibilityTransferCount == 1)
    #expect(target.health().state == .unavailable)
    #expect(target.health().failureCount == 1)
    #expect(target.activeReservation == nil)
}
