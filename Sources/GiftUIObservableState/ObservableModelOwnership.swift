import GiftUI

// SPEC-015's selected analyzer/counter capacities. The profile supplies model
// bytes separately; this ledger never contains or copies capture payloads.
package struct ObservableModelOwnership: ~Copyable {
    package enum Phase: UInt8 {
        case mutating, writing, reading, discovering, replacing, retired
    }

    package struct Address: Equatable {
        package let owner: UInt32
        package let generation: UInt32
        package let slot: UInt16
    }

    // A claim descriptor is private bookkeeping, not an application ticket.
    // The profile's noncopyable scoped ticket owns its one release obligation.
    package struct Claim: Equatable {
        package let address: Address
        fileprivate let index: UInt16
        fileprivate let serial: UInt32
    }

    package struct Replacement {
        package let former: Address
        package let candidate: Address
        fileprivate let formerClaim: Claim
        fileprivate let candidateClaim: Claim
    }

    struct Record {
        var generation: UInt32 = 0
        var schema: UInt16 = 0
        var occupied = false
        var claims: UInt16 = 0
        var registered = false
        var pinned = false
        var ownsCapture = false
    }

    struct ClaimRecord {
        var serial: UInt32 = 0
        var address: Address?
    }

    package let identity: ObservableModelOwnerIdentity
    private var generations = ObservableModelAllocationNamespace()
    private var nextClaimSerial: UInt32? = 0
    private var records: InlineArray<2, Record> = .init(repeating: Record())
    private var claims: InlineArray<4, ClaimRecord> = .init(repeating: ClaimRecord())
    private let modelLimit: UInt16
    private let claimLimit: UInt16
    private let pinLimit: UInt16
    private let captureLimit: UInt16
    package private(set) var phase: Phase = .mutating
    private var activeRead = false
    private var replacement: Replacement?

    package init?(
        identity: ObservableModelOwnerIdentity,
        modelLimit: UInt16 = 2,
        claimLimit: UInt16 = 4,
        pinLimit: UInt16 = 2,
        captureLimit: UInt16
    ) {
        guard modelLimit > 0, modelLimit <= 2,
            claimLimit > 0, claimLimit <= 4,
            pinLimit > 0, pinLimit <= 2, captureLimit <= 1
        else { return nil }
        self.identity = identity
        self.modelLimit = modelLimit
        self.claimLimit = claimLimit
        self.pinLimit = pinLimit
        self.captureLimit = captureLimit
    }

    package var occupiedCount: Int {
        var count = 0
        for index in 0 ..< Int(modelLimit) where records[index].occupied { count += 1 }
        return count
    }

    package var claimCount: Int {
        var count = 0
        for index in 0 ..< Int(claimLimit) where claims[index].address != nil { count += 1 }
        return count
    }

    package var pinCount: Int {
        var count = 0
        for index in 0 ..< Int(modelLimit) where records[index].pinned { count += 1 }
        return count
    }

    package var captureCount: Int {
        var count = 0
        for index in 0 ..< Int(modelLimit) where records[index].ownsCapture { count += 1 }
        return count
    }

    // The activation callback has ended: its nonescapable tickets and readers
    // cannot remain live. Retire every remaining claim before destroying model
    // values, while preserving both non-reusing identity cursors.
    package mutating func finishActivation() -> UInt8 {
        var occupied: UInt8 = 0
        for index in 0 ..< Int(modelLimit) {
            if records[index].occupied { occupied |= 1 << index }
            records[index] = Record()
        }
        for index in 0 ..< Int(claimLimit) { claims[index].address = nil }
        activeRead = false
        replacement = nil
        phase = .mutating
        return occupied
    }

    package func key<Schema>(for address: Address, as schema: Schema.Type) -> _GiftUIModelKey<
        Schema
    > {
        _GiftUIModelKey(
            ownerInstance: address.owner, allocationGeneration: address.generation,
            slot: address.slot)
    }

    package func address<Schema>(for key: _GiftUIModelKey<Schema>) -> Address {
        Address(
            owner: key._giftUIOwnerInstance, generation: key._giftUIAllocationGeneration,
            slot: key._giftUISlot)
    }

    package func operationAllowed(discovery: Bool = false) -> ObservableStateError? {
        if phase == .replacing || phase == .writing { return .reentrancyViolation }
        if activeRead { return .invalidPhaseSafetyNotProven }
        if phase == .mutating || (discovery && phase == .discovering) { return nil }
        return .invalidPhaseContained
    }

    private func validate(_ address: Address) throws(ObservableStateError) -> Int {
        guard address.owner == identity.rawValue, address.slot < modelLimit else {
            throw .staleModel
        }
        let index = Int(address.slot)
        guard records[index].occupied, records[index].generation == address.generation else {
            throw .staleModel
        }
        return index
    }

    private func validate(_ claim: Claim) throws(ObservableStateError) -> Int {
        let index = try validate(claim.address)
        guard claim.index < claimLimit,
            claims[Int(claim.index)].address == claim.address,
            claims[Int(claim.index)].serial == claim.serial
        else { throw .staleModel }
        return index
    }

    package mutating func beginMutation(_ address: Address, schema: UInt16)
        throws(ObservableStateError) -> Int
    {
        if let failure = operationAllowed() { throw failure }
        let index = try validate(address)
        guard records[index].schema == schema else { throw .staleModel }
        phase = .writing
        return index
    }

    package mutating func endMutation() {
        // Only the checked operation route can enter this phase. Keeping its
        // end non-failing avoids inventing a rollback after an admitted commit.
        if phase == .writing { phase = .mutating }
    }

    package func validatedClaim(_ claim: Claim, schema: UInt16)
        throws(ObservableStateError) -> Int
    {
        if let failure = operationAllowed(discovery: true) { throw failure }
        let index = try validate(claim)
        guard records[index].schema == schema else { throw .staleModel }
        return index
    }

    package func validateAssociation(_ address: Address, schema: UInt16)
        throws(ObservableStateError)
    {
        if let failure = operationAllowed(discovery: true) { throw failure }
        let index = try validate(address)
        guard records[index].schema == schema else { throw .incompatibleAssociation }
        guard !records[index].registered else { throw .duplicateOwner }
    }

    package func callbackIndex(_ address: Address, schema: UInt16)
        throws(ObservableStateError) -> Int
    {
        let index = try validate(address)
        guard records[index].schema == schema else { throw .incompatibleAssociation }
        return index
    }

    private func freeModel() -> Int? {
        for index in 0 ..< Int(modelLimit) where !records[index].occupied { return index }
        return nil
    }

    private func freeClaim() -> Int? {
        for index in 0 ..< Int(claimLimit) where claims[index].address == nil { return index }
        return nil
    }

    private mutating func issueClaim(at index: Int, for address: Address) -> Claim {
        // Every caller reserves capacity and checks exhaustion before mutation.
        let serial = nextClaimSerial!
        let next = serial.addingReportingOverflow(1)
        nextClaimSerial = next.overflow ? nil : next.partialValue
        claims[index] = ClaimRecord(serial: serial, address: address)
        records[Int(address.slot)].claims += 1
        return Claim(address: address, index: UInt16(index), serial: serial)
    }

    package mutating func materialize(schema: UInt16, needsCapture: Bool)
        throws(ObservableStateError) -> Claim
    {
        if let failure = operationAllowed(discovery: true) { throw failure }
        guard !generations.isExhausted else { throw .modelGenerationExhausted }
        guard let model = freeModel() else { throw .modelCapacityExhausted }
        guard let claim = freeClaim(), nextClaimSerial != nil else { throw .ownerCapacityExhausted }
        guard !needsCapture || (captureLimit == 1 && captureCount == 0) else {
            throw .modelCapacityExhausted
        }
        let generation = try generations.issue()
        let address = Address(owner: identity.rawValue, generation: generation, slot: UInt16(model))
        records[model] = Record(
            generation: generation, schema: schema, occupied: true, ownsCapture: needsCapture)
        return issueClaim(at: claim, for: address)
    }

    package mutating func retain(_ address: Address) throws(ObservableStateError) -> Claim {
        if let failure = operationAllowed() { throw failure }
        _ = try validate(address)
        guard let claim = freeClaim(), nextClaimSerial != nil else { throw .ownerCapacityExhausted }
        return issueClaim(at: claim, for: address)
    }

    // Returns the slot whose initialized model must now be destroyed by the profile.
    private mutating func reclaimIfUnowned(_ index: Int) -> UInt16? {
        guard records[index].occupied, records[index].claims == 0,
            !records[index].registered, !records[index].pinned
        else { return nil }
        records[index].occupied = false
        records[index].ownsCapture = false
        return UInt16(index)
    }

    package mutating func release(_ claim: Claim) throws(ObservableStateError) -> UInt16? {
        if let failure = operationAllowed(discovery: true) { throw failure }
        let index = try validate(claim)
        claims[Int(claim.index)].address = nil
        records[index].claims -= 1
        return reclaimIfUnowned(index)
    }

    package mutating func register(_ address: Address, schema: UInt16) throws(ObservableStateError)
    {
        if let failure = operationAllowed(discovery: true) { throw failure }
        let index = try validate(address)
        guard records[index].schema == schema else { throw .incompatibleAssociation }
        guard !records[index].registered else { throw .duplicateOwner }
        records[index].registered = true
    }

    package mutating func unregister(_ address: Address) throws(ObservableStateError) -> UInt16? {
        if let failure = operationAllowed(discovery: true) { throw failure }
        let index = try validate(address)
        guard records[index].registered else { throw .staleAttachment }
        records[index].registered = false
        return reclaimIfUnowned(index)
    }

    package mutating func beginFrame() throws(ObservableStateError) {
        if let failure = operationAllowed() { throw failure }
        phase = .reading
    }

    package mutating func beginDiscovery() throws(ObservableStateError) {
        guard phase != .replacing else { throw .reentrancyViolation }
        guard phase == .reading, !activeRead else { throw .invalidPhaseSafetyNotProven }
        phase = .discovering
    }

    package mutating func endDiscovery() throws(ObservableStateError) {
        guard phase == .discovering else { throw .invalidPhaseSafetyNotProven }
        phase = .reading
    }

    package mutating func pin(_ address: Address) throws(ObservableStateError) {
        guard phase != .replacing else { throw .reentrancyViolation }
        guard phase == .reading || phase == .discovering, !activeRead else {
            throw .invalidPhaseSafetyNotProven
        }
        let index = try validate(address)
        if records[index].pinned { return }
        guard pinCount < Int(pinLimit) else { throw .ownerCapacityExhausted }
        records[index].pinned = true
    }

    package mutating func beginRead() throws(ObservableStateError) {
        guard phase == .reading, !activeRead else { throw .invalidPhaseSafetyNotProven }
        activeRead = true
    }

    package func bind<Schema>(_ key: _GiftUIModelKey<Schema>, schema: UInt16)
        throws(_GiftUIAccessFailure) -> Int
    {
        guard phase == .reading, activeRead else { throw .invalidPhase }
        guard key._giftUIOwnerInstance == identity.rawValue else { throw .wrongOwner }
        guard key._giftUISlot < modelLimit else { throw .staleModel }
        let index = Int(key._giftUISlot)
        guard records[index].schema == schema else { throw .wrongSchema }
        guard records[index].occupied, records[index].generation == key._giftUIAllocationGeneration
        else { throw .staleModel }
        guard records[index].pinned else { throw .invalidPhase }
        return index
    }

    package mutating func endRead() throws(ObservableStateError) {
        guard phase == .reading, activeRead else { throw .invalidPhaseSafetyNotProven }
        activeRead = false
    }

    package mutating func endFrame(reclaim: (UInt16) -> Void) throws(ObservableStateError) {
        guard phase == .reading, !activeRead else { throw .invalidPhaseSafetyNotProven }
        for index in 0 ..< Int(modelLimit) {
            records[index].pinned = false
            if let slot = reclaimIfUnowned(index) { reclaim(slot) }
        }
        phase = .mutating
    }

    package mutating func reserveReplacement(
        transferring finalClaim: Claim, schema: UInt16, candidateIsEmpty: Bool,
        registrationAvailable: Bool, stagingAvailable: Bool
    ) throws(ObservableStateError) -> Replacement {
        if let failure = operationAllowed() { throw failure }
        let old = try validate(finalClaim)
        guard records[old].schema == schema, records[old].registered else {
            throw .incompatibleAssociation
        }
        guard !generations.isExhausted else { throw .modelGenerationExhausted }
        guard records[old].claims == 1, !records[old].pinned else { throw .retainedModel }
        guard candidateIsEmpty else { throw .modelCapacityExhausted }
        guard let model = freeModel() else { throw .modelCapacityExhausted }
        guard let claim = freeClaim(), nextClaimSerial != nil else { throw .ownerCapacityExhausted }
        guard registrationAvailable else { throw .registrationCapacityExhausted }
        guard stagingAvailable else { throw .replacementStagingCapacityExhausted }
        let generation = try generations.issue()
        let address = Address(owner: identity.rawValue, generation: generation, slot: UInt16(model))
        records[model] = Record(generation: generation, schema: schema, occupied: true)
        let candidate = issueClaim(at: claim, for: address)
        let reservation = Replacement(
            former: finalClaim.address, candidate: address, formerClaim: finalClaim,
            candidateClaim: candidate)
        replacement = reservation
        phase = .replacing
        return reservation
    }

    package mutating func finishReplacement(_ reservation: Replacement, commit: Bool)
        throws(ObservableStateError) -> Claim?
    {
        guard phase == .replacing, let current = replacement,
            current.formerClaim == reservation.formerClaim,
            current.candidateClaim == reservation.candidateClaim
        else { throw .invariantViolation }
        let old = try validate(reservation.formerClaim)
        let new = try validate(reservation.candidateClaim)
        if commit {
            records[new].registered = true
            records[new].ownsCapture = records[old].ownsCapture
            records[old].registered = false
            records[old].ownsCapture = false
            claims[Int(reservation.formerClaim.index)].address = nil
            records[old].claims = 0
            records[old].occupied = false
        } else {
            claims[Int(reservation.candidateClaim.index)].address = nil
            records[new].claims = 0
            records[new].occupied = false
        }
        replacement = nil
        phase = .mutating
        return commit ? reservation.candidateClaim : nil
    }
}
