// Exact modifier payload packing for the current portable Signal Analyzer tree.
// Unsupported modifier shapes fail closed instead of changing the Static region.

import GiftUI
import GiftUISemanticCore

package struct StaticSignalAnalyzerNRFModifierPayload: Equatable, Sendable {
    package let flags: UInt8
    package let auxiliary: UInt16
    package let payload0: UInt32
    package let payload1: UInt32
    package let payload2: UInt32

    private static let passthrough: UInt8 = 1
    private static let padding: UInt8 = 2
    private static let fixedFrame: UInt8 = 3
    private static let flexibleFrame: UInt8 = 4
    private static let structural: UInt8 = 0
    private static let clip: UInt8 = 1
    private static let foreground: UInt8 = 2
    private static let background: UInt8 = 3

    package init?(
        modifier: SemanticLayoutModifier,
        renderScope: SemanticRenderScope
    ) {
        let renderCode: UInt8
        let colorWord: UInt32
        switch renderScope {
        case .structural:
            renderCode = Self.structural
            colorWord = 0
        case .clipBoundary:
            renderCode = Self.clip
            colorWord = 0
        case .foregroundStyle(let color):
            renderCode = Self.foreground
            colorWord = Self.pack(color)
        case .background(let color):
            renderCode = Self.background
            colorWord = Self.pack(color)
        default:
            return nil
        }

        switch modifier {
        case .passthrough:
            guard renderCode != Self.clip else { return nil }
            flags = Self.passthrough | renderCode << 3
            auxiliary = 0
            payload0 = colorWord
            payload1 = 0
            payload2 = 0
        case .padding(let edges, let length):
            guard renderCode == Self.structural,
                edges.rawValue & ~EdgeSet.all.rawValue == 0
            else { return nil }
            flags = Self.padding
            auxiliary = UInt16(edges.rawValue)
            payload0 = UInt32(bitPattern: length)
            payload1 = 0
            payload2 = 0
        case .fixedFrame(let width, let height, let alignment):
            guard renderCode == Self.clip else { return nil }
            flags = Self.fixedFrame | Self.clip << 3
            var bits = Self.alignmentBits(alignment) << 2
            if width != nil { bits |= 1 }
            if height != nil { bits |= 2 }
            auxiliary = bits
            payload0 = width.map { UInt32(bitPattern: $0) } ?? 0
            payload1 = height.map { UInt32(bitPattern: $0) } ?? 0
            payload2 = 0
        case .flexibleFrame(
            let minWidth,
            let maxWidth,
            let minHeight,
            let maxHeight,
            let alignment
        ):
            guard renderCode == Self.clip else { return nil }
            flags = Self.flexibleFrame | Self.clip << 3
            var bits = Self.alignmentBits(alignment) << 6
            var first: UInt32 = 0
            var second: UInt32 = 0
            var third: UInt32 = 0
            var count: UInt8 = 0
            if let minWidth {
                bits |= 1
                guard Self.append(minWidth, to: &first, &second, &third, count: &count)
                else { return nil }
            }
            if let maxWidth {
                switch maxWidth {
                case .points(let value):
                    bits |= 2
                    guard Self.append(value, to: &first, &second, &third, count: &count)
                    else { return nil }
                case .infinity:
                    bits |= 4
                }
            }
            if let minHeight {
                bits |= 8
                guard Self.append(minHeight, to: &first, &second, &third, count: &count)
                else { return nil }
            }
            if let maxHeight {
                switch maxHeight {
                case .points(let value):
                    bits |= 16
                    guard Self.append(value, to: &first, &second, &third, count: &count)
                    else { return nil }
                case .infinity:
                    bits |= 32
                }
            }
            auxiliary = bits
            payload0 = first
            payload1 = second
            payload2 = third
        case .paddingInsets:
            return nil
        }
    }

    package func decoded() -> (SemanticLayoutModifier, SemanticRenderScope)? {
        guard flags & 0xC0 == 0 else { return nil }
        let kind = flags & 7
        let renderCode = (flags >> 3) & 7
        let render: SemanticRenderScope
        switch renderCode {
        case Self.structural: render = .structural
        case Self.clip: render = .clipBoundary
        case Self.foreground:
            guard kind == Self.passthrough else { return nil }
            render = .foregroundStyle(Self.unpack(payload0))
        case Self.background:
            guard kind == Self.passthrough else { return nil }
            render = .background(Self.unpack(payload0))
        default: return nil
        }
        switch kind {
        case Self.passthrough:
            guard auxiliary == 0, payload1 == 0, payload2 == 0,
                renderCode != Self.clip,
                (renderCode != Self.structural || payload0 == 0),
                payload0 & 0xFF00_0000 == 0
            else { return nil }
            return (.passthrough, render)
        case Self.padding:
            guard renderCode == Self.structural,
                auxiliary <= UInt16(EdgeSet.all.rawValue),
                payload1 == 0, payload2 == 0
            else { return nil }
            return (
                .padding(
                    edges: EdgeSet(rawValue: UInt8(auxiliary)),
                    length: Int32(bitPattern: payload0)
                ),
                render
            )
        case Self.fixedFrame:
            guard renderCode == Self.clip, auxiliary & ~UInt16(0x1F) == 0,
                payload2 == 0,
                let alignment = Self.alignment(from: auxiliary >> 2),
                (auxiliary & 1 != 0 || payload0 == 0),
                (auxiliary & 2 != 0 || payload1 == 0)
            else { return nil }
            return (
                .fixedFrame(
                    width: auxiliary & 1 != 0 ? Int32(bitPattern: payload0) : nil,
                    height: auxiliary & 2 != 0 ? Int32(bitPattern: payload1) : nil,
                    alignment: alignment
                ),
                render
            )
        case Self.flexibleFrame:
            guard renderCode == Self.clip,
                auxiliary & ~UInt16(0x1FF) == 0,
                auxiliary & 6 != 6,
                auxiliary & 48 != 48,
                let alignment = Self.alignment(from: auxiliary >> 6)
            else { return nil }
            var used: UInt8 = 0
            func next() -> Int32? {
                let value: UInt32
                switch used {
                case 0: value = payload0
                case 1: value = payload1
                case 2: value = payload2
                default: return nil
                }
                used += 1
                return Int32(bitPattern: value)
            }
            let minWidth = auxiliary & 1 != 0 ? next() : nil
            let maxWidth: FrameLimit?
            if auxiliary & 2 != 0 {
                guard let value = next() else { return nil }
                maxWidth = .points(value)
            } else {
                maxWidth = auxiliary & 4 != 0 ? .infinity : nil
            }
            let minHeight = auxiliary & 8 != 0 ? next() : nil
            let maxHeight: FrameLimit?
            if auxiliary & 16 != 0 {
                guard let value = next() else { return nil }
                maxHeight = .points(value)
            } else {
                maxHeight = auxiliary & 32 != 0 ? .infinity : nil
            }
            guard used <= 3,
                (used > 0 || payload0 == 0),
                (used > 1 || payload1 == 0),
                (used > 2 || payload2 == 0),
                (auxiliary & 1 == 0 || minWidth != nil),
                (auxiliary & 8 == 0 || minHeight != nil)
            else { return nil }
            return (
                .flexibleFrame(
                    minWidth: minWidth,
                    maxWidth: maxWidth,
                    minHeight: minHeight,
                    maxHeight: maxHeight,
                    alignment: alignment
                ),
                render
            )
        default:
            return nil
        }
    }

    private static func alignmentBits(_ alignment: Alignment) -> UInt16 {
        UInt16(alignment.horizontal.rawValue)
            | UInt16(alignment.vertical.rawValue) << 1
    }

    private static func alignment(from bits: UInt16) -> Alignment? {
        guard bits < 6,
            let horizontal = HorizontalAlignment(rawValue: UInt8(bits & 1)),
            let vertical = VerticalAlignment(rawValue: UInt8(bits >> 1))
        else { return nil }
        return Alignment(horizontal: horizontal, vertical: vertical)
    }

    private static func pack(_ color: Color) -> UInt32 {
        UInt32(color.red) | UInt32(color.green) << 8 | UInt32(color.blue) << 16
    }

    private static func unpack(_ word: UInt32) -> Color {
        Color(
            red: UInt8(truncatingIfNeeded: word),
            green: UInt8(truncatingIfNeeded: word >> 8),
            blue: UInt8(truncatingIfNeeded: word >> 16)
        )
    }

    private static func append(
        _ value: Int32,
        to first: inout UInt32,
        _ second: inout UInt32,
        _ third: inout UInt32,
        count: inout UInt8
    ) -> Bool {
        switch count {
        case 0: first = UInt32(bitPattern: value)
        case 1: second = UInt32(bitPattern: value)
        case 2: third = UInt32(bitPattern: value)
        default: return false
        }
        count += 1
        return true
    }
}
