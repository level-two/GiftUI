public struct GiftUIConditionID: RawRepresentable, Sendable, Equatable {
    public let rawValue: UInt16

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    public static let unknownProducerCondition = Self(rawValue: 0)
    public static let invalidValue = Self(rawValue: 1)
    public static let arithmeticOverflow = Self(rawValue: 2)
    public static let capacityExhausted = Self(rawValue: 3)
    public static let invalidIdentity = Self(rawValue: 4)
    public static let invalidProvenance = Self(rawValue: 5)
    public static let invalidPhase = Self(rawValue: 6)
    public static let reentrancyViolation = Self(rawValue: 7)
    public static let requiredFacilityUnavailable = Self(rawValue: 8)
    public static let nonRetryableRefusal = Self(rawValue: 9)
    public static let invariantViolation = Self(rawValue: 10)
}

public enum GiftUIFailureOrigin: UInt8, Sendable {
    case foundation = 0
    case capability = 1
    case semantic = 2
    case layout = 3
    case rendering = 4
    case execution = 5
    case observableState = 6
    case interaction = 7
    case backend = 8
    case presentationIntegration = 9
    case inputIntegration = 10
    case hostComposition = 11
    case displayDriver = 12
    case inputDriver = 13
    case transport = 14
}

public enum GiftUIAffectedScope: UInt8, Sendable {
    case operation = 0
    case activeCycle = 1
    case candidateFrame = 2
    case component = 3
    case runtime = 4
}

public enum GiftUIContainment: UInt8, Sendable {
    case contained = 0
    case safetyNotProven = 1
}

public struct GiftUIFailureFact: Sendable, Equatable {
    public let condition: GiftUIConditionID
    public let origin: GiftUIFailureOrigin
    public let affectedScope: GiftUIAffectedScope
    public let containment: GiftUIContainment

    public init(
        condition: GiftUIConditionID,
        origin: GiftUIFailureOrigin,
        affectedScope: GiftUIAffectedScope,
        containment: GiftUIContainment
    ) {
        self.condition = condition
        self.origin = origin
        self.affectedScope = affectedScope
        self.containment = containment
    }
}

public enum GiftUIOperationalKind: UInt8, Sendable {
    case noChange = 0
    case cacheMiss = 1
    case backpressured = 2
    case superseded = 3
    case deferredToLaterAdmission = 4
    case retryableRefusal = 5
}

public struct GiftUIOperationalFact: Sendable, Equatable {
    public let kind: GiftUIOperationalKind
    public let origin: GiftUIFailureOrigin
    public let affectedScope: GiftUIAffectedScope

    public init(
        kind: GiftUIOperationalKind,
        origin: GiftUIFailureOrigin,
        affectedScope: GiftUIAffectedScope
    ) {
        self.kind = kind
        self.origin = origin
        self.affectedScope = affectedScope
    }
}

public enum GiftUIOutcome<Success> {
    case success(Success)
    case operational(GiftUIOperationalFact)
    case failure(GiftUIFailureFact)
}

extension GiftUIOutcome: Sendable where Success: Sendable {}
extension GiftUIOutcome: Equatable where Success: Equatable {}

public struct GiftUIFailureAnnotation: Sendable, Equatable {
    public let key: UInt16
    public let value: UInt32

    public init(key: UInt16, value: UInt32) {
        self.key = key
        self.value = value
    }
}

public struct GiftUIFailureAnnotations: Sendable, Equatable {
    public static let capacity: UInt8 = 2

    public private(set) var count: UInt8
    private var first: GiftUIFailureAnnotation
    private var second: GiftUIFailureAnnotation

    public init() {
        count = 0
        first = GiftUIFailureAnnotation(key: 0, value: 0)
        second = GiftUIFailureAnnotation(key: 0, value: 0)
    }

    public mutating func append(_ annotation: GiftUIFailureAnnotation) -> Bool {
        switch count {
        case 0:
            first = annotation
            count = 1
            return true
        case 1:
            second = annotation
            count = Self.capacity
            return true
        default:
            return false
        }
    }

    public subscript(index: UInt8) -> GiftUIFailureAnnotation? {
        switch index {
        case 0 where count > 0:
            first
        case 1 where count > 1:
            second
        default:
            nil
        }
    }
}
