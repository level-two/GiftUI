package enum HostComponentGraphValidation {
    package static let requiredRoleCount: UInt8 = 18
    private static let validRoleMask: UInt32 = (1 << requiredRoleCount) - 1

    package enum Request {
        case count
        case record(UInt8)
        case finished
    }
    package struct Engine {
        private enum Phase { case initialCount, missingCount, ordered, scan, done }
        private var phase: Phase = .initialCount
        private var index: UInt8 = 0
        private var scanLimit: UInt8 = 0
        private var seen: UInt32 = 0
        private var error: HostConfigurationError?
        #if GIFTUI_GRAPH_ENGINE_QUALIFICATION
            @_noAllocation
        #endif
        package init() {}
        #if GIFTUI_GRAPH_ENGINE_QUALIFICATION
            @_noAllocation
        #endif
        package func request() -> Request {
            switch phase {
            case .initialCount, .missingCount: return .count
            case .ordered, .scan: return .record(index)
            case .done: return .finished
            }
        }
        #if GIFTUI_GRAPH_ENGINE_QUALIFICATION
            @_noAllocation
        #endif
        package func result() -> HostConfigurationError? {
            let finished: Bool
            if case .done = phase { finished = true } else { finished = false }
            precondition(finished)
            return error
        }
        #if GIFTUI_GRAPH_ENGINE_QUALIFICATION
            @_noAllocation
        #endif
        package mutating func acceptCount(_ count: UInt8) {
            switch phase {
            case .initialCount:
                phase = count == requiredRoleCount ? .ordered : .missingCount
            case .missingCount:
                scanLimit = count
                if count == 0 { finishMissing() } else { phase = .scan }
            default: preconditionFailure("unexpected graph count response")
            }
        }
        #if GIFTUI_GRAPH_ENGINE_QUALIFICATION
            @_noAllocation
        #endif
        package mutating func acceptRecord(_ record: HostComponentRecord?) {
            switch phase {
            case .ordered:
                let expected = HostComponentRole(rawValue: index)!
                guard let record else {
                    finish(.missingRole(expected))
                    return
                }
                let role = HostComponentRoleSet(record.role).rawValue
                if seen & role != 0 {
                    finish(.duplicateRole(record.role))
                    return
                }
                guard record.role == expected else {
                    finish(.invalidGraph)
                    return
                }
                guard record.dependencies.rawValue & ~validRoleMask == 0 else {
                    finish(.invalidGraph)
                    return
                }
                guard record.dependencies.rawValue & role == 0 else {
                    finish(.invalidGraph)
                    return
                }
                let upward = validRoleMask & ~((UInt32(1) << UInt32(index + 1)) - 1)
                guard record.dependencies.rawValue & upward == 0 else {
                    finish(.invalidGraph)
                    return
                }
                seen |= role
                index += 1
                if index == requiredRoleCount { finish(nil) }
            case .scan:
                if let record {
                    let role = HostComponentRoleSet(record.role).rawValue
                    if seen & role != 0 {
                        finish(.duplicateRole(record.role))
                        return
                    }
                    seen |= role
                }
                index += 1
                if index == scanLimit { finishMissing() }
            default: preconditionFailure("unexpected graph record response")
            }
        }
        #if GIFTUI_GRAPH_ENGINE_QUALIFICATION
            @_noAllocation
        #endif
        private mutating func finish(_ result: HostConfigurationError?) {
            error = result
            phase = .done
        }
        #if GIFTUI_GRAPH_ENGINE_QUALIFICATION
            @_noAllocation
        #endif
        private mutating func finishMissing() {
            var raw: UInt8 = 0
            while raw < requiredRoleCount {
                let role = HostComponentRole(rawValue: raw)!
                if seen & HostComponentRoleSet(role).rawValue == 0 {
                    finish(.missingRole(role))
                    return
                }
                raw += 1
            }
            finish(.invalidGraph)
        }
    }

    package static func validate<Graph>(_ graph: borrowing Graph) -> HostConfigurationError?
    where Graph: HostComponentGraphView {
        var engine = Engine()
        while true {
            switch engine.request() {
            case .count: engine.acceptCount(graph.count)
            case .record(let index): engine.acceptRecord(graph.record(at: index))
            case .finished: return engine.result()
            }
        }
    }
}
