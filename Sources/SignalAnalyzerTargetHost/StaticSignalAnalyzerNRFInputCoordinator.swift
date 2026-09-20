import GiftUI
import GiftUIExecution
import GiftUIHostConfiguration

private enum StaticSignalAnalyzerNRFUnusedFact: Sendable {
    case unsupported
}

package enum StaticSignalAnalyzerNRFInputHandling: UInt8, Equatable, Sendable {
    case consumed = 0
    case dispatched = 1
    case cancelledOrRejected = 2
}

package protocol StaticSignalAnalyzerNRFInputHandler {
    mutating func handle(
        _ event: NormalizedPointerEvent
    ) -> StaticSignalAnalyzerNRFInputHandling
}

package struct StaticSignalAnalyzerNRFInputDrainSummary: Equatable, Sendable {
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

package enum StaticSignalAnalyzerNRFInputOpportunityResult: Equatable, Sendable {
    case completed(StaticSignalAnalyzerNRFInputDrainSummary)
    case rejected(HostApplicationOpportunityRejection)
}

private struct StaticSignalAnalyzerNRFInputQueue: ExecutionAdmissionSink {
    typealias StateChangeFact = StaticSignalAnalyzerNRFUnusedFact
    typealias CompletionFact = StaticSignalAnalyzerNRFUnusedFact

    static let capacity: UInt16 = 6

    let context: ExecutionContext
    private var values:
        (
            NormalizedPointerEvent?, NormalizedPointerEvent?,
            NormalizedPointerEvent?, NormalizedPointerEvent?,
            NormalizedPointerEvent?, NormalizedPointerEvent?
        ) = (nil, nil, nil, nil, nil, nil)
    private var head: UInt8 = 0
    private var tail: UInt8 = 0
    private(set) var count: UInt16 = 0
    private var isAvailable = true

    init(context: ExecutionContext) {
        self.context = context
    }

    mutating func submit(pointer: NormalizedPointerEvent) -> ExecutionAdmissionOutcome {
        guard isAvailable else { return outcome(.unavailable) }
        guard count < Self.capacity else { return outcome(.capacityRefused) }
        set(pointer, at: tail)
        tail = successor(of: tail)
        count += 1
        return outcome(.queued)
    }

    mutating func submit(
        stateChange _: StaticSignalAnalyzerNRFUnusedFact
    ) -> ExecutionAdmissionOutcome {
        outcome(.invalidValue)
    }

    mutating func submit(
        completion _: StaticSignalAnalyzerNRFUnusedFact
    ) -> ExecutionAdmissionOutcome {
        outcome(.invalidValue)
    }

    mutating func takeNext() -> NormalizedPointerEvent? {
        guard count > 0 else { return nil }
        let event = value(at: head)
        set(nil, at: head)
        head = successor(of: head)
        count -= 1
        return event
    }

    mutating func quiesce() {
        isAvailable = false
        values = (nil, nil, nil, nil, nil, nil)
        head = 0
        tail = 0
        count = 0
    }

    private func outcome(_ result: ExecutionAdmissionResult) -> ExecutionAdmissionOutcome {
        ExecutionAdmissionOutcome(result: result, context: context)
    }

    private func successor(of index: UInt8) -> UInt8 {
        index == UInt8(Self.capacity - 1) ? 0 : index + 1
    }

    private func value(at index: UInt8) -> NormalizedPointerEvent? {
        switch index {
        case 0: values.0
        case 1: values.1
        case 2: values.2
        case 3: values.3
        case 4: values.4
        case 5: values.5
        default: nil
        }
    }

    private mutating func set(_ value: NormalizedPointerEvent?, at index: UInt8) {
        switch index {
        case 0: values.0 = value
        case 1: values.1 = value
        case 2: values.2 = value
        case 3: values.3 = value
        case 4: values.4 = value
        case 5: values.5 = value
        default: break
        }
    }
}

/// Owns target provenance and fixed-capacity admission for normalized nRF
/// contacts. Device decoding and model dispatch remain outside this owner.
package struct StaticSignalAnalyzerNRFInputCoordinator {
    package static var capacity: UInt16 { StaticSignalAnalyzerNRFInputQueue.capacity }

    private var gate: HostNormalizedInputGate
    private var queue: StaticSignalAnalyzerNRFInputQueue
    private var opportunityGate = HostApplicationOpportunityGate()

    package init(
        source: InputSourceID,
        context: ExecutionContext,
        nextSubmittedSequenceRaw: UInt32? = 0
    ) {
        gate = HostNormalizedInputGate(
            configuredSource: source,
            nextSubmittedSequenceRaw: nextSubmittedSequenceRaw
        )
        queue = StaticSignalAnalyzerNRFInputQueue(context: context)
    }

    package var inputIsEligible: Bool { gate.inputIsEligible }
    package var pendingCount: UInt16 { queue.count }

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

    package mutating func runOpportunity<Handler>(
        into handler: inout Handler
    ) -> StaticSignalAnalyzerNRFInputOpportunityResult
    where Handler: StaticSignalAnalyzerNRFInputHandler {
        switch opportunityGate.begin() {
        case .admitted:
            break
        case .rejected(let rejection):
            return .rejected(rejection)
        }
        defer { _ = opportunityGate.complete() }

        var eventCount: UInt16 = 0
        var dispatchedActionCount: UInt16 = 0
        var cancelledOrRejectedCount: UInt16 = 0
        while let event = queue.takeNext() {
            eventCount += 1
            switch handler.handle(event) {
            case .consumed:
                break
            case .dispatched:
                dispatchedActionCount += 1
            case .cancelledOrRejected:
                cancelledOrRejectedCount += 1
            }
        }
        return .completed(
            StaticSignalAnalyzerNRFInputDrainSummary(
                eventCount: eventCount,
                dispatchedActionCount: dispatchedActionCount,
                cancelledOrRejectedCount: cancelledOrRejectedCount
            )
        )
    }

    package mutating func quiesce() {
        guard opportunityGate.quiesce() == nil else { return }
        gate.quiesce()
        queue.quiesce()
    }
}
