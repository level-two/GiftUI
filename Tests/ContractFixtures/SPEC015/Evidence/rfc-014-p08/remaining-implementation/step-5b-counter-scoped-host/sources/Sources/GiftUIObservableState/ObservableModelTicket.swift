import GiftUI

/// A profile-issued claim whose lifetime cannot exceed the activation scope.
package struct ObservableModelTicket<Schema>: ~Copyable, ~Escapable {
    package let claim: ObservableModelOwnership.Claim
    private var ownsClaim = true

    @_lifetime(copy lifetime)
    package init<Scope: ~Copyable & ~Escapable>(
        claim: ObservableModelOwnership.Claim, lifetime: borrowing Scope
    ) {
        self.claim = claim
    }

    package borrowing func requireClaim() throws(ObservableStateError)
        -> ObservableModelOwnership.Claim
    {
        guard ownsClaim else { throw .staleModel }
        return claim
    }

    package mutating func endOwnership() { ownsClaim = false }

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
package struct ObservableModelReadSlot<Model: ~Copyable> {
    package let ownership: UnsafePointer<ObservableModelOwnership>
    package let model: UnsafePointer<Model?>
    package let schema: UInt16

    package init(
        ownership: UnsafePointer<ObservableModelOwnership>,
        model: UnsafePointer<Model?>, schema: UInt16
    ) {
        self.ownership = ownership
        self.model = model
        self.schema = schema
    }
}
