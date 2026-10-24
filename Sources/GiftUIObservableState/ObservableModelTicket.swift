import GiftUI

/// A profile-issued claim whose lifetime cannot exceed the activation scope.
@usableFromInline
package struct ObservableModelTicket<Schema>: ~Copyable, ~Escapable {
    @usableFromInline
    package let claim: ObservableModelOwnership.Claim
    @usableFromInline
    internal var ownsClaim = true

    @_lifetime(copy lifetime)
    @inlinable
    package init<Scope: ~Copyable & ~Escapable>(
        claim: ObservableModelOwnership.Claim, lifetime: borrowing Scope
    ) {
        self.claim = claim
    }

    @inlinable
    package borrowing func requireClaim() throws(ObservableStateError)
        -> ObservableModelOwnership.Claim
    {
        guard ownsClaim else { throw .staleModel }
        return claim
    }

    @inlinable
    package mutating func endOwnership() { ownsClaim = false }

    @inlinable
    package var key: _GiftUIModelKey<Schema> {
        _GiftUIModelKey(
            ownerInstance: claim.address.owner,
            allocationGeneration: claim.address.generation,
            slot: claim.address.slot
        )
    }
}

/// Internal descriptor constructed only while the profile owns initialized,
/// stable model and metadata storage. It is never an authored model value.
@usableFromInline
package struct ObservableModelReadSlot<Model: ~Copyable> {
    @usableFromInline package let ownership: UnsafePointer<ObservableModelOwnership>
    @usableFromInline package let model: UnsafePointer<Model?>
    @usableFromInline package let schema: UInt16

    @inlinable
    package init(
        ownership: UnsafePointer<ObservableModelOwnership>,
        model: UnsafePointer<Model?>, schema: UInt16
    ) {
        self.ownership = ownership
        self.model = model
        self.schema = schema
    }
}
