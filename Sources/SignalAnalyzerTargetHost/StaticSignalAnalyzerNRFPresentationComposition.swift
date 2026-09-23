import GiftUIHostConfiguration

/// Joins the generated application/profile owners to one borrowed raster
/// endpoint for a complete synchronous presentation lifetime. The caller
/// retains all four disjoint regions until this scope returns.
package enum StaticSignalAnalyzerNRFPresentationComposition {
    package static func withOwners<Transport, Result>(
        assemblyReport: HostAssemblyReport,
        inputSourceRawValue: UInt16,
        initialFrameOriginMicroseconds: UInt64,
        profileStorage: UnsafeMutableRawBufferPointer,
        captureRegion: UnsafeMutableRawBufferPointer,
        rasterRegion: UnsafeMutableRawBufferPointer,
        coverageRegion: UnsafeMutableRawBufferPointer,
        transport: consuming Transport,
        _ body: (
            inout StaticSignalAnalyzerNRFApplicationOwner,
            inout StaticSignalAnalyzerNRFProductionProfileBinding,
            inout StaticSignalAnalyzerNRFCaptureRegions,
            inout HostWakePacingController,
            inout StaticSignalAnalyzerNRFPresentationIdentityOwner,
            StaticSignalAnalyzerNRFPresentationIdentity,
            inout StaticSignalAnalyzerNRFEndpoint<
                StaticSignalAnalyzerNRFDisplayTarget<Transport>
            >,
            inout HostEndpointHealthController
        ) -> Result
    ) -> Result? where Transport: StaticSignalAnalyzerNRFDisplayTransport {
        guard
            regionsAreDisjoint(
                profileStorage, captureRegion, rasterRegion, coverageRegion
            ),
            var capture = StaticSignalAnalyzerNRFCaptureRegions(
                storage: captureRegion
            ),
            let metadata = StaticSignalAnalyzerNRFGeneratedMetadataFactory.make(
                assemblyReport: assemblyReport,
                canvasTable: StaticSignalAnalyzerNRFCanvasCallableTable()
            ),
            var runtime = StaticSignalAnalyzerNRFRuntimeStorage(
                assemblyReport: assemblyReport,
                inputSourceRawValue: inputSourceRawValue,
                initialFrameOriginMicroseconds: initialFrameOriginMicroseconds,
                profileStorage: profileStorage,
                metadata: metadata
            ),
            let initialIdentity = runtime.presentationIdentities.reserve(),
            var endpoint = StaticSignalAnalyzerNRFEndpointFactory.make(
                transport: consume transport,
                provenance: initialIdentity.provenance,
                assemblyReport: assemblyReport,
                rasterRegion: rasterRegion,
                coverageRegion: coverageRegion
            ),
            var health = HostEndpointHealthController(
                initialHealth: endpoint.health(),
                inputIsEligible: false
            )
        else { return nil }

        return runtime.withAddressStableOwners {
            application, profile, pacing, identities in
            body(
                &application,
                &profile,
                &capture,
                &pacing,
                &identities,
                initialIdentity,
                &endpoint,
                &health
            )
        }
    }

    private static func regionsAreDisjoint(
        _ profile: UnsafeMutableRawBufferPointer,
        _ capture: UnsafeMutableRawBufferPointer,
        _ raster: UnsafeMutableRawBufferPointer,
        _ coverage: UnsafeMutableRawBufferPointer
    ) -> Bool {
        aligned(profile) && aligned(capture) && aligned(raster)
            && aligned(coverage)
            && disjoint(profile, capture) && disjoint(profile, raster)
            && disjoint(profile, coverage) && disjoint(capture, raster)
            && disjoint(capture, coverage) && disjoint(raster, coverage)
    }

    private static func aligned(_ region: UnsafeMutableRawBufferPointer) -> Bool {
        guard let address = region.baseAddress else { return false }
        return UInt(bitPattern: address) & 7 == 0
    }

    private static func disjoint(
        _ first: UnsafeMutableRawBufferPointer,
        _ second: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let firstAddress = first.baseAddress,
            let secondAddress = second.baseAddress,
            first.count > 0, second.count > 0
        else { return false }
        let a = UInt(bitPattern: firstAddress)
        let b = UInt(bitPattern: secondAddress)
        guard a <= UInt.max - UInt(first.count),
            b <= UInt.max - UInt(second.count)
        else { return false }
        return a + UInt(first.count) <= b || b + UInt(second.count) <= a
    }
}
