public struct CapabilityExtent: Equatable, Sendable {
    public let width: UInt16
    public let height: UInt16

    public init?(width: UInt16, height: UInt16) {
        guard width > 0, height > 0 else { return nil }
        self.width = width
        self.height = height
    }
}

public struct CapabilityByteCount: Equatable, Comparable, Sendable {
    public let rawValue: UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public struct RasterOperationSet: OptionSet, Equatable, Sendable {
    public let rawValue: UInt8
    public init(rawValue: UInt8) { self.rawValue = rawValue }
    public static let opaqueRectangles = Self(rawValue: 1 << 0)
    public static let positionedText = Self(rawValue: 1 << 1)
    public static let straightLineStrokes = Self(rawValue: 1 << 2)
    public static let clipping = Self(rawValue: 1 << 3)
    public static let damage = Self(rawValue: 1 << 4)
}

public enum OperationStreamLifetime: UInt8, Equatable, Sendable {
    case synchronousBorrowedOneShot = 1
    case incompatibleWithSynchronousBorrowedOneShot = 2
}

public struct CanonicalPixelEncodingSet: OptionSet, Equatable, Sendable {
    public let rawValue: UInt8
    public init(rawValue: UInt8) { self.rawValue = rawValue }
    public static let rgb565BigEndian = Self(rawValue: 1 << 0)
    public static let rgba8888 = Self(rawValue: 1 << 1)
}

public struct SubmissionLifetimeSet: OptionSet, Equatable, Sendable {
    public let rawValue: UInt8
    public init(rawValue: UInt8) { self.rawValue = rawValue }
    public static let synchronousBorrow = Self(rawValue: 1 << 0)
    public static let synchronousCopy = Self(rawValue: 1 << 1)
    public static let ownershipTransfer = Self(rawValue: 1 << 2)
}

public struct SubmissionHandoffSet: OptionSet, Equatable, Sendable {
    public let rawValue: UInt8
    public init(rawValue: UInt8) { self.rawValue = rawValue }
    public static let synchronous = Self(rawValue: 1 << 0)
    public static let queued = Self(rawValue: 1 << 1)
}

public enum CapabilityAbsence: UInt8, Equatable, Sendable {
    case required = 1
    case optional = 2
}

public struct RasterPresentationRequirement: Equatable, Sendable {
    public let operations: RasterOperationSet
    public let extent: CapabilityExtent
    public let operationStream: OperationStreamLifetime
    public let acceptedEncodings: CanonicalPixelEncodingSet
    public let acceptedSubmissionLifetimes: SubmissionLifetimeSet
    public let maximumRasterBytes: CapabilityByteCount
    public let maximumPayloadBytes: CapabilityByteCount
    public let maximumInFlightBytes: CapabilityByteCount
    public let absence: CapabilityAbsence

    public init?(
        operations: RasterOperationSet,
        extent: CapabilityExtent,
        operationStream: OperationStreamLifetime,
        acceptedEncodings: CanonicalPixelEncodingSet,
        acceptedSubmissionLifetimes: SubmissionLifetimeSet,
        maximumRasterBytes: CapabilityByteCount,
        maximumPayloadBytes: CapabilityByteCount,
        maximumInFlightBytes: CapabilityByteCount,
        absence: CapabilityAbsence
    ) {
        guard operations == .allDeclared,
              operationStream == .synchronousBorrowedOneShot,
              acceptedEncodings.isValidNonempty,
              acceptedSubmissionLifetimes.isValidNonempty else { return nil }
        self.operations = operations
        self.extent = extent
        self.operationStream = operationStream
        self.acceptedEncodings = acceptedEncodings
        self.acceptedSubmissionLifetimes = acceptedSubmissionLifetimes
        self.maximumRasterBytes = maximumRasterBytes
        self.maximumPayloadBytes = maximumPayloadBytes
        self.maximumInFlightBytes = maximumInFlightBytes
        self.absence = absence
    }
}

public struct RenderProducerContribution: Equatable, Sendable {
    public let operations: RasterOperationSet
    public let operationStream: OperationStreamLifetime

    public init?(
        operations: RasterOperationSet,
        operationStream: OperationStreamLifetime
    ) {
        guard operations.isValidNonempty else { return nil }
        self.operations = operations
        self.operationStream = operationStream
    }
}

public enum RasterRealizationKind: UInt8, Equatable, Sendable {
    case fullSurface = 1
    case tiled = 2
}

public struct RasterRealizationKindSet: OptionSet, Equatable, Sendable {
    public let rawValue: UInt8
    public init(rawValue: UInt8) { self.rawValue = rawValue }
    public static let fullSurface = Self(rawValue: 1 << 0)
    public static let tiled = Self(rawValue: 1 << 1)
}

public struct RasterRealizationContribution: Equatable, Sendable {
    public let kind: RasterRealizationKind
    public let operations: RasterOperationSet
    public let operationStream: OperationStreamLifetime
    public let encodings: CanonicalPixelEncodingSet
    public let producedSubmissionLifetimes: SubmissionLifetimeSet
    public let maximumExtent: CapabilityExtent
    public let maximumRegionWidth: UInt16
    public let maximumRegionHeight: UInt16
    public let rowByteAlignment: UInt16
    public let maximumRasterBytes: CapabilityByteCount
    public let maximumPayloadBytes: CapabilityByteCount

