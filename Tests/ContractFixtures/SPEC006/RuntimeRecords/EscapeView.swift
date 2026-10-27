import GiftUISemanticCore
func escape(_ store: borrowing SemanticRecordStore) throws(SemanticExpansionError) -> SemanticRecordView {
    try store.withPublishedView { view in view }
}
