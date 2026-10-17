import GiftUIObservableState
func bad(_ owner: borrowing UnsafeMutablePointer<ObservableModelOwnership>,
         _ models: borrowing UnsafeMutableBufferPointer<Int?>) {
    let scope = ObservableModelScope<Int, UInt8>(ownership: owner, models: models, schema: 1, needsCapture: false)
    _ = scope
}