    public init?(
        kind: RasterRealizationKind,
        operations: RasterOperationSet,
        operationStream: OperationStreamLifetime,
        encodings: CanonicalPixelEncodingSet,
        producedSubmissionLifetimes: SubmissionLifetimeSet,
        maximumExtent: CapabilityExtent,
        maximumRegionWidth: UInt16,
        maximumRegionHeight: UInt16,
        rowByteAlignment: UInt16,
        maximumRasterBytes: CapabilityByteCount,
        maximumPayloadBytes: CapabilityByteCount
    ) {
        guard operations.isValidNonempty,
              encodings.isValidNonempty,
              producedSubmissionLifetimes.isValidNonempty,
              maximumRegionWidth > 0,
              maximumRegionHeight > 0,
              maximumRegionWidth <= maximumExtent.width,
              maximumRegionHeight <= maximumExtent.height,
              rowByteAlignment > 0 else { return nil }
        if kind == .tiled {
            guard Self.payloadAdmitsOneRow(
                width: maximumRegionWidth,
                alignment: rowByteAlignment,
                encodings: encodings,
                maximumPayloadBytes: maximumPayloadBytes.rawValue
            ) else { return nil }
        }
        self.kind = kind
        self.operations = operations
        self.operationStream = operationStream
        self.encodings = encodings
        self.producedSubmissionLifetimes = producedSubmissionLifetimes
        self.maximumExtent = maximumExtent
        self.maximumRegionWidth = maximumRegionWidth
        self.maximumRegionHeight = maximumRegionHeight
        self.rowByteAlignment = rowByteAlignment
        self.maximumRasterBytes = maximumRasterBytes
        self.maximumPayloadBytes = maximumPayloadBytes
    }

    private static func payloadAdmitsOneRow(
        width: UInt16,
        alignment: UInt16,
        encodings: CanonicalPixelEncodingSet,
        maximumPayloadBytes: UInt32
    ) -> Bool {
        if encodings.contains(.rgb565BigEndian),
           !rowFits(width: width, alignment: alignment, bytesPerPixel: 2,
                    maximumPayloadBytes: maximumPayloadBytes) {
            return false
        }
        return !encodings.contains(.rgba8888) ||
            rowFits(width: width, alignment: alignment, bytesPerPixel: 4,
                    maximumPayloadBytes: maximumPayloadBytes)
    }

    private static func rowFits(
        width: UInt16,
        alignment: UInt16,
        bytesPerPixel: UInt32,
        maximumPayloadBytes: UInt32
    ) -> Bool {
        let unaligned = UInt32(width).multipliedReportingOverflow(by: bytesPerPixel)
        guard !unaligned.overflow else { return false }
        let alignmentValue = UInt32(alignment)
        let remainder = unaligned.partialValue % alignmentValue
        let padding = remainder == 0 ? 0 : alignmentValue - remainder
        let aligned = unaligned.partialValue.addingReportingOverflow(padding)
        return !aligned.overflow && aligned.partialValue <= maximumPayloadBytes
    }
}

public struct RasterBackendContribution: Equatable, Sendable {
    public let primary: RasterRealizationContribution
    public let alternate: RasterRealizationContribution?

    public init?(
        primary: RasterRealizationContribution,
        alternate: RasterRealizationContribution?
    ) {
        guard alternate?.kind != primary.kind else { return nil }
        self.primary = primary
        self.alternate = alternate
    }
}

public struct SurfaceDisplayContribution: Equatable, Sendable {
    public let extent: CapabilityExtent
    public let encodings: CanonicalPixelEncodingSet
    public let acceptedSubmissionLifetimes: SubmissionLifetimeSet
    public let handoffs: SubmissionHandoffSet
    public let maximumRegionWidth: UInt16
    public let maximumRegionHeight: UInt16
    public let rowByteAlignment: UInt16
    public let maximumInFlightCount: UInt8
    public let maximumInFlightBytes: CapabilityByteCount

    public init?(
        extent: CapabilityExtent,
        encodings: CanonicalPixelEncodingSet,
        acceptedSubmissionLifetimes: SubmissionLifetimeSet,
        handoffs: SubmissionHandoffSet,
        maximumRegionWidth: UInt16,
        maximumRegionHeight: UInt16,
        rowByteAlignment: UInt16,
        maximumInFlightCount: UInt8,
        maximumInFlightBytes: CapabilityByteCount
    ) {
        guard encodings.isValidNonempty,
              acceptedSubmissionLifetimes.isValidNonempty,
              handoffs.isValidNonempty,
              maximumRegionWidth > 0,
              maximumRegionHeight > 0,
              maximumRegionWidth <= extent.width,
              maximumRegionHeight <= extent.height,
              rowByteAlignment > 0,
              maximumInFlightCount > 0 else { return nil }
        self.extent = extent
        self.encodings = encodings
        self.acceptedSubmissionLifetimes = acceptedSubmissionLifetimes
        self.handoffs = handoffs
        self.maximumRegionWidth = maximumRegionWidth
        self.maximumRegionHeight = maximumRegionHeight
        self.rowByteAlignment = rowByteAlignment
        self.maximumInFlightCount = maximumInFlightCount
        self.maximumInFlightBytes = maximumInFlightBytes
    }
}

public struct RasterPresentationPolicy: Equatable, Sendable {
    public let maximumRasterBytes: CapabilityByteCount
    public let maximumPayloadBytes: CapabilityByteCount
    public let maximumInFlightBytes: CapabilityByteCount
    public let allowedRealizations: RasterRealizationKindSet
    public let allowedEncodings: CanonicalPixelEncodingSet
    public let preferredRealization: RasterRealizationKind
    public let preferredEncoding: CanonicalPixelEncodingSet

