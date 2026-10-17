@attached(
    member,
    names: named(_giftUIVisitObservableStateDeclarations), named(_giftUITraverse)
)
@attached(extension, conformances: _GiftUIObservableStateHost)
public macro ObservableStateHost() =
    #externalMacro(
        module: "GiftUIMacros",
        type: "ObservableStateHostMacro"
    )

/// Generated application schemas provide only an inert, owned initializer seed.
public protocol _GiftUIModelSchema {
    associatedtype Seed
}

package struct _GiftUIBoundState<Schema> {
    package let locationSlot: UInt16
    package let declarationOrdinal: UInt16
    package let registrationGeneration: UInt32
    package let key: _GiftUIModelKey<Schema>

    package init(
        locationSlot: UInt16, declarationOrdinal: UInt16,
        registrationGeneration: UInt32, key: _GiftUIModelKey<Schema>
    ) {
        self.locationSlot = locationSlot
        self.declarationOrdinal = declarationOrdinal
        self.registrationGeneration = registrationGeneration
        self.key = key
    }
}

@usableFromInline
package enum _GiftUIStateInitial<Schema: _GiftUIModelSchema> {
    case seed(Schema.Seed)
    // The host holds the candidate's owning ticket until the binder explicitly
    // transfers it. This key alone never creates or transfers ownership.
    case candidate(_GiftUIModelKey<Schema>)
}

@propertyWrapper
public struct State<Schema: _GiftUIModelSchema> {
    private enum Storage {
        case initial(_GiftUIStateInitial<Schema>)
        case bound(_GiftUIBoundState<Schema>)
    }
    private var storage: Storage

    public init(seed: Schema.Seed) {
        storage = .initial(.seed(seed))
    }

    public init(candidate: _GiftUIModelKey<Schema>) {
        storage = .initial(.candidate(candidate))
    }

    // Generated reads use the checked accessor below. This inert projection is
    // never a raw model reference or an escaping runtime resolver.
    public var wrappedValue: _GiftUIModelKey<Schema>? {
        if case .bound(let binding) = storage { return binding.key }
        return nil
    }

    package func _giftUIKey() throws(_GiftUIAccessFailure) -> _GiftUIModelKey<Schema> {
        guard case .bound(let binding) = storage else { throw .invalidPhase }
        return binding.key
    }

    @usableFromInline
    package var _giftUIInitial: _GiftUIStateInitial<Schema>? {
        if case .initial(let seed) = storage { return seed }
        return nil
    }

    package var _giftUIBinding: _GiftUIBoundState<Schema>? {
        if case .bound(let binding) = storage { return binding }
        return nil
    }

    @discardableResult
    package mutating func _giftUIBind(_ binding: _GiftUIBoundState<Schema>) -> _GiftUIStateInitial<
        Schema
    >? {
        guard case .initial(let seed) = storage else { return nil }
        storage = .bound(binding)
        return seed
    }
}

public enum _GiftUIObservableChangeReportOutcome: UInt8, Equatable, Sendable {
    case dirtied = 0
    case coalesced = 1
    case staleAttachment = 2
    case invalidPhaseContained = 3
    case invalidPhaseSafetyNotProven = 4
    case reentrancyViolation = 5
    case invariantViolation = 6
}

public struct _GiftUIObservationAttachment: Equatable, Sendable {
    public let slot: UInt16
    public let generation: UInt32

    package init(slot: UInt16, generation: UInt32) {
        self.slot = slot
        self.generation = generation
    }
}

public struct _GiftUIObservableChangeSink: ~Copyable {
    private let storedAttachment: _GiftUIObservationAttachment
    private let context: UnsafeMutableRawPointer
    private let reportRoute: @convention(c) (UnsafeMutableRawPointer, UInt16, UInt32) -> UInt8

    package init(
        attachment: _GiftUIObservationAttachment,
        context: UnsafeMutableRawPointer,
        reportRoute: @escaping @convention(c) (UnsafeMutableRawPointer, UInt16, UInt32) -> UInt8
    ) {
        storedAttachment = attachment
        self.context = context
        self.reportRoute = reportRoute
    }

    public var attachment: _GiftUIObservationAttachment {
        storedAttachment
    }

    public mutating func reportChange()
        -> _GiftUIObservableChangeReportOutcome
    {
        _GiftUIObservableChangeReportOutcome(
            rawValue: reportRoute(
                context, storedAttachment.slot, storedAttachment.generation)) ?? .invariantViolation
    }
}

public protocol _GiftUIObservableReference {
    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment?

    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    )
}

public protocol _GiftUIObservableStateDeclarationVisitor: ~Copyable, ~Escapable {
    mutating func visit<Schema: _GiftUIModelSchema>(
        _ state: inout State<Schema>,
        declarationOrdinal: UInt16
    )
}

public protocol _GiftUIObservableStateHost {
    mutating func _giftUIVisitObservableStateDeclarations<
        Visitor: _GiftUIObservableStateDeclarationVisitor & ~Copyable & ~Escapable
    >(_ visitor: inout Visitor)
}
