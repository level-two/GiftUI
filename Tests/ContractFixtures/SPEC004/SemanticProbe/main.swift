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

private func resolverValues(
    producerStream: OperationStreamLifetime,
    encodings: CanonicalPixelEncodingSet = .rgb565BigEndian,
    fullRegionHeight: UInt16 = 4
) -> (RasterPresentationRequirement, [RasterPresentationContribution]) {
    guard let extent = CapabilityExtent(width: 480, height: 320),
          let requirement = RasterPresentationRequirement(
              operations: allOperations,
              extent: extent,
              operationStream: .synchronousBorrowedOneShot,
              acceptedEncodings: encodings,
              acceptedSubmissionLifetimes: .synchronousBorrow,
              maximumRasterBytes: .init(rawValue: 3_840),
              maximumPayloadBytes: .init(rawValue: 3_840),
              maximumInFlightBytes: .init(rawValue: 3_840),
              absence: .required
          ),
          let producer = RenderProducerContribution(
              operations: allOperations,
              operationStream: producerStream
          ),
          let full = RasterRealizationContribution(
              kind: .fullSurface,
              operations: allOperations,
              operationStream: .synchronousBorrowedOneShot,
              encodings: encodings,
              producedSubmissionLifetimes: .synchronousBorrow,
              maximumExtent: extent,
              maximumRegionWidth: 480,
              maximumRegionHeight: fullRegionHeight,
              rowByteAlignment: 2,
              maximumRasterBytes: .init(rawValue: 3_840),
              maximumPayloadBytes: .init(rawValue: 3_840)
          ),
          let tiled = RasterRealizationContribution(
              kind: .tiled,
              operations: allOperations,
              operationStream: .synchronousBorrowedOneShot,
              encodings: encodings,
              producedSubmissionLifetimes: .synchronousBorrow,
              maximumExtent: extent,
              maximumRegionWidth: 480,
              maximumRegionHeight: 4,
              rowByteAlignment: 2,
              maximumRasterBytes: .init(rawValue: 3_840),
              maximumPayloadBytes: .init(rawValue: 3_840)
          ),
          let backend = RasterBackendContribution(primary: full, alternate: tiled),
          let surface = SurfaceDisplayContribution(
              extent: extent,
              encodings: encodings,
              acceptedSubmissionLifetimes: .synchronousBorrow,
              handoffs: .synchronous,
              maximumRegionWidth: 480,
              maximumRegionHeight: 320,
              rowByteAlignment: 2,
              maximumInFlightCount: 1,
              maximumInFlightBytes: .init(rawValue: 3_840)
          ),
          let policy = RasterPresentationPolicy(
              maximumRasterBytes: .init(rawValue: 3_840),
              maximumPayloadBytes: .init(rawValue: 3_840),
              maximumInFlightBytes: .init(rawValue: 3_840),
              allowedRealizations: .tiled,
              allowedEncodings: encodings,
              preferredRealization: .tiled,
              preferredEncoding: .rgb565BigEndian
          ) else {
        fatalError("invalid checked-in resolver fixture")
    }
    return (requirement, [
        .renderProducer(producer),
        .rasterBackend(backend),
        .surfaceDisplay(surface),
        .hostResourcePolicy(policy),
    ])
}

private func verifyResolverPermutations(
    producerStream: OperationStreamLifetime,
    expected: RasterPresentationResolution
) {
    let (requirement, values) = resolverValues(producerStream: producerStream)
    var count = 0
    for first in 0 ..< 4 {
        for second in 0 ..< 4 where second != first {
            for third in 0 ..< 4 where third != first && third != second {
                for fourth in 0 ..< 4
                where fourth != first && fourth != second && fourth != third {
                    var contributions = RasterPresentationContributions()
                    _ = contributions.insert(values[first])
                    _ = contributions.insert(values[second])
                    _ = contributions.insert(values[third])
                    _ = contributions.insert(values[fourth])
                    var workspace = RasterPresentationResolverWorkspace()!
                    let result = RasterPresentationResolver.resolve(
                        requirement: requirement,
                        contributions: contributions,
                        workspace: &workspace
                    )
                    guard result == expected else {
                        fatalError("resolver role permutation mismatch")
                    }
                    count += 1
                }
            }
        }
    }
    guard count == 24 else { fatalError("resolver permutation count mismatch") }
}

