import GiftUI
import GiftUISemanticCore
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFPrimitivePayloadRejectsWrongAssociationOrScalarRange() {
    #expect(
        StaticSignalAnalyzerNRFPrimitivePayload(
            primitive: .text,
            renderScope: .text,
            textStart: 138,
            textCount: 2
        ) == nil
    )
    #expect(
        StaticSignalAnalyzerNRFPrimitivePayload(
            primitive: .canvas,
            renderScope: .canvas
        ) == nil
    )
    #expect(
        StaticSignalAnalyzerNRFPrimitivePayload(
            primitive: .canvas,
            renderScope: .canvas,
            canvasOccurrence: 6
        ) == nil
    )
    #expect(
        StaticSignalAnalyzerNRFPrimitivePayload(
            primitive: .vStack(alignment: .leading, spacing: 4),
            renderScope: .foregroundStyle(.white)
        ) == nil
    )
    #expect(
        StaticSignalAnalyzerNRFPrimitivePayload(
            primitive: .proxy,
            renderScope: .structural,
            textCount: 1
        ) == nil
    )
}
