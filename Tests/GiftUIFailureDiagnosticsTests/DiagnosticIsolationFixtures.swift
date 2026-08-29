import GiftUIFailureCore

enum DiagnosticDeliveryContext: Equatable {
    case callback
    case interrupt
}

final class DiagnosticAttackSurface {
    enum Stage: Equatable {
        case outcome
        case diagnostic
    }

    private(set) var stage: Stage = .outcome
    private(set) var semanticValue: UInt32 = 41
    private(set) var semanticMutationCount: UInt32 = 0
    private(set) var clientActionInvocationCount: UInt32 = 0
    private(set) var outcomeStageEntryCount: UInt32 = 1
    private(set) var rejectedAttemptCount: UInt32 = 0
    private(set) var deliveryContexts: [DiagnosticDeliveryContext] = []

    func commitOutcomeAndEnterDiagnostics() {
        stage = .diagnostic
    }

    func attemptSemanticMutation(from context: DiagnosticDeliveryContext) {
        deliveryContexts.append(context)
        guard stage == .outcome else {
            rejectedAttemptCount += 1
            return
        }
        semanticValue += 1
        semanticMutationCount += 1
    }

    func attemptClientAction(from context: DiagnosticDeliveryContext) {
        deliveryContexts.append(context)
        guard stage == .outcome else {
            rejectedAttemptCount += 1
            return
        }
        clientActionInvocationCount += 1
    }

    func attemptOutcomeReentry(from context: DiagnosticDeliveryContext) {
        deliveryContexts.append(context)
        guard stage == .outcome else {
            rejectedAttemptCount += 1
            return
        }
        outcomeStageEntryCount += 1
    }
}

struct CallbackAttemptingSink: GiftUIDiagnosticSink {
    let attackSurface: DiagnosticAttackSurface

    mutating func consume(_ record: GiftUIDiagnosticRecord) -> GiftUIDiagnosticSinkResult {
        _ = record
        attackSurface.attemptSemanticMutation(from: .callback)
        attackSurface.attemptClientAction(from: .callback)
        attackSurface.attemptOutcomeReentry(from: .callback)
        return .accepted
    }
}

struct InterruptAttemptingSink: GiftUIDiagnosticSink {
    let attackSurface: DiagnosticAttackSurface

    mutating func consume(_ record: GiftUIDiagnosticRecord) -> GiftUIDiagnosticSinkResult {
        _ = record
        attackSurface.attemptSemanticMutation(from: .interrupt)
        attackSurface.attemptClientAction(from: .interrupt)
        attackSurface.attemptOutcomeReentry(from: .interrupt)
        return .accepted
    }
}
