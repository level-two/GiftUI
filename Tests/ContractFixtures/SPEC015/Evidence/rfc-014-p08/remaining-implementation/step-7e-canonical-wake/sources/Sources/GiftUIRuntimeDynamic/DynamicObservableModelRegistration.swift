import GiftUIObservableState

// Dynamic retains this record in its root owner; Static lends the same bounded
// logical record. Report routes never borrow the object containing model bytes.
package typealias DynamicObservableModelRegistration<Identity: Equatable & Sendable> =
    ObservableStateRootStorage<Identity>
