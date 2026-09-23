import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIFailureCore
import GiftUISurfaceCore

/// Consumes each horizontal run before returning from `presentRGB565BigEndian`.
/// The bytes are borrowed from the one raster tile and must not be retained.
package protocol StaticSignalAnalyzerNRFDisplayTransport {
    mutating func presentRGB565BigEndian(
        x: UInt16,
        y: UInt16,
        pixelCount: UInt16,
        bytes: UnsafeRawBufferPointer
    ) -> Bool
}

/// Packs touched pixels toward the front of the same tile region. The raster
/// traversal reads pixels in ascending offset order, so this compaction never
/// overwrites an unread pixel. Discard resets metadata without clearing bytes.
package struct StaticSignalAnalyzerNRFDisplayWriter: DisplayPayloadWriter {
    package let capacityBytes: UInt32 = 3_840
    package let regionCapacity: UInt16 = 1
    package private(set) var writtenBytes: UInt32 = 0
    package private(set) var writtenRegionCount: UInt16 = 0
    package private(set) var origin: Point?
    package private(set) var pixelCount: UInt16 = 0
    package private(set) var isFinished = false

    private let region: UnsafeMutableRawBufferPointer
    private var remainingRegionBytes: UInt32 = 0

    package init?(region: UnsafeMutableRawBufferPointer) {
        guard region.count == Int(capacityBytes), region.baseAddress != nil else {
            return nil
        }
        self.region = region
    }

    package mutating func beginRegion(
        origin: Point,
        pixelCount: UInt16,
        encoding: CanonicalPixelEncoding
    ) -> Bool {
        guard !isFinished, self.origin == nil,
            remainingRegionBytes == 0, writtenRegionCount == 0,
            encoding == .rgb565BigEndian,
            pixelCount > 0,
            origin.x >= 0, origin.y >= 0,
            origin.x < 480, origin.y < 320,
            Int32(pixelCount) <= 480 - origin.x
        else { return false }
        let byteCount = UInt32(pixelCount) * 2
        guard byteCount <= capacityBytes else { return false }
        self.origin = origin
        self.pixelCount = pixelCount
        remainingRegionBytes = byteCount
        return true
    }

    package mutating func write(byte: UInt8) -> Bool {
        guard !isFinished, remainingRegionBytes > 0,
            writtenBytes < capacityBytes
        else { return false }
        region[Int(writtenBytes)] = byte
        writtenBytes += 1
        remainingRegionBytes -= 1
        return true
    }

    package mutating func endRegion() -> Bool {
        guard !isFinished, origin != nil, remainingRegionBytes == 0,
            writtenBytes == UInt32(pixelCount) * 2
        else { return false }
        writtenRegionCount = 1
        return true
    }

    package mutating func finish() -> Bool {
        guard !isFinished, writtenRegionCount == 1,
            remainingRegionBytes == 0
        else { return false }
        isFinished = true
        return true
    }

    package mutating func discard() {
        writtenBytes = 0
        writtenRegionCount = 0
        origin = nil
        pixelCount = 0
        remainingRegionBytes = 0
        isFinished = false
    }

    package borrowing func withBorrowedPayload<Result>(
        _ body: (Point, UInt16, UnsafeRawBufferPointer) -> Result
    ) -> Result? {
        guard isFinished, let origin,
            writtenBytes == UInt32(pixelCount) * 2,
            let baseAddress = region.baseAddress
        else { return nil }
        return body(
            origin,
            pixelCount,
            UnsafeRawBufferPointer(start: baseAddress, count: Int(writtenBytes))
        )
    }
}