    public init?(
        maximumRasterBytes: CapabilityByteCount,
        maximumPayloadBytes: CapabilityByteCount,
        maximumInFlightBytes: CapabilityByteCount,
        allowedRealizations: RasterRealizationKindSet,
        allowedEncodings: CanonicalPixelEncodingSet,
        preferredRealization: RasterRealizationKind,
        preferredEncoding: CanonicalPixelEncodingSet
    ) {
        guard allowedRealizations.isValidNonempty,
              allowedEncodings.isValidNonempty,
              allowedRealizations.contains(preferredRealization.option),
              preferredEncoding.isSingleDeclared,
              allowedEncodings.contains(preferredEncoding) else { return nil }
        self.maximumRasterBytes = maximumRasterBytes
        self.maximumPayloadBytes = maximumPayloadBytes
        self.maximumInFlightBytes = maximumInFlightBytes
        self.allowedRealizations = allowedRealizations
        self.allowedEncodings = allowedEncodings
        self.preferredRealization = preferredRealization
        self.preferredEncoding = preferredEncoding
    }
}

public enum RasterPresentationContribution: Equatable, Sendable {
    case renderProducer(RenderProducerContribution)
    case rasterBackend(RasterBackendContribution)
    case surfaceDisplay(SurfaceDisplayContribution)
    case hostResourcePolicy(RasterPresentationPolicy)
}

public struct RasterPresentationContributions: Equatable, Sendable {
    public static let capacity: UInt8 = 4

    var renderProducer: RenderProducerContribution?
    var rasterBackend: RasterBackendContribution?
    var surfaceDisplay: SurfaceDisplayContribution?
    var hostResourcePolicy: RasterPresentationPolicy?
    var duplicateMask: UInt8

    public init() {
        renderProducer = nil
        rasterBackend = nil
        surfaceDisplay = nil
        hostResourcePolicy = nil
        duplicateMask = 0
    }

    public mutating func insert(
        _ contribution: RasterPresentationContribution
    ) -> RasterPresentationContributionInsertion {
        switch contribution {
        case let .renderProducer(value):
            guard renderProducer == nil else {
                return rejectDuplicate(.renderProducer)
            }
            renderProducer = value
        case let .rasterBackend(value):
            guard rasterBackend == nil else {
                return rejectDuplicate(.rasterBackend)
            }
            rasterBackend = value
        case let .surfaceDisplay(value):
            guard surfaceDisplay == nil else {
                return rejectDuplicate(.surfaceDisplay)
            }
            surfaceDisplay = value
        case let .hostResourcePolicy(value):
            guard hostResourcePolicy == nil else {
                return rejectDuplicate(.hostResourcePolicy)
            }
            hostResourcePolicy = value
        }
        return .inserted
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.duplicateMask == rhs.duplicateMask else { return false }
        return (lhs.hasDuplicate(.renderProducer) || lhs.renderProducer == rhs.renderProducer) &&
            (lhs.hasDuplicate(.rasterBackend) || lhs.rasterBackend == rhs.rasterBackend) &&
            (lhs.hasDuplicate(.surfaceDisplay) || lhs.surfaceDisplay == rhs.surfaceDisplay) &&
            (lhs.hasDuplicate(.hostResourcePolicy) ||
                lhs.hostResourcePolicy == rhs.hostResourcePolicy)
    }

    var firstInputIssue: RasterPresentationUnavailable? {
        if let duplicate = lowestDuplicateRole {
            return .duplicateContributor(role: duplicate)
        }
        if let missing = lowestMissingRole {
            return .missingContributor(role: missing)
        }
        return nil
    }

    private mutating func rejectDuplicate(
        _ role: RasterPresentationContributorRole
    ) -> RasterPresentationContributionInsertion {
        duplicateMask |= role.mask
        return .rejected(.duplicateContributor(role: role))
    }

    private func hasDuplicate(_ role: RasterPresentationContributorRole) -> Bool {
        duplicateMask & role.mask != 0
    }

    private var lowestDuplicateRole: RasterPresentationContributorRole? {
        if hasDuplicate(.renderProducer) { return .renderProducer }
        if hasDuplicate(.rasterBackend) { return .rasterBackend }
        if hasDuplicate(.surfaceDisplay) { return .surfaceDisplay }
        if hasDuplicate(.hostResourcePolicy) { return .hostResourcePolicy }
        return nil
    }

    private var lowestMissingRole: RasterPresentationContributorRole? {
        if renderProducer == nil { return .renderProducer }
        if rasterBackend == nil { return .rasterBackend }
        if surfaceDisplay == nil { return .surfaceDisplay }
        if hostResourcePolicy == nil { return .hostResourcePolicy }
        return nil
    }
}

public enum RasterPresentationContributionInsertion: Equatable, Sendable {
    case inserted
    case rejected(RasterPresentationUnavailable)
}

struct NormalizedRasterPresentationCandidate: Equatable, Sendable {
    let realization: RasterRealizationContribution
}

struct RasterPresentationArithmeticValue: Equatable, Sendable {
    let effectiveRowAlignment: UInt32
    let regionExtent: CapabilityExtent
    let rowBytes: CapabilityByteCount
    let requiredRasterBytes: CapabilityByteCount
    let requiredPayloadBytes: CapabilityByteCount
    let requiredInFlightBytes: CapabilityByteCount
}

enum RasterPresentationArithmeticOutcome: Equatable, Sendable {
    case available(RasterPresentationArithmeticValue)
    case unavailable(RasterPresentationUnavailable)
}

enum RasterPresentationRegionOutcome: Equatable, Sendable {
    case available(CapabilityExtent)
    case unavailable(RasterPresentationUnavailable)
}

#if GIFTUI_CAPABILITY_INSTRUMENTATION
struct RasterPresentationResolverOperationCounts: Equatable, Sendable {
    var roleVisits: UInt16 = 0
    var setIntersectionsAndComparisons: UInt16 = 0
    var checkedArithmetic: UInt16 = 0
    var candidateChecks: UInt16 = 0
    var validationResultConstructions: UInt16 = 0
    var resolverInvocations: UInt16 = 0

