import GiftUISemanticCore

struct ScopedSemanticOwner: ~Copyable, ~Escapable {
    let semantic: SemanticRecordStore
    @_lifetime(copy semantic)
    init(semantic: consuming SemanticRecordStore) { self.semantic = consume semantic }
}
func forwardSemantic(_ semantic: borrowing SemanticRecordStore) {
    let owner = ScopedSemanticOwner(semantic: semantic.borrowedStore())
    _ = owner
}
