import P08CounterTable
import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUILayout
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIObservableState
import GiftUIReferenceTextResources
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore
import P08CounterSchema

typealias StaticCounterPayload = SemanticRecordPayload
// Only a finite assembly adapter: local IDs refer to the current borrowed bank.
// The existing target workspace still owns all layout records and algorithms.
struct LocalSemantic: ~Escapable, SemanticLayoutView {
    let bank: SemanticRecordView
    let base: SemanticRecordLayoutView
    @_lifetime(borrow bank)
    init(_ bank: borrowing SemanticRecordView) { self.bank = copy bank; base = SemanticRecordLayoutView(bank) }
    var rootIdentity: UInt16 { base.rootIdentity.ordinal + 1 }
    var scopeCount: UInt16 { base.scopeCount }
    func reference(_ id: UInt16) -> SemanticRecordReference? { id == 0 ? nil : bank.reference(at: id - 1) }
    func primitive(at id: UInt16) -> SemanticLayoutPrimitive? { guard let ref = reference(id) else { return nil }; return base.primitive(at: ref) }
    func childCount(of id: UInt16) -> UInt16? { guard let ref = reference(id) else { return nil }; return base.childCount(of: ref) }
    func child(of id: UInt16, at index: UInt16) -> UInt16? { guard let ref = reference(id) else { return nil }; return base.child(of: ref, at: index).map { $0.ordinal + 1 } }
    func modifierCount(of id: UInt16) -> UInt16? { guard let ref = reference(id) else { return nil }; return base.modifierCount(of: ref) }
    func modifierScope(of id: UInt16, at index: UInt16) -> UInt16? { guard let ref = reference(id) else { return nil }; return base.modifierScope(of: ref, at: index).map { $0.ordinal + 1 } }
    func modifier(of id: UInt16, at index: UInt16) -> SemanticLayoutModifier? { guard let ref = reference(id) else { return nil }; return base.modifier(of: ref, at: index) }
    func textScalarCount(of id: UInt16) -> UInt16? { guard let ref = reference(id) else { return nil }; return base.textScalarCount(of: ref) }
    func textScalar(of id: UInt16, at index: UInt16) -> UInt32? { guard let ref = reference(id) else { return nil }; return base.textScalar(of: ref, at: index) }
}
struct QualifiedLayout: ResolvedRenderLayoutView {
    let base: StaticCounterResolvedLayoutView
    let references: InlineArray<64, SemanticRecordReference?>
    var rootIdentity: SemanticRecordReference { references[Int(base.rootIdentity - 1)]! }
    var layoutScopeCount: UInt16 { base.layoutScopeCount }
    var renderSnapshotVersion: UInt32 { base.renderSnapshotVersion }
    var rootBounds: Rect { base.rootBounds }
    func local(_ ref: SemanticRecordReference) -> UInt16? {
        guard ref.ordinal < 64, references[Int(ref.ordinal)] == ref else { return nil }
        return ref.ordinal + 1
    }
    func layoutIdentity(at ordinal: UInt16) -> SemanticRecordReference? { guard let id = base.layoutIdentity(at: ordinal), id > 0, id <= 64 else { return nil }; return references[Int(id - 1)] }
    func layoutOrdinal(of ref: SemanticRecordReference) -> UInt16? { guard let id = local(ref) else { return nil }; return base.layoutOrdinal(of: id) }
    func bounds(of ref: SemanticRecordReference) -> Rect? { guard let id = local(ref) else { return nil }; return base.bounds(of: id) }
    func clip(of ref: SemanticRecordReference) -> Rect? { guard let id = local(ref) else { return nil }; return base.clip(of: id) }
    func textLineCount(of ref: SemanticRecordReference) -> UInt16? { guard let id = local(ref) else { return nil }; return base.textLineCount(of: id) }
    func textLine(of ref: SemanticRecordReference, at index: UInt16) -> ResolvedRenderTextLine? { guard let id = local(ref) else { return nil }; return base.textLine(of: id, at: index) }
    func glyph(of ref: SemanticRecordReference, at index: UInt16) -> ResolvedRenderGlyph? { guard let id = local(ref) else { return nil }; return base.glyph(of: id, at: index) }
}
struct QualifiedRender: RenderProductionWorkspace {
    typealias Identity = SemanticRecordReference
    var base: StaticCounterRenderWorkspace
    var capacity: RenderLimits { base.capacity }
    var structuralCapacity: RenderWorkspaceCapacity { base.structuralCapacity }
    var isActive: Bool { base.isActive }
    var currentForeground: Color? { base.currentForeground }
    mutating func acquire() -> Bool { base.acquire() }
    mutating func visitSemanticScope(at ordinal: UInt16) -> RenderWorkspaceVisit { base.visitSemanticScope(at: ordinal) }
    mutating func visitLayoutScope(at ordinal: UInt16) -> RenderWorkspaceVisit { base.visitLayoutScope(at: ordinal) }
    mutating func pushForeground(_ color: Color) -> Bool { base.pushForeground(color) }
    mutating func popForeground() -> Bool { base.popForeground() }
    mutating func reset() { base.reset() }
}

