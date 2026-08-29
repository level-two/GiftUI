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
