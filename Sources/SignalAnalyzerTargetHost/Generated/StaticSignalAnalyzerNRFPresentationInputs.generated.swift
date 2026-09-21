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
                semanticNodeCount: 47,
                bodyEvaluationCount: 14,
                modifierApplicationCount: 49,
                actionOccurrenceCount: 6,
                maximumObservedDepth: 34
            )
            structuralOccurrenceCount = 124
            recordedTraversalIdentityCount = 201
        } else {
            variant = .diagnostic
            expansion = SemanticExpansionSummary(
                semanticNodeCount: 48,
                bodyEvaluationCount: 14,
                modifierApplicationCount: 50,
                actionOccurrenceCount: 6,
                maximumObservedDepth: 34
            )
            structuralOccurrenceCount = 126
            recordedTraversalIdentityCount = 203
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

    package mutating func publishSemanticCandidate(
        revision: UInt32,
        in profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> StaticSignalAnalyzerNRFSemanticRegionHeader? {
        guard semanticCandidateStaged, !semanticCandidatePublished,
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
    package borrowing func textInput(at scopeOrdinal: UInt16) -> BoundedText? {
        switch scopeOrdinal {
        case 6: return BoundedText("DIGITAL SIGNAL ANALYZER")
        case 8: return BoundedText("Four-channel acquisition")
        case 36: return BoundedText("CH1")
        case 45: return BoundedText("CH2")
        case 54: return BoundedText("CH3")
        case 63: return BoundedText("CH4")
        case 75: return BoundedText("Start")
        case 79: return BoundedText("Stop")
        case 82: return BoundedText("Clear")
        case 87: return BoundedText("1 s")
        case 91: return BoundedText("2 s")
        case 95: return BoundedText("5 s")
        default:
            let range = visibleRange
            let variant = semantic.variant
            return model.withModel { source in
                switch scopeOrdinal {
                case 13:
                    return SignalAnalyzerControlState(
                        acquisitionState: source.state.acquisitionState,
                        selectedWindow: source.state.visibleWindow
                    ).statusText
                case 25, 28, 31:
                    let labels = SignalAnalyzerRulerLabels(visibleRange: range)
                    switch scopeOrdinal {
                    case 25: return labels.lowerBound
                    case 28: return labels.midpoint
                    default: return labels.upperBound
                    }
                case 40, 49, 58, 67:
                    let channel: Int
                    switch scopeOrdinal {
                    case 40: channel = 1
                    case 49: channel = 2
                    case 58: channel = 3
                    default: channel = 4
                    }
                    switch source.state.capture.currentLevel(
                        for: SignalChannelID(rawValue: channel)
                    ) {
                    case .low: return BoundedText("LOW")
                    case .high: return BoundedText("HIGH")
                    }
                case 97 where variant == .diagnostic:
                    return source.state.errorMessage?.boundedText
                default:
                    return nil
                }
            }
        }
    }

    package borrowing func liveModifierInput(
        at scopeOrdinal: UInt16
    ) -> StaticSignalAnalyzerNRFModifierPayload? {
        return model.withModel { source in
            let state = source.state
            switch scopeOrdinal {
            case 12:
                let color: Color
                switch state.acquisitionState {
                case .running: color = .green
                case .failed: color = .red
                case .idle, .stopped: color = .white
                }
                return StaticSignalAnalyzerNRFModifierPayload(
                    modifier: .passthrough,
                    renderScope: .foregroundStyle(color)
                )
            case 39, 48, 57, 66:
                let channel: Int
                switch scopeOrdinal {
                case 39: channel = 1
                case 48: channel = 2
                case 57: channel = 3
                default: channel = 4
                }
                let color: Color
                switch state.capture.currentLevel(
                    for: SignalChannelID(rawValue: channel)
                ) {
                case .low: color = Color(red: 0, green: 128, blue: 255)
                case .high: color = .green
                }
                return StaticSignalAnalyzerNRFModifierPayload(
                    modifier: .passthrough,
                    renderScope: .foregroundStyle(color)
                )
            case 72, 76, 84, 88, 92:
                let controls = SignalAnalyzerControlState(
                    acquisitionState: state.acquisitionState,
                    selectedWindow: state.visibleWindow
                )
                let disabled: Bool
                switch scopeOrdinal {
                case 72: disabled = controls.startDisabled
                case 76: disabled = controls.stopDisabled
                case 84: disabled = controls.oneSecondDisabled
                case 88: disabled = controls.twoSecondsDisabled
                default: disabled = controls.fiveSecondsDisabled
                }
                return StaticSignalAnalyzerNRFModifierPayload(
                    modifier: .passthrough,
                    renderScope: .structural,
                    disablesActions: disabled
                )
            default:
                return nil
            }
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
