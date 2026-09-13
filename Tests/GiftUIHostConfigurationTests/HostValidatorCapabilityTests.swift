import GiftUICapabilities
import Testing

@testable import GiftUIHostConfiguration

@Test func everyCapabilityContributionPermutationProducesTheSameExactReport() {
    let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
    let values = makeHostCapabilityValues(requirement: preset.capabilityRequirement)
    var expected = makeValidHostValidator()
    guard case .valid(let expectedReport) = expected.validate() else {
        Issue.record("exact capability fixture must validate")
        return
    }

    for permutation in permutationsOfFour() {
        let ordered = permutation.map { values[$0] }
        var validator = makeValidHostValidator(
            capabilityContributions: makeHostCapabilityContributions(ordered)
        )
        #expect(validator.validate() == .valid(expectedReport))
    }
}

@Test func capabilityStageRequiresFourRolesAndTwoCandidateWorkspace() {
    var missing = makeValidHostValidator(
        capabilityContributions: RasterPresentationContributions()
    )
    #expect(
        missing.validate()
            == .invalid(
                stage: .capability,
                error: .capabilityUnavailable(
                    .missingContributor(role: .renderProducer)
                )
            )
    )

    var insufficientWorkspace = makeValidHostValidator(
        capabilityWorkspace: RasterPresentationResolverWorkspace(
            usableCandidateCapacity: 0
        )!
    )
    #expect(
        insufficientWorkspace.validate()
            == .invalid(
                stage: .capability,
                error: .capabilityUnavailable(
                    .insufficientCapacity(
                        domain: .resolverWorkspace,
                        required: CapabilityByteCount(rawValue: 1),
                        available: CapabilityByteCount(rawValue: 0)
                    )
                )
            )
    )
}

@Test func capabilityRequirementCarriesEveryExactHostObligation() {
    let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
    let requirement = preset.capabilityRequirement
    #expect(requirement.operations.rawValue == 0x1F)
    #expect(requirement.extent == CapabilityExtent(width: 480, height: 320))
    #expect(requirement.operationStream == .synchronousBorrowedOneShot)
    #expect(requirement.acceptedEncodings == .rgb565BigEndian)
    #expect(
        requirement.acceptedSubmissionLifetimes
            == [.synchronousBorrow, .synchronousCopy, .ownershipTransfer]
    )
    #expect(requirement.maximumRasterBytes == CapabilityByteCount(rawValue: 3_840))
    #expect(requirement.maximumPayloadBytes == CapabilityByteCount(rawValue: 3_840))
    #expect(requirement.maximumInFlightBytes == CapabilityByteCount(rawValue: 3_840))
    #expect(requirement.absence == .required)
}

@Test func capabilityFailureDoesNotRepairAValidDrawingGate() {
    let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
    #expect(
        SignalAnalyzerDrawingStartupValidation.validate(
            workload: preset.workload,
            limits: preset.runtimeLimits,
            profile: preset.profile
        ) == nil
    )
    var validator = makeValidHostValidator(
        capabilityContributions: RasterPresentationContributions()
    )
    guard case .invalid(let stage, _) = validator.validate() else {
        Issue.record("missing capabilities must fail")
        return
    }
    #expect(stage == .capability)
}

@Test func aValidatorNeverResolvesCapabilitiesAfterItsFirstAttempt() {
    var validator = makeValidHostValidator()
    guard case .valid = validator.validate() else {
        Issue.record("first validation must succeed")
        return
    }
    #expect(
        validator.validate()
            == .invalid(stage: .graph, error: .invariantViolation)
    )
}

private func permutationsOfFour() -> [[Int]] {
    var result: [[Int]] = []
    for first in 0 ..< 4 {
        for second in 0 ..< 4 where second != first {
            for third in 0 ..< 4 where third != first && third != second {
                for fourth in 0 ..< 4
                where fourth != first && fourth != second && fourth != third {
                    result.append([first, second, third, fourth])
                }
            }
        }
    }
    return result
}
