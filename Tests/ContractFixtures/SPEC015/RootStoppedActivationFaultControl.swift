import GiftUI
import GiftUIObservableState

// A focused host-side failure control, not an authored model or a target resource
// claim. Observation storage exists outside the tested model/root activation.
private final class RetirementTrace {
    var events: [String] = []
}

private enum FaultSchema: _GiftUIModelSchema {
    typealias Seed = UInt8
}

private struct ObservedSink: ~Copyable {
    var sink: _GiftUIObservableChangeSink
    let trace: RetirementTrace

    var attachment: _GiftUIObservationAttachment { sink.attachment }

    deinit { trace.events.append("sink-destroyed") }

    mutating func report() -> _GiftUIObservableChangeReportOutcome {
        sink.reportChange()
    }
}

private struct FaultModel: ~Copyable, ObservableStateModel {
    typealias Schema = FaultSchema
    let trace: RetirementTrace?
    let refusesDetach: Bool
    private var sink: ObservedSink?

    init(trace: RetirementTrace?, refusesDetach: Bool) {
        self.trace = trace
        self.refusesDetach = refusesDetach
    }

    static func materialize(_ seed: UInt8) -> Self {
        Self(trace: nil, refusesDetach: false)
    }

    var isEmptyReplacement: Bool { true }

    mutating func attach(_ sink: consuming _GiftUIObservableChangeSink)
        -> _GiftUIObservationAttachment?
    {
        guard let trace else { preconditionFailure("missing fixture observer") }
        let attachment = sink.attachment
        self.sink = ObservedSink(sink: consume sink, trace: trace)
        trace.events.append("attached")
        return attachment
    }

    mutating func detach(_ attachment: _GiftUIObservationAttachment) -> Bool {
        guard sink?.attachment == attachment else { return false }
        if refusesDetach {
            trace?.events.append("detach-refused")
            return false
        }
        sink = nil
        trace?.events.append("detached")
        return true
    }

    mutating func reportChange() -> _GiftUIObservableChangeReportOutcome {
        sink?.report() ?? .coalesced
    }

    deinit { trace?.events.append("model-destroyed") }
}

private enum ControlCase: CaseIterable, Equatable {
    case baseline
    case detachFailure
    case retiredUnregisterFailure
}

private func runControl(_ controlCase: ControlCase) throws(ObservableStateError) -> Int {
    let trace = RetirementTrace()
    var namespace = ObservableModelOwnerNamespace()
    var ownership = ObservableModelOwnership(
        identity: try namespace.issue(), captureLimit: 0)!
    var backing: InlineArray<2, FaultModel?> = .init { _ in nil }
    var span = backing.mutableSpan
    var assertions = 0

    try withObservableModelScope(
        ownership: &ownership, models: &span, schema: 1, needsCapture: false
    ) {
        (models: borrowing ObservableModelScope<FaultModel, FaultSchema>)
            throws(ObservableStateError) in
        var original = try models.materialize(
            FaultModel(trace: trace, refusesDetach: controlCase != .baseline))
        let key = original.key
        // This independent claim deliberately outlives the root callback. Without
        // stopped-activation cleanup, failed detach leaves the model/sink alive.
        var independent = try models.retain(key)
        var state = State<FaultSchema>(candidate: key)
        var identities: InlineArray<2, UInt32?> = .init(repeating: nil)
        var identitySpan = identities.mutableSpan
        var rootControl = ObservableStateRootControl()

        try models.withRoot(identities: &identitySpan, control: &rootControl) {
            root throws(ObservableStateError) in
            try models.beginFrame()
            try models.withDiscovery {
                () throws(ObservableStateError) in
                precondition(root.beginCandidate() == .success(.candidateStarted))
                precondition(
                    root.encounter(
                        identity: UInt32(7), ordinal: 0, state: &state,
                        transferring: &original) == .success(.materialized))
                precondition(root.finishCandidate(.publish) == .success(.associationsCommitted))
                assertions += 3
            }
            try models.endFrame()
            try models.validateTicket(independent)
            precondition(independent.key == key)
            assertions += 1

            if controlCase == .retiredUnregisterFailure {
                models.requireStop()
                do throws(ObservableStateError) {
                    try models.unregister(key)
                    preconditionFailure("retired unregister unexpectedly succeeded")
                } catch {
                    precondition(error == .invalidPhaseSafetyNotProven)
                    trace.events.append("unregister-refused")
                    assertions += 1
                }
            }

            do throws(ObservableStateError) {
                try root.shutdown()
                precondition(controlCase == .baseline)
                trace.events.append("shutdown-succeeded")
            } catch {
                precondition(controlCase != .baseline && error == .invariantViolation)
                // The same returning catch action used by the counter pipeline.
                models.requireStop()
                trace.events.append("shutdown-failed")
            }
            assertions += 1
            precondition(!trace.events.contains("model-destroyed"))
            precondition(trace.events.contains("sink-destroyed") == (controlCase == .baseline))
            assertions += 2
            trace.events.append("root-body-returning")
        }

        trace.events.append("root-returned")
        // The ticket value is still present. Its key is owned metadata; reading
        // it does not invoke the model, root report pointer, or revoked claim.
        precondition(independent.key == key)
        assertions += 1
        if controlCase == .baseline {
            precondition(!trace.events.contains("model-destroyed"))
            try models.release(&independent)
            precondition(trace.events.last == "model-destroyed")
            assertions += 2
        } else {
            precondition(models.report(key) == .invalidPhaseSafetyNotProven)
            let sinkDestroyed = trace.events.firstIndex(of: "sink-destroyed")!
            let bodyReturning = trace.events.firstIndex(of: "root-body-returning")!
            let rootReturned = trace.events.firstIndex(of: "root-returned")!
            precondition(bodyReturning < sinkDestroyed && sinkDestroyed < rootReturned)
            precondition(trace.events.filter { $0 == "model-destroyed" }.count == 1)
            precondition(trace.events.filter { $0 == "sink-destroyed" }.count == 1)
            assertions += 4
            // A stopped activation has already revoked the independent claim.
            // Do not release it through a retired scope or invoke a retained sink.
        }
    }
    precondition(trace.events.filter { $0 == "model-destroyed" }.count == 1)
    precondition(trace.events.filter { $0 == "sink-destroyed" }.count == 1)
    return assertions + 2
}

@main
private struct RootStoppedActivationFaultControl {
    static func main() throws {
        var assertions = 0
        for controlCase in ControlCase.allCases {
            assertions += try runControl(controlCase)
        }
        print(
            "PASS root-stopped-activation baseline=1 detach-failure=1 retired-unregister-failure=1 assertions=\(assertions)"
        )
    }
}
