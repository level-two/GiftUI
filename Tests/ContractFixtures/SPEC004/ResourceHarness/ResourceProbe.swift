#if GIFTUI_SPEC004_CANDIDATE
public nonisolated(unsafe) var giftuiSpec004CapabilityRequirement:
    RasterPresentationRequirement?
public nonisolated(unsafe) var giftuiSpec004CapabilityResolution:
    RasterPresentationResolution = .unavailable(
        .missingContributor(role: .renderProducer)
    )
public nonisolated(unsafe) var giftuiSpec004CapabilitySnapshot =
    CapabilitySnapshot(rasterPresentation: nil)
public nonisolated(unsafe) var giftuiSpec004CapabilityContributions =
    RasterPresentationContributions()
public nonisolated(unsafe) var giftuiSpec004ResolverWorkspace =
    RasterPresentationResolverWorkspace()!

@inline(never)
public func giftuiSpec004Resolve(
    requirement: RasterPresentationRequirement,
    contributions: RasterPresentationContributions,
    workspace: inout RasterPresentationResolverWorkspace
) -> RasterPresentationResolution {
    RasterPresentationResolver.resolve(
        requirement: requirement,
        contributions: contributions,
        workspace: &workspace
    )
}
#endif

@_cdecl("giftui_spec004_resource_probe")
public func giftuiSpec004ResourceProbe(_ seed: UInt32) -> UInt32 {
#if GIFTUI_SPEC004_CANDIDATE
    let extent = CapabilityExtent(width: 480, height: 320)!
    let operations = RasterOperationSet(rawValue: 0x1f)
    let encodings = CanonicalPixelEncodingSet.rgb565BigEndian
    let lifetimes = SubmissionLifetimeSet(rawValue: 0x07)
    let requirement = RasterPresentationRequirement(
        operations: operations,
        extent: extent,
        operationStream: .synchronousBorrowedOneShot,
        acceptedEncodings: encodings,
        acceptedSubmissionLifetimes: lifetimes,
        maximumRasterBytes: .init(rawValue: 3_840),
        maximumPayloadBytes: .init(rawValue: 3_840),
        maximumInFlightBytes: .init(rawValue: 3_840),
        absence: .required
    )!
    let producer = RenderProducerContribution(
        operations: operations,
        operationStream: .synchronousBorrowedOneShot
    )!
    let realization = RasterRealizationContribution(
        kind: .tiled,
        operations: operations,
        operationStream: .synchronousBorrowedOneShot,
        encodings: encodings,
        producedSubmissionLifetimes: lifetimes,
        maximumExtent: extent,
        maximumRegionWidth: 480,
        maximumRegionHeight: 4,
        rowByteAlignment: 4,
        maximumRasterBytes: .init(rawValue: 3_840),
        maximumPayloadBytes: .init(rawValue: 3_840)
    )!
    let backend = RasterBackendContribution(primary: realization, alternate: nil)!
    let surface = SurfaceDisplayContribution(
        extent: extent,
        encodings: encodings,
        acceptedSubmissionLifetimes: lifetimes,
        handoffs: .synchronous,
        maximumRegionWidth: 480,
        maximumRegionHeight: 4,
        rowByteAlignment: 4,
        maximumInFlightCount: 1,
        maximumInFlightBytes: .init(rawValue: 3_840)
    )!
    let policy = RasterPresentationPolicy(
        maximumRasterBytes: .init(rawValue: 3_840),
        maximumPayloadBytes: .init(rawValue: 3_840),
        maximumInFlightBytes: .init(rawValue: 3_840),
        allowedRealizations: .tiled,
        allowedEncodings: encodings,
        preferredRealization: .tiled,
        preferredEncoding: encodings
    )!
    var contributions = RasterPresentationContributions()
    _ = contributions.insert(.renderProducer(producer))
    _ = contributions.insert(.rasterBackend(backend))
    _ = contributions.insert(.surfaceDisplay(surface))
    _ = contributions.insert(.hostResourcePolicy(policy))
    giftuiSpec004CapabilityContributions = contributions
    let resolution = giftuiSpec004Resolve(
        requirement: requirement,
        contributions: contributions,
        workspace: &giftuiSpec004ResolverWorkspace
    )
    giftuiSpec004CapabilityRequirement = requirement
    giftuiSpec004CapabilityResolution = resolution
    switch resolution {
    case let .available(value):
        giftuiSpec004CapabilitySnapshot = CapabilitySnapshot(rasterPresentation: value)
        return seed &+ value.requiredRasterBytes.rawValue
    case .unavailable:
        return UInt32.max
    }
#else
    return seed
#endif
}
