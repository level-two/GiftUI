import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIFailureCore
import GiftUISurfaceCore

package struct PiScreenPayloadRegion: Equatable, Sendable {
    package let origin: Point
    package let pixelCount: UInt16
    package let byteOffset: UInt32
}

package protocol PiScreenFramebufferSink {
    mutating func presentRGB565BigEndian(
        bytes: UnsafeRawBufferPointer,
        regions: [PiScreenPayloadRegion],
        transform: PiScreenAspectFitTransform
    ) -> Bool
}

package struct PiScreenPayloadWriter: DisplayPayloadWriter {
    package let capacityBytes: UInt32
    package let regionCapacity: UInt16
    package private(set) var writtenBytes: UInt32 = 0
    package private(set) var writtenRegionCount: UInt16 = 0
    package private(set) var storage: [UInt8]
    package private(set) var regions: [PiScreenPayloadRegion] = []
    private var remainingRegionBytes: UInt32 = 0
    private var finished = false

    package init(capacityBytes: UInt32, regionCapacity: UInt16) {
        self.capacityBytes = capacityBytes
        self.regionCapacity = regionCapacity
        storage = [UInt8](repeating: 0, count: Int(capacityBytes))
        regions.reserveCapacity(Int(regionCapacity))
    }

    package mutating func beginRegion(
        origin: Point,
        pixelCount: UInt16,
        encoding: CanonicalPixelEncoding
    ) -> Bool {
        guard !finished, remainingRegionBytes == 0,
            writtenRegionCount < regionCapacity,
            encoding == .rgb565BigEndian,
            pixelCount > 0
        else { return false }
        let required = UInt32(pixelCount).multipliedReportingOverflow(by: 2)
        guard !required.overflow, required.partialValue <= capacityBytes - writtenBytes else {
            return false
        }
        regions.append(
            PiScreenPayloadRegion(
                origin: origin,
                pixelCount: pixelCount,
                byteOffset: writtenBytes
            )
        )
        remainingRegionBytes = required.partialValue
        return true
    }

    package mutating func write(byte: UInt8) -> Bool {
        guard !finished, remainingRegionBytes > 0, writtenBytes < capacityBytes else {
            return false
        }
        storage[Int(writtenBytes)] = byte
        writtenBytes += 1
        remainingRegionBytes -= 1
        return true
    }

    package mutating func endRegion() -> Bool {
        guard !finished, remainingRegionBytes == 0 else { return false }
        writtenRegionCount += 1
        return true
    }

    package mutating func finish() -> Bool {
        guard !finished, remainingRegionBytes == 0, writtenRegionCount > 0 else {
            return false
        }
        finished = true
        return true
    }

    package mutating func discard() {
        _ = storage.withUnsafeMutableBytes {
            $0.initializeMemory(as: UInt8.self, repeating: 0)
        }
        writtenBytes = 0
        writtenRegionCount = 0
        regions.removeAll(keepingCapacity: true)
        remainingRegionBytes = 0
        finished = false
    }
}

package struct PiScreenDisplayTarget<Sink: PiScreenFramebufferSink>: DisplayTarget {
    package let submissionLifetime: SubmissionLifetime = .synchronousBorrow
    package let handoff: SubmissionHandoff = .synchronous
    package let maximumInFlightPayloads: UInt8 = 1
    package let maximumInFlightBytes: UInt32 = 7_680
    package private(set) var sink: Sink
    package private(set) var writer: PiScreenPayloadWriter
    private let transform: PiScreenAspectFitTransform
    private var descriptor: RasterSurfaceDescriptor?
    private var reservation: DisplayReservationID?
    private var nextReservationRaw: UInt32 = 1
    private var operationalHealth = GiftUIOperationalHealth()

    package init?(
        sink: Sink,
        layout: PiScreenFramebufferLayout,
        payloadCapacityBytes: UInt32 = 7_680,
        regionCapacity: UInt16 = 320
    ) {
        guard payloadCapacityBytes > 0, payloadCapacityBytes <= maximumInFlightBytes,
            regionCapacity > 0,
            let transform = PiScreenAspectFitTransform(
                physicalWidth: Int32(layout.width),
                physicalHeight: Int32(layout.height),
                logicalWidth: 240,
                logicalHeight: 240
            )
        else { return nil }
        self.sink = sink
        self.transform = transform
        writer = PiScreenPayloadWriter(
            capacityBytes: payloadCapacityBytes,
            regionCapacity: regionCapacity
        )
    }

    package mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult {
        guard reservation == nil else { return .failure(.reentrancyViolation) }
        guard descriptor.bounds.size == Size(width: 240, height: 240),
            descriptor.encoding == .rgb565BigEndian,
            descriptor.realization == .tiled,
            descriptor.regionWidth == 240,
            descriptor.regionHeight == 16,
            descriptor.bytesPerRow == 480,
            payloadCapacityBytes > 0,
            payloadCapacityBytes <= writer.capacityBytes,
            regionCapacity > 0,
            regionCapacity <= writer.regionCapacity
        else { return .failure(.invalidDescriptor) }
        let id = DisplayReservationID(rawValue: nextReservationRaw)
        let successor = nextReservationRaw.addingReportingOverflow(1)
        guard !successor.overflow, successor.partialValue != 0 else {
            return .failure(.capacityExhausted)
        }
        nextReservationRaw = successor.partialValue
        self.descriptor = descriptor
        reservation = id
        return .reserved(id)
    }

    package mutating func withWriter<Result>(
        for reservation: DisplayReservationID,
        _ body: (inout PiScreenPayloadWriter) -> Result
    ) -> Result? {
        guard self.reservation == reservation else { return nil }
        return body(&writer)
    }

    package mutating func submitPayload(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        guard self.reservation == reservation, descriptor != nil else {
            return .failureBeforeAcceptance(.invalidReservation)
        }
        let accepted = writer.storage.withUnsafeBytes { bytes in
            sink.presentRGB565BigEndian(
                bytes: UnsafeRawBufferPointer(rebasing: bytes[..<Int(writer.writtenBytes)]),
                regions: writer.regions,
                transform: transform
            )
        }
        guard accepted else { return .failureBeforeAcceptance(.transportUnavailable) }
        writer.discard()
        return .completed
    }

    package mutating func finishFrame(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        guard self.reservation == reservation else {
            return .failureBeforeAcceptance(.invalidReservation)
        }
        self.reservation = nil
        descriptor = nil
        return .completed
    }

    package mutating func cancelFrame(_ reservation: DisplayReservationID) {
        guard self.reservation == reservation else { return }
        writer.discard()
        self.reservation = nil
        descriptor = nil
    }

    package borrowing func health() -> GiftUIOperationalHealth {
        operationalHealth
    }
}
