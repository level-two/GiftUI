// Disposable SPIKE-003 host semantics. Nothing here is a production API.

@propertyWrapper
struct State<Value> {
    var wrappedValue: Value
    init(wrappedValue: Value) { self.wrappedValue = wrappedValue }
}

struct PortableFixture<Model> {
    @State var model: Model

    init(model: Model) {
        _model = State(wrappedValue: model)
    }
}

struct BorrowedDescendant<Model> {
    let model: Model
}

protocol FixtureModelStore {
    associatedtype Model: Equatable

    mutating func create(control: Int32, capture: Int32) -> Model
    func identity(of model: Model) -> UInt16
    func values(of model: Model) -> (Int32, Int32)
    mutating func mutate(_ model: Model, controlDelta: Int32, captureDelta: Int32)
    func ownerToken(of model: Model) -> UInt32?
    mutating func setOwnerToken(_ token: UInt32?, for model: Model)
}

final class DynamicModel: Equatable {
    let identity: UInt16
    var control: Int32
    var capture: Int32
    var ownerToken: UInt32?

    init(identity: UInt16, control: Int32, capture: Int32) {
        self.identity = identity
        self.control = control
        self.capture = capture
    }

    static func == (lhs: DynamicModel, rhs: DynamicModel) -> Bool { lhs === rhs }
}

struct DynamicModelStore: FixtureModelStore {
    private var nextIdentity: UInt16 = 1

    mutating func create(control: Int32, capture: Int32) -> DynamicModel {
        defer { nextIdentity &+= 1 }
        return DynamicModel(identity: nextIdentity, control: control, capture: capture)
    }

    func identity(of model: DynamicModel) -> UInt16 { model.identity }
    func values(of model: DynamicModel) -> (Int32, Int32) { (model.control, model.capture) }
    mutating func mutate(_ model: DynamicModel, controlDelta: Int32, captureDelta: Int32) {
        model.control &+= controlDelta
        model.capture &+= captureDelta
    }
    func ownerToken(of model: DynamicModel) -> UInt32? { model.ownerToken }
    mutating func setOwnerToken(_ token: UInt32?, for model: DynamicModel) {
        model.ownerToken = token
    }
}

struct StaticModelHandle: Equatable {
    let slot: UInt8
    let identity: UInt16
}

struct StaticModelRecord {
    var identity: UInt16 = 0
    var control: Int32 = 0
    var capture: Int32 = 0
    var ownerToken: UInt32? = nil
}

struct StaticModelStore: FixtureModelStore {
    private var records = Array(repeating: StaticModelRecord(), count: 16)
    private var count: UInt8 = 0
    private var nextIdentity: UInt16 = 1

    mutating func create(control: Int32, capture: Int32) -> StaticModelHandle {
        precondition(Int(count) < records.count, "fixture model capacity")
        let handle = StaticModelHandle(slot: count, identity: nextIdentity)
        records[Int(count)] = StaticModelRecord(
            identity: nextIdentity, control: control, capture: capture, ownerToken: nil
        )
        count &+= 1
        nextIdentity &+= 1
        return handle
    }

    func identity(of model: StaticModelHandle) -> UInt16 { model.identity }
    func values(of model: StaticModelHandle) -> (Int32, Int32) {
        let record = records[Int(model.slot)]
        precondition(record.identity == model.identity, "stale fixture model handle")
        return (record.control, record.capture)
    }
    mutating func mutate(_ model: StaticModelHandle, controlDelta: Int32, captureDelta: Int32) {
        precondition(records[Int(model.slot)].identity == model.identity, "stale fixture model handle")
        records[Int(model.slot)].control &+= controlDelta
        records[Int(model.slot)].capture &+= captureDelta
    }
    func ownerToken(of model: StaticModelHandle) -> UInt32? {
        records[Int(model.slot)].ownerToken
    }
    mutating func setOwnerToken(_ token: UInt32?, for model: StaticModelHandle) {
        records[Int(model.slot)].ownerToken = token
    }
}

enum Outcome: String {
    case ok
    case stateExhausted = "state-exhausted"
    case registrationExhausted = "registration-exhausted"
    case duplicateOwner = "duplicate-owner"
}

struct Registration {
    var active = false
    var location: UInt8 = 0
    var modelIdentity: UInt16 = 0
    var generation: UInt16 = 0
}

