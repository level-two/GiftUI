import GiftUI
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIHostConfiguration

package enum StaticSignalAnalyzerNRFPacedApplicationResult: Equatable, Sendable {
    case noWork
    case wait(untilMicroseconds: UInt64)
    case completed(
        reasons: ExecutionWakeReasons,
        result: StaticSignalAnalyzerNRFApplicationOpportunityResult
    )
    case rejected(HostWakePacingError)
}

package enum StaticSignalAnalyzerNRFPacedPresentationResult: Equatable, Sendable {
    case noWork
    case wait(untilMicroseconds: UInt64)
    case pacingRejected(HostWakePacingError)
    case freshConstructionRequired(HostFreshConstructionReason)
    case profileBeginRejected(ExecutionError)
    case profileFinishRejected(ExecutionError)
    case completed(
        reasons: ExecutionWakeReasons,
        application: StaticSignalAnalyzerNRFApplicationOpportunityResult,
        presentation: StaticSignalAnalyzerNRFPresentationTransactionResult?,
        health: StaticSignalAnalyzerNRFPresentationHealthResult
    )
}

/// Services application work at one generated frame boundary, with an entry
/// that also retains pacing and profile ownership through presentation.
package enum StaticSignalAnalyzerNRFPacedApplicationStage {
    /// Keeps the paced opportunity and attempt-local profile regions active
    /// until application work and its physical presentation have both ended.
    package static func serviceAndPresent<Target: DisplayTarget>(
        at timestampMicroseconds: UInt64,
        application: inout StaticSignalAnalyzerNRFApplicationOwner,
        profile: inout StaticSignalAnalyzerNRFProductionProfileBinding,
        pacing: inout HostWakePacingController,
        health: inout HostEndpointHealthController,
        endpoint: inout StaticSignalAnalyzerNRFEndpoint<Target>,
        provenance: FrameProvenance,
        renderSnapshotVersion: UInt32,
        presentationRevision: PresentationRevision
    ) -> StaticSignalAnalyzerNRFPacedPresentationResult {
        if health.requiresFreshConstruction {
            return .freshConstructionRequired(
                health.freshConstructionReason ?? .terminalUnavailability
            )
        }
        switch pacing.schedule(at: timestampMicroseconds) {
        case .noWork:
            return .noWork
        case .wait(let boundary):
            return .wait(untilMicroseconds: boundary)
        case .invalid(let error):
            return .pacingRejected(error)
        case .run:
            break
        }

        let reasons: ExecutionWakeReasons
        switch pacing.beginOpportunity(at: timestampMicroseconds) {
        case .began(let value):
            reasons = value
        case .rejected(let error):
            return .pacingRejected(error)
        }
        let active = ExecutionContext(
            cycle: provenance.cycle,
            semanticRevision: provenance.semanticRevision,
            candidateFrame: nil,
            phase: .admitting
        )
        if let error = profile.beginOpportunity(context: active) {
            if let pacingError = pacing.completeOpportunity(at: timestampMicroseconds) {
                return .pacingRejected(pacingError)
            }
            return .profileBeginRejected(error)
        }

        let applicationResult = application.runApplicationOpportunity()
        let presentation: StaticSignalAnalyzerNRFPresentationTransactionResult?
        if case .completed = applicationResult {
            presentation = StaticSignalAnalyzerNRFPresentationTransaction.present(
                application: application,
                profile: &profile,
                endpoint: &endpoint,
                provenance: provenance,
                renderSnapshotVersion: renderSnapshotVersion,
                presentationRevision: presentationRevision
            )
        } else {
            presentation = nil
        }
        let healthResult = StaticSignalAnalyzerNRFPresentationHealth.reconcile(
            presentation: presentation,
            endpoint: endpoint,
            application: &application,
            controller: &health
        )

        let idle = ExecutionContext(
            cycle: nil,
            semanticRevision: nil,
            candidateFrame: nil,
            phase: .idle
        )
        let profileError = profile.finishOpportunity(context: idle)
        let pacingError = pacing.completeOpportunity(at: timestampMicroseconds)
        if let pacingError { return .pacingRejected(pacingError) }
        if let profileError { return .profileFinishRejected(profileError) }
        return .completed(
            reasons: reasons,
            application: applicationResult,
            presentation: presentation,
            health: healthResult
        )
    }

    package static func service(
        at timestampMicroseconds: UInt64,
        application: inout StaticSignalAnalyzerNRFApplicationOwner,
        pacing: inout HostWakePacingController
    ) -> StaticSignalAnalyzerNRFPacedApplicationResult {
        switch pacing.schedule(at: timestampMicroseconds) {
        case .noWork:
            return .noWork
        case .wait(let boundary):
            return .wait(untilMicroseconds: boundary)
        case .invalid(let error):
            return .rejected(error)
        case .run:
            break
        }

        let reasons: ExecutionWakeReasons
        switch pacing.beginOpportunity(at: timestampMicroseconds) {
        case .began(let value):
            reasons = value
        case .rejected(let error):
            return .rejected(error)
        }
        let result = application.runApplicationOpportunity()
        if let error = pacing.completeOpportunity(at: timestampMicroseconds) {
            return .rejected(error)
        }
        return .completed(reasons: reasons, result: result)
    }
}
