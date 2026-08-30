private let allOperations: RasterOperationSet = [
    .opaqueRectangles, .positionedText, .straightLineStrokes, .clipping, .damage,
]

private func evaluate(
    width: UInt16,
    height: UInt16,
    kind: RasterRealizationKind,
    encoding: CanonicalPixelEncoding,
    realizationExtentHeight: UInt16? = nil,
    surfaceExtentHeight: UInt16? = nil,
    realizationRegionWidth: UInt16? = nil,
    surfaceRegionWidth: UInt16? = nil,
    realizationRegionHeight: UInt16,
    surfaceRegionHeight: UInt16,
    realizationAlignment: UInt16,
    surfaceAlignment: UInt16,
    ceiling: UInt32 = 1_000_000,
    rasterCeilings: (UInt32, UInt32, UInt32)? = nil,
    payloadCeilings: (UInt32, UInt32, UInt32)? = nil,
    inFlightCeilings: (UInt32, UInt32, UInt32)? = nil
) -> RasterPresentationArithmeticOutcome {
    let encodingSet: CanonicalPixelEncodingSet = encoding == .rgb565BigEndian
        ? .rgb565BigEndian
        : .rgba8888
    let raster = rasterCeilings ?? (ceiling, ceiling, ceiling)
    let payload = payloadCeilings ?? (ceiling, ceiling, ceiling)
    let inFlight = inFlightCeilings ?? (ceiling, ceiling, ceiling)
    guard let extent = CapabilityExtent(width: width, height: height),
          let realizationExtent = CapabilityExtent(
              width: width, height: realizationExtentHeight ?? height
          ),
          let surfaceExtent = CapabilityExtent(
              width: width, height: surfaceExtentHeight ?? height
          ),
          let requirement = RasterPresentationRequirement(
              operations: allOperations,
              extent: extent,
              operationStream: .synchronousBorrowedOneShot,
              acceptedEncodings: encodingSet,
              acceptedSubmissionLifetimes: .synchronousBorrow,
              maximumRasterBytes: .init(rawValue: raster.0),
              maximumPayloadBytes: .init(rawValue: payload.0),
              maximumInFlightBytes: .init(rawValue: inFlight.0),
              absence: .required
          ),
          let realization = RasterRealizationContribution(
              kind: kind,
              operations: allOperations,
              operationStream: .synchronousBorrowedOneShot,
              encodings: encodingSet,
              producedSubmissionLifetimes: .synchronousBorrow,
              maximumExtent: realizationExtent,
              maximumRegionWidth: realizationRegionWidth ?? width,
              maximumRegionHeight: realizationRegionHeight,
              rowByteAlignment: realizationAlignment,
              maximumRasterBytes: .init(rawValue: raster.1),
              maximumPayloadBytes: .init(rawValue: payload.1)
          ),
          let surface = SurfaceDisplayContribution(
              extent: surfaceExtent,
              encodings: encodingSet,
              acceptedSubmissionLifetimes: .synchronousBorrow,
              handoffs: .synchronous,
              maximumRegionWidth: surfaceRegionWidth ?? width,
              maximumRegionHeight: surfaceRegionHeight,
              rowByteAlignment: surfaceAlignment,
              maximumInFlightCount: 1,
              maximumInFlightBytes: .init(rawValue: inFlight.1)
          ),
          let policy = RasterPresentationPolicy(
              maximumRasterBytes: .init(rawValue: raster.2),
              maximumPayloadBytes: .init(rawValue: payload.2),
              maximumInFlightBytes: .init(rawValue: inFlight.2),
              allowedRealizations: kind == .fullSurface ? .fullSurface : .tiled,
              allowedEncodings: encodingSet,
              preferredRealization: kind,
              preferredEncoding: encodingSet
          ) else {
        fatalError("invalid checked-in arithmetic fixture")
    }
    return RasterPresentationArithmetic.evaluate(
        requirement: requirement,
        realization: realization,
        surface: surface,
        policy: policy,
        encoding: encoding
    )
}

private func require(
    _ id: StaticString,
    _ actual: RasterPresentationArithmeticOutcome,
    _ expected: RasterPresentationArithmeticOutcome,
    input: StaticString,
    result: StaticString
) {
    guard actual == expected else { fatalError("semantic mismatch for \(id)") }
    print("\(id)\tarithmetic\t\(input)\t\(result)")
}