    var primitiveOperations: UInt16 {
        roleVisits
            &+ setIntersectionsAndComparisons
            &+ checkedArithmetic
            &+ candidateChecks
            &+ validationResultConstructions
            &+ resolverInvocations
    }
}

enum RasterPresentationResolverInstrumentation {
    nonisolated(unsafe) private(set) static var counts =
        RasterPresentationResolverOperationCounts()

    static func reset() {
        counts = RasterPresentationResolverOperationCounts()
    }

    static func recordRoleVisits(_ count: UInt16) {
        counts.roleVisits &+= count
    }

    static func recordSetOperations(_ count: UInt16) {
        counts.setIntersectionsAndComparisons &+= count
    }

    static func recordCheckedArithmetic(_ count: UInt16) {
        counts.checkedArithmetic &+= count
    }

    static func recordCandidateChecks(_ count: UInt16) {
        counts.candidateChecks &+= count
    }

    static func recordValidationResultConstruction() {
        counts.validationResultConstructions &+= 1
    }

    static func recordResolverInvocation() {
        counts.resolverInvocations &+= 1
    }
}
#endif

enum RasterPresentationArithmetic {
    static func evaluate(
        requirement: RasterPresentationRequirement,
        realization: RasterRealizationContribution,
        surface: SurfaceDisplayContribution,
        policy: RasterPresentationPolicy,
        encoding: CanonicalPixelEncoding
    ) -> RasterPresentationArithmeticOutcome {
#if GIFTUI_CAPABILITY_INSTRUMENTATION
        RasterPresentationResolverInstrumentation.recordCheckedArithmetic(4)
#endif
        let regionExtent: CapabilityExtent
        switch region(
            requirement: requirement,
            realization: realization,
            surface: surface
        ) {
        case let .available(value): regionExtent = value
        case let .unavailable(reason): return .unavailable(reason)
        }
        let extent = requirement.extent

        let candidateAlignment = UInt32(realization.rowByteAlignment)
        let surfaceAlignment = UInt32(surface.rowByteAlignment)
        let divisor = greatestCommonDivisor(candidateAlignment, surfaceAlignment)
        let alignmentProduct = (candidateAlignment / divisor)
            .multipliedReportingOverflow(by: surfaceAlignment)
        guard !alignmentProduct.overflow else {
            return .unavailable(.byteCountOverflow(domain: .raster))
        }
        let effectiveAlignment = alignmentProduct.partialValue

        let unalignedRow = UInt32(extent.width)
            .multipliedReportingOverflow(by: encoding.bytesPerPixel)
        guard !unalignedRow.overflow else {
            return .unavailable(.byteCountOverflow(domain: .raster))
        }
        let remainder = unalignedRow.partialValue % effectiveAlignment
        let padding = remainder == 0 ? 0 : effectiveAlignment - remainder
        let alignedRow = unalignedRow.partialValue.addingReportingOverflow(padding)
        guard !alignedRow.overflow else {
            return .unavailable(.byteCountOverflow(domain: .raster))
        }

        let usage = alignedRow.partialValue
            .multipliedReportingOverflow(by: UInt32(regionExtent.height))
        guard !usage.overflow else {
            return .unavailable(.byteCountOverflow(domain: .raster))
        }

        let required = CapabilityByteCount(rawValue: usage.partialValue)
        let rasterAvailable = minimum(
            requirement.maximumRasterBytes,
            realization.maximumRasterBytes,
            policy.maximumRasterBytes
        )
        guard required <= rasterAvailable else {
            return .unavailable(.insufficientCapacity(
                domain: .raster,
                required: required,
                available: rasterAvailable
            ))
        }

        let payloadAvailable = minimum(
            requirement.maximumPayloadBytes,
            realization.maximumPayloadBytes,
            policy.maximumPayloadBytes
        )
        guard required <= payloadAvailable else {
            return .unavailable(.insufficientCapacity(
                domain: .payload,
                required: required,
                available: payloadAvailable
            ))
        }

        let inFlightAvailable = minimum(
            requirement.maximumInFlightBytes,
            surface.maximumInFlightBytes,
            policy.maximumInFlightBytes
        )
        guard required <= inFlightAvailable else {
            return .unavailable(.insufficientCapacity(
                domain: .inFlight,
                required: required,
                available: inFlightAvailable
            ))
        }

        return .available(RasterPresentationArithmeticValue(
            effectiveRowAlignment: effectiveAlignment,
            regionExtent: regionExtent,
            rowBytes: CapabilityByteCount(rawValue: alignedRow.partialValue),
            requiredRasterBytes: required,
            requiredPayloadBytes: required,
            requiredInFlightBytes: required
        ))
    }

