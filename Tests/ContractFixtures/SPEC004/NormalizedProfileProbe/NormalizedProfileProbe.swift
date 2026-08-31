import GiftUICapabilities

public enum NormalizedProfileProbe {
    public static func checksum() -> UInt32 {
        // corpus-row: configuration-macos-dynamic|configuration|640,480,1,2|available,31,640,480,640,480,2560,1,2,1,1,1,1228800,1228800,1,1228800
        // corpus-code: 1
        guard availableCode(
            resolution(
                width: 640, height: 480, kind: .fullSurface,
                encoding: .rgba8888, regionHeight: 480,
                maximumBytes: 1_228_800
            ),
            expectedExtent: (640, 480), expectedRegionHeight: 480,
            expectedRowBytes: 2_560, expectedBytes: 1_228_800,
            expectedKind: .fullSurface, expectedEncoding: .rgba8888
        ) == 1,
        // corpus-row: configuration-macos-static|configuration|640,480,1,2|available,31,640,480,640,480,2560,1,2,1,1,1,1228800,1228800,1,1228800
        // corpus-code: 1
        availableCode(
            resolution(
                width: 640, height: 480, kind: .fullSurface,
                encoding: .rgba8888, regionHeight: 480,
                maximumBytes: 1_228_800
            ),
            expectedExtent: (640, 480), expectedRegionHeight: 480,
            expectedRowBytes: 2_560, expectedBytes: 1_228_800,
            expectedKind: .fullSurface, expectedEncoding: .rgba8888
        ) == 1,
        // corpus-row: configuration-pi-screen|configuration|240,240,2,1|available,31,240,240,240,16,480,1,1,1,1,2,7680,7680,1,7680
        // corpus-code: 2
        availableCode(
            resolution(
                width: 240, height: 240, kind: .tiled,
                encoding: .rgb565BigEndian, regionHeight: 16,
                maximumBytes: 7_680
            ),
            expectedExtent: (240, 240), expectedRegionHeight: 16,
            expectedRowBytes: 480, expectedBytes: 7_680,
            expectedKind: .tiled, expectedEncoding: .rgb565BigEndian
        ) == 2,
        // corpus-row: configuration-nrf52840-tft|configuration|480,320,2,1|available,31,480,320,480,4,960,1,1,1,1,2,3840,3840,1,3840
        // corpus-code: 3
        availableCode(
            resolution(
                width: 480, height: 320, kind: .tiled,
                encoding: .rgb565BigEndian, regionHeight: 4,
                maximumBytes: 3_840
            ),
            expectedExtent: (480, 320), expectedRegionHeight: 4,
            expectedRowBytes: 960, expectedBytes: 3_840,
            expectedKind: .tiled, expectedEncoding: .rgb565BigEndian
        ) == 3,
        // corpus-row: configuration-nrf52840-full-rgba-negative|configuration|480,320,1,2,3840|unavailable,insufficient-capacity,2,614400,3840
        // corpus-code: 5
        unavailableCode(resolution(
            width: 480, height: 320, kind: .fullSurface,
            encoding: .rgba8888, regionHeight: 320,
            maximumBytes: 3_840
        )) == 5 else {
            return 0
        }
        return 12
    }

    private static func unavailableCode(
        _ resolution: RasterPresentationResolution
    ) -> UInt32 {
        guard resolution == .unavailable(.insufficientCapacity(
            domain: .raster,
            required: .init(rawValue: 614_400),
            available: .init(rawValue: 3_840)
        )) else {
            return 0
        }
        return 5
    }

