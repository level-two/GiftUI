import GiftUI
import GiftUICapabilities
import GiftUIFailureCore
import GiftUISurfaceCore

@testable import GiftUIDisplayCore

struct RecordingDisplayWriter: DisplayPayloadWriter {
    let capacityBytes: UInt32
    let regionCapacity: UInt16
    let descriptor: RasterSurfaceDescriptor
    let damageBounds: Rect

    private(set) var writtenBytes: UInt32 = 0
    private(set) var writtenRegionCount: UInt16 = 0
    private(set) var regions: [RecordedDisplayRegion] = []
    private(set) var stagedBytes: [UInt8]
    private(set) var isFinished = false
    private(set) var lastError: DisplayTargetError?

    private var activeRegion: ActiveDisplayRegion?

    var hasActiveRegion: Bool { activeRegion != nil }

    init(
        capacityBytes: UInt32,
        regionCapacity: UInt16,
        descriptor: RasterSurfaceDescriptor,
        damageBounds: Rect
    ) {
        self.capacityBytes = capacityBytes
        self.regionCapacity = regionCapacity
        self.descriptor = descriptor
        self.damageBounds = damageBounds
        stagedBytes = Array(repeating: 0, count: Int(capacityBytes))
    }

    mutating func beginRegion(
        origin: Point,
        pixelCount: UInt16,
        encoding: CanonicalPixelEncoding
    ) -> Bool {
        guard lastError == nil,
            !isFinished,
            activeRegion == nil,
            pixelCount > 0,
            encoding == descriptor.encoding,
            descriptor.bounds.contains(origin),
            damageBounds.contains(origin)
        else {
            return fault(.invariantViolation)
        }

        let endX = origin.x.addingReportingOverflow(Int32(pixelCount))
        guard !endX.overflow,
            endX.partialValue <= descriptor.bounds.maxX,
            endX.partialValue <= damageBounds.maxX,
            origin.y >= descriptor.bounds.minY,
            origin.y < descriptor.bounds.maxY,
            origin.y >= damageBounds.minY,
            origin.y < damageBounds.maxY
        else {
            return fault(.invariantViolation)
        }

        let bytesPerPixel: UInt32 = encoding == .rgba8888 ? 4 : 2
        let byteCount = UInt32(pixelCount).multipliedReportingOverflow(
            by: bytesPerPixel
        )
        let endBytes = writtenBytes.addingReportingOverflow(byteCount.partialValue)
        guard !byteCount.overflow,
            !endBytes.overflow,
            endBytes.partialValue <= capacityBytes,
            writtenRegionCount < regionCapacity
        else {
            return fault(.capacityExhausted)
        }

        activeRegion = ActiveDisplayRegion(
            origin: origin,
            pixelCount: pixelCount,
            encoding: encoding,
            byteOffset: writtenBytes,
            expectedByteCount: byteCount.partialValue,
            writtenByteCount: 0
        )
        return true
    }

    mutating func write(byte: UInt8) -> Bool {
        guard lastError == nil, !isFinished, var region = activeRegion else {
            return fault(.invariantViolation)
        }
        guard region.writtenByteCount < region.expectedByteCount,
            writtenBytes < capacityBytes
        else {
            return fault(.capacityExhausted)
        }
        stagedBytes[Int(writtenBytes)] = byte
        writtenBytes += 1
        region.writtenByteCount += 1
        activeRegion = region
        return true
    }

    mutating func endRegion() -> Bool {
        guard lastError == nil, !isFinished, let region = activeRegion else {
            return fault(.invariantViolation)
        }
        guard region.writtenByteCount == region.expectedByteCount else {
            return fault(.invariantViolation)
        }
        regions.append(
            RecordedDisplayRegion(
                origin: region.origin,
                pixelCount: region.pixelCount,
                encoding: region.encoding,
                byteOffset: region.byteOffset,
                byteCount: region.expectedByteCount
            )
        )
        writtenRegionCount += 1
        activeRegion = nil
        return true
    }

    mutating func finish() -> Bool {
        guard lastError == nil,
            !isFinished,
            activeRegion == nil,
            writtenRegionCount > 0,
            writtenBytes <= capacityBytes,
            writtenRegionCount <= regionCapacity
        else {
            return fault(.invariantViolation)
        }
        isFinished = true
        return true
    }

    mutating func discard() {
        for index in stagedBytes.indices {
            stagedBytes[index] = 0
        }
        writtenBytes = 0
        writtenRegionCount = 0
        regions.removeAll(keepingCapacity: true)
        activeRegion = nil
        isFinished = false
        lastError = nil
    }