struct Location<Model> {
    var live = false
    var model: Model? = nil
    var registration: UInt8 = 0
    var dirty = false
}

struct FixtureRuntime<Store: FixtureModelStore> {
    var store: Store
    private var locations: [Location<Store.Model>]
    private var registrations: [Registration]
    private var nextGeneration: UInt16 = 1
    private(set) var reevaluationCount = 0
    private(set) var wakeCount = 0

    init(store: Store, stateCapacity: Int = 4, registrationCapacity: Int = 4) {
        self.store = store
        locations = Array(repeating: Location(), count: stateCapacity)
        registrations = Array(repeating: Registration(), count: registrationCapacity)
    }

    mutating func materialize(location: UInt8, initial: Store.Model) -> (Outcome, Store.Model?, UInt32?) {
        let index = Int(location)
        guard index < locations.count else { return (.stateExhausted, nil, nil) }
        if locations[index].live {
            return (.ok, locations[index].model, token(for: locations[index].registration))
        }
        if store.ownerToken(of: initial) != nil { return (.duplicateOwner, nil, nil) }
        guard let registrationIndex = registrations.firstIndex(where: { !$0.active }) else {
            return (.registrationExhausted, nil, nil)
        }
        let generation = nextGeneration
        nextGeneration &+= 1
        registrations[registrationIndex] = Registration(
            active: true, location: location,
            modelIdentity: store.identity(of: initial), generation: generation
        )
        let token = makeToken(registration: UInt8(registrationIndex), generation: generation)
        store.setOwnerToken(token, for: initial)
        locations[index] = Location(
            live: true, model: initial, registration: UInt8(registrationIndex), dirty: false
        )
        return (.ok, initial, token)
    }

    mutating func mutate(_ model: Store.Model, controlDelta: Int32, captureDelta: Int32) {
        store.mutate(model, controlDelta: controlDelta, captureDelta: captureDelta)
        if let token = store.ownerToken(of: model) { _ = report(token: token) }
    }

    mutating func admittedExternalFact(_ model: Store.Model, captureDelta: Int32) {
        mutate(model, controlDelta: 0, captureDelta: captureDelta)
    }

    mutating func replace(location: UInt8, with replacement: Store.Model) -> (Outcome, UInt32?) {
        let index = Int(location)
        guard index < locations.count, locations[index].live else {
            let result = materialize(location: location, initial: replacement)
            return (result.0, result.2)
        }
        if store.ownerToken(of: replacement) != nil { return (.duplicateOwner, nil) }
        detach(location: location)
        let result = materialize(location: location, initial: replacement)
        return (result.0, result.2)
    }

    mutating func publish(liveLocations: [UInt8]) {
        for index in locations.indices where locations[index].live {
            if !liveLocations.contains(UInt8(index)) { detach(location: UInt8(index)) }
        }
    }

    mutating func failedDerivation(candidateLiveLocations: [UInt8]) {
        // Candidate liveness is deliberately ignored; the published live set remains authoritative.
        _ = candidateLiveLocations
    }

    mutating func report(token: UInt32) -> Bool {
        let registrationIndex = Int(token & 0xff)
        let generation = UInt16((token >> 8) & 0xffff)
        guard registrationIndex < registrations.count else { return false }
        let registration = registrations[registrationIndex]
        guard registration.active, registration.generation == generation else { return false }
        let locationIndex = Int(registration.location)
        guard locationIndex < locations.count, locations[locationIndex].live,
              let model = locations[locationIndex].model,
              store.identity(of: model) == registration.modelIdentity else { return false }
        if !locations[locationIndex].dirty {
            locations[locationIndex].dirty = true
            wakeCount += 1
        }
        return true
    }

    mutating func reevaluateDirtyRoot() -> Bool {
        guard locations.contains(where: { $0.live && $0.dirty }) else { return false }
        reevaluationCount += 1
        for index in locations.indices { locations[index].dirty = false }
        return true
    }

    func isLive(_ location: UInt8) -> Bool {
        Int(location) < locations.count && locations[Int(location)].live
    }

    func values(_ model: Store.Model) -> (Int32, Int32) { store.values(of: model) }
    func identity(_ model: Store.Model) -> UInt16 { store.identity(of: model) }

    private func makeToken(registration: UInt8, generation: UInt16) -> UInt32 {
        UInt32(registration) | (UInt32(generation) << 8)
    }

