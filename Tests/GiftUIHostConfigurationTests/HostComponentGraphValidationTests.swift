import Testing

@testable import GiftUIHostConfiguration

private struct GraphFixture: HostComponentGraphView {
    let records: [HostComponentRecord]
    var count: UInt8 { UInt8(records.count) }

    func record(at index: UInt8) -> HostComponentRecord? {
        guard Int(index) < records.count else { return nil }
        return records[Int(index)]
    }
}

private func validGraph() -> GraphFixture {
    GraphFixture(
        records: (UInt8(0) ... 17).map { rawValue in
            HostComponentRecord(
                role: HostComponentRole(rawValue: rawValue)!,
                dependencies: rawValue == 0
                    ? HostComponentRoleSet(rawValue: 0)
                    : HostComponentRoleSet(
                        HostComponentRole(rawValue: rawValue - 1)!
                    )
            )
        }
    )
}

@Test func exactOrderedComponentGraphIsAccepted() {
    #expect(HostComponentGraphValidation.validate(validGraph()) == nil)
}

@Test func graphRejectsMissingDuplicateUpwardAndUnknownBits() {
    var missing = validGraph().records
    missing.removeLast()
    #expect(
        HostComponentGraphValidation.validate(GraphFixture(records: missing))
            == .missingRole(.residualPolicy)
    )

    var duplicate = validGraph().records
    duplicate[2] = HostComponentRecord(
        role: .textResourcePackage,
        dependencies: HostComponentRoleSet(.runtimeProfile)
    )
    #expect(
        HostComponentGraphValidation.validate(GraphFixture(records: duplicate))
            == .duplicateRole(.textResourcePackage)
    )

    var upward = validGraph().records
    upward[1] = HostComponentRecord(
        role: .textResourcePackage,
        dependencies: HostComponentRoleSet(.residualPolicy)
    )
    #expect(
        HostComponentGraphValidation.validate(GraphFixture(records: upward))
            == .invalidGraph
    )

    var unknown = validGraph().records
    unknown[17] = HostComponentRecord(
        role: .residualPolicy,
        dependencies: HostComponentRoleSet(rawValue: 1 << 18)
    )
    #expect(
        HostComponentGraphValidation.validate(GraphFixture(records: unknown))
            == .invalidGraph
    )
}