    private static func availableCode(
        _ resolution: RasterPresentationResolution,
        expectedExtent: (UInt16, UInt16),
        expectedRegionHeight: UInt16,
        expectedRowBytes: UInt32,
        expectedBytes: UInt32,
        expectedKind: RasterRealizationKind,
        expectedEncoding: CanonicalPixelEncoding
    ) -> UInt32 {
        guard case let .available(value) = resolution,
              value.operations.rawValue == 31,
              value.extent.width == expectedExtent.0,
              value.extent.height == expectedExtent.1,
              value.regionExtent.width == expectedExtent.0,
              value.regionExtent.height == expectedRegionHeight,
              value.rowBytes.rawValue == expectedRowBytes,
              value.operationStream == .synchronousBorrowedOneShot,
              value.encoding == expectedEncoding,
              value.submissionLifetime == .synchronousBorrow,
              value.handoff == .synchronous,
              value.realization == expectedKind,
              value.requiredRasterBytes.rawValue == expectedBytes,
              value.requiredPayloadBytes.rawValue == expectedBytes,
              value.inFlightCount == 1,
              value.requiredInFlightBytes.rawValue == expectedBytes else {
            return 0
        }
        if expectedExtent.0 == 640 { return 1 }
        if expectedExtent.0 == 240 { return 2 }
        return 3
    }

    private static func resolution(
        width: UInt16,
        height: UInt16,
        kind: RasterRealizationKind,
        encoding: CanonicalPixelEncoding,
        regionHeight: UInt16,
        maximumBytes: UInt32
    ) -> RasterPresentationResolution {
        let operations = RasterOperationSet(rawValue: 31)
        let encodings: CanonicalPixelEncodingSet = encoding == .rgb565BigEndian
            ? .rgb565BigEndian
            : .rgba8888
        let realizations: RasterRealizationKindSet = kind == .fullSurface
            ? .fullSurface
            : .tiled
        guard let extent = CapabilityExtent(width: width, height: height),
              let requirement = RasterPresentationRequirement(
                  operations: operations,
                  extent: extent,
                  operationStream: .synchronousBorrowedOneShot,
                  acceptedEncodings: encodings,
                  acceptedSubmissionLifetimes: .synchronousBorrow,
                  maximumRasterBytes: .init(rawValue: maximumBytes),
                  maximumPayloadBytes: .init(rawValue: maximumBytes),
                  maximumInFlightBytes: .init(rawValue: maximumBytes),
                  absence: .required
              ),
              let producer = RenderProducerContribution(
                  operations: operations,
                  operationStream: .synchronousBorrowedOneShot
              ),
              let realization = RasterRealizationContribution(
                  kind: kind,
                  operations: operations,
                  operationStream: .synchronousBorrowedOneShot,
                  encodings: encodings,
                  producedSubmissionLifetimes: .synchronousBorrow,
                  maximumExtent: extent,
                  maximumRegionWidth: width,
                  maximumRegionHeight: regionHeight,
                  rowByteAlignment: 2,
                  maximumRasterBytes: .init(rawValue: maximumBytes),
                  maximumPayloadBytes: .init(rawValue: maximumBytes)
              ),
              let backend = RasterBackendContribution(
                  primary: realization,
                  alternate: nil
              ),
              let surface = SurfaceDisplayContribution(
                  extent: extent,
                  encodings: encodings,
                  acceptedSubmissionLifetimes: .synchronousBorrow,
                  handoffs: .synchronous,
                  maximumRegionWidth: width,
                  maximumRegionHeight: regionHeight,
                  rowByteAlignment: 2,
                  maximumInFlightCount: 1,
                  maximumInFlightBytes: .init(rawValue: maximumBytes)
              ),
              let policy = RasterPresentationPolicy(
                  maximumRasterBytes: .init(rawValue: maximumBytes),
                  maximumPayloadBytes: .init(rawValue: maximumBytes),
                  maximumInFlightBytes: .init(rawValue: maximumBytes),
                  allowedRealizations: realizations,
                  allowedEncodings: encodings,
                  preferredRealization: kind,
                  preferredEncoding: encodings
              ) else {
            return .unavailable(.policyHasNoConformingRealization)
        }
        var contributions = RasterPresentationContributions()
        guard contributions.insert(.renderProducer(producer)) == .inserted,
              contributions.insert(.rasterBackend(backend)) == .inserted,
              contributions.insert(.surfaceDisplay(surface)) == .inserted,
              contributions.insert(.hostResourcePolicy(policy)) == .inserted,
              var workspace = RasterPresentationResolverWorkspace() else {
            return .unavailable(.policyHasNoConformingRealization)
        }
        return RasterPresentationResolver.resolve(
            requirement: requirement,
            contributions: contributions,
            workspace: &workspace
        )
    }
}
