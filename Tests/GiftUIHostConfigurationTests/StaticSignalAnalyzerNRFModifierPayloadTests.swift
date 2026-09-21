import GiftUI
import GiftUISemanticCore
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFModifierPayloadRejectsUnsupportedOrIncoherentShapes() {
    let insets = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)!
    #expect(
        StaticSignalAnalyzerNRFModifierPayload(
            modifier: .paddingInsets(insets),
            renderScope: .structural
        ) == nil
    )
    #expect(
        StaticSignalAnalyzerNRFModifierPayload(
            modifier: .flexibleFrame(
                minWidth: 1,
                maxWidth: .points(2),
                minHeight: 3,
                maxHeight: .points(4),
                alignment: .center
            ),
            renderScope: .clipBoundary
        ) == nil
    )
    #expect(
        StaticSignalAnalyzerNRFModifierPayload(
            modifier: .fixedFrame(width: 120, height: 16, alignment: .center),
            renderScope: .foregroundStyle(.red)
        ) == nil
    )
    #expect(
        StaticSignalAnalyzerNRFModifierPayload(
            modifier: .padding(edges: .all, length: 4),
            renderScope: .clipBoundary
        ) == nil
    )
    #expect(
        StaticSignalAnalyzerNRFModifierPayload(
            modifier: .passthrough,
            renderScope: .foregroundStyle(.white),
            disablesActions: true
        ) == nil
    )
    #expect(
        StaticSignalAnalyzerNRFModifierPayload(
            modifier: .padding(edges: .all, length: 4),
            renderScope: .structural,
            disablesActions: true
        ) == nil
    )
    let disabled = StaticSignalAnalyzerNRFModifierPayload(
        modifier: .passthrough,
        renderScope: .structural,
        disablesActions: true
    )
    #expect(disabled?.decoded()?.2 == true)
}