let (positiveRequirement, _) = resolverValues(
    producerStream: .synchronousBorrowedOneShot
)
let positiveArithmetic = value(
    alignment: 2, width: 480, height: 4, rowBytes: 960, usage: 3_840
)
guard case let .available(arithmeticValue) = positiveArithmetic else {
    fatalError("invalid resolver arithmetic fixture")
}
let positiveEffective = EffectiveRasterPresentation(
    operations: allOperations,
    extent: positiveRequirement.extent,
    regionExtent: arithmeticValue.regionExtent,
    rowBytes: arithmeticValue.rowBytes,
    operationStream: .synchronousBorrowedOneShot,
    encoding: .rgb565BigEndian,
    submissionLifetime: .synchronousBorrow,
    handoff: .synchronous,
    realization: .tiled,
    requiredRasterBytes: arithmeticValue.requiredRasterBytes,
    requiredPayloadBytes: arithmeticValue.requiredPayloadBytes,
    inFlightCount: 1,
    requiredInFlightBytes: arithmeticValue.requiredInFlightBytes
)
verifyResolverPermutations(
    producerStream: .synchronousBorrowedOneShot,
    expected: .available(positiveEffective)
)
print("resolver-positive-role-permutations\tresolver\t24,1\tavailable,2,1,1,1,480,4,960,3840")
verifyResolverPermutations(
    producerStream: .incompatibleWithSynchronousBorrowedOneShot,
    expected: .unavailable(.operationStreamMismatch)
)
print("resolver-stream-mismatch-role-permutations\tresolver\t24,2\tunavailable,operation-stream-mismatch")

private func resolveBoundary(
    _ contributions: RasterPresentationContributions,
    workspaceCapacity: UInt8 = 2
) -> RasterPresentationResolution {
    let (requirement, _) = resolverValues(
        producerStream: .synchronousBorrowedOneShot
    )
    var workspace = RasterPresentationResolverWorkspace(
        usableCandidateCapacity: workspaceCapacity
    )!
    return RasterPresentationResolver.resolve(
        requirement: requirement,
        contributions: contributions,
        workspace: &workspace
    )
}

let missingBoundary = resolveBoundary(RasterPresentationContributions())
guard missingBoundary == .unavailable(
    .missingContributor(role: .renderProducer)
) else {
    fatalError("missing boundary mismatch")
}
print("negative-missing-required-role\tnegative\t0,4\tunavailable,missing,1,no-snapshot")

let (_, boundaryValues) = resolverValues(
    producerStream: .synchronousBorrowedOneShot
)
var duplicateBoundary = RasterPresentationContributions()
for value in boundaryValues {
    guard duplicateBoundary.insert(value) == .inserted else {
        fatalError("duplicate boundary setup failed")
    }
}
let firstProducer = duplicateBoundary.renderProducer
let incompatibleProducer = RenderProducerContribution(
    operations: allOperations,
    operationStream: .incompatibleWithSynchronousBorrowedOneShot
)!
guard duplicateBoundary.insert(.renderProducer(incompatibleProducer))
        == .rejected(.duplicateContributor(role: .renderProducer)),
      duplicateBoundary.renderProducer == firstProducer,
      resolveBoundary(duplicateBoundary) == .unavailable(
          .duplicateContributor(role: .renderProducer)
      ) else {
    fatalError("duplicate boundary substituted the last writer")
}
print("negative-duplicate-preserves-first\tnegative\t1,2\tunavailable,duplicate,1,first-preserved,no-snapshot")

var completeBoundary = RasterPresentationContributions()
for value in boundaryValues {
    guard completeBoundary.insert(value) == .inserted else {
        fatalError("workspace boundary setup failed")
    }
}
guard resolveBoundary(completeBoundary, workspaceCapacity: 1) == .unavailable(
    .insufficientCapacity(
        domain: .resolverWorkspace,
        required: .init(rawValue: 2),
        available: .init(rawValue: 1)
    )
) else {
    fatalError("workspace boundary mismatch")
}
print("negative-resolver-workspace\tnegative\t2,1\tunavailable,insufficient-capacity,1,2,1,no-snapshot")

