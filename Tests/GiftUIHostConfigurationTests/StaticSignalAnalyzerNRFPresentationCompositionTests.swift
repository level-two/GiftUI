import GiftUIHostConfiguration
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
    let raster = UnsafeMutableRawPointer.allocate(byteCount: 3_840, alignment: 8)
    defer { raster.deallocate() }
    let coverage = UnsafeMutableRawPointer.allocate(byteCount: 240, alignment: 8)
    defer { coverage.deallocate() }

    let joined = StaticSignalAnalyzerNRFPresentationComposition.withOwners(
        assemblyReport: report,
        inputSourceRawValue: 51,
        initialFrameOriginMicroseconds: 0,
        profileStorage: UnsafeMutableRawBufferPointer(start: profile, count: 36_368),
        rasterRegion: UnsafeMutableRawBufferPointer(start: raster, count: 3_840),
        coverageRegion: UnsafeMutableRawBufferPointer(start: coverage, count: 240),
        transport: StaticNRFCompositionRecordingTransport()
    ) { application, profile, pacing, identities, first, endpoint, health in
        let rootIsActive = application.rootIsActive
        #expect(!rootIsActive)
        #expect(profile.storageLifetimeState == .beforeUse)
        #expect(pacing.schedule(at: 0) == .noWork)
        #expect(endpoint.health().state == .available)
        #expect(!health.inputIsEligible)
        #expect(first.provenance.semanticRevision.rawValue == 1)
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
    var bodyCalls = 0
    let joined: Void? = StaticSignalAnalyzerNRFPresentationComposition.withOwners(
        assemblyReport: report,
        inputSourceRawValue: 51,
        initialFrameOriginMicroseconds: 0,
        profileStorage: UnsafeMutableRawBufferPointer(start: storage, count: 36_368),
        rasterRegion: UnsafeMutableRawBufferPointer(
            start: storage.advanced(by: 36_000), count: 3_840
        ),
        coverageRegion: UnsafeMutableRawBufferPointer(
            start: storage.advanced(by: 39_968), count: 240
        ),
        transport: StaticNRFCompositionRecordingTransport()
    ) { _, _, _, _, _, _, _ in
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
        rasterRegion: UnsafeMutableRawBufferPointer(start: raster, count: 3_840),
        coverageRegion: UnsafeMutableRawBufferPointer(start: coverage, count: 240),
        transport: StaticNRFCompositionRecordingTransport()
    ) { _, _, _, _, _, _, _ in
        bodyCalls += 1
    }
    #expect(joined == nil)
    #expect(bodyCalls == 0)
}