/// One synchronous borrowed-payload target for the validated 480 x 320 nRF
/// surface. Its writer shares the caller's raster region with the tile store.
package struct StaticSignalAnalyzerNRFDisplayTarget<Transport>: DisplayTarget
where Transport: StaticSignalAnalyzerNRFDisplayTransport {
    package let submissionLifetime: SubmissionLifetime = .synchronousBorrow
    package let handoff: SubmissionHandoff = .synchronous
    package let maximumInFlightPayloads: UInt8 = 1
    package let maximumInFlightBytes: UInt32 = 3_840
    package private(set) var transport: Transport
    package private(set) var writer: StaticSignalAnalyzerNRFDisplayWriter

    private var reservation: DisplayReservationID?
    private var nextReservationRaw: UInt32 = 1
    private var operationalHealth = GiftUIOperationalHealth()
    private var drainingAfterTransportFailure = false

    package init?(
        transport: consuming Transport,
        rasterRegion: UnsafeMutableRawBufferPointer
    ) {
        guard let writer = StaticSignalAnalyzerNRFDisplayWriter(region: rasterRegion)
        else { return nil }
        self.transport = transport
        self.writer = writer
    }

    package mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult {
        guard reservation == nil else { return .failure(.reentrancyViolation) }
        guard operationalHealth.state == .available else {
            return .nonRetryableRefusal
        }
        guard descriptor == StaticSignalAnalyzerNRFAssembly.descriptor(),
            payloadCapacityBytes == writer.capacityBytes,
            regionCapacity == writer.regionCapacity
        else { return .failure(.invalidDescriptor) }
        let next = nextReservationRaw.addingReportingOverflow(1)
        guard !next.overflow, next.partialValue != 0 else {
            return .failure(.capacityExhausted)
        }
        let id = DisplayReservationID(rawValue: nextReservationRaw)
        nextReservationRaw = next.partialValue
        reservation = id
        return .reserved(id)
    }

    package mutating func withWriter<Result>(
        for reservation: DisplayReservationID,
        _ body: (inout StaticSignalAnalyzerNRFDisplayWriter) -> Result
    ) -> Result? {
        guard self.reservation == reservation,
            !drainingAfterTransportFailure
        else { return nil }
        return body(&writer)
    }

    package mutating func submitPayload(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        guard self.reservation == reservation else {
            return .failureBeforeAcceptance(.invalidReservation)
        }
        if drainingAfterTransportFailure {
            return .failureAfterAcceptance(.transportUnavailable)
        }
        let transportResult = writer.withBorrowedPayload { origin, pixelCount, bytes in
            transport.presentRGB565BigEndian(
                x: UInt16(origin.x),
                y: UInt16(origin.y),
                pixelCount: pixelCount,
                bytes: bytes
            )
        }
        guard let transportResult else {
            return .failureBeforeAcceptance(.invariantViolation)
        }
        guard transportResult else {
            // A failed synchronous driver call may have sent a prefix of the
            // payload. Keep responsibility, drain once, and require a fresh
            // target before another frame.
            drainingAfterTransportFailure = true
            writer.discard()
            operationalHealth.recordFailure(
                GiftUIFailureFact(
                    condition: .requiredFacilityUnavailable,
                    origin: .presentationIntegration,
                    affectedScope: .component,
                    containment: .contained
                ),
                resultingState: .unavailable
            )
            return .failureAfterAcceptance(.transportUnavailable)
        }
        writer.discard()
        return .completed
    }

    package mutating func finishFrame(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        guard self.reservation == reservation else {
            return .failureBeforeAcceptance(.invalidReservation)
        }
        if drainingAfterTransportFailure {
            self.reservation = nil
            drainingAfterTransportFailure = false
            return .completed
        }
        guard
            !writer.isFinished,
            writer.writtenRegionCount == 0
        else { return .failureBeforeAcceptance(.invalidReservation) }
        self.reservation = nil
        return .completed
    }

    package mutating func cancelFrame(_ reservation: DisplayReservationID) {
        guard self.reservation == reservation else { return }
        writer.discard()
        self.reservation = nil
        drainingAfterTransportFailure = false
    }

    package borrowing func health() -> GiftUIOperationalHealth {
        operationalHealth
    }
}