    static func region(
        requirement: RasterPresentationRequirement,
        realization: RasterRealizationContribution,
        surface: SurfaceDisplayContribution
    ) -> RasterPresentationRegionOutcome {
        let extent = requirement.extent
        guard extent.width <= realization.maximumExtent.width,
              extent.height <= realization.maximumExtent.height,
              extent.width <= surface.extent.width,
              extent.height <= surface.extent.height,
              extent.width <= realization.maximumRegionWidth,
              extent.width <= surface.maximumRegionWidth else {
            return .unavailable(.unsupportedLogicalExtent)
        }

        let regionHeight: UInt16
        switch realization.kind {
        case .fullSurface:
            guard extent.height <= realization.maximumRegionHeight,
                  extent.height <= surface.maximumRegionHeight else {
                return .unavailable(.unsupportedLogicalExtent)
            }
            regionHeight = extent.height
        case .tiled:
            regionHeight = minimum(
                extent.height,
                realization.maximumRegionHeight,
                surface.maximumRegionHeight
            )
        }
        guard let value = CapabilityExtent(width: extent.width, height: regionHeight) else {
            return .unavailable(.unsupportedLogicalExtent)
        }
        return .available(value)
    }

    private static func greatestCommonDivisor(_ lhs: UInt32, _ rhs: UInt32) -> UInt32 {
        var first = lhs
        var second = rhs
        while second != 0 {
            let remainder = first % second
            first = second
            second = remainder
        }
        return first
    }

    private static func minimum<T: Comparable>(_ first: T, _ second: T, _ third: T) -> T {
        min(first, min(second, third))
    }
}

struct RasterPresentationCandidatePath: Equatable, Sendable {
    let realization: RasterRealizationKind
    let encoding: CanonicalPixelEncoding
    let submissionLifetime: SubmissionLifetime
    let handoff: SubmissionHandoff
    let arithmetic: RasterPresentationArithmeticValue
}

enum RasterPresentationCandidateOutcome: Equatable, Sendable {
    case available(RasterPresentationCandidatePath)
    case unavailable(RasterPresentationUnavailable)
}

enum RasterPresentationCompatibility {
    static func producerIssue(
        requirement: RasterPresentationRequirement,
        producer: RenderProducerContribution
    ) -> RasterPresentationUnavailable? {
#if GIFTUI_CAPABILITY_INSTRUMENTATION
        RasterPresentationResolverInstrumentation.recordSetOperations(2)
#endif
        guard producer.operations.isSuperset(of: requirement.operations) else {
            return .operationSetMismatch
        }
        guard producer.operationStream == requirement.operationStream else {
            return .operationStreamMismatch
        }
        return nil
    }

    static func evaluateCandidate(
        requirement: RasterPresentationRequirement,
        realization: RasterRealizationContribution,
        surface: SurfaceDisplayContribution,
        policy: RasterPresentationPolicy
    ) -> RasterPresentationCandidateOutcome {
#if GIFTUI_CAPABILITY_INSTRUMENTATION
        RasterPresentationResolverInstrumentation.recordCandidateChecks(1)
        RasterPresentationResolverInstrumentation.recordSetOperations(9)
#endif
        if case let .unavailable(reason) = RasterPresentationArithmetic.region(
            requirement: requirement,
            realization: realization,
            surface: surface
        ) {
            return .unavailable(reason)
        }
        guard realization.operations.isSuperset(of: requirement.operations) else {
            return .unavailable(.operationSetMismatch)
        }
        guard realization.operationStream == requirement.operationStream else {
            return .unavailable(.operationStreamMismatch)
        }

        let encodings = requirement.acceptedEncodings
            .intersection(realization.encodings)
            .intersection(surface.encodings)
        guard !encodings.isEmpty else {
            return .unavailable(.noCommonCanonicalPixelEncoding)
        }

        let lifetimes = requirement.acceptedSubmissionLifetimes
            .intersection(realization.producedSubmissionLifetimes)
            .intersection(surface.acceptedSubmissionLifetimes)
        guard !lifetimes.isEmpty else {
            return .unavailable(.incompatibleSubmissionLifetime)
        }
        guard let lifetimeAndHandoff = firstCompatibleLifetimeAndHandoff(
            lifetimes: lifetimes,
            handoffs: surface.handoffs
        ) else {
            return .unavailable(.incompatibleSubmissionHandoff)
        }

        var firstArithmeticReason: RasterPresentationUnavailable?
        var rgbPath: RasterPresentationCandidatePath?
        var rgbaPath: RasterPresentationCandidatePath?
        if encodings.contains(.rgb565BigEndian) {
            switch makePath(
                requirement: requirement,
                realization: realization,
                surface: surface,
                policy: policy,
                encoding: .rgb565BigEndian,
                lifetimeAndHandoff: lifetimeAndHandoff
            ) {
            case let .available(path): rgbPath = path
            case let .unavailable(reason): firstArithmeticReason = reason
            }
        }
        if encodings.contains(.rgba8888) {
            switch makePath(
                requirement: requirement,
                realization: realization,
                surface: surface,
                policy: policy,
                encoding: .rgba8888,
                lifetimeAndHandoff: lifetimeAndHandoff
            ) {
            case let .available(path): rgbaPath = path
            case let .unavailable(reason):
                if let existing = firstArithmeticReason {
                    if arithmeticReasonPrecedes(reason, existing) {
                        firstArithmeticReason = reason
                    }
                } else {
                    firstArithmeticReason = reason
                }
            }
        }

        guard rgbPath != nil || rgbaPath != nil else {
            return .unavailable(firstArithmeticReason ?? .policyHasNoConformingRealization)
        }
        guard policy.allowedRealizations.contains(realization.kind.option) else {
            return .unavailable(.policyHasNoConformingRealization)
        }

        if policy.preferredEncoding == .rgb565BigEndian,
           policy.allowedEncodings.contains(.rgb565BigEndian),
           let rgbPath {
            return .available(rgbPath)
        }
        if policy.preferredEncoding == .rgba8888,
           policy.allowedEncodings.contains(.rgba8888),
           let rgbaPath {
            return .available(rgbaPath)
        }
        if policy.allowedEncodings.contains(.rgb565BigEndian), let rgbPath {
            return .available(rgbPath)
        }
        if policy.allowedEncodings.contains(.rgba8888), let rgbaPath {
            return .available(rgbaPath)
        }
        return .unavailable(.policyHasNoConformingRealization)
    }

