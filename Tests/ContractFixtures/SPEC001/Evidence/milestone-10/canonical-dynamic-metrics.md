# T10.3 — Inject the selected canonical metrics view

2026-10-02, macOS host-native production-owner tests.

DynamicSignalAnalyzerPresentationPipeline is generic over the existing
CanonicalTextMetricsView contract and stores the host-supplied immutable view.
Its initializer checks the selected first font-instance identity and checked
line-height arithmetic. Layout, combined preflight and render streaming all
borrow this same view. The pipeline imports GiftUITextResources, names no Pi
assembly and imports no concrete font package. PiAssembly retains concrete
selection; PiInitialPresentationOwner supplies that selected metrics view and
PiEndpoint consumes the same assembly-selected raster package. Host validation
still validates the complete package before device activation.

The added canonical-metrics regression validates the selected Inter package,
rejects a deliberately mismatched compact-metrics/reference-raster pair using
the existing TextResourceValidator (invalidCount precedes incompatibleViews
because those package catalogues differ in realization/manifest cardinality),
and derives the same 95-glyph diagnostic presentation. Existing production
layout/render, full diagnostic and endpoint raster tests preserve approved
current behavior. No font or resource-identity substitution was introduced.

`scripts/format-swift.sh` was run. The focused command
`swift test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE --filter 'dynamic.*(Derivation|Pi|TargetHost|Pipeline)|reference.*(Font|Metrics)|[Ff]ont.*[Ll]ayout'`
passes 19 tests, including T10.2's six fault cases, production layout and raster,
committed routing and host lifecycle. These are host-native tests, not physical
Pi display/pixel-review evidence.
