import GiftUI

/// Finite generated/trusted operations, never an authored inout callback.
/// Prepared contains only bounded preflight data; it must not be a full capture
/// rollback copy. The witness lives on the concrete storage value so this route
/// does not require noncopyable associated types from the compiler.
@usableFromInline
package protocol ObservableModelMutation: ~Copyable {
    associatedtype Mutation
    associatedtype Prepared

    borrowing func preflight(_ mutation: Mutation)
        throws(ObservableStateError) -> Prepared
    mutating func commit(_ prepared: Prepared) -> Bool
}