private func value(
    alignment: UInt32,
    width: UInt16,
    height: UInt16,
    rowBytes: UInt32,
    usage: UInt32
) -> RasterPresentationArithmeticOutcome {
    guard let region = CapabilityExtent(width: width, height: height) else {
        fatalError("invalid checked-in region")
    }
    return .available(RasterPresentationArithmeticValue(
        effectiveRowAlignment: alignment,
        regionExtent: region,
        rowBytes: .init(rawValue: rowBytes),
        requiredRasterBytes: .init(rawValue: usage),
        requiredPayloadBytes: .init(rawValue: usage),
        requiredInFlightBytes: .init(rawValue: usage)
    ))
}

private func requireCapacityOwner(
    _ id: StaticString,
    domain: RasterPresentationCapacity,
    equality: (UInt32, UInt32, UInt32),
    firstExcess: (UInt32, UInt32, UInt32),
    input: StaticString,
    result: StaticString
) {
    let equalityOutcome: RasterPresentationArithmeticOutcome
    let firstExcessOutcome: RasterPresentationArithmeticOutcome
    switch domain {
    case .raster:
        equalityOutcome = evaluate(
            width: 4, height: 2, kind: .fullSurface, encoding: .rgb565BigEndian,
            realizationRegionHeight: 2, surfaceRegionHeight: 2,
            realizationAlignment: 1, surfaceAlignment: 1,
            rasterCeilings: equality
        )
        firstExcessOutcome = evaluate(
            width: 4, height: 2, kind: .fullSurface, encoding: .rgb565BigEndian,
            realizationRegionHeight: 2, surfaceRegionHeight: 2,
            realizationAlignment: 1, surfaceAlignment: 1,
            rasterCeilings: firstExcess
        )
    case .payload:
        equalityOutcome = evaluate(
            width: 4, height: 2, kind: .fullSurface, encoding: .rgb565BigEndian,
            realizationRegionHeight: 2, surfaceRegionHeight: 2,
            realizationAlignment: 1, surfaceAlignment: 1,
            payloadCeilings: equality
        )
        firstExcessOutcome = evaluate(
            width: 4, height: 2, kind: .fullSurface, encoding: .rgb565BigEndian,
            realizationRegionHeight: 2, surfaceRegionHeight: 2,
            realizationAlignment: 1, surfaceAlignment: 1,
            payloadCeilings: firstExcess
        )
    case .inFlight:
        equalityOutcome = evaluate(
            width: 4, height: 2, kind: .fullSurface, encoding: .rgb565BigEndian,
            realizationRegionHeight: 2, surfaceRegionHeight: 2,
            realizationAlignment: 1, surfaceAlignment: 1,
            inFlightCeilings: equality
        )
        firstExcessOutcome = evaluate(
            width: 4, height: 2, kind: .fullSurface, encoding: .rgb565BigEndian,
            realizationRegionHeight: 2, surfaceRegionHeight: 2,
            realizationAlignment: 1, surfaceAlignment: 1,
            inFlightCeilings: firstExcess
        )
    case .resolverWorkspace:
        fatalError("workspace is not a byte arithmetic domain")
    }
    let expectedAvailable = value(
        alignment: 1, width: 4, height: 2, rowBytes: 8, usage: 16
    )
    let expectedFailure = RasterPresentationArithmeticOutcome.unavailable(
        .insufficientCapacity(
            domain: domain,
            required: .init(rawValue: 16),
            available: .init(rawValue: 15)
        )
    )
    guard equalityOutcome == expectedAvailable,
          firstExcessOutcome == expectedFailure else {
        fatalError("capacity-owner mismatch for \(id)")
    }
    print("\(id)\tarithmetic\t\(input)\t\(result)")
}

