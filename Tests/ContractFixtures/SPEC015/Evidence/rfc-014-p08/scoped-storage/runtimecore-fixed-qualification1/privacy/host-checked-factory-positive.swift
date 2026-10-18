import GiftUIHostConfiguration
@_lifetime(copy owner)
package func forward<Owner: SignalAnalyzerPresetLiveOwner & ~Copyable & ~Escapable>(report: HostAssemblyReport, owner: consuming Owner) -> SignalAnalyzerPresetHostInstance<Owner>? where Owner.ActivationFailure == MacOSStaticHostActivationFailure { SignalAnalyzerPresetHostInstances.macOSStatic(report: report, owner: consume owner) }
