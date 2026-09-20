import GiftUI
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIHostConfiguration

private enum DynamicSignalAnalyzerPiUnusedFact: Sendable {
    case unsupported
}

private struct DynamicSignalAnalyzerPiInputQueue: ExecutionAdmissionSink {
    typealias StateChangeFact = DynamicSignalAnalyzerPiUnusedFact
    typealias CompletionFact = DynamicSignalAnalyzerPiUnusedFact

    let capacity: UInt16
    let context: ExecutionContext
    private var events: [NormalizedPointerEvent] = []
    private var isAvailable = true

    init(capacity: UInt16, context: ExecutionContext) {
        self.capacity = capacity
        self.context = context
        events.reserveCapacity(Int(capacity))
    }

    mutating func submit(pointer: NormalizedPointerEvent) -> ExecutionAdmissionOutcome {
        guard isAvailable else { return outcome(.unavailable) }
        guard events.count < Int(capacity) else { return outcome(.capacityRefused) }
        events.append(pointer)
        return outcome(.queued)
    }

    mutating func submit(
        stateChange _: DynamicSignalAnalyzerPiUnusedFact
    ) -> ExecutionAdmissionOutcome {
        outcome(.invalidValue)
    }

    mutating func submit(
        completion _: DynamicSignalAnalyzerPiUnusedFact
    ) -> ExecutionAdmissionOutcome {
        outcome(.invalidValue)
    }

    mutating func takeAll() -> [NormalizedPointerEvent] {
        defer { events.removeAll(keepingCapacity: true) }
        return events
    }

    mutating func quiesce() {
        isAvailable = false
        events.removeAll(keepingCapacity: true)
    }

    private func outcome(_ result: ExecutionAdmissionResult) -> ExecutionAdmissionOutcome {
        ExecutionAdmissionOutcome(result: result, context: context)
    }
}

package struct DynamicSignalAnalyzerPiInputDrainSummary: Equatable, Sendable {
    package let eventCount: UInt16
    package let dispatchedActionCount: UInt16
    package let cancelledOrRejectedCount: UInt16

    package init(
        eventCount: UInt16,
        dispatchedActionCount: UInt16,
        cancelledOrRejectedCount: UInt16
    ) {
        self.eventCount = eventCount
        self.dispatchedActionCount = dispatchedActionCount
        self.cancelledOrRejectedCount = cancelledOrRejectedCount
    }
}

package enum DynamicSignalAnalyzerPiInputOpportunityResult: Equatable, Sendable {
    case completed(DynamicSignalAnalyzerPiInputDrainSummary)
    case rejected(HostApplicationOpportunityRejection)
}

/// Connects target-normalized pointer phases to bounded execution admission.
/// Queued input mutates the model only inside the owned serialized opportunity.
package struct DynamicSignalAnalyzerPiInputCoordinator {
    private var gate: HostNormalizedInputGate
    private var queue: DynamicSignalAnalyzerPiInputQueue
    private var opportunityGate = HostApplicationOpportunityGate()

    package init(
        source: InputSourceID,
        capacity: UInt16,
        context: ExecutionContext
    ) {
        gate = HostNormalizedInputGate(configuredSource: source)
        queue = DynamicSignalAnalyzerPiInputQueue(
            capacity: capacity,
            context: context
        )
    }

    package var inputIsEligible: Bool { gate.inputIsEligible }

    package mutating func installPhysicalPresentation(
        _ revision: PresentationRevision
    ) {
        gate.installPhysicalPresentation(revision)
    }

    package mutating func admit(
        phase: PointerPhase,
        position: Point,
        source: InputSourceID,
        observedPresentationRevision: PresentationRevision?,
        isMalformed: Bool = false,
        priorPhysicalSequenceIsComplete: Bool = false
    ) -> HostNormalizedInputDisposition {
        gate.submit(
            phase: phase,
            position: position,
            source: source,
            observedPresentationRevision: observedPresentationRevision,
            isMalformed: isMalformed,
            priorPhysicalSequenceIsComplete: priorPhysicalSequenceIsComplete,
            to: &queue
        )
    }

    package mutating func runOpportunity<Target>(
        into owner: inout DynamicSignalAnalyzerPiInitialPresentationOwner<Target>
    ) -> DynamicSignalAnalyzerPiInputOpportunityResult
    where Target: DisplayTarget {
        switch opportunityGate.begin() {
        case .admitted:
            break
        case .rejected(let rejection):
            return .rejected(rejection)
        }
        defer { _ = opportunityGate.complete() }

        let events = queue.takeAll()
        var dispatched: UInt16 = 0
        var cancelledOrRejected: UInt16 = 0
        for event in events {
            switch owner.handle(event) {
            case .dispatched(.dispatched):
                dispatched += 1
            case .cancelled, .rejected, .dispatched:
                cancelledOrRejected += 1
            case .captured, .continued, .ignored:
                break
            }
        }
        return .completed(
            DynamicSignalAnalyzerPiInputDrainSummary(
                eventCount: UInt16(events.count),
                dispatchedActionCount: dispatched,
                cancelledOrRejectedCount: cancelledOrRejected
            )
        )
    }

    package mutating func quiesce() {
        _ = opportunityGate.quiesce()
        gate.quiesce()
        queue.quiesce()
    }
}
