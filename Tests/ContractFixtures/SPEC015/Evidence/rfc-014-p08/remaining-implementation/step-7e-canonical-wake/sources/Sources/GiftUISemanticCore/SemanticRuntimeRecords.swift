import GiftUI

/// A finite type-role codec may be generated; occurrence positions may not.
package protocol SemanticDeclarationRoles {
    static func role<Declaration>(of declaration: Declaration.Type) -> SemanticRecordingRole?
    static func modifierDiscriminator<Declaration>(of declaration: Declaration.Type) -> UInt16
}

package struct SemanticPathComponent: Equatable, Sendable {
    package enum Kind: UInt8, Sendable {
        case root, customBody, fixedChild, conditionalBranch, optionalPresence, declarationRole
    }
    package let kind: Kind
    package let ordinal: UInt8
    package let role: UInt16
    package let modifier: UInt16

    package init(kind: Kind, ordinal: UInt8 = 0, role: UInt16 = 0, modifier: UInt16 = 0) {
        self.kind = kind
        self.ordinal = ordinal
        self.role = role
        self.modifier = modifier
    }
    package var isValid: Bool {
        switch kind {
        case .fixedChild: ordinal < 5 && role == 0 && modifier == 0
        case .conditionalBranch: ordinal < 2 && role == 0 && modifier == 0
        case .declarationRole: ordinal == 0 && role != 0
        default: ordinal == 0 && role == 0 && modifier == 0
        }
    }
}

/// Complete owned key for the approved depth-34 profile. It never contains a
/// bank index or address. Configurations exceeding its physical extent refuse
/// before activation; a future extent change needs the corresponding audit.
package struct SemanticCompleteIdentity: Equatable, Sendable {
    package static let capacity: UInt16 = 34
    private var components: InlineArray<34, SemanticPathComponent> = .init(
        repeating: .init(kind: .root))
    package private(set) var count: UInt16 = 0
    package init() {}
    package func component(at index: UInt16) -> SemanticPathComponent? {
        guard index < count else { return nil }
        return components[Int(index)]
    }
    package mutating func append(_ component: SemanticPathComponent) -> Bool {
        guard count < Self.capacity, component.isValid, (count == 0) == (component.kind == .root)
        else { return false }
        components[Int(count)] = component
        count += 1
        return true
    }
    package mutating func removeLast() {
        precondition(count > 0)
        count -= 1
    }
    package static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count else { return false }
        var i: UInt16 = 0
        while i < lhs.count {
            if lhs.components[Int(i)] != rhs.components[Int(i)] { return false }
            i += 1
        }
        return true
    }
}

package struct SemanticRecordLimits: Equatable, Sendable {
    package let records: UInt16
    package let paths: UInt16
    package let depth: UInt16
    package let fanout: UInt16
    package let payloads: UInt16
    package let textScalars: UInt16
    package let payloadBytes: UInt32
    package init?(
        records: UInt16, paths: UInt16, depth: UInt16, fanout: UInt16,
        payloads: UInt16, textScalars: UInt16, payloadBytes: UInt32
    ) {
        guard records > 0, paths > 0, depth > 0, depth <= SemanticCompleteIdentity.capacity,
            fanout > 0
        else { return nil }
        self.records = records
        self.paths = paths
        self.depth = depth
        self.fanout = fanout
        self.payloads = payloads
        self.textScalars = textScalars
        self.payloadBytes = payloadBytes
    }
}

/// UInt16.max is the absent-link sentinel and is never an initialized index.
package struct SemanticPathEntry: Sendable {
    package var component = SemanticPathComponent(kind: .root)
    package var parent: UInt16 = .max
    package var firstChild: UInt16 = .max
    package var lastChild: UInt16 = .max
    package var nextSibling: UInt16 = .max
    package var childCount: UInt16 = 0
    package var depth: UInt16 = 0
    package var nearestRecord: UInt16 = .max
    /// Reconciliation scratch, valid only for the compared published revision.
    package var matchedPath: UInt16 = .max
    package init() {}
}

package struct SemanticRuntimeRecord: Sendable {
    package enum Kind: UInt8, Sendable {
        case structural, primitive, action, modifier, pendingCanvas
    }
    package var parent: UInt16 = .max
    package var firstChild: UInt16 = .max
    package var lastChild: UInt16 = .max
    package var nextSibling: UInt16 = .max
    package var path: UInt16 = .max
    package var kind: Kind = .structural
    package var payload: UInt16 = .max
    package var firstTextScalar: UInt16 = 0
    package var textScalarCount: UInt16 = 0
    package var modifierChainIndex: UInt16 = 0
    package init() {}
}

package struct SemanticRecordOwnerIdentity: Equatable, Sendable {
    package let rawValue: UInt32
    fileprivate init(_ rawValue: UInt32) { self.rawValue = rawValue }
}

