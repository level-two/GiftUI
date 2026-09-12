import GiftUI
import GiftUICapabilities
import GiftUIFailureCore
import GiftUISurfaceCore

package struct DisplayReservationID: Equatable, Hashable, Sendable {
    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

package enum DisplayReservationResult: Equatable, Sendable {
    case reserved(DisplayReservationID)
    case backpressured
    case retryableRefusal
    case nonRetryableRefusal
    case failure(DisplayTargetError)
}

package enum DisplayTransferResult: Equatable, Sendable {
    case completed
    case failureBeforeAcceptance(DisplayTargetError)
    case failureAfterAcceptance(DisplayTargetError)
}

package enum DisplayTargetError: UInt8, Equatable, Sendable {
    case invalidDescriptor = 0
    case invalidReservation = 1
    case capacityExhausted = 2
    case arithmeticOverflow = 3
    case transportUnavailable = 4
    case reentrancyViolation = 5
    case invariantViolation = 6
}

package protocol DisplayPayloadWriter {
    var capacityBytes: UInt32 { get }
    var writtenBytes: UInt32 { get }
    var regionCapacity: UInt16 { get }
    var writtenRegionCount: UInt16 { get }

    mutating func beginRegion(
        origin: Point,
        pixelCount: UInt16,
        encoding: CanonicalPixelEncoding
    ) -> Bool
    mutating func write(byte: UInt8) -> Bool
    mutating func endRegion() -> Bool
    mutating func finish() -> Bool
    mutating func discard()
}

package protocol DisplayTarget {
    associatedtype Writer: DisplayPayloadWriter

    var submissionLifetime: SubmissionLifetime { get }
    var handoff: SubmissionHandoff { get }
    var maximumInFlightPayloads: UInt8 { get }
    var maximumInFlightBytes: UInt32 { get }

    mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult
    mutating func withWriter<Result>(
        for reservation: DisplayReservationID,
        _ body: (inout Writer) -> Result
    ) -> Result?
    mutating func submitPayload(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult
    mutating func finishFrame(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult
    mutating func cancelFrame(_ reservation: DisplayReservationID)
    borrowing func health() -> GiftUIOperationalHealth
}
