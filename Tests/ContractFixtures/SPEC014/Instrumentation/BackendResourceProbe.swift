package struct BackendResourceSnapshot: Equatable, Sendable {
    package private(set) var surfaceBytes: UInt32 = 0
    package private(set) var tileBytes: UInt32 = 0
    package private(set) var glyphWorkspaceBytes: UInt32 = 0
    package private(set) var strokeWorkspaceBytes: UInt32 = 0
    package private(set) var regionRecordBytes: UInt32 = 0
    package private(set) var payloadBytes: UInt32 = 0
    package private(set) var inFlightBytes: UInt32 = 0
    package private(set) var displayTransportBytes: UInt32 = 0
    package private(set) var tileVisits: UInt32 = 0
    package private(set) var submittedRegions: UInt32 = 0
    package private(set) var submittedPayloads: UInt32 = 0
    package private(set) var stackHighWaterBytes: UInt32 = 0
    package private(set) var heapCalls: UInt32 = 0
    package private(set) var rasterNanoseconds: UInt64 = 0
    package private(set) var submitNanoseconds: UInt64 = 0
    package private(set) var countersSaturated = false

    package mutating func observeStorage(
        surface: UInt32,
        tile: UInt32,
        glyph: UInt32,
        stroke: UInt32,
        regionRecords: UInt32,
        payload: UInt32,
        inFlight: UInt32,
        displayTransport: UInt32,
        stack: UInt32
    ) {
        surfaceBytes = max(surfaceBytes, surface)
        tileBytes = max(tileBytes, tile)
        glyphWorkspaceBytes = max(glyphWorkspaceBytes, glyph)
        strokeWorkspaceBytes = max(strokeWorkspaceBytes, stroke)
        regionRecordBytes = max(regionRecordBytes, regionRecords)
        payloadBytes = max(payloadBytes, payload)
        inFlightBytes = max(inFlightBytes, inFlight)
        displayTransportBytes = max(displayTransportBytes, displayTransport)
        stackHighWaterBytes = max(stackHighWaterBytes, stack)
    }

    package mutating func recordWork(
        tiles: UInt32,
        regions: UInt32,
        payloads: UInt32
    ) {
        tileVisits = adding(tileVisits, tiles)
        submittedRegions = adding(submittedRegions, regions)
        submittedPayloads = adding(submittedPayloads, payloads)
    }

    package mutating func recordHeapCalls(_ count: UInt32) {
        heapCalls = adding(heapCalls, count)
    }

    package mutating func recordTiming(
        raster: UInt64,
        submit: UInt64
    ) {
        rasterNanoseconds = raster
        submitNanoseconds = submit
    }

    private mutating func adding(_ current: UInt32, _ increment: UInt32) -> UInt32 {
        let result = current.addingReportingOverflow(increment)
        if result.overflow { countersSaturated = true }
        return result.overflow ? .max : result.partialValue
    }
}
