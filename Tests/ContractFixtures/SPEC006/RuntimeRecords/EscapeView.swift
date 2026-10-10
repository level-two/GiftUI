import GiftUISemanticCore
func escape(_ store: borrowing SemanticRecordStore<UInt32>) throws(SemanticExpansionError) -> SemanticRecordView<UInt32> {
    try store.withPublishedView { view in view }
}
