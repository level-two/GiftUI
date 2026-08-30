@_silgen_name("giftui_allocation_probe_reset")
private func resetAllocationCount()

@_silgen_name("giftui_allocation_probe_read")
private func readAllocationCount() -> UInt64

@inline(never)
private func exercise(seed: UInt32) -> UInt32 {
    let extent = CapabilityExtent(width: 480, height: 320)!
    let operations = RasterOperationSet(rawValue: 0x1f)
    let encodings = CanonicalPixelEncodingSet(rawValue: 0x03)
    let lifetimes = SubmissionLifetimeSet(rawValue: 0x07)
    let requirement = RasterPresentationRequirement(
        operations: operations,
        extent: extent,
        operationStream: .synchronousBorrowedOneShot,
        acceptedEncodings: encodings,
        acceptedSubmissionLifetimes: lifetimes,
        maximumRasterBytes: .init(rawValue: 307_200 &+ (seed & 1)),
        maximumPayloadBytes: .init(rawValue: 307_200),
        maximumInFlightBytes: .init(rawValue: 307_200),
        absence: .required
    )!
    let producer = RenderProducerContribution(
        operations: operations,
        operationStream: .synchronousBorrowedOneShot
    )!
    let full = RasterRealizationContribution(
        kind: .fullSurface,
        operations: operations,
        operationStream: .synchronousBorrowedOneShot,
        encodings: encodings,
        producedSubmissionLifetimes: lifetimes,
        maximumExtent: extent,
        maximumRegionWidth: 480,
        maximumRegionHeight: 320,
        rowByteAlignment: 4,
        maximumRasterBytes: .init(rawValue: 614_400),
        maximumPayloadBytes: .init(rawValue: 614_400)
    )!
    let tiled = RasterRealizationContribution(
        kind: .tiled,
        operations: operations,
        operationStream: .synchronousBorrowedOneShot,
        encodings: encodings,
        producedSubmissionLifetimes: lifetimes,
        maximumExtent: extent,
        maximumRegionWidth: 480,
        maximumRegionHeight: 4,
        rowByteAlignment: 4,
        maximumRasterBytes: .init(rawValue: 7_680),
        maximumPayloadBytes: .init(rawValue: 7_680)
    )!
    let backend = RasterBackendContribution(primary: full, alternate: tiled)!
    let surface = SurfaceDisplayContribution(
        extent: extent,
        encodings: encodings,
        acceptedSubmissionLifetimes: lifetimes,
        handoffs: SubmissionHandoffSet(rawValue: 0x03),
        maximumRegionWidth: 480,
        maximumRegionHeight: 320,
        rowByteAlignment: 4,
        maximumInFlightCount: 2,
        maximumInFlightBytes: .init(rawValue: 614_400)
    )!
    let policy = RasterPresentationPolicy(
        maximumRasterBytes: .init(rawValue: 614_400),
        maximumPayloadBytes: .init(rawValue: 614_400),
        maximumInFlightBytes: .init(rawValue: 614_400),
        allowedRealizations: RasterRealizationKindSet(rawValue: 0x03),
        allowedEncodings: encodings,
        preferredRealization: .tiled,
        preferredEncoding: CanonicalPixelEncodingSet(rawValue: 0x01)
    )!
    let arithmetic = RasterPresentationArithmetic.evaluate(
        requirement: requirement,
        realization: tiled,
        surface: surface,
        policy: policy,
        encoding: .rgb565BigEndian
    )
    let compatibility = RasterPresentationCompatibility.evaluateCandidate(
        requirement: requirement,
        realization: tiled,
        surface: surface,
        policy: policy
    )
    var contributions = RasterPresentationContributions()
    _ = contributions.insert(.hostResourcePolicy(policy))
    _ = contributions.insert(.surfaceDisplay(surface))
    _ = contributions.insert(.rasterBackend(backend))
    _ = contributions.insert(.renderProducer(producer))
    let duplicate = contributions.insert(.renderProducer(producer))
    var workspace = RasterPresentationResolverWorkspace(
        usableCandidateCapacity: UInt8(seed % 3)
    )!
    let resolution = RasterPresentationResolver.resolve(
        requirement: requirement,
        contributions: contributions,
        workspace: &workspace
    )
    let snapshot: CapabilitySnapshot?
    switch resolution {
    case let .available(value):
        snapshot = CapabilitySnapshot(rasterPresentation: value)
    case .unavailable:
        snapshot = nil
    }

    var checksum = requirement.maximumRasterBytes.rawValue
    checksum &+= UInt32(producer.operations.rawValue)
    checksum &+= UInt32(backend.primary.kind.rawValue)
    checksum &+= UInt32(surface.maximumInFlightCount)
    checksum &+= UInt32(policy.preferredRealization.rawValue)
    checksum &+= UInt32(workspace.usableCandidateCapacity)
    checksum &+= duplicate == .rejected(.duplicateContributor(role: .renderProducer)) ? 1 : 0
    if case let .available(value) = arithmetic {
        checksum &+= value.requiredRasterBytes.rawValue
    }
    if case let .available(path) = compatibility {
        checksum &+= UInt32(path.encoding.rawValue)
        checksum &+= UInt32(path.submissionLifetime.rawValue)
        checksum &+= UInt32(path.handoff.rawValue)
    }
    if case let .available(value) = resolution {
        checksum &+= value.requiredRasterBytes.rawValue
    }
    checksum &+= snapshot?.rasterPresentation?.rowBytes.rawValue ?? 0
    return checksum
}

private func reportLayout<T>(_ name: String, _: T.Type) {
    print("layout.\(name)=\(MemoryLayout<T>.size),\(MemoryLayout<T>.stride),\(MemoryLayout<T>.alignment)")
}

var warmup: UInt32 = 0
for index in UInt32(0) ..< 100 {
    warmup &+= exercise(seed: index)
}

resetAllocationCount()
var checksum = warmup
for iteration in UInt32(0) ..< 10_000 {
    checksum &+= exercise(seed: iteration)
}
let allocationCount = readAllocationCount()

print("allocation_count=\(allocationCount)")
print("checksum=\(checksum)")
reportLayout("RasterPresentationRequirement", RasterPresentationRequirement.self)
reportLayout("RasterRealizationContribution", RasterRealizationContribution.self)
reportLayout("RasterBackendContribution", RasterBackendContribution.self)
reportLayout("SurfaceDisplayContribution", SurfaceDisplayContribution.self)
reportLayout("RasterPresentationPolicy", RasterPresentationPolicy.self)
reportLayout("RasterPresentationContributions", RasterPresentationContributions.self)
reportLayout("RasterPresentationResolverWorkspace", RasterPresentationResolverWorkspace.self)
reportLayout("EffectiveRasterPresentation", EffectiveRasterPresentation.self)
reportLayout("RasterPresentationUnavailable", RasterPresentationUnavailable.self)
reportLayout("CapabilitySnapshot", CapabilitySnapshot.self)

if allocationCount != 0 {
    fatalError("SPEC-004 construction allocation probe failed")
}
