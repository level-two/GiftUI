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

@propertyWrapper
public struct State<Value: _GiftUIObservableReference> {
    private enum Storage {
        case initial(Value)
        case bound(read: () -> Value, replace: (Value) -> Void)
    }

    private var storage: Storage

    public init(wrappedValue: Value) {
        storage = .initial(wrappedValue)
    }

    public var wrappedValue: Value {
        get {
            switch storage {
            case .initial:
                fatalError("observable state accessed before runtime binding")
            case .bound(let read, _):
                return read()
            }
        }
        nonmutating set {
            switch storage {
            case .initial:
                fatalError("observable state replaced before runtime binding")
            case .bound(_, let replace):
                replace(newValue)
            }
        }
    }

    package mutating func _giftUIBind(
        read: @escaping () -> Value,
        replace: @escaping (Value) -> Void
    ) -> Value? {
        guard case .initial(let initial) = storage else {
            return nil
        }
        storage = .bound(read: read, replace: replace)
        return initial
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
    private let reportRoute:
        (_GiftUIObservationAttachment) ->
            _GiftUIObservableChangeReportOutcome

    package init(
        attachment: _GiftUIObservationAttachment,
        reportRoute:
            @escaping (_GiftUIObservationAttachment) ->
            _GiftUIObservableChangeReportOutcome
    ) {
        storedAttachment = attachment
        self.reportRoute = reportRoute
    }

    public var attachment: _GiftUIObservationAttachment {
        storedAttachment
    }

    public mutating func reportChange()
        -> _GiftUIObservableChangeReportOutcome
    {
        reportRoute(storedAttachment)
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

public protocol _GiftUIObservableStateDeclarationVisitor {
    mutating func visit<Value: _GiftUIObservableReference>(
        _ state: inout State<Value>,
        declarationOrdinal: UInt16
    )
}

public protocol _GiftUIObservableStateHost {
    mutating func _giftUIVisitObservableStateDeclarations<
        Visitor: _GiftUIObservableStateDeclarationVisitor
    >(_ visitor: inout Visitor)
}
