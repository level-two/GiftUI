import GiftUI
import GiftUICapabilities
import GiftUIFailureCore
import GiftUISurfaceCore

@testable import GiftUIDisplayCore

struct RecordingDisplayWriter: DisplayPayloadWriter {
    let capacityBytes: UInt32
    var writtenBytes: UInt32 = 0
    let regionCapacity: UInt16
    var writtenRegionCount: UInt16 = 0

    mutating func beginRegion(
        origin: Point,
        pixelCount: UInt16,
        encoding: CanonicalPixelEncoding
    ) -> Bool {
        _ = origin
        _ = pixelCount
        _ = encoding
        return false
    }

    mutating func write(byte: UInt8) -> Bool {
        _ = byte
        return false
    }

    mutating func endRegion() -> Bool { false }
    mutating func finish() -> Bool { false }

    mutating func discard() {
        writtenBytes = 0
        writtenRegionCount = 0
    }
}

struct RecordedDisplayReservation: Equatable {
    let id: DisplayReservationID
    let descriptor: RasterSurfaceDescriptor
    let payloadCapacityBytes: UInt32
    let regionCapacity: UInt16
}

struct RecordingDisplayTarget: DisplayTarget {
    let submissionLifetime: SubmissionLifetime
    let handoff: SubmissionHandoff
    let maximumInFlightPayloads: UInt8
    let maximumInFlightBytes: UInt32
    let expectedDescriptor: RasterSurfaceDescriptor
    let expectedPayloadCapacityBytes: UInt32
    let expectedRegionCapacity: UInt16

    private(set) var writer: RecordingDisplayWriter
    private(set) var activeReservation: DisplayReservationID?
    private(set) var reservations: [RecordedDisplayReservation] = []
    private(set) var finishedReservations: [DisplayReservationID] = []
    private(set) var cancelledReservations: [DisplayReservationID] = []
    private(set) var lastError: DisplayTargetError?
    private(set) var currentHealth = GiftUIOperationalHealth()

    private var nextReservationRawValue: UInt32
    private var reservationIdentityExhausted: Bool

    init(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16,
        submissionLifetime: SubmissionLifetime = .synchronousBorrow,
        handoff: SubmissionHandoff = .synchronous,
        maximumInFlightPayloads: UInt8 = 1,
        maximumInFlightBytes: UInt32? = nil,
        nextReservationRawValue: UInt32 = 0
    ) {
        expectedDescriptor = descriptor
        expectedPayloadCapacityBytes = payloadCapacityBytes
        expectedRegionCapacity = regionCapacity
        self.submissionLifetime = submissionLifetime
        self.handoff = handoff
        self.maximumInFlightPayloads = maximumInFlightPayloads
        self.maximumInFlightBytes = maximumInFlightBytes ?? payloadCapacityBytes
        writer = RecordingDisplayWriter(
            capacityBytes: payloadCapacityBytes,
            regionCapacity: regionCapacity
        )
        self.nextReservationRawValue = nextReservationRawValue
        reservationIdentityExhausted = false
    }

    mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult {
        guard activeReservation == nil else {
            lastError = .reentrancyViolation
            return .failure(.reentrancyViolation)
        }
        guard descriptor == expectedDescriptor else {
            lastError = .invalidDescriptor
            return .failure(.invalidDescriptor)
        }
        guard payloadCapacityBytes <= maximumInFlightBytes,
            maximumInFlightPayloads > 0
        else {
            lastError = .capacityExhausted
            return .failure(.capacityExhausted)
        }
        guard payloadCapacityBytes == expectedPayloadCapacityBytes,
            regionCapacity == expectedRegionCapacity
        else {
            lastError = .invariantViolation
            return .failure(.invariantViolation)
        }
        guard !reservationIdentityExhausted else {
            lastError = .capacityExhausted
            return .failure(.capacityExhausted)
        }

        let id = DisplayReservationID(rawValue: nextReservationRawValue)
        if nextReservationRawValue == .max {
            reservationIdentityExhausted = true
        } else {
            nextReservationRawValue += 1
        }
        activeReservation = id
        lastError = nil
        reservations.append(
            RecordedDisplayReservation(
                id: id,
                descriptor: descriptor,
                payloadCapacityBytes: payloadCapacityBytes,
                regionCapacity: regionCapacity
            )
        )
        return .reserved(id)
    }

    mutating func withWriter<Result>(
        for reservation: DisplayReservationID,
        _ body: (inout RecordingDisplayWriter) -> Result
    ) -> Result? {
        _ = reservation
        _ = body
        return nil
    }

    mutating func submitPayload(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        guard reservation == activeReservation else {
            lastError = .invalidReservation
            return .failureBeforeAcceptance(.invalidReservation)
        }
        lastError = .invariantViolation
        return .failureBeforeAcceptance(.invariantViolation)
    }

    mutating func finishFrame(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        guard reservation == activeReservation else {
            lastError = .invalidReservation
            return .failureBeforeAcceptance(.invalidReservation)
        }
        finishedReservations.append(reservation)
        activeReservation = nil
        lastError = nil
        return .completed
    }

    mutating func cancelFrame(_ reservation: DisplayReservationID) {
        guard reservation == activeReservation else {
            lastError = .invalidReservation
            return
        }
        cancelledReservations.append(reservation)
        activeReservation = nil
        lastError = nil
        writer.discard()
    }

    borrowing func health() -> GiftUIOperationalHealth {
        currentHealth
    }
}
