import GiftUI
import GiftUIExecution
import GiftUIHostConfiguration

// Finite scalar application owners for the approved counter, with synchronous
// callback arguments. No observer closure, admission adapter or model alias is
// retained by the source/repository/use cases.
struct CounterFactSource {
    private(set) var value: UInt8 = 0
    private(set) var running = false
    private(set) var emissionCount = 0
    mutating func start(deliver: (UInt8) -> Bool) -> Bool {
        guard !running else { return false }
        running = true
        return service(value: value, deliver: deliver)
    }
    mutating func service(value: UInt8, deliver: (UInt8) -> Bool) -> Bool {
        guard running, value <= 9 else { return false }
        self.value = value; emissionCount += 1
        return deliver(value)
    }
    mutating func stop() { running = false }
}
struct CounterFactRepository {
    private(set) var value: UInt8 = 0
    private(set) var observation: UInt32?
    private(set) var publicationCount = 0
    mutating func observe() -> (token: UInt32, current: UInt8) {
        precondition(observation == nil)
        observation = 1
        return (1, value)
    }
    mutating func detach(_ token: UInt32) {
        precondition(observation == token)
        observation = nil
    }
    mutating func receive(_ value: UInt8, notify: (UInt8) -> Bool) -> Bool {
        guard value <= 9 else { return false }
        self.value = value
        guard observation != nil else { return false }
        publicationCount += 1
        return notify(value)
    }
}
struct CounterFactUseCases {
    private(set) var startCalls = 0
    mutating func start(source: inout CounterFactSource, repository: inout CounterFactRepository, deliver: (UInt8) -> Bool) -> Bool {
        startCalls += 1
        return source.start { value in repository.receive(value, notify: deliver) }
    }
}
struct CounterApplicationOwners {
    var source = CounterFactSource()
    var repository = CounterFactRepository()
    var useCases = CounterFactUseCases()
    var observation: UInt32?
    var deliveryEnabled = false
    var inputEnabled = false
    var gate = HostApplicationOpportunityGate()
    let control: UnsafeMutablePointer<CounterControl>
    init(control: UnsafeMutablePointer<CounterControl>) {
        self.control = control
        control.pointee.applicationConstructions += 1
    }
    var constructedProjectionIsValid: Bool {
        source.running && source.emissionCount == 1 && repository.publicationCount == 1
            && repository.observation == observation && observation != nil
            && useCases.startCalls == 1 && gate.isAvailable && !gate.isExecuting
            && deliveryEnabled && inputEnabled && control.pointee.applicationConstructions == 1
    }
    mutating func installObservation() -> UInt8 {
        let installed = repository.observe()
        observation = installed.token
        control.pointee.observationsInstalled += 1
        return installed.current
    }
    mutating func startSource() -> Bool {
        guard gate.begin() == .admitted else { return false }
        defer { precondition(gate.complete() == nil) }
        return withUnsafeMutablePointer(to: &self) { application in
            application.pointee.useCases.start(source: &application.pointee.source, repository: &application.pointee.repository) { value in
                // This reentrant application opportunity is rejected while the
                // real source→repository callback is still on the stack.
                precondition(application.pointee.gate.begin() == .rejected(.reentrant))
                let control = application.pointee.control
                control.pointee.reentrantApplicationRejections += 1
                guard application.pointee.deliveryEnabled else { return false }
                precondition(control.pointee.context.phase == .idle && !control.pointee.frameActive)
                var admission = CounterAdmission(borrowing: control)
                let accepted = admission.submit(stateChange: value).result == .queued
                if accepted { control.pointee.applicationCallbacks += 1 }
                return accepted
            }
        }
    }
    mutating func stopDelivery() {
        deliveryEnabled = false; inputEnabled = false
        source.stop()
        if let token = observation.take() {
            repository.detach(token)
            control.pointee.observationsDetached += 1
        }
        precondition(gate.quiesce() == nil)
        // Both actual stopped owners refuse callback delivery. These callback
        // bodies must remain uncalled after shutdown, before owner release.
        precondition(!source.service(value: 1) { _ in preconditionFailure("stopped counter source delivered") })
        precondition(!repository.receive(1) { _ in preconditionFailure("detached counter observation delivered") })
        precondition(gate.begin() == .rejected(.unavailable))
        control.pointee.stoppedApplicationChecks += 1
    }
}
