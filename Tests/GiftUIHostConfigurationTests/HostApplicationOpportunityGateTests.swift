import Testing

@testable import GiftUIHostConfiguration

@Test func applicationOpportunityGateSerializesEntryAndCompletion() {
    var gate = HostApplicationOpportunityGate()

    #expect(gate.isAvailable)
    #expect(!gate.isExecuting)
    #expect(gate.begin() == .admitted)
    #expect(gate.isExecuting)
    #expect(gate.begin() == .rejected(.reentrant))
    #expect(gate.complete() == nil)
    #expect(!gate.isExecuting)
    #expect(gate.complete() == .invalidCompletion)
}

@Test func applicationOpportunityGateQuiescesOnlyOutsideAnOpportunity() {
    var gate = HostApplicationOpportunityGate()

    #expect(gate.begin() == .admitted)
    #expect(gate.quiesce() == .reentrant)
    #expect(gate.complete() == nil)
    #expect(gate.quiesce() == nil)
    #expect(!gate.isAvailable)
    #expect(gate.begin() == .rejected(.unavailable))
    #expect(gate.complete() == .invalidCompletion)
    #expect(gate.quiesce() == nil)
}
