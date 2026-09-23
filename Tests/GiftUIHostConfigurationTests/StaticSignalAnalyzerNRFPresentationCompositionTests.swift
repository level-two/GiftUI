import GiftUIHostConfiguration
import SignalAnalyzerDomain
import SignalAnalyzerTargetHost
import Testing

private struct StaticNRFCompositionRecordingTransport:
    StaticSignalAnalyzerNRFDisplayTransport
{
    mutating func presentRGB565BigEndian(
        x: UInt16,
        y: UInt16,
        pixelCount: UInt16,
        bytes: UnsafeRawBufferPointer
    ) -> Bool { true }
}

@Test func staticNRFPresentationCompositionJoinsOneScopedEndpoint() {
    guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate() else {
        Issue.record("Static nRF assembly did not validate")
        return
    }
    let profile = UnsafeMutableRawPointer.allocate(byteCount: 36_368, alignment: 8)
    defer { profile.deallocate() }
    let capture = UnsafeMutableRawPointer.allocate(byteCount: 115_392, alignment: 8)
    defer { capture.deallocate() }
    let raster = UnsafeMutableRawPointer.allocate(byteCount: 3_840, alignment: 8)
    defer { raster.deallocate() }
    let coverage = UnsafeMutableRawPointer.allocate(byteCount: 240, alignment: 8)
    defer { coverage.deallocate() }

    let joined = StaticSignalAnalyzerNRFPresentationComposition.withOwners(
        assemblyReport: report,
        inputSourceRawValue: 51,
        initialFrameOriginMicroseconds: 0,
        profileStorage: UnsafeMutableRawBufferPointer(start: profile, count: 36_368),
        captureRegion: UnsafeMutableRawBufferPointer(start: capture, count: 115_392),
        rasterRegion: UnsafeMutableRawBufferPointer(start: raster, count: 3_840),
        coverageRegion: UnsafeMutableRawBufferPointer(start: coverage, count: 240),
        transport: StaticNRFCompositionRecordingTransport()
    ) {
        application, profile, captureOwner, captureHistory, pacing, identities, first, endpoint,
        health -> UInt32?
        in
        let rootIsActive = application.rootIsActive
        #expect(!rootIsActive)
        #expect(profile.storageLifetimeState == .beforeUse)
        #expect(pacing.schedule(at: 0) == .noWork)
        #expect(endpoint.health().state == .available)
        #expect(!health.inputIsEligible)
        #expect(first.provenance.semanticRevision.rawValue == 1)
        let transition = SignalTransition(
            channelID: SignalChannelID(rawValue: 1),
            timestamp: .microseconds(1),
            level: .high
        )
        let result = captureHistory.receive(transition, in: &captureOwner)
        let loaded = captureOwner.load(from: .live, at: 0)?.transition
        #expect(captureHistory.count == 1)
        #expect(captureHistory.revision == 1)
        #expect(result != .rejected(.invalidTransition))
        #expect(loaded == transition)
        return identities.reserve()?.provenance.cycle.rawValue
    }
    #expect(joined == 1)
}

@Test func staticNRFPresentationCompositionRejectsOverlappingRegionsBeforeBody() {
    guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate() else {
        Issue.record("Static nRF assembly did not validate")
        return
    }
    let storage = UnsafeMutableRawPointer.allocate(byteCount: 40_208, alignment: 8)
    defer { storage.deallocate() }
    let capture = UnsafeMutableRawPointer.allocate(byteCount: 115_392, alignment: 8)
    defer { capture.deallocate() }
    var bodyCalls = 0
    let joined: Void? = StaticSignalAnalyzerNRFPresentationComposition.withOwners(
        assemblyReport: report,
        inputSourceRawValue: 51,
        initialFrameOriginMicroseconds: 0,
        profileStorage: UnsafeMutableRawBufferPointer(start: storage, count: 36_368),
        captureRegion: UnsafeMutableRawBufferPointer(start: capture, count: 115_392),
        rasterRegion: UnsafeMutableRawBufferPointer(
            start: storage.advanced(by: 36_000), count: 3_840
        ),
        coverageRegion: UnsafeMutableRawBufferPointer(
            start: storage.advanced(by: 39_968), count: 240
        ),
        transport: StaticNRFCompositionRecordingTransport()
    ) { _, _, _, _, _, _, _, _, _ in
        bodyCalls += 1
    }
    #expect(joined == nil)
    #expect(bodyCalls == 0)
}

@Test func staticNRFPresentationCompositionRejectsMisalignedProfile() {
    guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate() else {
        Issue.record("Static nRF assembly did not validate")
        return
    }
    let profile = UnsafeMutableRawPointer.allocate(byteCount: 36_369, alignment: 8)
    defer { profile.deallocate() }
    let capture = UnsafeMutableRawPointer.allocate(byteCount: 115_392, alignment: 8)
    defer { capture.deallocate() }
    let raster = UnsafeMutableRawPointer.allocate(byteCount: 3_840, alignment: 8)
    defer { raster.deallocate() }
    let coverage = UnsafeMutableRawPointer.allocate(byteCount: 240, alignment: 8)
    defer { coverage.deallocate() }
    var bodyCalls = 0
    let joined: Void? = StaticSignalAnalyzerNRFPresentationComposition.withOwners(
        assemblyReport: report,
        inputSourceRawValue: 51,
        initialFrameOriginMicroseconds: 0,
        profileStorage: UnsafeMutableRawBufferPointer(
            start: profile.advanced(by: 1), count: 36_368
        ),
        captureRegion: UnsafeMutableRawBufferPointer(start: capture, count: 115_392),
        rasterRegion: UnsafeMutableRawBufferPointer(start: raster, count: 3_840),
        coverageRegion: UnsafeMutableRawBufferPointer(start: coverage, count: 240),
        transport: StaticNRFCompositionRecordingTransport()
    ) { _, _, _, _, _, _, _, _, _ in
        bodyCalls += 1
    }
    #expect(joined == nil)
    #expect(bodyCalls == 0)
}

@Test func staticNRFPresentationCompositionRejectsCaptureOverlap() {
    guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate() else {
        Issue.record("Static nRF assembly did not validate")
        return
    }
    let shared = UnsafeMutableRawPointer.allocate(byteCount: 151_760, alignment: 8)
    defer { shared.deallocate() }
    let raster = UnsafeMutableRawPointer.allocate(byteCount: 3_840, alignment: 8)
    defer { raster.deallocate() }
    let coverage = UnsafeMutableRawPointer.allocate(byteCount: 240, alignment: 8)
    defer { coverage.deallocate() }
    var bodyCalls = 0
    let joined: Void? = StaticSignalAnalyzerNRFPresentationComposition.withOwners(
        assemblyReport: report,
        inputSourceRawValue: 51,
        initialFrameOriginMicroseconds: 0,
        profileStorage: UnsafeMutableRawBufferPointer(start: shared, count: 36_368),
        captureRegion: UnsafeMutableRawBufferPointer(
            start: shared.advanced(by: 8), count: 115_392
        ),
        rasterRegion: UnsafeMutableRawBufferPointer(start: raster, count: 3_840),
        coverageRegion: UnsafeMutableRawBufferPointer(start: coverage, count: 240),
        transport: StaticNRFCompositionRecordingTransport()
    ) { _, _, _, _, _, _, _, _, _ in
        bodyCalls += 1
    }
    #expect(joined == nil)
    #expect(bodyCalls == 0)
}
