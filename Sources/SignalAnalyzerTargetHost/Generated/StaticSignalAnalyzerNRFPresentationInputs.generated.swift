// Generated from the portable Signal Analyzer hierarchy and SPEC-015 workload.
// Keep this output synchronized with the SPEC-001 Static Canvas manifest.

import GiftUIDrawing
import GiftUI
import GiftUIExecution
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore
import SignalAnalyzerDomain
import SignalAnalyzerPresentation

package enum StaticSignalAnalyzerNRFSemanticVariant: UInt8, Equatable, Sendable {
    case normal = 0
    case diagnostic = 1
}

package struct StaticSignalAnalyzerNRFGeneratedSemanticSummary: Equatable, Sendable {
    package let variant: StaticSignalAnalyzerNRFSemanticVariant
    package let expansion: SemanticExpansionSummary
    package let structuralOccurrenceCount: UInt16
    package let recordedTraversalIdentityCount: UInt16
    package let canvasOccurrenceCount: UInt16

    fileprivate init(model: borrowing SignalAnalyzerViewModel) {
        if model.state.errorMessage == nil {
            variant = .normal
            expansion = SemanticExpansionSummary(
                semanticNodeCount: 41,
                bodyEvaluationCount: 16,
                modifierApplicationCount: 51,
                actionOccurrenceCount: 3,
                maximumObservedDepth: 40
            )
            structuralOccurrenceCount = 119
            recordedTraversalIdentityCount = 187
        } else {
            variant = .diagnostic
            expansion = SemanticExpansionSummary(
                semanticNodeCount: 41,
                bodyEvaluationCount: 16,
                modifierApplicationCount: 51,
                actionOccurrenceCount: 3,
                maximumObservedDepth: 40
            )
            structuralOccurrenceCount = 119
            recordedTraversalIdentityCount = 187
        }
        canvasOccurrenceCount = 5
    }
}

package struct StaticSignalAnalyzerNRFGeneratedCanvasInput: Sendable {
    package let occurrenceIdentity: UInt16
    package let callableID: UInt16
    package let declaredCaptureByteCount: UInt16
    package let capture: StaticSignalAnalyzerNRFCanvasCaptureStorage
}