    static func prefers(
        _ lhs: RasterPresentationCandidatePath,
        over rhs: RasterPresentationCandidatePath,
        policy: RasterPresentationPolicy
    ) -> Bool {
        let lhsPreferred = lhs.realization == policy.preferredRealization
        let rhsPreferred = rhs.realization == policy.preferredRealization
        if lhsPreferred != rhsPreferred { return lhsPreferred }
        return lhs.realization.rawValue < rhs.realization.rawValue
    }

    private static func makePath(
        requirement: RasterPresentationRequirement,
        realization: RasterRealizationContribution,
        surface: SurfaceDisplayContribution,
        policy: RasterPresentationPolicy,
        encoding: CanonicalPixelEncoding,
        lifetimeAndHandoff: (SubmissionLifetime, SubmissionHandoff)
    ) -> RasterPresentationCandidateOutcome {
        switch RasterPresentationArithmetic.evaluate(
            requirement: requirement,
            realization: realization,
            surface: surface,
            policy: policy,
            encoding: encoding
        ) {
        case let .available(arithmetic):
            return .available(RasterPresentationCandidatePath(
                realization: realization.kind,
                encoding: encoding,
                submissionLifetime: lifetimeAndHandoff.0,
                handoff: lifetimeAndHandoff.1,
                arithmetic: arithmetic
            ))
        case let .unavailable(reason): return .unavailable(reason)
        }
    }

    private static func firstCompatibleLifetimeAndHandoff(
        lifetimes: SubmissionLifetimeSet,
        handoffs: SubmissionHandoffSet
    ) -> (SubmissionLifetime, SubmissionHandoff)? {
        if lifetimes.contains(.synchronousBorrow), handoffs.contains(.synchronous) {
            return (.synchronousBorrow, .synchronous)
        }
        if lifetimes.contains(.synchronousCopy) {
            if handoffs.contains(.synchronous) { return (.synchronousCopy, .synchronous) }
            if handoffs.contains(.queued) { return (.synchronousCopy, .queued) }
        }
        if lifetimes.contains(.ownershipTransfer) {
            if handoffs.contains(.synchronous) { return (.ownershipTransfer, .synchronous) }
            if handoffs.contains(.queued) { return (.ownershipTransfer, .queued) }
        }
        return nil
    }

    private static func arithmeticReasonPrecedes(
        _ lhs: RasterPresentationUnavailable,
        _ rhs: RasterPresentationUnavailable
    ) -> Bool {
        arithmeticRank(lhs) < arithmeticRank(rhs)
    }

    private static func arithmeticRank(_ reason: RasterPresentationUnavailable) -> UInt8 {
        switch reason {
        case .byteCountOverflow: 1
        case let .insufficientCapacity(domain, _, _): domain.rawValue
        default: .max
        }
    }
}

public struct RasterPresentationResolverWorkspace: Equatable, Sendable {
    public static let candidateCapacity: UInt8 = 2
    public let usableCandidateCapacity: UInt8

    var firstCandidate: NormalizedRasterPresentationCandidate?
    var secondCandidate: NormalizedRasterPresentationCandidate?

    public init?(usableCandidateCapacity: UInt8 = 2) {
        guard usableCandidateCapacity <= Self.candidateCapacity else { return nil }
        self.usableCandidateCapacity = usableCandidateCapacity
        firstCandidate = nil
        secondCandidate = nil
    }

    mutating func append(_ candidate: NormalizedRasterPresentationCandidate) -> Bool {
        if firstCandidate == nil, usableCandidateCapacity >= 1 {
            firstCandidate = candidate
            return true
        }
        if secondCandidate == nil, usableCandidateCapacity >= 2 {
            secondCandidate = candidate
            return true
        }
        return false
    }

