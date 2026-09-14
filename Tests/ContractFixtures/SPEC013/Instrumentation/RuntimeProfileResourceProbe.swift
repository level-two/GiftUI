package enum RuntimeProfileStackStage: UInt8, CaseIterable, Sendable {
    case construction
    case admission
    case derivation
    case canvasInvocation
    case rendering
    case offer
    case finalization
}

package struct RuntimeProfileResourceSnapshot: Equatable, Sendable {
    package private(set) var stackConstruction: UInt64 = 0
    package private(set) var stackAdmission: UInt64 = 0
    package private(set) var stackDerivation: UInt64 = 0
    package private(set) var stackCanvasInvocation: UInt64 = 0
    package private(set) var stackRendering: UInt64 = 0
    package private(set) var stackOffer: UInt64 = 0
    package private(set) var stackFinalization: UInt64 = 0
    package private(set) var heapAllocations: UInt64 = 0
    package private(set) var peakHeapBytes: UInt64 = 0
    package private(set) var dynamicAllocatorBookkeeping: UInt64 = 0
    package private(set) var excludedTextResourceBytes: UInt64 = 0
    package private(set) var excludedCapabilityBytes: UInt64 = 0
    package private(set) var excludedBackendBytes: UInt64 = 0
    package private(set) var excludedHostBytes: UInt64 = 0
    package private(set) var generatedCanvasCodeBytes: UInt64 = 0
    package private(set) var greatestInlineCaptureBytes: UInt64 = 0
    package private(set) var linkedTextBytes: UInt64 = 0
    package private(set) var linkedReadOnlyDataBytes: UInt64 = 0
    package private(set) var linkedWritableDataBytes: UInt64 = 0
    package private(set) var linkedBSSBytes: UInt64 = 0
    package private(set) var linkedTotalImageBytes: UInt64 = 0
    package private(set) var smallFixtureCycleTimeNanoseconds: UInt64 = 0
    package private(set) var signalAnalyzerCycleTimeNanoseconds: UInt64 = 0
    package private(set) var countersSaturated = false

    package mutating func observeStack(stage: RuntimeProfileStackStage, bytes: UInt64) {
        switch stage {
        case .construction: stackConstruction = max(stackConstruction, bytes)
        case .admission: stackAdmission = max(stackAdmission, bytes)
        case .derivation: stackDerivation = max(stackDerivation, bytes)
        case .canvasInvocation: stackCanvasInvocation = max(stackCanvasInvocation, bytes)
        case .rendering: stackRendering = max(stackRendering, bytes)
        case .offer: stackOffer = max(stackOffer, bytes)
        case .finalization: stackFinalization = max(stackFinalization, bytes)
        }
    }

    package mutating func recordHeap(allocations: UInt64, peakBytes: UInt64, bookkeeping: UInt64) {
        heapAllocations = adding(heapAllocations, allocations)
        peakHeapBytes = max(peakHeapBytes, peakBytes)
        dynamicAllocatorBookkeeping = max(dynamicAllocatorBookkeeping, bookkeeping)
    }

    package mutating func recordExcludedBytes(text: UInt64, capability: UInt64, backend: UInt64, host: UInt64) {
        excludedTextResourceBytes = max(excludedTextResourceBytes, text)
        excludedCapabilityBytes = max(excludedCapabilityBytes, capability)
        excludedBackendBytes = max(excludedBackendBytes, backend)
        excludedHostBytes = max(excludedHostBytes, host)
    }

    package mutating func recordGeneratedCanvas(code: UInt64, greatestCapture: UInt64) {
        generatedCanvasCodeBytes = max(generatedCanvasCodeBytes, code)
        greatestInlineCaptureBytes = max(greatestInlineCaptureBytes, greatestCapture)
    }

    package mutating func recordLinkedSections(
        text: UInt64, readOnlyData: UInt64, writableData: UInt64, bss: UInt64, total: UInt64
    ) {
        linkedTextBytes = text
        linkedReadOnlyDataBytes = readOnlyData
        linkedWritableDataBytes = writableData
        linkedBSSBytes = bss
        linkedTotalImageBytes = total
    }

    package mutating func recordCycleTime(smallFixture: UInt64, signalAnalyzer: UInt64) {
        smallFixtureCycleTimeNanoseconds = smallFixture
        signalAnalyzerCycleTimeNanoseconds = signalAnalyzer
    }

    private mutating func adding(_ current: UInt64, _ increment: UInt64) -> UInt64 {
        let result = current.addingReportingOverflow(increment)
        if result.overflow { countersSaturated = true }
        return result.overflow ? .max : result.partialValue
    }
}
