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

/// Services the application stage at one generated frame boundary. The full
/// presentation transaction remains the caller's next stage in this cycle.
package enum StaticSignalAnalyzerNRFPacedApplicationStage {
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
