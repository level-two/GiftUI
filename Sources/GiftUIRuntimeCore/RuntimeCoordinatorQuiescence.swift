package enum RuntimeQuiescenceOrigin: UInt8, Equatable, Sendable {
    case idle = 0
    case activeCycle = 1
}

package enum RuntimeQuiescenceAction: UInt8, Equatable, Sendable {
    case refuseAdmission = 0
    case cancelPointerSources = 1
    case finishActiveCycleContainment = 2
    case detachObservableRegistrations = 3
    case releaseAdmissionQueues = 4
    case releaseCommittedRouting = 5
    case resetAllStorage = 6
}

package struct RuntimeQuiescenceActions: OptionSet, Equatable, Sendable {
    package let rawValue: UInt8

    package init(rawValue: UInt8) {
        self.rawValue = rawValue & 0x7F
    }

    package static let refuseAdmission = action(.refuseAdmission)
    package static let cancelPointerSources = action(.cancelPointerSources)
    package static let finishActiveCycleContainment = action(.finishActiveCycleContainment)
    package static let detachObservableRegistrations = action(.detachObservableRegistrations)
    package static let releaseAdmissionQueues = action(.releaseAdmissionQueues)
    package static let releaseCommittedRouting = action(.releaseCommittedRouting)
    package static let resetAllStorage = action(.resetAllStorage)

    private static func action(_ action: RuntimeQuiescenceAction) -> Self {
        Self(rawValue: 1 << action.rawValue)
    }

    package func contains(_ action: RuntimeQuiescenceAction) -> Bool {
        contains(Self.action(action))
    }
}

package struct RuntimeQuiescenceProhibitedCalls: OptionSet, Equatable, Sendable {
    package let rawValue: UInt8

    package init(rawValue: UInt8) {
        self.rawValue = rawValue & 0x0F
    }

    package static let newCycle = Self(rawValue: 0x01)
    package static let endpointOffer = Self(rawValue: 0x02)
    package static let handler = Self(rawValue: 0x04)
    package static let diagnostic = Self(rawValue: 0x08)
    package static let all: Self = [.newCycle, .endpointOffer, .handler, .diagnostic]
}

package struct RuntimeQuiescencePlan: Equatable, Sendable {
    package let origin: RuntimeQuiescenceOrigin
    package let actions: RuntimeQuiescenceActions
    package let prohibitedCalls: RuntimeQuiescenceProhibitedCalls
}

package enum RuntimeCoordinatorQuiescenceOracle {
    package static func plan(origin: RuntimeQuiescenceOrigin) -> RuntimeQuiescencePlan {
        var actions: RuntimeQuiescenceActions = [
            .refuseAdmission,
            .cancelPointerSources,
            .detachObservableRegistrations,
            .releaseAdmissionQueues,
            .releaseCommittedRouting,
            .resetAllStorage,
        ]
        if origin == .activeCycle {
            actions.insert(.finishActiveCycleContainment)
        }
        return RuntimeQuiescencePlan(
            origin: origin,
            actions: actions,
            prohibitedCalls: .all
        )
    }
}

package struct RuntimeQuiescenceTracker: Equatable, Sendable {
    private var outstanding: RuntimeQuiescenceActions

    package init(plan: RuntimeQuiescencePlan) {
        outstanding = plan.actions
    }

    package var isComplete: Bool {
        outstanding.isEmpty
    }

    package mutating func takeNext() -> RuntimeQuiescenceAction? {
        if take(.refuseAdmission) { return .refuseAdmission }
        if take(.cancelPointerSources) { return .cancelPointerSources }
        if take(.finishActiveCycleContainment) { return .finishActiveCycleContainment }
        if take(.detachObservableRegistrations) { return .detachObservableRegistrations }
        if take(.releaseAdmissionQueues) { return .releaseAdmissionQueues }
        if take(.releaseCommittedRouting) { return .releaseCommittedRouting }
        if take(.resetAllStorage) { return .resetAllStorage }
        return nil
    }

    private mutating func take(_ action: RuntimeQuiescenceAction) -> Bool {
        guard outstanding.contains(action) else { return false }
        outstanding.remove(RuntimeQuiescenceActions(rawValue: 1 << action.rawValue))
        return true
    }
}
