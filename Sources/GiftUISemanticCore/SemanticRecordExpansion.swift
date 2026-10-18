import GiftUI

@usableFromInline
package protocol SemanticRecordPayloadCodec {
    associatedtype Payload
    static func primitive<Value: _GiftUISemanticPrimitivePayload>(
        _ value: borrowing Value, writer: borrowing SemanticPayloadWriter<Payload>
    ) -> SemanticExpansionError?
    static func modifier<Value: _GiftUISemanticModifierPayload>(
        _ value: borrowing Value, chainIndex: UInt16,
        writer: borrowing SemanticPayloadWriter<Payload>
    ) -> SemanticExpansionError?
    static func action<Value: GiftUIAction>(
        _ value: borrowing Value, writer: borrowing SemanticPayloadWriter<Payload>
    ) -> SemanticExpansionError?
}

@usableFromInline
package struct SemanticPayloadWriter<Payload>: ~Copyable, ~Escapable {
    @usableFromInline
    internal let bank: SemanticRecordBankBuffers<Payload>
    @usableFromInline
    internal let limits: SemanticRecordLimits
    @_lifetime(borrow bank)
    @usableFromInline
    init(
        bank: borrowing SemanticRecordBankBuffers<Payload>, limits: SemanticRecordLimits
    ) {
        self.bank = copy bank
        self.limits = limits
    }
    @inlinable
    package borrowing func store(
        _ value: consuming Payload, kind: SemanticRuntimeRecord.Kind,
        chainIndex: UInt16 = 0, text: borrowing Span<UInt32>
    ) -> SemanticExpansionError? {
        bank.store(consume value, kind: kind, chainIndex: chainIndex, text: text, limits: limits)
    }
    @inlinable
    package borrowing func store(
        _ value: consuming Payload, kind: SemanticRuntimeRecord.Kind,
        chainIndex: UInt16 = 0
    ) -> SemanticExpansionError? {
        let empty: InlineArray<0, UInt32> = .init(repeating: 0)
        return store(consume value, kind: kind, chainIndex: chainIndex, text: empty.span)
    }
}

@usableFromInline
struct RecordWorkspace<Roles: SemanticDeclarationRoles, Payload>: SemanticExpansionWorkspace {
    @usableFromInline
    typealias Identity = SemanticCompleteIdentity
    @usableFromInline
    let bank: SemanticRecordBankBuffers<Payload>
    @usableFromInline
    let limits: SemanticRecordLimits
    @usableFromInline
    var identity = SemanticCompleteIdentity()
    @usableFromInline
    var isExpanding = false
    @inlinable
    @inline(__always)
    init(bank: SemanticRecordBankBuffers<Payload>, limits: SemanticRecordLimits) {
        self.bank = bank
        self.limits = limits
    }
    @usableFromInline
    var maximumPathComponents: UInt16 { limits.depth }
    @usableFromInline
    var maximumIdentities: UInt16 { limits.paths }
    @usableFromInline
    mutating func beginExpansion() -> Bool {
        guard !isExpanding, bank.metadata.pointee.phase == .expanding else { return false }
        isExpanding = true
        return true
    }
    @usableFromInline
    mutating func enter(_ component: SemanticPathComponent, identity output: inout Identity?)
        -> SemanticExpansionError?
    {
        if let error = bank.enter(component, limits: limits) { return error }
        guard identity.append(component) else { return bank.fail(.invalidIdentity) }
        output = identity
        return nil
    }
    @usableFromInline
    mutating func enterRoot<D: View>(_ declaration: D.Type, identity: inout Identity?)
        -> SemanticExpansionError?
    { enter(.init(kind: .root), identity: &identity) }
    @usableFromInline
    mutating func enterCustomBody<D: View>(_ declaration: D.Type, identity: inout Identity?)
        -> SemanticExpansionError?
    { enter(.init(kind: .customBody), identity: &identity) }
    @usableFromInline
    mutating func enterFixedChild(_ index: UInt8, identity: inout Identity?)
        -> SemanticExpansionError?
    { enter(.init(kind: .fixedChild, ordinal: index), identity: &identity) }
    @usableFromInline
    mutating func enterConditionalBranch(_ index: UInt8, identity: inout Identity?)
        -> SemanticExpansionError?
    { enter(.init(kind: .conditionalBranch, ordinal: index), identity: &identity) }
    @usableFromInline
    mutating func enterOptionalPresence(identity: inout Identity?) -> SemanticExpansionError? {
        enter(.init(kind: .optionalPresence), identity: &identity)
    }
    @inlinable
    @inline(__always)
    mutating func enterDeclarationRole<D>(_ declaration: D.Type, identity: inout Identity?)
        -> SemanticExpansionError?
    {
        guard let role = Roles.role(of: declaration), role.rawValue != 0 else {
            return bank.fail(.invalidIdentity)
        }
        return enter(
            .init(
                kind: .declarationRole, role: role.rawValue,
                modifier: Roles.modifierDiscriminator(of: declaration)), identity: &identity)
    }
    @usableFromInline
    mutating func leavePathComponent() {
        bank.leave()
        identity.removeLast()
    }
    @usableFromInline
    mutating func completeExpansion() {}
    @usableFromInline
    mutating func discardExpansion() {}
    @usableFromInline
    mutating func resetExpansion() {
        isExpanding = false
        identity = SemanticCompleteIdentity()
    }
}