    mutating func reset() {
        firstCandidate = nil
        secondCandidate = nil
    }
}

public enum CanonicalPixelEncoding: UInt8, Equatable, Sendable {
    case rgb565BigEndian = 1
    case rgba8888 = 2
}

private extension CanonicalPixelEncoding {
    var bytesPerPixel: UInt32 {
        switch self {
        case .rgb565BigEndian: 2
        case .rgba8888: 4
        }
    }
}

public enum SubmissionLifetime: UInt8, Equatable, Sendable {
    case synchronousBorrow = 1
    case synchronousCopy = 2
    case ownershipTransfer = 3
}

public enum SubmissionHandoff: UInt8, Equatable, Sendable {
    case synchronous = 1
    case queued = 2
}

public struct EffectiveRasterPresentation: Equatable, Sendable {
    public let operations: RasterOperationSet
    public let extent: CapabilityExtent
    public let regionExtent: CapabilityExtent
    public let rowBytes: CapabilityByteCount
    public let operationStream: OperationStreamLifetime
    public let encoding: CanonicalPixelEncoding
    public let submissionLifetime: SubmissionLifetime
    public let handoff: SubmissionHandoff
    public let realization: RasterRealizationKind
    public let requiredRasterBytes: CapabilityByteCount
    public let requiredPayloadBytes: CapabilityByteCount
    public let inFlightCount: UInt8
    public let requiredInFlightBytes: CapabilityByteCount
}

public enum RasterPresentationResolution: Equatable, Sendable {
    case available(EffectiveRasterPresentation)
    case unavailable(RasterPresentationUnavailable)
}

public enum RasterPresentationResolver {
    public static func resolve(
        requirement: RasterPresentationRequirement,
        contributions: borrowing RasterPresentationContributions,
        workspace: inout RasterPresentationResolverWorkspace
    ) -> RasterPresentationResolution {
#if GIFTUI_CAPABILITY_INSTRUMENTATION
        RasterPresentationResolverInstrumentation.recordResolverInvocation()
        RasterPresentationResolverInstrumentation.recordRoleVisits(4)
        defer {
            RasterPresentationResolverInstrumentation
                .recordValidationResultConstruction()
        }
#endif
        workspace.reset()
        let result = resolvePrepared(
            requirement: requirement,
            contributions: contributions,
            workspace: &workspace
        )
        workspace.reset()
        return result
    }

    private static func resolvePrepared(
        requirement: RasterPresentationRequirement,
        contributions: borrowing RasterPresentationContributions,
        workspace: inout RasterPresentationResolverWorkspace
    ) -> RasterPresentationResolution {
        if let issue = contributions.firstInputIssue {
            return .unavailable(issue)
        }
        guard let producer = contributions.renderProducer,
              let backend = contributions.rasterBackend,
              let surface = contributions.surfaceDisplay,
              let policy = contributions.hostResourcePolicy else {
            return .unavailable(.missingContributor(role: .renderProducer))
        }

        let candidateCount: UInt32 = backend.alternate == nil ? 1 : 2
        guard UInt32(workspace.usableCandidateCapacity) >= candidateCount else {
            return .unavailable(.insufficientCapacity(
                domain: .resolverWorkspace,
                required: CapabilityByteCount(rawValue: candidateCount),
                available: CapabilityByteCount(
                    rawValue: UInt32(workspace.usableCandidateCapacity)
                )
            ))
        }
        if let producerIssue = RasterPresentationCompatibility.producerIssue(
            requirement: requirement,
            producer: producer
        ) {
            return .unavailable(producerIssue)
        }

        if let alternate = backend.alternate {
            if backend.primary.kind.rawValue < alternate.kind.rawValue {
                _ = workspace.append(NormalizedRasterPresentationCandidate(
                    realization: backend.primary
                ))
                _ = workspace.append(NormalizedRasterPresentationCandidate(
                    realization: alternate
                ))
            } else {
                _ = workspace.append(NormalizedRasterPresentationCandidate(
                    realization: alternate
                ))
                _ = workspace.append(NormalizedRasterPresentationCandidate(
                    realization: backend.primary
                ))
            }
        } else {
            _ = workspace.append(NormalizedRasterPresentationCandidate(
                realization: backend.primary
            ))
        }

        return resolveCandidates(
            requirement: requirement,
            surface: surface,
            policy: policy,
            workspace: workspace
        )
    }

    private static func resolveCandidates(
        requirement: RasterPresentationRequirement,
        surface: SurfaceDisplayContribution,
        policy: RasterPresentationPolicy,
        workspace: borrowing RasterPresentationResolverWorkspace
    ) -> RasterPresentationResolution {
        let firstPath: RasterPresentationCandidatePath?
        let firstReason: RasterPresentationUnavailable?
        if let candidate = workspace.firstCandidate {
            switch RasterPresentationCompatibility.evaluateCandidate(
                requirement: requirement,
                realization: candidate.realization,
                surface: surface,
                policy: policy
            ) {
            case let .available(path):
                firstPath = path
                firstReason = nil
            case let .unavailable(reason):
                firstPath = nil
                firstReason = reason
            }
        } else {
            firstPath = nil
            firstReason = nil
        }

        guard let candidate = workspace.secondCandidate else {
            if let firstPath {
                return .available(effective(requirement: requirement, path: firstPath))
            }
            return .unavailable(firstReason ?? .policyHasNoConformingRealization)
        }
        switch RasterPresentationCompatibility.evaluateCandidate(
            requirement: requirement,
            realization: candidate.realization,
            surface: surface,
            policy: policy
        ) {
        case let .available(path):
            if let firstPath {
                let selected = RasterPresentationCompatibility.prefers(
                    path, over: firstPath, policy: policy
                ) ? path : firstPath
                return .available(effective(requirement: requirement, path: selected))
            }
            return .available(effective(requirement: requirement, path: path))
        case let .unavailable(reason):
            if let firstPath {
                return .available(effective(requirement: requirement, path: firstPath))
            }
            if let firstReason {
                return .unavailable(primaryReason(firstReason, reason))
            }
            return .unavailable(reason)
        }
    }

    static func primaryReason(
        _ first: RasterPresentationUnavailable,
        _ second: RasterPresentationUnavailable
    ) -> RasterPresentationUnavailable {
        primaryReason(
            first,
            stage: reasonRank(first),
            second,
            stage: reasonRank(second)
        )
    }