    private func token(for registration: UInt8) -> UInt32 {
        makeToken(
            registration: registration,
            generation: registrations[Int(registration)].generation
        )
    }

    private mutating func detach(location: UInt8) {
        let index = Int(location)
        guard index < locations.count, locations[index].live,
              let model = locations[index].model else { return }
        let registrationIndex = Int(locations[index].registration)
        store.setOwnerToken(nil, for: model)
        registrations[registrationIndex].active = false
        locations[index] = Location()
    }
}

struct CaseResult: Equatable {
    let id: String
    let expected: String
    let actual: String
    let identity: String
    let dirtyTransitions: Int
    let reevaluations: Int
    let generationEvidence: String

    var passed: Bool { expected == actual }
}

func runSharedCases<Store: FixtureModelStore>(profile: String, initialStore: Store) -> [CaseResult] {
    var results: [CaseResult] = []

    do {
        var runtime = FixtureRuntime(store: initialStore)
        let first = runtime.store.create(control: 1, capture: 2)
        let materialized = runtime.materialize(location: 0, initial: first)
        let identity = runtime.identity(materialized.1!)
        let descendant = BorrowedDescendant(model: materialized.1!)
        var preserved = true
        for _ in 0..<5 {
            let repeated = runtime.store.create(control: 99, capture: 99)
            let fixture = PortableFixture(model: repeated)
            let again = runtime.materialize(location: 0, initial: fixture.model)
            preserved = preserved && runtime.identity(again.1!) == identity
        }
        preserved = preserved && runtime.identity(descendant.model) == identity
        results.append(CaseResult(id: "preservation", expected: "preserved", actual: preserved ? "preserved" : "replaced", identity: "model-\(identity)", dirtyTransitions: 0, reevaluations: 0, generationEvidence: "token-\(materialized.2!)"))
    }

    do {
        var runtime = FixtureRuntime(store: initialStore)
        let model = runtime.store.create(control: 0, capture: 0)
        _ = runtime.materialize(location: 0, initial: model)
        for _ in 0..<20 { runtime.mutate(model, controlDelta: 1, captureDelta: 1) }
        let reevaluated = runtime.reevaluateDirtyRoot()
        let values = runtime.values(model)
        let actual = runtime.wakeCount == 1 && runtime.reevaluationCount == 1 && reevaluated && values == (20, 20) ? "coalesced" : "mismatch"
        results.append(CaseResult(id: "coalescing-20", expected: "coalesced", actual: actual, identity: "model-\(runtime.identity(model))", dirtyTransitions: runtime.wakeCount, reevaluations: runtime.reevaluationCount, generationEvidence: "active"))
    }

    do {
        var runtime = FixtureRuntime(store: initialStore)
        let model = runtime.store.create(control: 0, capture: 4)
        _ = runtime.materialize(location: 0, initial: model)
        runtime.admittedExternalFact(model, captureDelta: 7)
        let actual = runtime.values(model).1 == 11 && runtime.reevaluateDirtyRoot() ? "admitted" : "mismatch"
        results.append(CaseResult(id: "external-fact", expected: "admitted", actual: actual, identity: "model-\(runtime.identity(model))", dirtyTransitions: runtime.wakeCount, reevaluations: runtime.reevaluationCount, generationEvidence: "serialized"))
    }

    do {
        var runtime = FixtureRuntime(store: initialStore)
        let old = runtime.store.create(control: 1, capture: 1)
        let oldResult = runtime.materialize(location: 0, initial: old)
        let replacement = runtime.store.create(control: 8, capture: 9)
        let newResult = runtime.replace(location: 0, with: replacement)
        let staleRejected = !runtime.report(token: oldResult.2!)
        let freshAccepted = runtime.report(token: newResult.1!)
        let actual = newResult.0 == .ok && staleRejected && freshAccepted ? "detached-attached" : "mismatch"
        results.append(CaseResult(id: "replacement", expected: "detached-attached", actual: actual, identity: "model-\(runtime.identity(replacement))", dirtyTransitions: runtime.wakeCount, reevaluations: runtime.reevaluationCount, generationEvidence: "old-\(oldResult.2!)-new-\(newResult.1!)"))
    }

    do {
        var runtime = FixtureRuntime(store: initialStore)
        let removed = runtime.store.create(control: 0, capture: 0)
        let removedResult = runtime.materialize(location: 0, initial: removed)
        runtime.publish(liveLocations: [])
        let afterRemovalRejected = !runtime.report(token: removedResult.2!)
        let fresh = runtime.store.create(control: 3, capture: 3)
        let freshResult = runtime.materialize(location: 0, initial: fresh)
        let afterReuseRejected = !runtime.report(token: removedResult.2!)
        let freshAccepted = runtime.report(token: freshResult.2!)
        let actual = afterRemovalRejected && afterReuseRejected && freshAccepted ? "stale-rejected" : "mismatch"
        results.append(CaseResult(id: "removal-reuse", expected: "stale-rejected", actual: actual, identity: "model-\(runtime.identity(fresh))", dirtyTransitions: runtime.wakeCount, reevaluations: runtime.reevaluationCount, generationEvidence: "old-\(removedResult.2!)-new-\(freshResult.2!)"))
    }

    do {
        var runtime = FixtureRuntime(store: initialStore)
        let model = runtime.store.create(control: 0, capture: 0)
        let result = runtime.materialize(location: 0, initial: model)
        runtime.mutate(model, controlDelta: 1, captureDelta: 0)
        runtime.failedDerivation(candidateLiveLocations: [])
        let stayedLive = runtime.isLive(0)
        let rederived = runtime.reevaluateDirtyRoot()
        let noReplay = runtime.values(model).0 == 1
        let actual = stayedLive && rederived && noReplay ? "live-rederived-no-replay" : "mismatch"
        results.append(CaseResult(id: "failed-derivation", expected: "live-rederived-no-replay", actual: actual, identity: "model-\(runtime.identity(model))", dirtyTransitions: runtime.wakeCount, reevaluations: runtime.reevaluationCount, generationEvidence: "token-\(result.2!)"))
    }

    do {
        var runtime = FixtureRuntime(store: initialStore)
        let model = runtime.store.create(control: 0, capture: 0)
        _ = runtime.materialize(location: 0, initial: model)
        let duplicate = runtime.materialize(location: 1, initial: model)
        results.append(CaseResult(id: "duplicate-owner", expected: "duplicate-owner", actual: duplicate.0.rawValue, identity: "model-\(runtime.identity(model))", dirtyTransitions: 0, reevaluations: 0, generationEvidence: "one-owner"))
    }

    do {
        var runtime = FixtureRuntime(store: initialStore, stateCapacity: 1, registrationCapacity: 2)
        let first = runtime.store.create(control: 0, capture: 0)
        let second = runtime.store.create(control: 0, capture: 0)
        _ = runtime.materialize(location: 0, initial: first)
        let exhausted = runtime.materialize(location: 1, initial: second)
        results.append(CaseResult(id: "state-exhaustion", expected: "state-exhausted", actual: exhausted.0.rawValue, identity: "none", dirtyTransitions: 0, reevaluations: 0, generationEvidence: "state-cap-1"))
    }

    do {
        var runtime = FixtureRuntime(store: initialStore, stateCapacity: 2, registrationCapacity: 1)
        let first = runtime.store.create(control: 0, capture: 0)
        let second = runtime.store.create(control: 0, capture: 0)
        _ = runtime.materialize(location: 0, initial: first)
        let exhausted = runtime.materialize(location: 1, initial: second)
        results.append(CaseResult(id: "registration-exhaustion", expected: "registration-exhausted", actual: exhausted.0.rawValue, identity: "none", dirtyTransitions: 0, reevaluations: 0, generationEvidence: "registration-cap-1"))
    }

    for result in results {
        print("\(profile)\t\(result.id)\t\(result.expected)\t\(result.actual)\t\(result.identity)\t\(result.dirtyTransitions)\t\(result.reevaluations)\t\(result.generationEvidence)")
    }
    return results
}

print("profile\tcase\texpected\tactual\tidentity\tdirty-transitions\treevaluations\tgeneration-evidence")
let dynamic = runSharedCases(profile: "dynamic-class", initialStore: DynamicModelStore())
let staticResults = runSharedCases(profile: "static-handle", initialStore: StaticModelStore())

precondition(dynamic.count == staticResults.count)
for index in dynamic.indices {
    precondition(dynamic[index].id == staticResults[index].id)
    precondition(dynamic[index].expected == staticResults[index].expected)
    precondition(dynamic[index].actual == staticResults[index].actual)
    precondition(dynamic[index].passed && staticResults[index].passed)
}
