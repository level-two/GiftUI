import GiftUIDrawing
import GiftUIHostConfiguration
import GiftUIRuntimeCore
import GiftUIRuntimeStatic

/// Owns the application and Static profile halves of one validated nRF
/// runtime composition. The caller retains the profile buffer for this
/// value's complete lifetime.
package struct StaticSignalAnalyzerNRFRuntimeStorage<Metadata>: ~Copyable
where Metadata: RuntimeStaticCanvasAuditMetadata & StaticCanvasCallableTable {
    package var application: StaticSignalAnalyzerNRFApplicationStorage
    package var profile:
        StaticRuntimeProfileBinding<StaticSignalAnalyzerNRFProfileRegions, Metadata>
    package var pacing: HostWakePacingController

    package init?(
        assemblyReport: HostAssemblyReport,
        inputSourceRawValue: UInt16,
        initialFrameOriginMicroseconds: UInt64,
        profileStorage: UnsafeMutableRawBufferPointer,
        metadata: consuming Metadata
    ) {
        guard
            let application = StaticSignalAnalyzerNRFApplicationStorage(
                assemblyReport: assemblyReport,
                inputSourceRawValue: inputSourceRawValue
            ),
            let profile = StaticSignalAnalyzerNRFProfileBinding.make(
                assemblyReport: assemblyReport,
                storage: profileStorage,
                metadata: consume metadata
            )
        else { return nil }

        self.application = consume application
        self.profile = consume profile
        pacing = HostWakePacingController(
            policy: GeneratedSignalAnalyzerPresets.nrf52840Static().pacing,
            initialFrameOriginMicroseconds: initialFrameOriginMicroseconds
        )
    }

    /// Lends both owners for one complete address-stable composition scope.
    /// The body must finish an active profile opportunity before returning.
    package mutating func withAddressStableOwners<Result>(
        _ body: (
            inout StaticSignalAnalyzerNRFApplicationOwner,
            inout StaticRuntimeProfileBinding<
                StaticSignalAnalyzerNRFProfileRegions,
                Metadata
            >,
            inout HostWakePacingController
        ) -> Result
    ) -> Result {
        defer {
            profile.quiesce()
            _ = pacing.quiesce()
        }
        return application.withAddressStableOwner { application in
            body(&application, &profile, &pacing)
        }
    }
}
