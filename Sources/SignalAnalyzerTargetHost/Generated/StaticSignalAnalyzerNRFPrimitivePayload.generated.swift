// Exact primitive payload packing for the current portable Signal Analyzer tree.

import GiftUI
import GiftUISemanticCore

package struct StaticSignalAnalyzerNRFPrimitivePayload: Equatable, Sendable {
    package let kind: StaticSignalAnalyzerNRFScopeKind
    package let auxiliary: UInt16
    package let payload0: UInt32
    package let payload1: UInt32
    package let payload2: UInt32

    package init?(
        primitive: SemanticLayoutPrimitive,
        renderScope: SemanticRenderScope,
        textStart: UInt16 = 0,
        textCount: UInt16 = 0,
        canvasOccurrence: UInt16? = nil
    ) {
        switch primitive {
        case .proxy:
            guard renderScope == .structural,
                textStart == 0, textCount == 0, canvasOccurrence == nil
            else { return nil }
            kind = .proxy
            auxiliary = 0
            payload0 = 0
            payload1 = 0
            payload2 = 0
        case .vStack(let alignment, let spacing):
            guard renderScope == .structural,
                textStart == 0, textCount == 0, canvasOccurrence == nil
            else { return nil }
            kind = .vStack
            auxiliary = UInt16(alignment.rawValue)
            payload0 = UInt32(bitPattern: spacing)
            payload1 = 0
            payload2 = 0
        case .hStack(let alignment, let spacing):
            guard renderScope == .structural,
                textStart == 0, textCount == 0, canvasOccurrence == nil
            else { return nil }
            kind = .hStack
            auxiliary = UInt16(alignment.rawValue)
            payload0 = UInt32(bitPattern: spacing)
            payload1 = 0
            payload2 = 0
        case .zStack(let alignment):
            guard renderScope == .structural,
                textStart == 0, textCount == 0, canvasOccurrence == nil
            else { return nil }
            kind = .zStack
            auxiliary = UInt16(alignment.horizontal.rawValue)
                | UInt16(alignment.vertical.rawValue) << 8
            payload0 = 0
            payload1 = 0
            payload2 = 0
        case .spacer(let minLength):
            guard renderScope == .structural,
                textStart == 0, textCount == 0, canvasOccurrence == nil
            else { return nil }
            kind = .spacer
            auxiliary = 0
            payload0 = UInt32(bitPattern: minLength)
            payload1 = 0
            payload2 = 0
        case .text:
            guard renderScope == .text,
                canvasOccurrence == nil,
                Int(textStart) + Int(textCount)
                    <= Int(StaticSignalAnalyzerNRFPackedSemanticRecords.maximumScalarCount)
            else { return nil }
            kind = .text
            auxiliary = 0
            payload0 = UInt32(textStart)
            payload1 = UInt32(textCount)
            payload2 = 0
        case .canvas:
            guard renderScope == .canvas,
                textStart == 0, textCount == 0,
                let canvasOccurrence, (1...5).contains(canvasOccurrence)
            else { return nil }
            kind = .canvas
            auxiliary = 0
            payload0 = UInt32(canvasOccurrence)
            payload1 = 0
            payload2 = 0
        }
    }

    package func decoded() -> (
        primitive: SemanticLayoutPrimitive,
        renderScope: SemanticRenderScope,
        textStart: UInt16,
        textCount: UInt16,
        canvasOccurrence: UInt16?
    )? {
        switch kind {
        case .proxy:
            guard auxiliary == 0, payload0 == 0, payload1 == 0, payload2 == 0
            else { return nil }
            return (.proxy, .structural, 0, 0, nil)
        case .vStack:
            guard let alignment = HorizontalAlignment(rawValue: UInt8(truncatingIfNeeded: auxiliary)),
                auxiliary <= UInt16(UInt8.max), payload1 == 0, payload2 == 0
            else { return nil }
            return (.vStack(alignment: alignment, spacing: Int32(bitPattern: payload0)), .structural, 0, 0, nil)
        case .hStack:
            guard let alignment = VerticalAlignment(rawValue: UInt8(truncatingIfNeeded: auxiliary)),
                auxiliary <= UInt16(UInt8.max), payload1 == 0, payload2 == 0
            else { return nil }
            return (.hStack(alignment: alignment, spacing: Int32(bitPattern: payload0)), .structural, 0, 0, nil)
        case .zStack:
            guard payload0 == 0, payload1 == 0, payload2 == 0,
                let horizontal = HorizontalAlignment(rawValue: UInt8(truncatingIfNeeded: auxiliary)),
                let vertical = VerticalAlignment(rawValue: UInt8(truncatingIfNeeded: auxiliary >> 8))
            else { return nil }
            return (
                .zStack(alignment: Alignment(horizontal: horizontal, vertical: vertical)),
                .structural, 0, 0, nil
            )
        case .spacer:
            guard auxiliary == 0, payload1 == 0, payload2 == 0 else { return nil }
            return (.spacer(minLength: Int32(bitPattern: payload0)), .structural, 0, 0, nil)
        case .text:
            guard auxiliary == 0, payload2 == 0,
                payload0 <= UInt32(StaticSignalAnalyzerNRFPackedSemanticRecords.maximumScalarCount),
                payload1 <= UInt32(StaticSignalAnalyzerNRFPackedSemanticRecords.maximumScalarCount) - payload0
            else { return nil }
            return (.text, .text, UInt16(payload0), UInt16(payload1), nil)
        case .canvas:
            guard auxiliary == 0, (1...5).contains(payload0),
                payload1 == 0, payload2 == 0
            else { return nil }
            return (.canvas, .canvas, 0, 0, UInt16(payload0))
        case .modifier:
            return nil
        }
    }
}
