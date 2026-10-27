import GiftUI

@usableFromInline
package protocol SemanticRecordPayloadCodec: ~Escapable {
    associatedtype Sink: SemanticExpansionSink & ~Escapable
    where Sink.Identity == SemanticCompleteIdentity

    @_lifetime(copy self, copy state)
    borrowing func makeSink(state: consuming SemanticRecordSinkState) -> Sink

    borrowing func prepare(maximumSemanticNodes: UInt16) -> SemanticExpansionError?
    borrowing func discardPending()
    borrowing func ownsPendingCandidate(
        owner: SemanticRecordOwnerIdentity, bank: UInt8, revision: UInt32, required: Bool
    ) -> Bool
    borrowing func primitive<Value: _GiftUISemanticPrimitivePayload>(
        _ value: borrowing Value, writer: borrowing SemanticPayloadWriter
    ) -> SemanticExpansionError?
    borrowing func modifier<Value: _GiftUISemanticModifierPayload>(
        _ value: borrowing Value, chainIndex: UInt16,
        writer: borrowing SemanticPayloadWriter
    ) -> SemanticExpansionError?
    borrowing func action<Value: GiftUIAction>(
        _ value: borrowing Value, writer: borrowing SemanticPayloadWriter
    ) -> SemanticExpansionError?
}

extension SemanticRecordPayloadCodec {
    @inlinable
    package borrowing func prepare(maximumSemanticNodes: UInt16) -> SemanticExpansionError? { nil }
    @inlinable
    package borrowing func discardPending() {}
    @inlinable
    package borrowing func ownsPendingCandidate(
        owner: SemanticRecordOwnerIdentity, bank: UInt8, revision: UInt32, required: Bool
    ) -> Bool { !required }
}

@usableFromInline
package struct SemanticPayloadWriter: ~Copyable, ~Escapable {
    @usableFromInline
    internal let bank: SemanticRecordBankBuffers
    @usableFromInline
    internal let limits: SemanticRecordLimits
    @usableFromInline
    internal let owner: SemanticRecordOwnerIdentity
    @usableFromInline
    internal let bankNumber: UInt8
    @_lifetime(borrow bank)
    @usableFromInline
    init(
        bank: borrowing SemanticRecordBankBuffers, limits: SemanticRecordLimits,
        owner: SemanticRecordOwnerIdentity, bankNumber: UInt8
    ) {
        self.bank = copy bank
        self.limits = limits
        self.owner = owner
        self.bankNumber = bankNumber
    }
    @inlinable
    package borrowing func store(
        _ value: consuming SemanticRecordPayload, kind: SemanticRuntimeRecord.Kind,
        chainIndex: UInt16 = 0, text: borrowing Span<UInt32>
    ) -> SemanticExpansionError? {
        bank.store(consume value, kind: kind, chainIndex: chainIndex, text: text, limits: limits)
    }
    @inlinable
    package borrowing func store(
        _ value: consuming SemanticRecordPayload, kind: SemanticRuntimeRecord.Kind,
        chainIndex: UInt16 = 0
    ) -> SemanticExpansionError? {
        let empty: InlineArray<0, UInt32> = .init(repeating: 0)
        return store(consume value, kind: kind, chainIndex: chainIndex, text: empty.span)
    }

    /// Canvas reserves its dense typed slot only after every canonical guard.
    /// The callback may refuse before mutation; a successful reservation is
    /// followed by an infallible canonical marker commit.
    @inlinable
    package borrowing func storeCanvas(
        additionalBytes: UInt64,
        reserve: (UInt16, SemanticRecordReference) -> SemanticExpansionError?
    ) -> SemanticExpansionError? {
        if let failure = bank.preflightStore(
            textCount: 0, limits: limits, additionalBytes: additionalBytes)
        {
            return failure
        }
        let record = bank.paths[Int(bank.metadata.pointee.activePath)].nearestRecord
        let reference = SemanticRecordReference(
            owner: owner, bank: bankNumber, revision: bank.metadata.pointee.revision,
            ordinal: record)
        if let failure = reserve(bank.metadata.pointee.payloads, reference) { return failure }
        let empty: InlineArray<0, UInt32> = .init(repeating: 0)
        bank.commitStore(
            .canvas, kind: .pendingCanvas, chainIndex: 0, text: empty.span,
            additionalBytes: additionalBytes)
        return nil
    }
}

@usableFromInline
struct RecordWorkspace<Roles: SemanticDeclarationRoles>: SemanticExpansionWorkspace {
    @usableFromInline
    typealias Identity = SemanticCompleteIdentity
    @usableFromInline
    let bank: SemanticRecordBankBuffers
    @usableFromInline
    let limits: SemanticRecordLimits
    @usableFromInline
    var identity = SemanticCompleteIdentity()
    @usableFromInline
    var isExpanding = false
    @inlinable
    @inline(__always)
    init(bank: SemanticRecordBankBuffers, limits: SemanticRecordLimits) {
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

extension SemanticRecordStore {
    @inlinable
    @inline(__always)
    package borrowing func expand<
        Root: View, Roles: SemanticDeclarationRoles, Codec: SemanticRecordPayloadCodec & ~Escapable,
        Binding: SemanticStatefulBinding & ~Copyable & ~Escapable
    >(
        _ root: borrowing Root, roles: Roles.Type, codec: borrowing Codec,
        limits: SemanticExpansionLimits, binding: consuming Binding
    ) -> BoundSemanticExpansionResult<Binding.Failure>
    where
        Root.Domain == Binding.Domain, Binding.Identity == SemanticCompleteIdentity
    {
        let number: UInt8
        do throws(SemanticExpansionError) { number = try beginCandidate() } catch {
            return .semanticFailure(error)
        }
        guard let bank = expansionBank(number) else { return .semanticFailure(.invariantViolation) }
        if let error = codec.prepare(maximumSemanticNodes: limits.maximumSemanticNodes) {
            bank.clear()
            return .semanticFailure(error)
        }
        var workspace = RecordWorkspace<Roles>(bank: bank, limits: self.limits)
        let state = SemanticRecordSinkState(
            bank: bank, owner: owner, bankNumber: number,
            limits: self.limits, expansion: limits)
        let sink = codec.makeSink(state: consume state)
        let result = expandSemanticTreeConsumingSinkWithStateBinding(
            root, limits: limits, workspace: &workspace, sink: consume sink,
            stateBinding: consume binding)
        switch result {
        case .success: break
        default:
            // This attempt cannot have lent a view before completion.
            codec.discardPending()
            bank.clear()
        }
        return result
    }
}
