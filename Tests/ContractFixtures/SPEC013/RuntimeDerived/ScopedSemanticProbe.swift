import GiftUISemanticCore

struct ScopedSemanticOwner<Payload>: ~Copyable, ~Escapable {
    let semantic: SemanticRecordStore<Payload>
    @_lifetime(copy semantic)
    init(semantic: consuming SemanticRecordStore<Payload>) { self.semantic = consume semantic }
}
func forwardSemantic<Payload>(_ semantic: borrowing SemanticRecordStore<Payload>) {
    let owner = ScopedSemanticOwner(semantic: semantic.borrowedStore())
    _ = owner
}