private func boundarySnapshot(
    resolution: RasterPresentationResolution,
    absence: CapabilityAbsence
) -> CapabilitySnapshot? {
    switch resolution {
    case let .available(value):
        return CapabilitySnapshot(rasterPresentation: value)
    case .unavailable:
        return absence == .optional
            ? CapabilitySnapshot(rasterPresentation: nil)
            : nil
    }
}

guard boundarySnapshot(resolution: missingBoundary, absence: .optional)
        == CapabilitySnapshot(rasterPresentation: nil),
      boundarySnapshot(resolution: missingBoundary, absence: .required) == nil else {
    fatalError("absence snapshot boundary mismatch")
}
print("negative-optional-required-absence\tnegative\t2,3\toptional,nil-snapshot,required,no-snapshot")

#if GIFTUI_CAPABILITY_INSTRUMENTATION
private func instrumentedResolution(
    producerStream: OperationStreamLifetime,
    encodings: CanonicalPixelEncodingSet = .rgb565BigEndian,
    fullRegionHeight: UInt16 = 4
) -> (RasterPresentationResolution, RasterPresentationResolverOperationCounts) {
    let (requirement, values) = resolverValues(
        producerStream: producerStream,
        encodings: encodings,
        fullRegionHeight: fullRegionHeight
    )
    var contributions = RasterPresentationContributions()
    for value in values {
        guard contributions.insert(value) == .inserted else {
            fatalError("instrumentation contribution insertion failed")
        }
    }
    var workspace = RasterPresentationResolverWorkspace()!
    RasterPresentationResolverInstrumentation.reset()
    let result = RasterPresentationResolver.resolve(
        requirement: requirement,
        contributions: contributions,
        workspace: &workspace
    )
    return (result, RasterPresentationResolverInstrumentation.counts)
}

let (widestResult, widestCounts) = instrumentedResolution(
    producerStream: .synchronousBorrowedOneShot,
    encodings: CanonicalPixelEncodingSet(rawValue: 3),
    fullRegionHeight: 320
)
guard case .available = widestResult,
      widestCounts.roleVisits == 4,
      widestCounts.setIntersectionsAndComparisons == 20,
      widestCounts.checkedArithmetic == 16,
      widestCounts.candidateChecks == 2,
      widestCounts.validationResultConstructions == 1,
      widestCounts.resolverInvocations == 1,
      widestCounts.primitiveOperations == 44,
      widestCounts.primitiveOperations <= 96 else {
    fatalError("widest resolver operation bound mismatch")
}
print("instrumentation-widest-resolver-path\tinstrumentation\t2,2,96\t44,4,20,16,2,1,1")

let (earlyResult, earlyCounts) = instrumentedResolution(
    producerStream: .incompatibleWithSynchronousBorrowedOneShot
)
guard earlyResult == .unavailable(.operationStreamMismatch),
      earlyCounts.roleVisits == 4,
      earlyCounts.setIntersectionsAndComparisons == 2,
      earlyCounts.checkedArithmetic == 0,
      earlyCounts.candidateChecks == 0,
      earlyCounts.validationResultConstructions == 1,
      earlyCounts.resolverInvocations == 1,
      earlyCounts.primitiveOperations == 8,
      earlyCounts.primitiveOperations <= 96 else {
    fatalError("early resolver operation bound mismatch")
}
print("instrumentation-early-negative-path\tinstrumentation\t5,96\t8,4,2,0,0,1,1")

guard case let .available(effective) = widestResult else {
    fatalError("instrumentation snapshot fixture unavailable")
}
let snapshot = CapabilitySnapshot(rasterPresentation: effective)
RasterPresentationResolverInstrumentation.reset()
var snapshotChecksum: UInt32 = 0
for _ in 0 ..< 10_000 {
    snapshotChecksum &+= snapshot.rasterPresentation?.rowBytes.rawValue ?? 0
}
let snapshotCounts = RasterPresentationResolverInstrumentation.counts
guard snapshotChecksum != 0,
      snapshotCounts.resolverInvocations == 0,
      snapshotCounts.primitiveOperations == 0 else {
    fatalError("snapshot access unexpectedly invoked resolver")
}
print("instrumentation-repeated-snapshot-access\tinstrumentation\t10000\t0,0")
#endif

