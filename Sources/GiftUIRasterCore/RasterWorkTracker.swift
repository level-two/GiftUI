package struct RasterWorkHighWater: Equatable, Sendable {
    package fileprivate(set) var rasterBytes: UInt32 = 0
    package fileprivate(set) var payloadBytes: UInt32 = 0
    package fileprivate(set) var payloads: UInt32 = 0
    package fileprivate(set) var regionSubmissions: UInt32 = 0
    package fileprivate(set) var tileVisits: UInt32 = 0
    package fileprivate(set) var pixelVisits: UInt32 = 0
    package fileprivate(set) var glyphBytes: UInt32 = 0
    package fileprivate(set) var strokeWorkspaceBytes: UInt32 = 0
}

package struct RasterWorkTracker {
    package let limits: RasterPayloadLimits
    package private(set) var highWater = RasterWorkHighWater()
    package private(set) var failure: RasterBackendError?
    package private(set) var presentationResponsibilityAccepted = false
    package private(set) var isDraining = false

    package init(limits: RasterPayloadLimits) {
        self.limits = limits
    }

    package mutating func observeRasterBytes(_ bytes: UInt32) -> Bool {
        highWater.rasterBytes = max(highWater.rasterBytes, bytes)
        guard limits.admitsRasterBytes(bytes) else {
            return fault(.capacityExhausted)
        }
        return canContinue
    }

    package mutating func observeGlyphBytes(_ bytes: UInt32) -> Bool {
        highWater.glyphBytes = max(highWater.glyphBytes, bytes)
        guard limits.admitsGlyphRasterBytes(bytes) else {
            return fault(.capacityExhausted)
        }
        return canContinue
    }

    package mutating func observeStrokeWorkspaceBytes(_ bytes: UInt32) -> Bool {
        highWater.strokeWorkspaceBytes = max(
            highWater.strokeWorkspaceBytes,
            bytes
        )
        guard limits.admitsStrokeWorkspaceBytes(bytes) else {
            return fault(.capacityExhausted)
        }
        return canContinue
    }

    package mutating func recordTileVisits(_ count: UInt32 = 1) -> Bool {
        guard let total = checkedAdd(highWater.tileVisits, count) else {
            return fault(.arithmeticOverflow)
        }
        highWater.tileVisits = total
        guard limits.admitsTileVisits(total) else {
            return fault(.capacityExhausted)
        }
        return canContinue
    }

    package mutating func recordPixelVisits(_ count: UInt32 = 1) -> Bool {
        guard let total = checkedAdd(highWater.pixelVisits, count) else {
            return fault(.arithmeticOverflow)
        }
        highWater.pixelVisits = total
        guard limits.admitsRegionSubmissions(total) else {
            return fault(.capacityExhausted)
        }
        return canContinue
    }

    package mutating func recordPayload(
        bytes: UInt32,
        regions: UInt16
    ) -> Bool {
        guard bytes > 0, regions > 0 else {
            return fault(.malformedStream)
        }
        highWater.payloadBytes = max(highWater.payloadBytes, bytes)
        guard limits.admitsPayloadBytes(bytes),
            limits.admitsRegionsPerPayload(regions)
        else {
            return fault(.capacityExhausted)
        }
        guard let payloads = checkedAdd(highWater.payloads, 1),
            let submittedRegions = checkedAdd(
                highWater.regionSubmissions,
                UInt32(regions)
            )
        else {
            return fault(.arithmeticOverflow)
        }
        highWater.payloads = payloads
        highWater.regionSubmissions = submittedRegions
        guard limits.admitsRegionSubmissions(payloads),
            limits.admitsRegionSubmissions(submittedRegions)
        else {
            return fault(.capacityExhausted)
        }
        return canContinue
    }

    package mutating func acceptPresentationResponsibility() {
        presentationResponsibilityAccepted = true
        if failure != nil { isDraining = true }
    }

    package mutating func recordFailure(_ error: RasterBackendError) -> Bool {
        fault(error)
    }

    package mutating func reset() {
        highWater = RasterWorkHighWater()
        failure = nil
        presentationResponsibilityAccepted = false
        isDraining = false
    }

    private var canContinue: Bool {
        failure == nil || presentationResponsibilityAccepted
    }

    private mutating func fault(_ error: RasterBackendError) -> Bool {
        if failure == nil { failure = error }
        if presentationResponsibilityAccepted { isDraining = true }
        return presentationResponsibilityAccepted
    }

    private func checkedAdd(_ lhs: UInt32, _ rhs: UInt32) -> UInt32? {
        let result = lhs.addingReportingOverflow(rhs)
        return result.overflow ? nil : result.partialValue
    }
}