    private mutating func fault(_ error: DisplayTargetError) -> Bool {
        if lastError == nil {
            lastError = error
        }
        return false
    }
}

private struct ActiveDisplayRegion {
    let origin: Point
    let pixelCount: UInt16
    let encoding: CanonicalPixelEncoding
    let byteOffset: UInt32
    let expectedByteCount: UInt32
    var writtenByteCount: UInt32
}

struct RecordedDisplayRegion: Equatable {
    let origin: Point
    let pixelCount: UInt16
    let encoding: CanonicalPixelEncoding
    let byteOffset: UInt32
    let byteCount: UInt32
}

struct RecordedDisplayReservation: Equatable {
    let id: DisplayReservationID
    let descriptor: RasterSurfaceDescriptor
    let payloadCapacityBytes: UInt32
    let regionCapacity: UInt16
}

struct RecordedDisplayPayload: Equatable {
    let reservation: DisplayReservationID
    let bytes: [UInt8]
    let regions: [RecordedDisplayRegion]
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
    private(set) var submittedPayloads: [RecordedDisplayPayload] = []
    private(set) var inFlightPayloadCount: UInt8 = 0
    private(set) var inFlightBytes: UInt32 = 0
    private(set) var responsibilityTransferCount: UInt32 = 0
    private(set) var presentationResponsibilityAccepted = false
    private(set) var isDraining = false
    private(set) var lastError: DisplayTargetError?
    private(set) var currentHealth = GiftUIOperationalHealth()

    private var nextReservationRawValue: UInt32
    private var reservationIdentityExhausted: Bool
    private var writerBorrowActive = false
    private var payloadSlotReusable = true
    private var injectedSubmitResults: [DisplayTransferResult]
    private var injectedFinishResults: [DisplayTransferResult]
    private var healthFailureRecordedForFrame = false

    init(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16,
        submissionLifetime: SubmissionLifetime = .synchronousBorrow,
        handoff: SubmissionHandoff = .synchronous,
        maximumInFlightPayloads: UInt8 = 1,
        maximumInFlightBytes: UInt32? = nil,
        damageBounds: Rect? = nil,
        submitResults: [DisplayTransferResult] = [],
        finishResults: [DisplayTransferResult] = [],
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
            regionCapacity: regionCapacity,
            descriptor: descriptor,
            damageBounds: damageBounds ?? descriptor.bounds
        )
        self.nextReservationRawValue = nextReservationRawValue
        reservationIdentityExhausted = false
        injectedSubmitResults = submitResults
        injectedFinishResults = finishResults
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
        guard
            expectedDescriptor.realization != .tiled
                || (handoff == .synchronous
                    && submissionLifetime != .ownershipTransfer)
        else {
            lastError = .invariantViolation
            return .failure(.invariantViolation)
        }

