import GiftUIRuntimeCore
import GiftUITextResources
import Testing

@testable import GiftUIHostConfiguration

@Test func validProfileAndTextProjectionsReachACompleteReport() {
    var validator = makeValidHostValidator()
    guard case .valid(let report) = validator.validate() else {
        Issue.record("exact fixture must pass all currently implemented stages")
        return
    }
    #expect(report.kind == .nrf52840Static)
    #expect(report.profile == .static)
    #expect(report.storageAudit.profile == .static)
    #expect(report.maximumCompactFactsPerServiceWindow == 28)
}

@Test func everyRuntimeProfileErrorIsPreservedAtItsOwnedStage() {
    let errors: [RuntimeProfileValidationError] = [
        .invalidLimits,
        .incompatibleLimits,
        .missingStorage,
        .insufficientStorage,
        .arithmeticOverflow,
        .staticCanvasTableInvalid,
        .invariantViolation,
    ]

    for error in errors {
        var validator = makeValidHostValidator(
            runtimeProfileValidation: .invalid(error)
        )
        #expect(
            validator.validate()
                == .invalid(
                    stage: .runtimeProfile,
                    error: .invalidRuntimeProfile(error)
                )
        )
    }
}

@Test func everyTextResourceErrorIsPreservedAtItsOwnedStage() {
    let errors: [TextResourceValidationError] = [
        .unsupportedSchema,
        .capacityExceeded,
        .invalidCount,
        .invalidIdentity,
        .incompatibleViews,
        .malformedMetrics,
        .malformedMapping,
        .malformedRasterRecord,
        .integrityMismatch,
    ]

    for error in errors {
        var validator = makeValidHostValidator(
            textResourceValidation: .invalid(error)
        )
        #expect(
            validator.validate()
                == .invalid(
                    stage: .textResources,
                    error: .invalidTextResources(error)
                )
        )
    }
}
