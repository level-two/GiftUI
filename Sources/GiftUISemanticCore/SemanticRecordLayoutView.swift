import GiftUI

/// Finite payload codecs project bounded values; they cannot evaluate bodies or
/// resolve models. Canvas's separately owned codec uses the same consumer seam.

extension SemanticStandardPayload {
    package var layoutPrimitive: SemanticLayoutPrimitive? {
        switch self {
        case .vStack(let value): .vStack(alignment: value.alignment, spacing: value.spacing)
        case .hStack(let value): .hStack(alignment: value.alignment, spacing: value.spacing)
        case .zStack(let value): .zStack(alignment: value.alignment)
        case .spacer(let value): .spacer(minLength: value.minLength)
        case .text: .text
        case .action: .proxy
        default: nil
        }
    }
    package var layoutModifier: SemanticLayoutModifier? {
        switch self {
        case .padding(let value): .padding(edges: value.edges, length: value.length)
        case .insets(let value): .paddingInsets(value.insets)
        case .fixedFrame(let value):
            .fixedFrame(width: value.width, height: value.height, alignment: value.alignment)
        case .flexibleFrame(let value):
            .flexibleFrame(
                minWidth: value.minWidth, maxWidth: value.maxWidth, minHeight: value.minHeight,
                maxHeight: value.maxHeight, alignment: value.alignment)
        case .foreground, .background, .disabled: .passthrough
        default: nil
        }
    }
    package var renderScope: SemanticRenderScope {
        switch self {
        case .text: .text
        case .fixedFrame, .flexibleFrame: .clipBoundary
        case .foreground(let color): .foregroundStyle(color)
        case .background(let color): .background(color)
        default: .structural
        }
    }
}

/// This view contains only a scoped borrow of the canonical record bank. Each
/// modifier record is its own one-modifier wrapper, including passthrough style
/// scopes. Transparent declaration records add neither scope nor layout depth.
package struct SemanticRecordLayoutView:
    SemanticLayoutView, BitwiseCopyable, ~Escapable
{
    private let view: SemanticRecordView
    @_lifetime(copy view)
    package init(_ view: borrowing SemanticRecordView) { self.view = copy view }
    package var rootIdentity: SemanticRecordReference { view.rootReference }
    package var scopeCount: UInt16 {
        var count: UInt16 = 0
        for index in 0 ..< view.recordCount {
            if let reference = view.reference(at: index), let record = view.record(reference),
                record.kind != .structural
            {
                count += 1
            }
        }
        return count
    }
    package func primitive(at identity: SemanticRecordReference) -> SemanticLayoutPrimitive? {
        guard let record = view.record(identity),
            record.kind == .primitive || record.kind == .action,
            let payload = view.payload(at: record.payload)
        else { return nil }
        return payload.layoutPrimitive
    }
    package func childCount(of identity: SemanticRecordReference) -> UInt16? {
        guard let record = view.record(identity) else { return nil }
        var cursor = record.firstChild
        var count: UInt16 = 0
        while cursor != .max {
            guard let child = view.reference(at: cursor), let next = view.record(child),
                next.parent == identity.ordinal, cursor > identity.ordinal
            else { return nil }
            count += 1
            guard next.nextSibling == .max || next.nextSibling > cursor else { return nil }
            cursor = next.nextSibling
        }
        return count
    }
    package func child(of identity: SemanticRecordReference, at index: UInt16)
        -> SemanticRecordReference?
    {
        guard let record = view.record(identity) else { return nil }
        var cursor = record.firstChild
        var offset: UInt16 = 0
        while cursor != .max {
            guard let child = view.reference(at: cursor), let next = view.record(child),
                next.parent == identity.ordinal, cursor > identity.ordinal
            else { return nil }
            if offset == index { return child }
            offset += 1
            guard next.nextSibling == .max || next.nextSibling > cursor else { return nil }
            cursor = next.nextSibling
        }
        return nil
    }
    package func modifierCount(of identity: SemanticRecordReference) -> UInt16? {
        guard let record = view.record(identity) else { return nil }
        return record.kind == .modifier ? 1 : 0
    }
    package func modifierScope(of identity: SemanticRecordReference, at index: UInt16)
        -> SemanticRecordReference?
    {
        guard index == 0, view.record(identity)?.kind == .modifier else { return nil }
        return identity
    }
    package func modifier(of identity: SemanticRecordReference, at index: UInt16)
        -> SemanticLayoutModifier?
    {
        guard index == 0, let record = view.record(identity), record.kind == .modifier,
            let payload = view.payload(at: record.payload)
        else { return nil }
        return payload.layoutModifier
    }
    package func textScalarCount(of identity: SemanticRecordReference) -> UInt16? {
        guard primitive(at: identity) == .text, let record = view.record(identity) else {
            return nil
        }
        return record.textScalarCount
    }
    package func textScalar(of identity: SemanticRecordReference, at index: UInt16) -> UInt32? {
        guard let count = textScalarCount(of: identity), index < count,
            let record = view.record(identity)
        else { return nil }
        let offset = UInt32(record.firstTextScalar) + UInt32(index)
        guard offset < UInt32(view.scalarCount) else { return nil }
        return view.scalar(at: UInt16(offset))
    }
}