/// Host assembly keeps this namespace across store teardown and reconstruction.
package struct SemanticRecordOwnerNamespace: ~Copyable {
    private var next: UInt32? = 0
    package init() {}
    package mutating func issue() throws(SemanticExpansionError) -> SemanticRecordOwnerIdentity {
        guard let value = next else { throw .invalidIdentity }
        let successor = value.addingReportingOverflow(1)
        next = successor.overflow ? nil : successor.partialValue
        return SemanticRecordOwnerIdentity(value)
    }
}

package struct SemanticRecordReference: Equatable, Sendable {
    package let owner: SemanticRecordOwnerIdentity
    package let bank: UInt8
    package let revision: UInt32
    package let ordinal: UInt16
}

package struct SemanticRecordBankMetadata {
    package enum Phase: UInt8 { case idle, expanding, candidate, published, retired }
    package var phase: Phase = .idle
    package var revision: UInt32 = 0
    package var readers: UInt16 = 0
    package var records: UInt16 = 0
    package var paths: UInt16 = 0
    package var payloads: UInt16 = 0
    package var scalars: UInt16 = 0
    package var payloadBytes: UInt32 = 0
    package var activePath: UInt16 = .max
    package var matchedRevision: UInt32 = 0
    package var componentComparisons: UInt32 = 0
    package var summary: SemanticExpansionSummary?
    package var failure: SemanticExpansionError?
    package init() {}
}