private func normalizedConfiguration(
    width: UInt16,
    height: UInt16,
    kind: RasterRealizationKind,
    encoding: CanonicalPixelEncoding,
    regionHeight: UInt16,
    maximumBytes: UInt32
) -> RasterPresentationResolution {
    let encodingSet: CanonicalPixelEncodingSet = encoding == .rgb565BigEndian
        ? .rgb565BigEndian
        : .rgba8888
    let realizationSet: RasterRealizationKindSet = kind == .fullSurface
        ? .fullSurface
        : .tiled
    guard let extent = CapabilityExtent(width: width, height: height),
          let requirement = RasterPresentationRequirement(
              operations: allOperations,
              extent: extent,
              operationStream: .synchronousBorrowedOneShot,
              acceptedEncodings: encodingSet,
              acceptedSubmissionLifetimes: .synchronousBorrow,
              maximumRasterBytes: .init(rawValue: maximumBytes),
              maximumPayloadBytes: .init(rawValue: maximumBytes),
              maximumInFlightBytes: .init(rawValue: maximumBytes),
              absence: .required
          ),
          let producer = RenderProducerContribution(
              operations: allOperations,
              operationStream: .synchronousBorrowedOneShot
          ),
          let realization = RasterRealizationContribution(
              kind: kind,
              operations: allOperations,
              operationStream: .synchronousBorrowedOneShot,
              encodings: encodingSet,
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
              encodings: encodingSet,
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
              allowedRealizations: realizationSet,
              allowedEncodings: encodingSet,
              preferredRealization: kind,
              preferredEncoding: encodingSet
          ) else {
        fatalError("invalid normalized configuration fixture")
    }
    var contributions = RasterPresentationContributions()
    guard contributions.insert(.renderProducer(producer)) == .inserted,
          contributions.insert(.rasterBackend(backend)) == .inserted,
          contributions.insert(.surfaceDisplay(surface)) == .inserted,
          contributions.insert(.hostResourcePolicy(policy)) == .inserted else {
        fatalError("normalized configuration insertion failed")
    }
    var workspace = RasterPresentationResolverWorkspace()!
    return RasterPresentationResolver.resolve(
        requirement: requirement,
        contributions: contributions,
        workspace: &workspace
    )
}

let desktopDynamic = normalizedConfiguration(
    width: 640, height: 480, kind: .fullSurface, encoding: .rgba8888,
    regionHeight: 480, maximumBytes: 1_228_800
)
let desktopStatic = normalizedConfiguration(
    width: 640, height: 480, kind: .fullSurface, encoding: .rgba8888,
    regionHeight: 480, maximumBytes: 1_228_800
)
guard desktopDynamic == desktopStatic,
      case let .available(desktopEffective) = desktopDynamic,
      desktopEffective.operations == allOperations,
      desktopEffective.extent == CapabilityExtent(width: 640, height: 480),
      desktopEffective.regionExtent == CapabilityExtent(width: 640, height: 480),
      desktopEffective.rowBytes == .init(rawValue: 2_560),
      desktopEffective.operationStream == .synchronousBorrowedOneShot,
      desktopEffective.encoding == .rgba8888,
      desktopEffective.submissionLifetime == .synchronousBorrow,
      desktopEffective.handoff == .synchronous,
      desktopEffective.realization == .fullSurface,
      desktopEffective.requiredRasterBytes == .init(rawValue: 1_228_800),
      desktopEffective.requiredPayloadBytes == .init(rawValue: 1_228_800),
      desktopEffective.inFlightCount == 1,
      desktopEffective.requiredInFlightBytes == .init(rawValue: 1_228_800) else {
    fatalError("desktop normalized configuration mismatch")
}
print("configuration-macos-dynamic\tconfiguration\t640,480,1,2\tavailable,31,640,480,640,480,2560,1,2,1,1,1,1228800,1228800,1,1228800")
print("configuration-macos-static\tconfiguration\t640,480,1,2\tavailable,31,640,480,640,480,2560,1,2,1,1,1,1228800,1228800,1,1228800")

