import GiftUIObservableState
import GiftUISemanticCore

@_noAllocation @inline(never)
package func ownerRootImportedProbe(_ identity: ObservableModelOwnerIdentity, models: UInt16, claims: UInt16, pins: UInt16, captures: UInt16) -> (UInt32, UInt16, UInt16, UInt16, UInt16, Int, Int, Int)? {
    guard let owner = ObservableModelOwnership(identity: identity, modelLimit: models, claimLimit: claims, pinLimit: pins, captureLimit: captures) else { return nil }
    let capacities = owner.storageCapacities
    _ = ObservableStateRootControl()
    let root = ObservableStateRootControl.storageCapacities()
    return (owner.identityForAccounting().rawValue, capacities.models, capacities.claims, capacities.pins, capacities.captures, ObservableModelOwnership.metadataStorageBytes, ObservableModelOwnership.framePinStorageBytes, ObservableStateRootControl.candidateStorageBytes + Int(root.locations + root.registrations + root.associations))
}
