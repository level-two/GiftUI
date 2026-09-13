package enum HostComponentGraphValidation {
    package static let requiredRoleCount: UInt8 = 18
    private static let validRoleMask: UInt32 = (1 << requiredRoleCount) - 1

    package static func validate<Graph>(
        _ graph: borrowing Graph
    ) -> HostConfigurationError?
    where Graph: HostComponentGraphView {
        guard graph.count == requiredRoleCount else {
            return firstMissingRole(in: graph) ?? .invalidGraph
        }

        var seen = HostComponentRoleSet(rawValue: 0)
        for index in UInt8(0) ..< requiredRoleCount {
            guard let expectedRole = HostComponentRole(rawValue: index),
                let record = graph.record(at: index)
            else {
                return .missingRole(HostComponentRole(rawValue: index)!)
            }
            let roleSet = HostComponentRoleSet(record.role)
            if seen.contains(roleSet) {
                return .duplicateRole(record.role)
            }
            guard record.role == expectedRole else { return .invalidGraph }
            guard record.dependencies.rawValue & ~validRoleMask == 0 else {
                return .invalidGraph
            }
            guard !record.dependencies.contains(roleSet) else {
                return .invalidGraph
            }

            let upwardMask = validRoleMask & ~((UInt32(1) << UInt32(index + 1)) - 1)
            guard record.dependencies.rawValue & upwardMask == 0 else {
                return .invalidGraph
            }
            seen.formUnion(roleSet)
        }
        return nil
    }

    private static func firstMissingRole<Graph>(
        in graph: borrowing Graph
    ) -> HostConfigurationError?
    where Graph: HostComponentGraphView {
        var seen = HostComponentRoleSet(rawValue: 0)
        for index in UInt8(0) ..< graph.count {
            guard let record = graph.record(at: index) else { continue }
            let roleSet = HostComponentRoleSet(record.role)
            if seen.contains(roleSet) {
                return .duplicateRole(record.role)
            }
            seen.formUnion(roleSet)
        }
        for rawValue in UInt8(0) ..< requiredRoleCount {
            let role = HostComponentRole(rawValue: rawValue)!
            if !seen.contains(HostComponentRoleSet(role)) {
                return .missingRole(role)
            }
        }
        return nil
    }
}
