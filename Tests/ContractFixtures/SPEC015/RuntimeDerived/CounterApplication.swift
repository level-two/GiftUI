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
        let p08Presence72: Bool;
        if case .none = observation { p08Presence72 = true } else { p08Presence72 = false };
        precondition(p08Presence72)
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
        guard case .some = observation else { return false }
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
    private let control: UnsafeMutablePointer<CounterControl>
    private let producerOrigin: CounterProducerOrigin?
    init(control: UnsafeMutablePointer<CounterControl>) {
        self.control = control
        producerOrigin = CounterControl.snapshotProducerOrigin(at: control)
        control.pointee.applicationConstructions += 1
    }
    var constructedProjectionIsValid: Bool {
        if CounterControl.acceptsProducer(at: control, producerOrigin) {
            if source.running {
                if source.emissionCount == 1 {
                    if repository.publicationCount == 1 {
                        if repository.observation == observation {
                            if case .some = observation {
                                if useCases.startCalls == 1 {
                                    if gate.isAvailable {
                                        if !gate.isExecuting {
                                            if deliveryEnabled {
                                                if inputEnabled {
                                                    if control.pointee.applicationConstructions == 1
                                                    {
                                                        return true
                                                    } else {
                                                        return false
                                                    }
                                                } else {
                                                    return false
                                                }
                                            } else {
                                                return false
                                            }
                                        } else {
                                            return false
                                        }
                                    } else {
                                        return false
                                    }
                                } else {
                                    return false
                                }
                            } else {
                                return false
                            }
                        } else {
                            return false
                        }
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    mutating func installObservation() -> UInt8 {
        guard CounterControl.acceptsProducer(at: control, producerOrigin) else { return repository.value }
        let installed = repository.observe()
        observation = installed.token
        control.pointee.observationsInstalled += 1
        return installed.current
    }
    mutating func startSource() -> Bool {
        guard CounterControl.acceptsProducer(at: control, producerOrigin) else { return false }
        guard gate.begin() == .admitted else { return false }
        defer {
            let p08Presence73: Bool;
            if case .none = gate.complete() { p08Presence73 = true } else { p08Presence73 = false };
            precondition(p08Presence73)
        }
        return withUnsafeMutablePointer(to: &self) { application in
            application.pointee.useCases.start(source: &application.pointee.source, repository: &application.pointee.repository) { value in
                return application.pointee.deliver(value)
            }
        }
    }
    private mutating func deliver(_ value: UInt8) -> Bool {
        guard CounterControl.acceptsProducer(at: control, producerOrigin), deliveryEnabled else { return false }
        let p08ExactCase86: Bool;
        if case .rejected(.reentrant) = gate.begin() {
            p08ExactCase86 = true
        } else {
            p08ExactCase86 = false
        }; precondition(p08ExactCase86)
        control.pointee.reentrantApplicationRejections += 1
        let p08ExactCase87: Bool;
        if case .idle = control.pointee.context.phase {
            if !control.pointee.frameActive {
                p08ExactCase87 = true
            } else {
                p08ExactCase87 = false
            }
        } else {
            p08ExactCase87 = false
        }; precondition(p08ExactCase87)
        var admission = CounterAdmission(borrowing: control)
        let accepted = admission.submit(stateChange: value).result == .queued
        if accepted { control.pointee.applicationCallbacks += 1 }
        return accepted
    }
    mutating func serviceSource(value: UInt8) -> Bool {
        guard CounterControl.acceptsProducer(at: control, producerOrigin), deliveryEnabled, gate.begin() == .admitted else { return false }
        defer {
            let p08Presence74: Bool;
            if case .none = gate.complete() { p08Presence74 = true } else { p08Presence74 = false };
            precondition(p08Presence74)
        }
        return withUnsafeMutablePointer(to: &self) { application in
            application.pointee.source.service(value: value) { value in
                application.pointee.repository.receive(value) { application.pointee.deliver($0) }
            }
        }
    }
    mutating func stopDelivery() {
        guard CounterControl.acceptsProducer(at: control, producerOrigin) else { return }
        deliveryEnabled = false; inputEnabled = false
        source.stop()
        if let token = observation.take() {
            repository.detach(token)
            control.pointee.observationsDetached += 1
        }
        let p08Presence75: Bool;
        if case .none = gate.quiesce() { p08Presence75 = true } else { p08Presence75 = false };
        precondition(p08Presence75)
        // Both actual stopped owners refuse callback delivery. These callback
        // bodies must remain uncalled after shutdown, before owner release.
        precondition(!source.service(value: 1) { _ in preconditionFailure("stopped counter source delivered") })
        precondition(!repository.receive(1) { _ in preconditionFailure("detached counter observation delivered") })
        let p08ExactCase88: Bool;
        if case .rejected(.unavailable) = gate.begin() {
            p08ExactCase88 = true
        } else {
            p08ExactCase88 = false
        }; precondition(p08ExactCase88)
        control.pointee.stoppedApplicationChecks += 1
    }
}
