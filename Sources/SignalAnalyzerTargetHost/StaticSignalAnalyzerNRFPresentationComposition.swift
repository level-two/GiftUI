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
            inout StaticSignalAnalyzerNRFCaptureHistory,
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
            StaticSignalAnalyzerNRFRegionMap.validate(
                profile: profileStorage,
                capture: captureRegion,
                raster: rasterRegion,
                coverage: coverageRegion
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

        var captureHistory = StaticSignalAnalyzerNRFCaptureHistory()
        return runtime.withAddressStableOwners {
            application, profile, pacing, identities in
            body(
                &application,
                &profile,
                &capture,
                &captureHistory,
                &pacing,
                &identities,
                initialIdentity,
                &endpoint,
                &health
            )
        }
    }

}
