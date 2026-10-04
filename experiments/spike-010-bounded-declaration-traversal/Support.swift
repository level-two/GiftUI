// Disposable bounded snapshot lowering; it does not implement State attachment.
import GiftUI
import GiftUISemanticCore
import SignalAnalyzerDomain
import SignalAnalyzerPresentation

package struct SignalCapture: Equatable, @unchecked Sendable {
    package let transitions: UnsafeBufferPointer<SignalTransition>
    package let duration: Duration
    package static func empty() -> Self {
        Self(transitions: UnsafeBufferPointer(start: nil, count: 0), duration: .zero)
    }
    package func baselineLevel(for channel: SignalChannelID) -> DigitalLevel { .low }
    package static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.transitions.baseAddress == rhs.transitions.baseAddress
            && lhs.transitions.count == rhs.transitions.count && lhs.duration == rhs.duration
    }
}

package struct SignalAnalyzerViewModel {
    package let state: SignalAnalyzerViewState
    package var visibleRange: Range<Duration> {
        let end = max(state.visibleWindow.duration, state.capture.duration)
        return max(.zero, end - state.visibleWindow.duration)..<end
    }
}

private struct BoundedWorkspace: SemanticExpansionWorkspace {
    let maximumPathComponents: UInt16 = 64
    let maximumIdentities: UInt16 = 2_048
    var isExpanding = false
    var depth: UInt16 = 0
    var next: UInt16 = 0
    mutating func beginExpansion() -> Bool {
        guard !isExpanding else { return false }
        isExpanding = true; depth = 0; next = 0; return true
    }
    private mutating func enter(_ identity: inout UInt16?) -> SemanticExpansionError? {
        guard depth < maximumPathComponents, next < maximumIdentities else { return .capacityExhausted }
        depth += 1; identity = next; next += 1; return nil
    }
    mutating func enterRoot<D: View>(_ type: D.Type, identity: inout UInt16?) -> SemanticExpansionError? { enter(&identity) }
    mutating func enterCustomBody<D: View>(_ type: D.Type, identity: inout UInt16?) -> SemanticExpansionError? { enter(&identity) }
    mutating func enterDeclarationRole<D>(_ type: D.Type, identity: inout UInt16?) -> SemanticExpansionError? { enter(&identity) }
    mutating func enterFixedChild(_ index: UInt8, identity: inout UInt16?) -> SemanticExpansionError? { enter(&identity) }
    mutating func enterConditionalBranch(_ index: UInt8, identity: inout UInt16?) -> SemanticExpansionError? { enter(&identity) }
    mutating func enterOptionalPresence(identity: inout UInt16?) -> SemanticExpansionError? { enter(&identity) }
    mutating func leavePathComponent() { depth -= 1 }
    mutating func completeExpansion() {}
    mutating func discardExpansion() { depth = 0 }
    mutating func resetExpansion() { isExpanding = false; depth = 0 }
}

private struct CountingSink: SemanticExpansionSink {
    let maximumStructuralOccurrences: UInt16 = 512
    let maximumBodyEvaluations: UInt16 = 512
    let maximumSemanticOccurrences: UInt16 = 512
    let maximumModifierApplications: UInt16 = 512
    let maximumActionOccurrences: UInt16 = 32
    var texts: UInt16 = 0
    var canvases: UInt16 = 0
    var actions: UInt16 = 0
    var scopes: UInt16 = 0
    var published = false
    mutating func beginExpansion() -> Bool { texts = 0; canvases = 0; actions = 0; scopes = 0; published = false; return true }
    mutating func stageStructuralOccurrence(identity: borrowing UInt16) -> Bool { true }
    mutating func stageBodyEvaluation(identity: borrowing UInt16) -> Bool { true }
    mutating func stageSemanticOccurrence<P: _GiftUISemanticPrimitivePayload>(identity: borrowing UInt16, payload: borrowing P) -> Bool {
        scopes += 1
        let primitive = SemanticLayoutPrimitive(payload: payload)
        if primitive == .text { texts += 1 }
        if primitive == .canvas { canvases += 1 }
        return true
    }
    mutating func stageModifierApplication<P: _GiftUISemanticModifierPayload>(identity: borrowing UInt16, payload: borrowing P, chainIndex: UInt16) -> Bool {
        scopes += 1
        let payloadCopy = copy payload
        return SemanticLayoutModifier(payload: payload) != nil || payloadCopy is DisabledSemanticPayload
    }
    mutating func stageActionOccurrence<A: GiftUIAction>(identity: borrowing UInt16, action: borrowing A) -> Bool {
        scopes += 1; actions += 1; return true
    }
    mutating func publishExpansion(_ summary: SemanticExpansionSummary) -> Bool { published = true; return true }
    mutating func discardExpansion() { scopes = 0; published = false }
    mutating func resetExpansion() {}
}

@_cdecl("giftui_spike010_derive")
public func spike010Derive(_ state: UInt32, _ window: UInt32, _ diagnostic: UInt32,
                          _ populated: UInt32, _ depth: UInt16, _ nodes: UInt16) -> UInt32 {
    let diagnosticText: StaticString = "diagnostic"
    let error = diagnosticText.withUTF8Buffer { SignalAnalyzerDiagnostic(exactUTF8: $0)! }
    let acquisition: AcquisitionState = switch state {
    case 0: .idle
    case 1: .running
    case 2: .stopped
    default: .failed(error)
    }
    let selected: VisibleTimeWindow = switch window {
    case 0: .oneSecond
    case 1: .twoSeconds
    default: .fiveSeconds
    }
    var records = (
        SignalTransition(channelID: SignalChannelID(rawValue: 1), timestamp: .milliseconds(17_300), level: .low),
        SignalTransition(channelID: SignalChannelID(rawValue: 2), timestamp: .milliseconds(17_300), level: .high),
        SignalTransition(channelID: SignalChannelID(rawValue: 3), timestamp: .milliseconds(17_300), level: .low),
        SignalTransition(channelID: SignalChannelID(rawValue: 4), timestamp: .milliseconds(17_300), level: .high))
    return withUnsafePointer(to: &records) { tuple in
        tuple.withMemoryRebound(to: SignalTransition.self, capacity: 4) { pointer in
            let capture = SignalCapture(transitions: UnsafeBufferPointer(start: pointer, count: populated == 0 ? 0 : 4),
                                        duration: populated == 0 ? .zero : .milliseconds(17_300))
            let model = SignalAnalyzerViewModel(state: SignalAnalyzerViewState(acquisitionState: acquisition,
                capture: capture, visibleWindow: selected, errorMessage: diagnostic == 0 ? nil : error))
            var workspace = BoundedWorkspace()
            var sink = CountingSink()
            let limits = SemanticExpansionLimits(maximumDepth: depth, maximumSemanticNodes: nodes,
                maximumBodyEvaluations: 512, maximumModifierApplications: 512, maximumActionOccurrences: 32)!
            let result = expandSemanticTree(SignalAnalyzerView(viewModel: model), limits: limits, workspace: &workspace, sink: &sink)
            guard case .success(let summary) = result else {
                return !workspace.isExpanding && !sink.published && sink.scopes == 0 ? 0 : UInt32.max
            }
            guard summary.semanticNodeCount == 41, summary.modifierApplicationCount == 51,
                  summary.bodyEvaluationCount == 16, sink.scopes == 92,
                  sink.texts == 17, sink.canvases == 5, sink.actions == 3, sink.published else { return UInt32.max }
            return 92
        }
    }
}