        let id = DisplayReservationID(rawValue: nextReservationRawValue)
        if nextReservationRawValue == .max {
            reservationIdentityExhausted = true
        } else {
            nextReservationRawValue += 1
        }
        activeReservation = id
        payloadSlotReusable = true
        presentationResponsibilityAccepted = false
        isDraining = false
        healthFailureRecordedForFrame = false
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
        guard !isDraining else { return nil }
        guard reservation == activeReservation,
            !writerBorrowActive,
            !writer.isFinished,
            payloadSlotReusable
        else {
            lastError =
                reservation == activeReservation
                ? .reentrancyViolation : .invalidReservation
            return nil
        }
        writerBorrowActive = true
        defer { writerBorrowActive = false }
        return body(&writer)
    }

    mutating func submitPayload(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        guard reservation == activeReservation else {
            lastError = .invalidReservation
            return .failureBeforeAcceptance(.invalidReservation)
        }
        guard !isDraining else {
            return .failureAfterAcceptance(lastError ?? .invariantViolation)
        }
        guard writer.isFinished, writer.lastError == nil else {
            lastError = .invariantViolation
            return .failureBeforeAcceptance(.invariantViolation)
        }

        let plannedResult =
            injectedSubmitResults.isEmpty
            ? .completed : injectedSubmitResults.removeFirst()

        switch plannedResult {
        case .completed:
            acceptCurrentPayload(for: reservation)
            lastError = nil
            return .completed
        case .failureBeforeAcceptance(let error):
            if presentationResponsibilityAccepted {
                writer.discard()
                payloadSlotReusable = false
                isDraining = true
                recordHealthFailure(.invariantViolation)
                if lastError == nil { lastError = .invariantViolation }
                return .failureAfterAcceptance(.invariantViolation)
            }
            if lastError == nil { lastError = error }
            return .failureBeforeAcceptance(error)
        case .failureAfterAcceptance(let error):
            acceptCurrentPayload(for: reservation)
            payloadSlotReusable = false
            isDraining = true
            recordHealthFailure(error)
            if lastError == nil { lastError = error }
            return .failureAfterAcceptance(error)
        }
    }

    private mutating func acceptCurrentPayload(
        for reservation: DisplayReservationID
    ) {
        let bytes = Array(writer.stagedBytes.prefix(Int(writer.writtenBytes)))
        let retainsPayload =
            handoff != .synchronous
            || submissionLifetime == .ownershipTransfer
        var retainedPayloadCount = inFlightPayloadCount
        var retainedPayloadBytes = inFlightBytes
        if retainsPayload {
            let payloadCount = inFlightPayloadCount.addingReportingOverflow(1)
            let payloadBytes = inFlightBytes.addingReportingOverflow(
                UInt32(bytes.count)
            )
            precondition(
                !payloadCount.overflow
                    && !payloadBytes.overflow
                    && payloadCount.partialValue <= maximumInFlightPayloads
                    && payloadBytes.partialValue <= maximumInFlightBytes,
                "reservation admitted a payload that exceeds declared in-flight bounds"
            )
            retainedPayloadCount = payloadCount.partialValue
            retainedPayloadBytes = payloadBytes.partialValue
        }

        submittedPayloads.append(
            RecordedDisplayPayload(
                reservation: reservation,
                bytes: bytes,
                regions: writer.regions
            )
        )
        transferResponsibilityIfNeeded()

        if !retainsPayload {
            writer.discard()
            payloadSlotReusable = true
        } else {
            inFlightPayloadCount = retainedPayloadCount
            inFlightBytes = retainedPayloadBytes
            payloadSlotReusable = false
            writer.discard()
        }
    }

    mutating func finishFrame(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        guard reservation == activeReservation else {
            lastError = .invalidReservation
            return .failureBeforeAcceptance(.invalidReservation)
        }
        guard
            isDraining
                || (!writerBorrowActive
                    && !writer.isFinished
                    && !writer.hasActiveRegion
                    && writer.writtenBytes == 0
                    && writer.writtenRegionCount == 0)
        else {
            lastError = .invariantViolation
            return .failureBeforeAcceptance(.invariantViolation)
        }
        let plannedResult =
            injectedFinishResults.isEmpty
            ? .completed : injectedFinishResults.removeFirst()
        finishedReservations.append(reservation)
        switch plannedResult {
        case .completed:
            resetSession()
            lastError = nil
            return .completed
        case .failureBeforeAcceptance(let error):
            if presentationResponsibilityAccepted {
                recordHealthFailure(.invariantViolation)
                resetSession()
                if lastError == nil { lastError = .invariantViolation }
                return .failureAfterAcceptance(.invariantViolation)
            }
            resetSession()
            if lastError == nil { lastError = error }
            return .failureBeforeAcceptance(error)
        case .failureAfterAcceptance(let error):
            transferResponsibilityIfNeeded()
            recordHealthFailure(error)
            resetSession()
            if lastError == nil { lastError = error }
            return .failureAfterAcceptance(error)
        }
    }

    mutating func cancelFrame(_ reservation: DisplayReservationID) {
        guard reservation == activeReservation else {
            lastError = .invalidReservation
            return
        }
        guard !presentationResponsibilityAccepted else {
            if lastError == nil { lastError = .invariantViolation }
            return
        }
        cancelledReservations.append(reservation)
        resetSession()
        lastError = nil
    }

    borrowing func health() -> GiftUIOperationalHealth {
        currentHealth
    }

    private mutating func resetSession() {
        activeReservation = nil
        payloadSlotReusable = true
        inFlightPayloadCount = 0
        inFlightBytes = 0
        writer.discard()
        presentationResponsibilityAccepted = false
        isDraining = false
        healthFailureRecordedForFrame = false
    }

    private mutating func transferResponsibilityIfNeeded() {
        guard !presentationResponsibilityAccepted else { return }
        presentationResponsibilityAccepted = true
        responsibilityTransferCount += 1
    }

    private mutating func recordHealthFailure(_ error: DisplayTargetError) {
        guard !healthFailureRecordedForFrame else { return }
        healthFailureRecordedForFrame = true
        let isTransport = error == .transportUnavailable
        currentHealth.recordFailure(
            GiftUIFailureFact(
                condition: isTransport ? .requiredFacilityUnavailable : .invariantViolation,
                origin: isTransport ? .presentationIntegration : .backend,
                affectedScope: isTransport ? .component : .runtime,
                containment: isTransport ? .contained : .safetyNotProven
            ),
            resultingState: isTransport ? .unavailable : .quiesced
        )
    }
}