let piConfiguration = normalizedConfiguration(
    width: 240, height: 240, kind: .tiled, encoding: .rgb565BigEndian,
    regionHeight: 16, maximumBytes: 7_680
)
guard case let .available(piEffective) = piConfiguration,
      piEffective.operations == allOperations,
      piEffective.extent == CapabilityExtent(width: 240, height: 240),
      piEffective.regionExtent == CapabilityExtent(width: 240, height: 16),
      piEffective.rowBytes == .init(rawValue: 480),
      piEffective.operationStream == .synchronousBorrowedOneShot,
      piEffective.encoding == .rgb565BigEndian,
      piEffective.submissionLifetime == .synchronousBorrow,
      piEffective.handoff == .synchronous,
      piEffective.realization == .tiled,
      piEffective.requiredRasterBytes == .init(rawValue: 7_680),
      piEffective.requiredPayloadBytes == .init(rawValue: 7_680),
      piEffective.inFlightCount == 1,
      piEffective.requiredInFlightBytes == .init(rawValue: 7_680) else {
    fatalError("Pi normalized configuration mismatch")
}
print("configuration-pi-screen\tconfiguration\t240,240,2,1\tavailable,31,240,240,240,16,480,1,1,1,1,2,7680,7680,1,7680")

let nrfConfiguration = normalizedConfiguration(
    width: 480, height: 320, kind: .tiled, encoding: .rgb565BigEndian,
    regionHeight: 4, maximumBytes: 3_840
)
guard case let .available(nrfEffective) = nrfConfiguration,
      nrfEffective.operations == allOperations,
      nrfEffective.extent == CapabilityExtent(width: 480, height: 320),
      nrfEffective.regionExtent == CapabilityExtent(width: 480, height: 4),
      nrfEffective.rowBytes == .init(rawValue: 960),
      nrfEffective.operationStream == .synchronousBorrowedOneShot,
      nrfEffective.encoding == .rgb565BigEndian,
      nrfEffective.submissionLifetime == .synchronousBorrow,
      nrfEffective.handoff == .synchronous,
      nrfEffective.realization == .tiled,
      nrfEffective.requiredRasterBytes == .init(rawValue: 3_840),
      nrfEffective.requiredPayloadBytes == .init(rawValue: 3_840),
      nrfEffective.inFlightCount == 1,
      nrfEffective.requiredInFlightBytes == .init(rawValue: 3_840) else {
    fatalError("nRF normalized configuration mismatch")
}
print("configuration-nrf52840-tft\tconfiguration\t480,320,2,1\tavailable,31,480,320,480,4,960,1,1,1,1,2,3840,3840,1,3840")

let nrfFullRGBA = normalizedConfiguration(
    width: 480, height: 320, kind: .fullSurface, encoding: .rgba8888,
    regionHeight: 320, maximumBytes: 3_840
)
guard nrfFullRGBA == .unavailable(.insufficientCapacity(
    domain: .raster,
    required: .init(rawValue: 614_400),
    available: .init(rawValue: 3_840)
)) else {
    fatalError("nRF full-surface RGBA negative mismatch")
}
print("configuration-nrf52840-full-rgba-negative\tconfiguration\t480,320,1,2,3840\tunavailable,insufficient-capacity,2,614400,3840")

private struct OneShotBorrowState {
    var active = true
    var postEndAccesses: UInt8 = 0
}

private struct OneShotOperationStream {
    private(set) var traversalCount: UInt8 = 0
    private(set) var operationCount: UInt8 = 0
    private var cursor: UInt8 = 0

    mutating func beginTraversal() -> Bool {
        guard traversalCount == 0 else { return false }
        traversalCount = 1
        return true
    }

    mutating func next(borrow: inout OneShotBorrowState) -> UInt8? {
        guard borrow.active else {
            borrow.postEndAccesses &+= 1
            return nil
        }
        let operation: UInt8
        switch cursor {
        case 0: operation = 3
        case 1: operation = 5
        case 2: operation = 7
        default: return nil
        }
        cursor &+= 1
        operationCount &+= 1
        return operation
    }
}

private struct FixedDerivedPayload: Equatable {
    let first: UInt8
    let second: UInt8
    let third: UInt8
}

