import GiftUI

/// Render independently borrows the same bank while consuming owned geometry.
/// Structural records are skipped using the bank's own parent/sibling links;
/// no projected node table or retained Layout borrow is created.
package struct SemanticRecordRenderView<Payload: SemanticRecordConsumerPayload>:
    SemanticRenderView, ~Escapable
{
    private let view: SemanticRecordView<Payload>
    @_lifetime(copy view)
    package init(_ view: borrowing SemanticRecordView<Payload>) { self.view = copy view }
    package var rootIdentity: SemanticRecordReference {
        semanticIdentity(at: 0) ?? view.rootReference
    }
    package var semanticScopeCount: UInt16 { SemanticRecordLayoutView(view).scopeCount }
    package var renderSnapshotVersion: UInt32 { view.revision }
    package func semanticIdentity(at ordinal: UInt16) -> SemanticRecordReference? {
        var count: UInt16 = 0
        for index in 0 ..< view.recordCount {
            guard let reference = view.reference(at: index), let record = view.record(reference)
            else { return nil }
            if record.kind != .structural {
                if count == ordinal { return reference }
                count += 1
            }
        }
        return nil
    }
    package func semanticOrdinal(of identity: SemanticRecordReference) -> UInt16? {
        guard let record = view.record(identity), record.kind != .structural else { return nil }
        var count: UInt16 = 0
        for index in 0 ..< identity.ordinal {
            guard let reference = view.reference(at: index), let record = view.record(reference)
            else { return nil }
            if record.kind != .structural { count += 1 }
        }
        return count
    }
    package func scope(at identity: SemanticRecordReference) -> SemanticRenderScope? {
        guard let record = view.record(identity), record.kind != .structural,
            let payload = view.payload(at: record.payload)
        else { return nil }
        return payload.renderScope
    }
    package func layoutIdentity(for identity: SemanticRecordReference) -> SemanticRecordReference? {
        scope(at: identity) == nil ? nil : identity
    }
    private func firstScope(_ ordinal: UInt16) -> SemanticRecordReference? {
        guard let reference = view.reference(at: ordinal), let record = view.record(reference)
        else { return nil }
        if record.kind != .structural { return reference }
        var child = record.firstChild
        while child != .max {
            guard let childReference = view.reference(at: child),
                let next = view.record(childReference), child > ordinal
            else { return nil }
            if let scope = firstScope(child) { return scope }
            guard next.nextSibling == .max || next.nextSibling > child else { return nil }
            child = next.nextSibling
        }
        return nil
    }
    private func nextScope(
        after reference: SemanticRecordReference, under parent: SemanticRecordReference
    ) -> SemanticRecordReference? {
        var cursor = reference
        while cursor != parent {
            guard let record = view.record(cursor) else { return nil }
            var sibling = record.nextSibling
            while sibling != .max {
                guard sibling > cursor.ordinal, let next = view.reference(at: sibling),
                    let nextRecord = view.record(next)
                else { return nil }
                if let scope = firstScope(sibling) { return scope }
                sibling = nextRecord.nextSibling
            }
            guard record.parent < cursor.ordinal, let next = view.reference(at: record.parent)
            else { return nil }
            cursor = next
        }
        return nil
    }
    package func child(of identity: SemanticRecordReference, at index: UInt16)
        -> SemanticRecordReference?
    {
        guard scope(at: identity) != nil, let record = view.record(identity) else { return nil }
        var cursor = firstScope(record.firstChild)
        // A transparent empty first child may have following nonempty siblings.
        if cursor == nil, let first = view.reference(at: record.firstChild) {
            cursor = nextScope(after: first, under: identity)
        }
        var offset: UInt16 = 0
        while let current = cursor {
            if offset == index { return current }
            offset += 1
            cursor = nextScope(after: current, under: identity)
        }
        return nil
    }
    package func childCount(of identity: SemanticRecordReference) -> UInt16? {
        guard scope(at: identity) != nil else { return nil }
        var count: UInt16 = 0
        while child(of: identity, at: count) != nil { count += 1 }
        return count
    }
}
