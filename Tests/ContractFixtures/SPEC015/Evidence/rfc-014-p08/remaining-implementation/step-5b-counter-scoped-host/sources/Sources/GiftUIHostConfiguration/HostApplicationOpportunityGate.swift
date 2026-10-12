package enum HostApplicationOpportunityRejection: UInt8, Equatable, Sendable {
    case reentrant = 0
    case unavailable = 1
    case invalidCompletion = 2
}

package enum HostApplicationOpportunityAdmission: Equatable, Sendable {
    case admitted
    case rejected(HostApplicationOpportunityRejection)
}

package struct HostApplicationOpportunityGate: Sendable {
    private enum State: UInt8, Sendable {
        case ready = 0
        case executing = 1
        case unavailable = 2
    }

    private var state: State = .ready

    package init() {}

    package var isExecuting: Bool { state == .executing }
    package var isAvailable: Bool { state != .unavailable }

    package mutating func begin() -> HostApplicationOpportunityAdmission {
        switch state {
        case .ready:
            state = .executing
            return .admitted
        case .executing:
            return .rejected(.reentrant)
        case .unavailable:
            return .rejected(.unavailable)
        }
    }

    package mutating func complete() -> HostApplicationOpportunityRejection? {
        guard state == .executing else { return .invalidCompletion }
        state = .ready
        return nil
    }

    package mutating func quiesce() -> HostApplicationOpportunityRejection? {
        guard state != .executing else { return .reentrant }
        state = .unavailable
        return nil
    }
}
