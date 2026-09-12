package struct RasterPayloadLimits: Equatable, Sendable {
    package let maximumRasterBytes: UInt32
    package let maximumPayloadBytes: UInt32
    package let maximumRegionsPerPayload: UInt16
    package let maximumRegionSubmissionsPerFrame: UInt32
    package let maximumTileVisitsPerFrame: UInt32
    package let maximumInFlightPayloads: UInt8
    package let maximumGlyphRasterBytes: UInt32
    package let maximumStrokeWorkspaceBytes: UInt32

    package init?(
        maximumRasterBytes: UInt32,
        maximumPayloadBytes: UInt32,
        maximumRegionsPerPayload: UInt16,
        maximumRegionSubmissionsPerFrame: UInt32,
        maximumTileVisitsPerFrame: UInt32,
        maximumInFlightPayloads: UInt8,
        maximumGlyphRasterBytes: UInt32,
        maximumStrokeWorkspaceBytes: UInt32
    ) {
        guard maximumRasterBytes > 0,
            maximumPayloadBytes > 0,
            maximumRegionsPerPayload > 0,
            maximumRegionSubmissionsPerFrame > 0,
            maximumTileVisitsPerFrame > 0,
            maximumInFlightPayloads > 0,
            maximumGlyphRasterBytes > 0,
            maximumStrokeWorkspaceBytes > 0,
            !maximumPayloadBytes.multipliedReportingOverflow(
                by: UInt32(maximumInFlightPayloads)
            ).overflow
        else {
            return nil
        }

        self.maximumRasterBytes = maximumRasterBytes
        self.maximumPayloadBytes = maximumPayloadBytes
        self.maximumRegionsPerPayload = maximumRegionsPerPayload
        self.maximumRegionSubmissionsPerFrame = maximumRegionSubmissionsPerFrame
        self.maximumTileVisitsPerFrame = maximumTileVisitsPerFrame
        self.maximumInFlightPayloads = maximumInFlightPayloads
        self.maximumGlyphRasterBytes = maximumGlyphRasterBytes
        self.maximumStrokeWorkspaceBytes = maximumStrokeWorkspaceBytes
    }

    package var maximumInFlightBytes: UInt32 {
        maximumPayloadBytes * UInt32(maximumInFlightPayloads)
    }

    package func admitsRasterBytes(_ bytes: UInt32) -> Bool {
        bytes <= maximumRasterBytes
    }

    package func admitsPayloadBytes(_ bytes: UInt32) -> Bool {
        bytes <= maximumPayloadBytes
    }

    package func admitsRegionsPerPayload(_ regions: UInt16) -> Bool {
        regions <= maximumRegionsPerPayload
    }

    package func admitsRegionSubmissions(_ submissions: UInt32) -> Bool {
        submissions <= maximumRegionSubmissionsPerFrame
    }

    package func admitsTileVisits(_ visits: UInt32) -> Bool {
        visits <= maximumTileVisitsPerFrame
    }

    package func admitsInFlight(payloads: UInt8, bytes: UInt32) -> Bool {
        payloads <= maximumInFlightPayloads && bytes <= maximumInFlightBytes
    }

    package func admitsGlyphRasterBytes(_ bytes: UInt32) -> Bool {
        bytes <= maximumGlyphRasterBytes
    }

    package func admitsStrokeWorkspaceBytes(_ bytes: UInt32) -> Bool {
        bytes <= maximumStrokeWorkspaceBytes
    }
}

package enum RasterBackendError: UInt8, Equatable, Sendable {
    case invalidEnvelope = 0
    case unsupportedOperation = 1
    case incompatibleResource = 2
    case invalidGeometry = 3
    case arithmeticOverflow = 4
    case capacityExhausted = 5
    case malformedStream = 6
    case rasterizationFailure = 7
    case displayFailure = 8
    case reentrancyViolation = 9
    case invariantViolation = 10
}