/// Scoped generated inputs for one Static presentation derivation. The model
/// handle is valid only for the synchronous body that receives this value.
package struct StaticSignalAnalyzerNRFGeneratedPresentationInputs {
    package let semantic: StaticSignalAnalyzerNRFGeneratedSemanticSummary
    private let model: StaticCanvasObservableModelHandle<SignalAnalyzerViewModel>
    private let visibleRange: Range<Duration>
    private var reserved = false
    private var semanticCandidateStaged = false
    private var generatedUTF8CandidateStaged = false
    private var semanticCandidatePublished = false

    fileprivate init(
        model: StaticCanvasObservableModelHandle<SignalAnalyzerViewModel>,
        semantic: StaticSignalAnalyzerNRFGeneratedSemanticSummary,
        visibleRange: Range<Duration>
    ) {
        self.model = model
        self.semantic = semantic
        self.visibleRange = visibleRange
    }

    package mutating func reserveCandidate(
        in profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> Bool {
        guard !reserved,
            profile.reserve(
                semantic.expansion.maximumObservedDepth,
                for: .semanticCandidateDepth
            ) == .accepted,
            profile.reserve(
                semantic.expansion.semanticNodeCount,
                for: .semanticCandidateNodes
            ) == .accepted,
            profile.reserve(
                semantic.expansion.bodyEvaluationCount,
                for: .semanticCandidateBodies
            ) == .accepted,
            profile.reserve(
                semantic.expansion.modifierApplicationCount,
                for: .semanticCandidateModifiers
            ) == .accepted,
            profile.reserve(
                semantic.expansion.actionOccurrenceCount,
                for: .semanticCandidateActions
            ) == .accepted,
            profile.reserve(
                semantic.canvasOccurrenceCount,
                for: .canvasOccurrences
            ) == .accepted
        else { return false }
        reserved = true
        return true
    }

    package mutating func stageSemanticCandidate(
        in profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> StaticSignalAnalyzerNRFSemanticRegionHeader? {
        guard !semanticCandidateStaged,
            StaticSignalAnalyzerNRFSemanticRegionStore.stageCandidate(
                inputs: &self,
                in: &profile
            )
        else { return nil }
        semanticCandidateStaged = true
        return StaticSignalAnalyzerNRFSemanticRegionStore.header(
            in: .semanticCandidate,
            profile: &profile
        )
    }

    package mutating func stageGeneratedSemanticCandidate(
        in profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> StaticSignalAnalyzerNRFSemanticRegionHeader? {
        guard !semanticCandidateStaged,
            StaticSignalAnalyzerNRFSemanticRegionStore.stageGeneratedUTF8Candidate(
                inputs: &self,
                in: &profile
            )
        else { return nil }
        semanticCandidateStaged = true
        generatedUTF8CandidateStaged = true
        return StaticSignalAnalyzerNRFSemanticRegionStore.header(
            in: .semanticCandidate,
            profile: &profile
        )
    }

    package mutating func publishSemanticCandidate(
        revision: UInt32,
        in profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> StaticSignalAnalyzerNRFSemanticRegionHeader? {
        guard semanticCandidateStaged, !generatedUTF8CandidateStaged,
            !semanticCandidatePublished,
            StaticSignalAnalyzerNRFSemanticRegionStore.publishCandidate(
                inputs: self,
                revision: revision,
                in: &profile
            )
        else { return nil }
        semanticCandidatePublished = true
        return StaticSignalAnalyzerNRFSemanticRegionStore.header(
            in: .semanticPublished,
            profile: &profile
        )
    }

    package mutating func publishGeneratedSemanticCandidate(
        revision: UInt32,
        in profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> StaticSignalAnalyzerNRFSemanticRegionHeader? {
        guard semanticCandidateStaged, generatedUTF8CandidateStaged,
            !semanticCandidatePublished,
            StaticSignalAnalyzerNRFSemanticRegionStore.publishGeneratedUTF8Candidate(
                inputs: self,
                revision: revision,
                in: &profile
            )
        else { return nil }
        semanticCandidatePublished = true
        return StaticSignalAnalyzerNRFSemanticRegionStore.header(
            in: .semanticPublished,
            profile: &profile
        )
    }

    package borrowing func canvasInput(
        at index: UInt16
    ) -> StaticSignalAnalyzerNRFGeneratedCanvasInput? {
        switch index {
        case 0:
            return StaticSignalAnalyzerNRFGeneratedCanvasInput(
                occurrenceIdentity: 1,
                callableID: 1,
                declaredCaptureByteCount: 0,
                capture: StaticSignalAnalyzerNRFCanvasCaptureStorage(
                    StaticSignalAnalyzerNRFGridCanvasCapture()
                )
            )
        case 1 ... 4:
            guard
                let trace = StaticSignalAnalyzerNRFTraceCanvasCapture(
                    model: model,
                    channelID: SignalChannelID(rawValue: Int(index)),
                    visibleRange: visibleRange
                )
            else { return nil }
            return StaticSignalAnalyzerNRFGeneratedCanvasInput(
                occurrenceIdentity: index + 1,
                callableID: 2,
                declaredCaptureByteCount: 32,
                capture: StaticSignalAnalyzerNRFCanvasCaptureStorage(trace)
            )
        default:
            return nil
        }
    }

    /// Generated root-first text values from the same portable presentation.
    /// The ordinal is a semantic scope ordinal, not a text-pool offset.
    package borrowing func actionCode(at index: UInt16) -> UInt16? {
        model.withModel { source in
            switch index {
            case 0: return SignalAnalyzerControlState(acquisitionState: source.state.acquisitionState, selectedWindow: source.state.visibleWindow).recordingAction.rawValue
            case 1: return source.state.visibleWindow.shorterAction.rawValue
            case 2: return source.state.visibleWindow.longerAction.rawValue
            default: return nil
            }
        }
    }

    package borrowing func textInput(at scopeOrdinal: UInt16) -> BoundedText? {
        let range = visibleRange
                return model.withModel { source in
            switch scopeOrdinal {
            case 8: return BoundedText("DIGITAL SIGNAL ANALYZER")
            case 10: return BoundedText("Four-channel acquisition")
            case 13: return source.state.errorMessage?.boundedText ?? BoundedText("")!
            case 22: return SignalAnalyzerControlState(acquisitionState: source.state.acquisitionState, selectedWindow: source.state.visibleWindow).recordingLabel
            case 39: return BoundedText("-")
            case 63: return BoundedText("+")
            case 46, 50, 54:
                let labels = SignalAnalyzerRulerLabels(visibleRange: range)
                switch scopeOrdinal {
                case 46: return labels.lowerBound
                case 50: return labels.midpoint
                default: return labels.upperBound
                }
            case 66: return BoundedText("CH1")
            case 73: return BoundedText("CH2")
            case 80: return BoundedText("CH3")
            case 87: return BoundedText("CH4")
            case 70, 77, 84, 91:
                let channel = Int((scopeOrdinal - 70) / 7) + 1
                return source.state.capture.currentLevel(for: SignalChannelID(rawValue: channel)) == .low ? BoundedText("LOW") : BoundedText("HIGH")
                        default: return nil
            }
        }
    }

    package borrowing func liveModifierInput(at ordinal: UInt16) -> StaticSignalAnalyzerNRFModifierPayload? {
        model.withModel { source in
            let state = source.state
            let controls = SignalAnalyzerControlState(acquisitionState: state.acquisitionState, selectedWindow: state.visibleWindow)
            let color: Color
            let background: Bool
            switch ordinal {
            case 17, 18, 20:
                color = ordinal == 20 ? controls.recordingFill : controls.recordingColor
                background = ordinal != 17
            case 32, 56:
                return StaticSignalAnalyzerNRFModifierPayload(modifier: .passthrough, renderScope: .structural,
                    disablesActions: ordinal == 32 ? state.visibleWindow == .oneSecond : state.visibleWindow == .fiveSeconds)
            case 34, 35, 37, 58, 59, 61:
                let disabled = ordinal < 56 ? state.visibleWindow == .oneSecond : state.visibleWindow == .fiveSeconds
                let fill = ordinal == 37 || ordinal == 61
                color = fill ? (disabled ? Color(red: 24, green: 24, blue: 24) : Color(red: 64, green: 64, blue: 64)) : (disabled ? .gray : .white)
                background = ordinal != 34 && ordinal != 58
            case 69, 76, 83, 90:
                let channel = Int((ordinal - 69) / 7) + 1
                color = state.capture.currentLevel(for: SignalChannelID(rawValue: channel)) == .low ? Color(red: 0, green: 128, blue: 255) : .green
                background = false
            default: return nil
            }
            return StaticSignalAnalyzerNRFModifierPayload(modifier: .passthrough,
                renderScope: background ? .background(color) : .foregroundStyle(color))
        }
    }

    package borrowing func stageCanvas(
        at index: UInt16,
        in profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> StaticCanvasOccurrence<UInt16, StaticSignalAnalyzerNRFCanvasCaptureStorage>? {
        guard reserved, let input = canvasInput(at: index) else { return nil }
        return profile.stageCanvas(
            identity: input.occurrenceIdentity,
            callableID: input.callableID,
            declaredCaptureByteCount: input.declaredCaptureByteCount,
            capture: input.capture
        )
    }
}

package typealias StaticSignalAnalyzerNRFProductionMetadata =
    StaticSignalAnalyzerNRFGeneratedMetadata<StaticSignalAnalyzerNRFCanvasCallableTable>

package typealias StaticSignalAnalyzerNRFProductionProfileBinding =
    StaticRuntimeProfileBinding<
        StaticSignalAnalyzerNRFProfileRegions,
        StaticSignalAnalyzerNRFProductionMetadata
    >

package enum StaticSignalAnalyzerNRFGeneratedPresentationInputFactory {
    package static func withInputs<Result>(
        model: borrowing SignalAnalyzerViewModel,
        _ body: (inout StaticSignalAnalyzerNRFGeneratedPresentationInputs) -> Result
    ) -> Result {
        let semantic = StaticSignalAnalyzerNRFGeneratedSemanticSummary(model: model)
        let visibleRange = model.visibleRange
        return withUnsafePointer(to: model) { location in
            var inputs = StaticSignalAnalyzerNRFGeneratedPresentationInputs(
                model: StaticCanvasObservableModelHandle(hostOwnedLocation: location),
                semantic: semantic,
                visibleRange: visibleRange
            )
            return body(&inputs)
        }
    }
}