/// Trusted profile adapter input. Each typed buffer is fully initialized,
/// pairwise disjoint and stable for the complete enclosing storage lifetime.
/// Only scoped store/view APIs expose its contents to consumers.
package struct SemanticRecordBankBuffers<Payload> {
    package let metadata: UnsafeMutablePointer<SemanticRecordBankMetadata>
    package let records: UnsafeMutableBufferPointer<SemanticRuntimeRecord>
    package let paths: UnsafeMutableBufferPointer<SemanticPathEntry>
    package let payloads: UnsafeMutableBufferPointer<Payload?>
    package let scalars: UnsafeMutableBufferPointer<UInt32>
    package init(
        metadata: UnsafeMutablePointer<SemanticRecordBankMetadata>,
        records: UnsafeMutableBufferPointer<SemanticRuntimeRecord>,
        paths: UnsafeMutableBufferPointer<SemanticPathEntry>,
        payloads: UnsafeMutableBufferPointer<Payload?>, scalars: UnsafeMutableBufferPointer<UInt32>
    ) {
        self.metadata = metadata
        self.records = records
        self.paths = paths
        self.payloads = payloads
        self.scalars = scalars
    }
    package func fits(_ limits: SemanticRecordLimits) -> Bool {
        records.count >= Int(limits.records) && paths.count >= Int(limits.paths)
            && payloads.count >= Int(limits.payloads) && scalars.count >= Int(limits.textScalars)
    }

    package func clear() {
        precondition(metadata.pointee.readers == 0)
        for index in 0 ..< Int(metadata.pointee.payloads) { payloads[index] = nil }
        let revision = metadata.pointee.revision
        metadata.pointee = SemanticRecordBankMetadata()
        metadata.pointee.revision = revision
    }

    package func fail(_ failure: SemanticExpansionError) -> SemanticExpansionError {
        if metadata.pointee.failure == nil { metadata.pointee.failure = failure }
        return metadata.pointee.failure!
    }

    package func enter(_ component: SemanticPathComponent, limits: SemanticRecordLimits)
        -> SemanticExpansionError?
    {
        guard metadata.pointee.phase == .expanding else { return fail(.invariantViolation) }
        if let failure = metadata.pointee.failure { return failure }
        let parent = metadata.pointee.activePath
        guard component.isValid,
            (parent == .max) == (component.kind == .root),
            parent == .max || parent < metadata.pointee.paths
        else { return fail(.invalidIdentity) }
        let depth = parent == .max ? 1 : UInt32(paths[Int(parent)].depth) + 1
        guard depth <= limits.depth, metadata.pointee.paths < limits.paths else {
            return fail(.capacityExhausted)
        }
        if parent != .max {
            guard paths[Int(parent)].childCount < limits.fanout else {
                return fail(.capacityExhausted)
            }
            var child = paths[Int(parent)].firstChild
            while child != .max {
                guard child < metadata.pointee.paths else { return fail(.invalidIdentity) }
                if paths[Int(child)].component == component { return fail(.invalidIdentity) }
                child = paths[Int(child)].nextSibling
            }
        } else if metadata.pointee.paths != 0 {
            return fail(.invalidIdentity)
        }
        let index = metadata.pointee.paths
        var entry = SemanticPathEntry()
        entry.component = component
        entry.parent = parent
        entry.depth = UInt16(depth)
        if parent != .max {
            entry.nearestRecord = paths[Int(parent)].nearestRecord
            let last = paths[Int(parent)].lastChild
            if last == .max {
                paths[Int(parent)].firstChild = index
            } else {
                paths[Int(last)].nextSibling = index
            }
            paths[Int(parent)].lastChild = index
            paths[Int(parent)].childCount += 1
        }
        paths[Int(index)] = entry
        metadata.pointee.paths += 1
        metadata.pointee.activePath = index
        return nil
    }

    package func leave() {
        let path = metadata.pointee.activePath
        guard path < metadata.pointee.paths else {
            _ = fail(.invalidIdentity)
            return
        }
        metadata.pointee.activePath = paths[Int(path)].parent
    }

    package func appendRecord(limits: SemanticRecordLimits) -> SemanticExpansionError? {
        if let failure = metadata.pointee.failure { return failure }
        let path = metadata.pointee.activePath
        guard metadata.pointee.phase == .expanding, path < metadata.pointee.paths,
            paths[Int(path)].component.kind == .declarationRole
        else { return fail(.invalidIdentity) }
        guard metadata.pointee.records < limits.records else { return fail(.capacityExhausted) }
        let index = metadata.pointee.records
        let parent = paths[Int(path)].nearestRecord
        var record = SemanticRuntimeRecord()
        record.path = path
        record.parent = parent
        if parent != .max {
            guard parent < index else { return fail(.invalidIdentity) }
            let last = records[Int(parent)].lastChild
            if last == .max {
                records[Int(parent)].firstChild = index
            } else {
                records[Int(last)].nextSibling = index
            }
            records[Int(parent)].lastChild = index
        } else if index != 0 {
            return fail(.invalidIdentity)
        }
        records[Int(index)] = record
        paths[Int(path)].nearestRecord = index
        metadata.pointee.records += 1
        return nil
    }

    package func store(
        _ value: consuming Payload, kind: SemanticRuntimeRecord.Kind, chainIndex: UInt16 = 0,
        text: borrowing Span<UInt32>, limits: SemanticRecordLimits
    ) -> SemanticExpansionError? {
        if let failure = metadata.pointee.failure { return failure }
        let path = metadata.pointee.activePath
        guard metadata.pointee.phase == .expanding, path < metadata.pointee.paths else {
            return fail(.invalidIdentity)
        }
        let record = paths[Int(path)].nearestRecord
        guard record < metadata.pointee.records, records[Int(record)].path == path,
            records[Int(record)].payload == .max
        else { return fail(.invalidIdentity) }
        guard text.count <= Int(limits.textScalars) else { return .capacityExhausted }
        let scalarEnd = UInt32(metadata.pointee.scalars) + UInt32(text.count)
        let bytes =
            UInt64(metadata.pointee.payloadBytes) + UInt64(MemoryLayout<Payload?>.stride) + UInt64(
                text.count) * 4
        guard metadata.pointee.payloads < limits.payloads, scalarEnd <= limits.textScalars,
            bytes <= limits.payloadBytes
        else { return fail(.capacityExhausted) }
        let payloadIndex = metadata.pointee.payloads
        payloads[Int(payloadIndex)] = consume value
        for index in 0 ..< text.count {
            scalars[Int(metadata.pointee.scalars) + index] = text[index]
        }
        records[Int(record)].kind = kind
        records[Int(record)].payload = payloadIndex
        records[Int(record)].firstTextScalar = metadata.pointee.scalars
        records[Int(record)].textScalarCount = UInt16(text.count)
        records[Int(record)].modifierChainIndex = chainIndex
        metadata.pointee.payloads += 1
        metadata.pointee.scalars = UInt16(scalarEnd)
        metadata.pointee.payloadBytes = UInt32(bytes)
        return nil
    }

    /// Parent-first candidate traversal; each node scans at most K children of
    /// its already matched published parent. No path reconstruction/all-pairs scan.
    package func reconcile(with published: Self, limits: SemanticRecordLimits)
        -> SemanticExpansionError?
    {
        guard metadata.pointee.phase == .candidate, published.metadata.pointee.phase == .published
        else { return fail(.invariantViolation) }
        metadata.pointee.componentComparisons = 0
        metadata.pointee.matchedRevision = published.metadata.pointee.revision
        for index in 0 ..< Int(metadata.pointee.paths) {
            paths[index].matchedPath = .max
            let parent = paths[index].parent
            var match: UInt16 = .max
            if parent == .max {
                guard index == 0 else { return fail(.invalidIdentity) }
                if published.metadata.pointee.paths > 0 { match = 0 }
            } else {
                guard parent < index else { return fail(.invalidIdentity) }
                let priorParent = paths[Int(parent)].matchedPath
                if priorParent != .max { match = published.paths[Int(priorParent)].firstChild }
            }
            var scanned: UInt16 = 0
            while match != .max {
                guard match < published.metadata.pointee.paths, scanned < limits.fanout else {
                    return fail(.invalidIdentity)
                }
                scanned += 1
                metadata.pointee.componentComparisons += 1
                if paths[index].component == published.paths[Int(match)].component {
                    paths[index].matchedPath = match
                    break
                }
                match = published.paths[Int(match)].nextSibling
            }
        }
        return nil
    }
}
