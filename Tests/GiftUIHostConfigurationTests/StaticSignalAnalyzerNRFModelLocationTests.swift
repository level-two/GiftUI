import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFModelHandlePreservesLocationAndRoutesSixActions() {
    var location = StaticSignalAnalyzerNRFModelLocation()
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
        pointer.pointee.retire()
        #expect(handle.dispatch(actionRawValue: 0) == nil)
        #expect(pointer.pointee.activate() == 1)
        #expect(copy.dispatch(actionRawValue: 3) == nil)
    }
}
