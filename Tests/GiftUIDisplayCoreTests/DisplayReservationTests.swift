import GiftUI
import GiftUICapabilities
import GiftUISurfaceCore
import Testing

@testable import GiftUIDisplayCore

private let reservationDescriptor = RasterSurfaceDescriptor(
    bounds: Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 4, height: 3)!
    )!,
    encoding: .rgba8888,
    bytesPerRow: 16,
    realization: .fullSurface,
    regionWidth: 4,
    regionHeight: 3
)!

private func target(
    nextReservationRawValue: UInt32 = 0
) -> RecordingDisplayTarget {
    RecordingDisplayTarget(
        descriptor: reservationDescriptor,
        payloadCapacityBytes: 48,
        regionCapacity: 4,
        nextReservationRawValue: nextReservationRawValue
    )
}

private func reserve(_ target: inout RecordingDisplayTarget) -> DisplayReservationResult {
    target.reserveFrame(
        descriptor: reservationDescriptor,
        payloadCapacityBytes: 48,
        regionCapacity: 4
    )
}

@Test
func reservationIdentityStartsAtZeroAdvancesAndNeverReuses() {
    var display = target()

    #expect(reserve(&display) == .reserved(DisplayReservationID(rawValue: 0)))
    display.cancelFrame(DisplayReservationID(rawValue: 0))
    #expect(reserve(&display) == .reserved(DisplayReservationID(rawValue: 1)))
    #expect(display.finishFrame(DisplayReservationID(rawValue: 1)) == .completed)
    #expect(reserve(&display) == .reserved(DisplayReservationID(rawValue: 2)))
    #expect(display.reservations.map(\.id.rawValue) == [0, 1, 2])
}

@Test
func reservationAllowsOnlyOneActiveSessionAndOneTerminalCall() {
    var display = target()
    let id = DisplayReservationID(rawValue: 0)

    #expect(reserve(&display) == .reserved(id))
    #expect(reserve(&display) == .failure(.reentrancyViolation))
    #expect(display.activeReservation == id)
    #expect(display.finishFrame(id) == .completed)
    #expect(display.finishFrame(id) == .failureBeforeAcceptance(.invalidReservation))
    display.cancelFrame(id)
    #expect(display.finishedReservations == [id])
    #expect(display.cancelledReservations.isEmpty)
    #expect(display.lastError == .invalidReservation)
}

@Test
func reservationRequiresExactDescriptorAndCapacitiesBeforeMutation() {
    var display = target()
    let wrongDescriptor = RasterSurfaceDescriptor(
        bounds: reservationDescriptor.bounds,
        encoding: .rgba8888,
        bytesPerRow: 20,
        realization: .fullSurface,
        regionWidth: 4,
        regionHeight: 3
    )!

    #expect(
        display.reserveFrame(
            descriptor: wrongDescriptor,
            payloadCapacityBytes: 48,
            regionCapacity: 4
        ) == .failure(.invalidDescriptor)
    )
    #expect(
        display.reserveFrame(
            descriptor: reservationDescriptor,
            payloadCapacityBytes: 49,
            regionCapacity: 4
        ) == .failure(.capacityExhausted)
    )
    #expect(
        display.reserveFrame(
            descriptor: reservationDescriptor,
            payloadCapacityBytes: 47,
            regionCapacity: 4
        ) == .failure(.invariantViolation)
    )
    #expect(
        display.reserveFrame(
            descriptor: reservationDescriptor,
            payloadCapacityBytes: 48,
            regionCapacity: 3
        ) == .failure(.invariantViolation)
    )
    #expect(display.reservations.isEmpty)
    #expect(display.activeReservation == nil)
}

@Test
func inactiveAndStaleReservationsAreRejectedWithoutMutation() {
    var display = target()
    let stale = DisplayReservationID(rawValue: 9)
    var writerBodyCalls = 0

    #expect(display.withWriter(for: stale) { _ in writerBodyCalls += 1 } == nil)
    #expect(
        display.submitPayload(stale)
            == .failureBeforeAcceptance(.invalidReservation)
    )
    #expect(
        display.finishFrame(stale)
            == .failureBeforeAcceptance(.invalidReservation)
    )
    display.cancelFrame(stale)
    #expect(writerBodyCalls == 0)
    #expect(display.reservations.isEmpty)
    #expect(display.activeReservation == nil)
}

@Test
func reservationIdentityExhaustionOccursBeforeMutationAndNeverWraps() {
    var display = target(nextReservationRawValue: .max)
    let maximum = DisplayReservationID(rawValue: .max)

    #expect(reserve(&display) == .reserved(maximum))
    display.cancelFrame(maximum)
    #expect(reserve(&display) == .failure(.capacityExhausted))
    #expect(reserve(&display) == .failure(.capacityExhausted))
    #expect(display.reservations.map(\.id) == [maximum])
    #expect(display.activeReservation == nil)
}