private struct OneShotDerivedEndpoint {
    private(set) var synchronousChecksum: UInt8 = 0
    private(set) var ownedPayload: FixedDerivedPayload?
    private(set) var copyCompletedBeforeBorrowEnd = false
    private(set) var transferCompletedBeforeBorrowEnd = false
    private(set) var retainedOperationCount: UInt8 = 0

    mutating func offer(
        stream: inout OneShotOperationStream,
        borrow: inout OneShotBorrowState,
        lifetime: SubmissionLifetime,
        handoff: SubmissionHandoff
    ) -> Bool {
        if lifetime == .synchronousBorrow, handoff == .queued { return false }
        guard borrow.active, stream.beginTraversal(),
              let first = stream.next(borrow: &borrow),
              let second = stream.next(borrow: &borrow),
              let third = stream.next(borrow: &borrow),
              stream.next(borrow: &borrow) == nil else {
            return false
        }
        let derived = FixedDerivedPayload(
            first: first &* 2,
            second: second &* 2,
            third: third &* 2
        )
        switch lifetime {
        case .synchronousBorrow:
            synchronousChecksum = derived.first &+ derived.second &+ derived.third
        case .synchronousCopy:
            ownedPayload = derived
            copyCompletedBeforeBorrowEnd = borrow.active
        case .ownershipTransfer:
            ownedPayload = derived
            transferCompletedBeforeBorrowEnd = borrow.active
        }
        return true
    }
}

private func verifyOneShotPair(
    lifetime: SubmissionLifetime,
    handoff: SubmissionHandoff,
    expectedAvailable: Bool
) {
    var borrow = OneShotBorrowState()
    var stream = OneShotOperationStream()
    var endpoint = OneShotDerivedEndpoint()
    let available = endpoint.offer(
        stream: &stream,
        borrow: &borrow,
        lifetime: lifetime,
        handoff: handoff
    )
    guard available == expectedAvailable else {
        fatalError("one-shot lifetime/handoff result mismatch")
    }
    if expectedAvailable {
        guard stream.traversalCount == 1,
              stream.operationCount == 3,
              endpoint.retainedOperationCount == 0 else {
            fatalError("one-shot stream was not consumed exactly once")
        }
        switch lifetime {
        case .synchronousBorrow:
            guard endpoint.synchronousChecksum == 30,
                  endpoint.ownedPayload == nil else {
                fatalError("synchronous borrow retained derived payload")
            }
        case .synchronousCopy:
            guard endpoint.ownedPayload == FixedDerivedPayload(
                first: 6, second: 10, third: 14
            ), endpoint.copyCompletedBeforeBorrowEnd else {
                fatalError("synchronous copy did not own bytes before borrow end")
            }
        case .ownershipTransfer:
            guard endpoint.ownedPayload == FixedDerivedPayload(
                first: 6, second: 10, third: 14
            ), endpoint.transferCompletedBeforeBorrowEnd else {
                fatalError("ownership transfer did not complete before borrow end")
            }
        }
    } else {
        guard stream.traversalCount == 0,
              stream.operationCount == 0,
              endpoint.ownedPayload == nil else {
            fatalError("rejected one-shot pair consumed candidate data")
        }
    }

    borrow.active = false
    guard stream.next(borrow: &borrow) == nil,
          borrow.postEndAccesses == 1,
          stream.beginTraversal() == !expectedAvailable else {
        fatalError("one-shot post-return poison or replay mismatch")
    }
}

let oneShotPairs: [(SubmissionLifetime, SubmissionHandoff, Bool)] = [
    (.synchronousBorrow, .synchronous, true),
    (.synchronousBorrow, .queued, false),
    (.synchronousCopy, .synchronous, true),
    (.synchronousCopy, .queued, true),
    (.ownershipTransfer, .synchronous, true),
    (.ownershipTransfer, .queued, true),
]
for pair in oneShotPairs {
    verifyOneShotPair(lifetime: pair.0, handoff: pair.1, expectedAvailable: pair.2)
}
print("one-shot-lifetime-handoff-matrix\tone-shot\t3,2,6\t5-available,1-rejected,3-operations,1-traversal,0-retained")

