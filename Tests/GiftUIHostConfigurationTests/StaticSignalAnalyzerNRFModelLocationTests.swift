import GiftUIHostConfiguration
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFModelHandlePreservesLocationAndRoutesSixActions() {
    var location = StaticSignalAnalyzerNRFModelLocation()
    let descriptor = GeneratedSignalAnalyzerPresets.nrf52840Static().staticRoot
    #expect(location.structuralIdentity == descriptor?.structuralIdentity)
    #expect(location.declarationOrdinal == descriptor?.declarationOrdinal)
    #expect(
        StaticSignalAnalyzerNRFModelDescriptor.modelStorageSlots == descriptor?.modelStorageSlots)
    #expect(StaticSignalAnalyzerNRFModelDescriptor.locationCapacity == descriptor?.locationCapacity)
    #expect(
        StaticSignalAnalyzerNRFModelDescriptor.registrationCapacity
            == descriptor?.registrationCapacity)
    #expect(
        StaticSignalAnalyzerNRFModelDescriptor.replacementCapacity
            == descriptor?.replacementCapacity)
    withUnsafeMutablePointer(to: &location) { pointer in
        guard let generation = pointer.pointee.activate(),
            let handle = StaticSignalAnalyzerNRFModelHandle(
                location: pointer, generation: generation
            )
        else {
            Issue.record("Static model location did not activate")
            return
        }
        let copy = handle
        #expect(generation == 0)
        #expect(handle.dispatch(actionRawValue: 0) == nil)
        let began = pointer.pointee.beginMutation()
        let repeatedBegin = pointer.pointee.beginMutation()
        #expect(began)
        #expect(!repeatedBegin)
        #expect(handle.dispatch(actionRawValue: 0) == .start)
        #expect(handle.dispatch(actionRawValue: 1) == .stop)
        #expect(handle.dispatch(actionRawValue: 2) == .clear)
        #expect(copy.dispatch(actionRawValue: 3) == .visibleWindowChanged)
        #expect(pointer.pointee.visibleWindowRawValue == 0)
        pointer.pointee.clearDirtyAfterPublication()
        #expect(!pointer.pointee.isDirty)
        #expect(handle.dispatch(actionRawValue: 4) == .visibleWindowChanged)
        #expect(pointer.pointee.visibleWindowRawValue == 1)
        #expect(pointer.pointee.isDirty)
        #expect(copy.dispatch(actionRawValue: 5) == .visibleWindowChanged)
        #expect(pointer.pointee.visibleWindowRawValue == 2)
        #expect(copy.dispatch(actionRawValue: 6) == nil)
        let ended = pointer.pointee.endMutation()
        let repeatedEnd = pointer.pointee.endMutation()
        #expect(ended)
        #expect(!repeatedEnd)
        #expect(handle.dispatch(actionRawValue: 3) == nil)
        #expect(pointer.pointee.visibleWindowRawValue == 2)
        pointer.pointee.retire()
        #expect(handle.dispatch(actionRawValue: 0) == nil)
        #expect(pointer.pointee.activate() == 1)
        #expect(copy.dispatch(actionRawValue: 3) == nil)
    }
}