require(
    "arithmetic-rgb565-tiled-unequal-alignment",
    evaluate(
        width: 5, height: 9, kind: .tiled, encoding: .rgb565BigEndian,
        realizationRegionHeight: 3, surfaceRegionHeight: 4,
        realizationAlignment: 6, surfaceAlignment: 8
    ),
    value(alignment: 24, width: 5, height: 3, rowBytes: 24, usage: 72),
    input: "5,9,2,1,3,4,6,8",
    result: "available,24,5,3,24,72,72,72"
)
require(
    "arithmetic-rgba8888-full-surface",
    evaluate(
        width: 5, height: 7, kind: .fullSurface, encoding: .rgba8888,
        realizationRegionHeight: 7, surfaceRegionHeight: 7,
        realizationAlignment: 4, surfaceAlignment: 8
    ),
    value(alignment: 8, width: 5, height: 7, rowBytes: 24, usage: 168),
    input: "5,7,1,2,7,7,4,8",
    result: "available,8,5,7,24,168,168,168"
)
require(
    "arithmetic-nrf52840-exact-tile",
    evaluate(
        width: 480, height: 320, kind: .tiled, encoding: .rgb565BigEndian,
        realizationRegionHeight: 4, surfaceRegionHeight: 320,
        realizationAlignment: 2, surfaceAlignment: 2, ceiling: 3_840
    ),
    value(alignment: 2, width: 480, height: 4, rowBytes: 960, usage: 3_840),
    input: "480,320,2,1,4,320,2,2",
    result: "available,2,480,4,960,3840,3840,3840"
)
require(
    "arithmetic-tiled-logical-height-minimum",
    evaluate(
        width: 5, height: 2, kind: .tiled, encoding: .rgb565BigEndian,
        realizationExtentHeight: 4, surfaceExtentHeight: 4,
        realizationRegionHeight: 3, surfaceRegionHeight: 4,
        realizationAlignment: 1, surfaceAlignment: 1
    ),
    value(alignment: 1, width: 5, height: 2, rowBytes: 10, usage: 20),
    input: "5,2,2,1,3,4,1,1",
    result: "available,1,5,2,10,20,20,20"
)
require(
    "arithmetic-tiled-surface-height-minimum",
    evaluate(
        width: 5, height: 9, kind: .tiled, encoding: .rgb565BigEndian,
        realizationRegionHeight: 4, surfaceRegionHeight: 3,
        realizationAlignment: 1, surfaceAlignment: 1
    ),
    value(alignment: 1, width: 5, height: 3, rowBytes: 10, usage: 30),
    input: "5,9,2,1,4,3,1,1",
    result: "available,1,5,3,10,30,30,30"
)
require(
    "arithmetic-candidate-width-rejection",
    evaluate(
        width: 5, height: 2, kind: .fullSurface, encoding: .rgb565BigEndian,
        realizationRegionWidth: 4,
        realizationRegionHeight: 2, surfaceRegionHeight: 2,
        realizationAlignment: 1, surfaceAlignment: 1
    ),
    .unavailable(.unsupportedLogicalExtent),
    input: "5,2,1,1,4,5,2,2",
    result: "unavailable,unsupported-logical-extent"
)
require(
    "arithmetic-surface-width-rejection",
    evaluate(
        width: 5, height: 2, kind: .fullSurface, encoding: .rgb565BigEndian,
        surfaceRegionWidth: 4,
        realizationRegionHeight: 2, surfaceRegionHeight: 2,
        realizationAlignment: 1, surfaceAlignment: 1
    ),
    .unavailable(.unsupportedLogicalExtent),
    input: "5,2,1,1,5,4,2,2",
    result: "unavailable,unsupported-logical-extent"
)
require(
    "arithmetic-candidate-full-height-rejection",
    evaluate(
        width: 5, height: 3, kind: .fullSurface, encoding: .rgb565BigEndian,
        realizationRegionHeight: 2, surfaceRegionHeight: 3,
        realizationAlignment: 1, surfaceAlignment: 1
    ),
    .unavailable(.unsupportedLogicalExtent),
    input: "5,3,1,1,2,3,1,1",
    result: "unavailable,unsupported-logical-extent"
)
require(
    "arithmetic-surface-full-height-rejection",
    evaluate(
        width: 5, height: 3, kind: .fullSurface, encoding: .rgb565BigEndian,
        realizationRegionHeight: 3, surfaceRegionHeight: 2,
        realizationAlignment: 1, surfaceAlignment: 1
    ),
    .unavailable(.unsupportedLogicalExtent),
    input: "5,3,1,1,3,2,1,1",
    result: "unavailable,unsupported-logical-extent"
)
require(
    "arithmetic-maximum-typed-lcm",
    evaluate(
        width: .max, height: 1, kind: .fullSurface, encoding: .rgb565BigEndian,
        realizationRegionHeight: 1, surfaceRegionHeight: 1,
        realizationAlignment: .max, surfaceAlignment: .max - 1, ceiling: .max
    ),
    value(
        alignment: 4_294_770_690, width: .max, height: 1,
        rowBytes: 4_294_770_690, usage: 4_294_770_690
    ),
    input: "65535,1,1,1,1,1,65535,65534",
    result: "available,4294770690,65535,1,4294770690,4294770690,4294770690,4294770690"
)
require(
    "arithmetic-maximum-typed-unaligned-row",
    evaluate(
        width: .max, height: 1, kind: .fullSurface, encoding: .rgba8888,
        realizationRegionHeight: 1, surfaceRegionHeight: 1,
        realizationAlignment: 1, surfaceAlignment: 1, ceiling: .max
    ),
    value(alignment: 1, width: .max, height: 1, rowBytes: 262_140, usage: 262_140),
    input: "65535,1,1,2,1,1,1,1",
    result: "available,1,65535,1,262140,262140,262140,262140"
)
require(
    "arithmetic-shared-usage-overflow",
    evaluate(
        width: .max, height: 2, kind: .fullSurface, encoding: .rgb565BigEndian,
        realizationRegionHeight: 2, surfaceRegionHeight: 2,
        realizationAlignment: .max, surfaceAlignment: .max - 1, ceiling: .max
    ),
    .unavailable(.byteCountOverflow(domain: .raster)),
    input: "65535,2,1,1,2,2,65535,65534",
    result: "unavailable,byte-count-overflow,2"
)
requireCapacityOwner(
    "arithmetic-raster-requirement-boundary", domain: .raster,
    equality: (16, 20, 20), firstExcess: (15, 20, 20),
    input: "2,1,16,15", result: "equality-available,16,first-excess,2,16,15"
)
requireCapacityOwner(
    "arithmetic-raster-candidate-boundary", domain: .raster,
    equality: (20, 16, 20), firstExcess: (20, 15, 20),
    input: "2,2,16,15", result: "equality-available,16,first-excess,2,16,15"
)
requireCapacityOwner(
    "arithmetic-raster-policy-boundary", domain: .raster,
    equality: (20, 20, 16), firstExcess: (20, 20, 15),
    input: "2,3,16,15", result: "equality-available,16,first-excess,2,16,15"
)
requireCapacityOwner(
    "arithmetic-payload-requirement-boundary", domain: .payload,
    equality: (16, 20, 20), firstExcess: (15, 20, 20),
    input: "3,1,16,15", result: "equality-available,16,first-excess,3,16,15"
)
requireCapacityOwner(
    "arithmetic-payload-candidate-boundary", domain: .payload,
    equality: (20, 16, 20), firstExcess: (20, 15, 20),
    input: "3,2,16,15", result: "equality-available,16,first-excess,3,16,15"
)
requireCapacityOwner(
    "arithmetic-payload-policy-boundary", domain: .payload,
    equality: (20, 20, 16), firstExcess: (20, 20, 15),
    input: "3,3,16,15", result: "equality-available,16,first-excess,3,16,15"
)
requireCapacityOwner(
    "arithmetic-in-flight-requirement-boundary", domain: .inFlight,
    equality: (16, 20, 20), firstExcess: (15, 20, 20),
    input: "4,1,16,15", result: "equality-available,16,first-excess,4,16,15"
)
requireCapacityOwner(
    "arithmetic-in-flight-surface-boundary", domain: .inFlight,
    equality: (20, 16, 20), firstExcess: (20, 15, 20),
    input: "4,2,16,15", result: "equality-available,16,first-excess,4,16,15"
)
requireCapacityOwner(
    "arithmetic-in-flight-policy-boundary", domain: .inFlight,
    equality: (20, 20, 16), firstExcess: (20, 20, 15),
    input: "4,3,16,15", result: "equality-available,16,first-excess,4,16,15"
)
require(
    "arithmetic-in-flight-zero-minimum",
    evaluate(
        width: 4, height: 2, kind: .fullSurface, encoding: .rgb565BigEndian,
        realizationRegionHeight: 2, surfaceRegionHeight: 2,
        realizationAlignment: 1, surfaceAlignment: 1,
        inFlightCeilings: (20, 0, 18)
    ),
    .unavailable(.insufficientCapacity(
        domain: .inFlight, required: .init(rawValue: 16), available: .init(rawValue: 0)
    )),
    input: "4,2,1,1,2,2,1,1,20,0,18",
    result: "unavailable,insufficient-capacity,4,16,0"
)