private func compatibilityControl(
    requirementEncoding: CanonicalPixelEncodingSet,
    realizationEncoding: CanonicalPixelEncodingSet,
    requirementLifetime: SubmissionLifetimeSet,
    realizationLifetime: SubmissionLifetimeSet,
    policyEncodings: CanonicalPixelEncodingSet = CanonicalPixelEncodingSet(rawValue: 3)
) -> RasterPresentationCandidateOutcome {
    let extent = CapabilityExtent(width: 4, height: 4)!
    let policyPreferred: CanonicalPixelEncodingSet = policyEncodings.contains(
        .rgb565BigEndian
    ) ? .rgb565BigEndian : .rgba8888
    let requirement = RasterPresentationRequirement(
        operations: allOperations,
        extent: extent,
        operationStream: .synchronousBorrowedOneShot,
        acceptedEncodings: requirementEncoding,
        acceptedSubmissionLifetimes: requirementLifetime,
        maximumRasterBytes: .init(rawValue: 64),
        maximumPayloadBytes: .init(rawValue: 64),
        maximumInFlightBytes: .init(rawValue: 64),
        absence: .required
    )!
    let realization = RasterRealizationContribution(
        kind: .tiled,
        operations: allOperations,
        operationStream: .synchronousBorrowedOneShot,
        encodings: realizationEncoding,
        producedSubmissionLifetimes: realizationLifetime,
        maximumExtent: extent,
        maximumRegionWidth: 4,
        maximumRegionHeight: 2,
        rowByteAlignment: 2,
        maximumRasterBytes: .init(rawValue: 64),
        maximumPayloadBytes: .init(rawValue: 64)
    )!
    let surface = SurfaceDisplayContribution(
        extent: extent,
        encodings: realizationEncoding,
        acceptedSubmissionLifetimes: realizationLifetime,
        handoffs: .synchronous,
        maximumRegionWidth: 4,
        maximumRegionHeight: 2,
        rowByteAlignment: 2,
        maximumInFlightCount: 1,
        maximumInFlightBytes: .init(rawValue: 64)
    )!
    let policy = RasterPresentationPolicy(
        maximumRasterBytes: .init(rawValue: 64),
        maximumPayloadBytes: .init(rawValue: 64),
        maximumInFlightBytes: .init(rawValue: 64),
        allowedRealizations: .tiled,
        allowedEncodings: policyEncodings,
        preferredRealization: .tiled,
        preferredEncoding: policyPreferred
    )!
    return RasterPresentationCompatibility.evaluateCandidate(
        requirement: requirement,
        realization: realization,
        surface: surface,
        policy: policy
    )
}

guard compatibilityControl(
    requirementEncoding: .rgb565BigEndian,
    realizationEncoding: .rgba8888,
    requirementLifetime: .synchronousBorrow,
    realizationLifetime: .synchronousBorrow
) == .unavailable(.noCommonCanonicalPixelEncoding),
compatibilityControl(
    requirementEncoding: .rgb565BigEndian,
    realizationEncoding: .rgb565BigEndian,
    requirementLifetime: .synchronousBorrow,
    realizationLifetime: .synchronousBorrow
) != .unavailable(.noCommonCanonicalPixelEncoding) else {
    fatalError("one-shot encoding negative/control mismatch")
}
print("one-shot-encoding-negative-control\tone-shot\t1,2,1,1\tnegative,9,control,available")

guard compatibilityControl(
    requirementEncoding: .rgb565BigEndian,
    realizationEncoding: .rgb565BigEndian,
    requirementLifetime: .synchronousBorrow,
    realizationLifetime: .synchronousCopy
) == .unavailable(.incompatibleSubmissionLifetime),
compatibilityControl(
    requirementEncoding: .rgb565BigEndian,
    realizationEncoding: .rgb565BigEndian,
    requirementLifetime: .synchronousBorrow,
    realizationLifetime: .synchronousBorrow
) != .unavailable(.incompatibleSubmissionLifetime) else {
    fatalError("one-shot lifetime negative/control mismatch")
}
print("one-shot-lifetime-negative-control\tone-shot\t1,1,1,2\tnegative,10,control,available")

