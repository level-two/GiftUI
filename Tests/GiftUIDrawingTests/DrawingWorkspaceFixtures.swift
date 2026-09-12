protocol CanvasIdentityFixtureStorage {
    var capacity: UInt16 { get }
    var count: UInt16 { get }
    mutating func append(_ identity: UInt16) -> Bool
    func identity(at index: UInt16) -> UInt16?
}

struct DynamicCanvasIdentityFixtureStorage: CanvasIdentityFixtureStorage {
    let capacity: UInt16
    private var identities: [UInt16] = []

    init(capacity: UInt16) {
        self.capacity = capacity
    }

    var count: UInt16 { UInt16(identities.count) }

    mutating func append(_ identity: UInt16) -> Bool {
        guard count < capacity else { return false }
        identities.append(identity)
        return true
    }

    func identity(at index: UInt16) -> UInt16? {
        guard Int(index) < identities.count else { return nil }
        return identities[Int(index)]
    }
}

struct StaticCanvasIdentityFixtureStorage: CanvasIdentityFixtureStorage {
    let capacity: UInt16
    private var storedCount: UInt16 = 0
    private var slots: (UInt16, UInt16, UInt16, UInt16) = (0, 0, 0, 0)

    init?(capacity: UInt16) {
        guard capacity > 0, capacity <= 4 else { return nil }
        self.capacity = capacity
    }

    var count: UInt16 { storedCount }

    mutating func append(_ identity: UInt16) -> Bool {
        guard storedCount < capacity else { return false }
        switch storedCount {
        case 0: slots.0 = identity
        case 1: slots.1 = identity
        case 2: slots.2 = identity
        case 3: slots.3 = identity
        default: return false
        }
        storedCount += 1
        return true
    }

    func identity(at index: UInt16) -> UInt16? {
        guard index < storedCount else { return nil }
        return switch index {
        case 0: slots.0
        case 1: slots.1
        case 2: slots.2
        case 3: slots.3
        default: nil
        }
    }
}
