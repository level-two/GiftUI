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

public enum CanonicalPixelEncoding: UInt8, Equatable, Sendable {
    case rgb565BigEndian = 1
    case rgba8888 = 2
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

private extension RasterOperationSet {
    static let allDeclared: Self = [
        .opaqueRectangles, .positionedText, .straightLineStrokes, .clipping, .damage,
    ]
    var isValidNonempty: Bool { !isEmpty && subtracting(.allDeclared).isEmpty }
}

private extension CanonicalPixelEncodingSet {
    static let allDeclared: Self = [.rgb565BigEndian, .rgba8888]
    var isValidNonempty: Bool { !isEmpty && subtracting(.allDeclared).isEmpty }
    var isSingleDeclared: Bool {
        isValidNonempty && (rawValue & (rawValue &- 1)) == 0
    }
}

private extension SubmissionLifetimeSet {
    static let allDeclared: Self = [.synchronousBorrow, .synchronousCopy, .ownershipTransfer]
    var isValidNonempty: Bool { !isEmpty && subtracting(.allDeclared).isEmpty }
}

private extension SubmissionHandoffSet {
    static let allDeclared: Self = [.synchronous, .queued]
    var isValidNonempty: Bool { !isEmpty && subtracting(.allDeclared).isEmpty }
}

private extension RasterRealizationKindSet {
    static let allDeclared: Self = [.fullSurface, .tiled]
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