@usableFromInline
struct RecordSink<Codec: SemanticRecordPayloadCodec>: SemanticExpansionSink {
    @usableFromInline
    typealias Identity = SemanticCompleteIdentity
    @usableFromInline
    let bank: SemanticRecordBankBuffers<Codec.Payload>
    @usableFromInline
    let limits: SemanticRecordLimits
    @usableFromInline
    let expansion: SemanticExpansionLimits
    @usableFromInline
    var bodyCount: UInt16 = 0
    @usableFromInline
    var semanticCount: UInt16 = 0
    @usableFromInline
    var modifierCount: UInt16 = 0
    @usableFromInline
    var actionCount: UInt16 = 0
    @inlinable
    @inline(__always)
    init(
        bank: SemanticRecordBankBuffers<Codec.Payload>, limits: SemanticRecordLimits,
        expansion: SemanticExpansionLimits
    ) {
        self.bank = bank
        self.limits = limits
        self.expansion = expansion
    }
    @usableFromInline
    var stagingFailure: SemanticExpansionError? { bank.metadata.pointee.failure }
    @usableFromInline
    var maximumStructuralOccurrences: UInt16 { limits.records }
    @usableFromInline
    var maximumBodyEvaluations: UInt16 { expansion.maximumBodyEvaluations }
    @usableFromInline
    var maximumSemanticOccurrences: UInt16 { expansion.maximumSemanticNodes }
    @usableFromInline
    var maximumModifierApplications: UInt16 { expansion.maximumModifierApplications }
    @usableFromInline
    var maximumActionOccurrences: UInt16 { expansion.maximumActionOccurrences }
    @usableFromInline
    mutating func beginExpansion() -> Bool { bank.metadata.pointee.phase == .expanding }
    @usableFromInline
    mutating func stageStructuralOccurrence(identity: borrowing Identity) -> Bool {
        bank.appendRecord(limits: limits) == nil
    }
    @usableFromInline
    mutating func stageBodyEvaluation(identity: borrowing Identity) -> Bool {
        bodyCount += 1
        return true
    }
    @inlinable
    @inline(__always)
    mutating func stageSemanticOccurrence<Value: _GiftUISemanticPrimitivePayload>(
        identity: borrowing Identity, payload: borrowing Value
    ) -> Bool {
        let writer = SemanticPayloadWriter(bank: bank, limits: limits)
        if let error = Codec.primitive(payload, writer: writer) {
            _ = bank.fail(error)
            return false
        }
        semanticCount += 1
        return true
    }
    @inlinable
    @inline(__always)
    mutating func stageModifierApplication<Value: _GiftUISemanticModifierPayload>(
        identity: borrowing Identity, payload: borrowing Value, chainIndex: UInt16
    ) -> Bool {
        let writer = SemanticPayloadWriter(bank: bank, limits: limits)
        if let error = Codec.modifier(payload, chainIndex: chainIndex, writer: writer) {
            _ = bank.fail(error)
            return false
        }
        modifierCount += 1
        return true
    }
    @inlinable
    @inline(__always)
    mutating func stageActionOccurrence<Value: GiftUIAction>(
        identity: borrowing Identity, action: borrowing Value
    ) -> Bool {
        let writer = SemanticPayloadWriter(bank: bank, limits: limits)
        if let error = Codec.action(action, writer: writer) {
            _ = bank.fail(error)
            return false
        }
        semanticCount += 1
        actionCount += 1
        return true
    }
    @inlinable
    mutating func publishExpansion(_ summary: SemanticExpansionSummary) -> Bool {
        guard bank.metadata.pointee.phase == .expanding, bank.metadata.pointee.failure == nil,
            bank.metadata.pointee.activePath == .max, summary.bodyEvaluationCount == bodyCount,
            summary.semanticNodeCount == semanticCount,
            summary.modifierApplicationCount == modifierCount,
            summary.actionOccurrenceCount == actionCount
        else { return false }
        bank.metadata.pointee.summary = summary
        bank.metadata.pointee.phase = .candidate
        return true
    }
    @usableFromInline
    mutating func discardExpansion() {}
    @usableFromInline
    mutating func resetExpansion() {}
}

extension SemanticRecordStore {
    @inlinable
    @inline(__always)
    package borrowing func expand<
        Root: View, Roles: SemanticDeclarationRoles, Codec: SemanticRecordPayloadCodec,
        Binding: SemanticStatefulBinding & ~Copyable & ~Escapable
    >(
        _ root: borrowing Root, roles: Roles.Type, codec: Codec.Type,
        limits: SemanticExpansionLimits, binding: consuming Binding
    ) -> BoundSemanticExpansionResult<Binding.Failure>
    where
        Root.Domain == Binding.Domain, Binding.Identity == SemanticCompleteIdentity,
        Codec.Payload == Payload
    {
        let number: UInt8
        do throws(SemanticExpansionError) { number = try beginCandidate() } catch {
            return .semanticFailure(error)
        }
        guard let bank = expansionBank(number) else { return .semanticFailure(.invariantViolation) }
        var workspace = RecordWorkspace<Roles, Payload>(bank: bank, limits: self.limits)
        var sink = RecordSink<Codec>(bank: bank, limits: self.limits, expansion: limits)
        let result = expandSemanticTreeWithStateBinding(
            root, limits: limits, workspace: &workspace, sink: &sink, stateBinding: consume binding)
        switch result {
        case .success: break
        default:
            // This attempt cannot have lent a view before completion.
            bank.clear()
        }
        return result
    }
}