guard compatibilityControl(
    requirementEncoding: .rgb565BigEndian,
    realizationEncoding: .rgb565BigEndian,
    requirementLifetime: .synchronousBorrow,
    realizationLifetime: .synchronousBorrow,
    policyEncodings: .rgba8888
) == .unavailable(.policyHasNoConformingRealization),
compatibilityControl(
    requirementEncoding: .rgb565BigEndian,
    realizationEncoding: .rgb565BigEndian,
    requirementLifetime: .synchronousBorrow,
    realizationLifetime: .synchronousBorrow,
    policyEncodings: .rgb565BigEndian
) != .unavailable(.policyHasNoConformingRealization) else {
    fatalError("policy negative/control mismatch")
}
print("negative-policy-control\tnegative\t1,2\tunavailable,policy,control,available,no-weakened-result")

let precedenceCount = CapabilityByteCount(rawValue: 16)
let precedenceAvailable = CapabilityByteCount(rawValue: 15)
let precedenceReasons: [RasterPresentationUnavailable] = [
    .unsupportedLogicalExtent,
    .operationSetMismatch,
    .operationStreamMismatch,
    .noCommonCanonicalPixelEncoding,
    .incompatibleSubmissionLifetime,
    .incompatibleSubmissionHandoff,
    .byteCountOverflow(domain: .raster),
    .insufficientCapacity(
        domain: .raster, required: precedenceCount, available: precedenceAvailable
    ),
    .insufficientCapacity(
        domain: .payload, required: precedenceCount, available: precedenceAvailable
    ),
    .insufficientCapacity(
        domain: .inFlight, required: precedenceCount, available: precedenceAvailable
    ),
    .policyHasNoConformingRealization,
]
var precedencePairCount = 0
for first in precedenceReasons.indices {
    for second in precedenceReasons.indices where second > first {
        guard RasterPresentationResolver.primaryReason(
            precedenceReasons[first], precedenceReasons[second]
        ) == precedenceReasons[first],
        RasterPresentationResolver.primaryReason(
            precedenceReasons[second], precedenceReasons[first]
        ) == precedenceReasons[first] else {
            fatalError("candidate precedence pair mismatch")
        }
        precedencePairCount += 1
    }
}
guard precedencePairCount == 55 else {
    fatalError("candidate precedence pair count mismatch")
}
print("precedence-candidate-pairs\tprecedence\t11,2\t55,all-pass")

let precedenceStages: [(UInt8, RasterPresentationUnavailable)] = [
    (1, .duplicateContributor(role: .renderProducer)),
    (2, .missingContributor(role: .hostResourcePolicy)),
    (3, .insufficientCapacity(
        domain: .resolverWorkspace,
        required: .init(rawValue: 2),
        available: .init(rawValue: 1)
    )),
    (4, .operationSetMismatch),
    (5, .operationStreamMismatch),
    (6, .unsupportedLogicalExtent),
    (7, .operationSetMismatch),
    (8, .operationStreamMismatch),
    (9, .noCommonCanonicalPixelEncoding),
    (10, .incompatibleSubmissionLifetime),
    (11, .incompatibleSubmissionHandoff),
    (12, .byteCountOverflow(domain: .raster)),
    (13, .insufficientCapacity(
        domain: .raster,
        required: precedenceCount,
        available: precedenceAvailable
    )),
    (14, .insufficientCapacity(
        domain: .payload,
        required: precedenceCount,
        available: precedenceAvailable
    )),
    (15, .insufficientCapacity(
        domain: .inFlight,
        required: precedenceCount,
        available: precedenceAvailable
    )),
    (16, .policyHasNoConformingRealization),
]
var allStagePairCount = 0
for first in precedenceStages.indices {
    for second in precedenceStages.indices where second > first {
        let firstEntry = precedenceStages[first]
        let secondEntry = precedenceStages[second]
        guard RasterPresentationResolver.primaryReason(
            firstEntry.1,
            stage: firstEntry.0,
            secondEntry.1,
            stage: secondEntry.0
        ) == firstEntry.1,
        RasterPresentationResolver.primaryReason(
            secondEntry.1,
            stage: secondEntry.0,
            firstEntry.1,
            stage: firstEntry.0
        ) == firstEntry.1 else {
            fatalError("sixteen-stage precedence pair mismatch")
        }
        allStagePairCount += 1
    }
}
guard allStagePairCount == 120 else {
    fatalError("sixteen-stage precedence pair count mismatch")
}
print("precedence-all-stage-pairs\tprecedence\t16,2\t120,all-pass")