    static func primaryReason(
        _ first: RasterPresentationUnavailable,
        stage firstStage: UInt8,
        _ second: RasterPresentationUnavailable,
        stage secondStage: UInt8
    ) -> RasterPresentationUnavailable {
        if secondStage < firstStage { return second }
        if firstStage < secondStage { return first }
        switch (first, second) {
        case let (.duplicateContributor(firstRole), .duplicateContributor(secondRole)):
            return firstRole.rawValue <= secondRole.rawValue ? first : second
        case let (.missingContributor(firstRole), .missingContributor(secondRole)):
            return firstRole.rawValue <= secondRole.rawValue ? first : second
        default:
            return first
        }
    }

    private static func effective(
        requirement: RasterPresentationRequirement,
        path: RasterPresentationCandidatePath
    ) -> EffectiveRasterPresentation {
        EffectiveRasterPresentation(
            operations: requirement.operations,
            extent: requirement.extent,
            regionExtent: path.arithmetic.regionExtent,
            rowBytes: path.arithmetic.rowBytes,
            operationStream: .synchronousBorrowedOneShot,
            encoding: path.encoding,
            submissionLifetime: path.submissionLifetime,
            handoff: path.handoff,
            realization: path.realization,
            requiredRasterBytes: path.arithmetic.requiredRasterBytes,
            requiredPayloadBytes: path.arithmetic.requiredPayloadBytes,
            inFlightCount: 1,
            requiredInFlightBytes: path.arithmetic.requiredInFlightBytes
        )
    }

    private static func reasonRank(_ reason: RasterPresentationUnavailable) -> UInt8 {
        switch reason {
        case .duplicateContributor: 1
        case .missingContributor: 2
        case .unsupportedLogicalExtent: 6
        case .operationSetMismatch: 7
        case .operationStreamMismatch: 8
        case .noCommonCanonicalPixelEncoding: 9
        case .incompatibleSubmissionLifetime: 10
        case .incompatibleSubmissionHandoff: 11
        case .byteCountOverflow: 12
        case let .insufficientCapacity(domain, _, _):
            switch domain {
            case .resolverWorkspace: 3
            case .raster: 13
            case .payload: 14
            case .inFlight: 15
            }
        case .policyHasNoConformingRealization: 16
        default: .max
        }
    }
}

public struct CapabilitySnapshot: Equatable, Sendable {
    public let rasterPresentation: EffectiveRasterPresentation?
    public init(rasterPresentation: EffectiveRasterPresentation?) {
        self.rasterPresentation = rasterPresentation
    }
}

public enum RasterPresentationMalformedField: UInt8, Equatable, Sendable {
    case operationSet = 1
    case encodingSet = 2
    case submissionLifetimeSet = 3
    case handoffSet = 4
    case extent = 5
    case region = 6
    case rowByteAlignment = 7
    case inFlightCount = 8
    case byteCount = 9
    case alternateRealization = 10
    case policyPreference = 11
}

public enum RasterPresentationContributorRole: UInt8, Equatable, Sendable {
    case renderProducer = 1
    case rasterBackend = 2
    case surfaceDisplay = 3
    case hostResourcePolicy = 4
}

public enum RasterPresentationCapacity: UInt8, Equatable, Sendable {
    case resolverWorkspace = 1
    case raster = 2
    case payload = 3
    case inFlight = 4
}

public enum RasterPresentationUnavailable: Equatable, Sendable {
    case malformedRequirement(field: RasterPresentationMalformedField)
    case duplicateContributor(role: RasterPresentationContributorRole)
    case missingContributor(role: RasterPresentationContributorRole)
    case malformedContribution(
        role: RasterPresentationContributorRole,
        field: RasterPresentationMalformedField
    )
    case insufficientCapacity(
        domain: RasterPresentationCapacity,
        required: CapabilityByteCount,
        available: CapabilityByteCount
    )
    case operationSetMismatch
    case operationStreamMismatch
    case logicalExtentOverflow
    case unsupportedLogicalExtent
    case noCommonCanonicalPixelEncoding
    case incompatibleSubmissionLifetime
    case incompatibleSubmissionHandoff
    case byteCountOverflow(domain: RasterPresentationCapacity)
    case policyHasNoConformingRealization
}

private extension RasterPresentationContributorRole {
    var mask: UInt8 { 1 << (rawValue - 1) }
}

private extension RasterOperationSet {
    static let allDeclared = Self(rawValue: 0x1f)
    var isValidNonempty: Bool { !isEmpty && subtracting(.allDeclared).isEmpty }
}

private extension CanonicalPixelEncodingSet {
    static let allDeclared = Self(rawValue: 0x03)
    var isValidNonempty: Bool { !isEmpty && subtracting(.allDeclared).isEmpty }
    var isSingleDeclared: Bool {
        isValidNonempty && (rawValue & (rawValue &- 1)) == 0
    }
}

private extension SubmissionLifetimeSet {
    static let allDeclared = Self(rawValue: 0x07)
    var isValidNonempty: Bool { !isEmpty && subtracting(.allDeclared).isEmpty }
}

private extension SubmissionHandoffSet {
    static let allDeclared = Self(rawValue: 0x03)
    var isValidNonempty: Bool { !isEmpty && subtracting(.allDeclared).isEmpty }
}

private extension RasterRealizationKindSet {
    static let allDeclared = Self(rawValue: 0x03)
    var isValidNonempty: Bool { !isEmpty && subtracting(.allDeclared).isEmpty }
}

private extension RasterRealizationKind {
    var option: RasterRealizationKindSet {
        switch self {
        case .fullSurface: .fullSurface
        case .tiled: .tiled
        }
    }
}
