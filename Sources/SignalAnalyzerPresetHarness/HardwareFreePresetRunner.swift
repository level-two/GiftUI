import GiftUICapabilities
import GiftUIHostConfiguration
import GiftUIRuntimeCore
import SignalAnalyzerDomain
import SignalAnalyzerHost
import SignalAnalyzerPresentation

package enum HardwareFreePresetSelection: UInt8, Sendable {
    case macOSDynamic
    case macOSStatic
    case raspberryPiDynamic
    case nrf52840Static
}

package enum HardwareFreePresetFailure: UInt8, Error, Sendable {
    case invalidGraph
    case invalidStorageAudit
    case unavailableCapability
    case invalidPhysicalProjection
    case invalidSemanticWorkload
}

package struct HardwareFreePresetReport: Equatable, Sendable {
    package let selection: HardwareFreePresetSelection
    package let profile: RuntimeProfileKind
    package let logicalWidth: UInt16
    package let logicalHeight: UInt16
    package let regionHeight: UInt16
    package let bytesPerRow: UInt32
    package let rasterBytes: UInt32
    package let profileStorageBytes: UInt32
    package let semanticChecksum: UInt32
    package let resolverCalls: UInt8
    package let actionCount: UInt16
    package let compactFactCapacity: UInt16
    package let canvasCount: UInt16
    package let livePointCount: UInt16
    package let planPointCount: UInt16
    package let graphRoleCount: UInt16
    package let semanticNodeCount: UInt16
    package let renderSemanticScopeCount: UInt16
    package let layoutScopeCount: UInt16
    package let traversalDepth: UInt16
    package let textLineCount: UInt16
    package let glyphCount: UInt16
    package let ordinaryOperationCount: UInt16
    package let drawingOperationCount: UInt16
    package let inputEventCount: UInt16
    package let completionFactCount: UInt16

    package var normalizedLine: String {
        [
            "schema=1",
            "preset=\(presetName)",
            "profile=\(profileName)",
            "extent=\(logicalWidth)x\(logicalHeight)",
            "region_height=\(regionHeight)",
            "bytes_per_row=\(bytesPerRow)",
            "raster_bytes=\(rasterBytes)",
            "profile_storage_bytes=\(profileStorageBytes)",
            "semantic_checksum=\(semanticChecksum)",
            "resolver_calls=\(resolverCalls)",
            "actions=\(actionCount)",
            "compact_facts=\(compactFactCapacity)",
            "canvases=\(canvasCount)",
            "live_points=\(livePointCount)",
            "plan_points=\(planPointCount)",
            "graph_roles=\(graphRoleCount)",
            "semantic_nodes=\(semanticNodeCount)",
            "render_semantic_scopes=\(renderSemanticScopeCount)",
            "layout_scopes=\(layoutScopeCount)",
            "traversal_depth=\(traversalDepth)",
            "text_lines=\(textLineCount)",
            "glyphs=\(glyphCount)",
            "ordinary_operations=\(ordinaryOperationCount)",
            "drawing_operations=\(drawingOperationCount)",
            "input_events=\(inputEventCount)",
            "completion_facts=\(completionFactCount)",
            "status=complete",
        ].joined(separator: "\t")
    }

    private var presetName: String {
        switch selection {
        case .macOSDynamic: "macos-dynamic"
        case .macOSStatic: "macos-static"
        case .raspberryPiDynamic: "raspberry-pi-armv6"
        case .nrf52840Static: "nrf52840-embedded"
        }
    }

    private var profileName: String {
        switch profile {
        case .dynamic: "dynamic"
        case .static: "static"
        }
    }
}

package enum HardwareFreePresetRunner {
    package static func run(
        _ selection: HardwareFreePresetSelection
    ) throws(HardwareFreePresetFailure) -> HardwareFreePresetReport {
        let preset = preset(for: selection)
        guard HostComponentGraphValidation.validate(FixedHostComponentGraph()) == nil else {
            throw .invalidGraph
        }
        let audit: RuntimeStorageAudit
        switch preset.validatedStorageAudit() {
        case .valid(let value):
            audit = value
        case .invalid:
            throw .invalidStorageAudit
        }
        guard let effective = resolveCapability(for: preset) else {
            throw .unavailableCapability
        }
        guard effective.extent == preset.capabilityRequirement.extent,
            effective.regionExtent.width == preset.raster.logicalWidth,
            effective.regionExtent.height == preset.raster.regionHeight,
            effective.rowBytes.rawValue == preset.raster.bytesPerRow,
            effective.requiredRasterBytes.rawValue == preset.raster.maximumRasterBytes,
            effective.requiredPayloadBytes.rawValue == preset.raster.maximumPayloadBytes
        else {
            throw .invalidPhysicalProjection
        }

        guard let semanticChecksum = semanticChecksum(for: preset.profile) else {
            throw .invalidSemanticWorkload
        }
        let workload = preset.workload
        guard workload.semanticActionsPerOpportunity == preset.cardinality.actionCaseCount,
            workload.drawing.canvasOccurrences == 5,
            workload.drawing.submittedStrokes == 5,
            workload.drawing.maximumLivePathPoints == 202,
            workload.drawing.snapshottedPoints == 832,
            MemoryLayout<SignalAnalyzerView>.size > 0
        else {
            throw .invalidSemanticWorkload
        }
        switch (preset.profile, preset.staticRoot) {
        case (.dynamic, nil):
            break
        case (.static, .some(let root)):
            guard root.modelStorageSlots == 2,
                root.locationCapacity == 1,
                root.registrationCapacity == 1,
                root.replacementCapacity == 1
            else {
                throw .invalidSemanticWorkload
            }
        default:
            throw .invalidSemanticWorkload
        }

        return HardwareFreePresetReport(
            selection: selection,
            profile: preset.profile,
            logicalWidth: preset.raster.logicalWidth,
            logicalHeight: preset.raster.logicalHeight,
            regionHeight: preset.raster.regionHeight,
            bytesPerRow: preset.raster.bytesPerRow,
            rasterBytes: preset.raster.maximumRasterBytes,
            profileStorageBytes: audit.totalProfileBytes,
            semanticChecksum: semanticChecksum,
            resolverCalls: 1,
            actionCount: preset.cardinality.actionCaseCount,
            compactFactCapacity: preset.cardinality.compactFactCapacity,
            canvasCount: workload.drawing.canvasOccurrences,
            livePointCount: workload.drawing.maximumLivePathPoints,
            planPointCount: workload.drawing.snapshottedPoints,
            graphRoleCount: 18,
            semanticNodeCount: workload.semanticNodeOccurrences,
            renderSemanticScopeCount: workload.renderSemanticScopeOccurrences,
            layoutScopeCount: workload.layoutScopeOccurrences,
            traversalDepth: workload.maximumRenderTraversalDepth,
            textLineCount: workload.renderTextLineCount,
            glyphCount: workload.positionedGlyphCount,
            ordinaryOperationCount: workload.ordinaryRenderOperations,
            drawingOperationCount: workload.drawing.normalizedStrokeOperations,
            inputEventCount: workload.inputEventsPerOpportunity,
            completionFactCount: workload.completionFactsPerOpportunity
        )
    }

    private static func preset(
        for selection: HardwareFreePresetSelection
    ) -> GeneratedSignalAnalyzerPreset {
        switch selection {
        case .macOSDynamic: GeneratedSignalAnalyzerPresets.macOSDynamic()
        case .macOSStatic: GeneratedSignalAnalyzerPresets.macOSStatic()
        case .raspberryPiDynamic: GeneratedSignalAnalyzerPresets.raspberryPiDynamic()
        case .nrf52840Static: GeneratedSignalAnalyzerPresets.nrf52840Static()
        }
    }

    private static func semanticChecksum(
        for profile: RuntimeProfileKind
    ) -> UInt32? {
        switch profile {
        case .dynamic:
            return exercise(DynamicSignalAnalyzerHostFactAdmission())
        case .static:
            var storage = StaticSignalAnalyzerHostFactAdmissionStorage()
            return withUnsafeMutablePointer(to: &storage) { pointer in
                exercise(StaticSignalAnalyzerHostFactAdmission(storage: pointer))
            }
        }
    }

    private static func exercise<Admission: HardwareFreeFactAdmission>(
        _ admission: Admission
    ) -> UInt32? {
        guard admission.beginProducer(.transition) else {
            return nil
        }
        for ordinal in UInt32(1) ... 20 {
            let state: AcquisitionState = ordinal.isMultiple(of: 2) ? .stopped : .running
            guard case .accepted(sequence: ordinal) = admission.submit(.acquisitionState(state))
            else {
                return nil
            }
        }
        admission.endProducer()
        guard admission.seal() else { return nil }
        var checksum: UInt32 = 2_166_136_261
        for expected in UInt32(1) ... 20 {
            guard let next = admission.takeNextSealed(), next.0 == expected,
                next.1 == .compact
            else {
                return nil
            }
            checksum = (checksum ^ next.0) &* 16_777_619
        }
        guard admission.takeNextSealed() == nil else {
            return nil
        }
        return checksum
    }

    private static func resolveCapability(
        for preset: GeneratedSignalAnalyzerPreset
    ) -> EffectiveRasterPresentation? {
        let tiled = preset.kind == .raspberryPiDynamic || preset.kind == .nrf52840Static
        let realizationKind: RasterRealizationKind = tiled ? .tiled : .fullSurface
        let encoding: CanonicalPixelEncodingSet = tiled ? .rgb565BigEndian : .rgba8888
        let lifetime: SubmissionLifetimeSet = tiled ? .synchronousBorrow : .synchronousCopy
        let handoff: SubmissionHandoffSet = .synchronous
        let extent = preset.capabilityRequirement.extent
        let byteCount = CapabilityByteCount(rawValue: preset.raster.maximumRasterBytes)
        let realization = RasterRealizationContribution(
            kind: realizationKind,
            operations: preset.capabilityRequirement.operations,
            operationStream: .synchronousBorrowedOneShot,
            encodings: encoding,
            producedSubmissionLifetimes: lifetime,
            maximumExtent: extent,
            maximumRegionWidth: preset.raster.logicalWidth,
            maximumRegionHeight: preset.raster.regionHeight,
            rowByteAlignment: tiled ? 2 : 4,
            maximumRasterBytes: byteCount,
            maximumPayloadBytes: byteCount
        )!
        var contributions = RasterPresentationContributions()
        _ = contributions.insert(
            .renderProducer(
                RenderProducerContribution(
                    operations: preset.capabilityRequirement.operations,
                    operationStream: .synchronousBorrowedOneShot
                )!
            )
        )
        _ = contributions.insert(
            .rasterBackend(RasterBackendContribution(primary: realization, alternate: nil)!))
        _ = contributions.insert(
            .surfaceDisplay(
                SurfaceDisplayContribution(
                    extent: extent,
                    encodings: encoding,
                    acceptedSubmissionLifetimes: lifetime,
                    handoffs: handoff,
                    maximumRegionWidth: preset.raster.logicalWidth,
                    maximumRegionHeight: preset.raster.regionHeight,
                    rowByteAlignment: tiled ? 2 : 4,
                    maximumInFlightCount: 1,
                    maximumInFlightBytes: byteCount
                )!
            )
        )
        _ = contributions.insert(
            .hostResourcePolicy(
                RasterPresentationPolicy(
                    maximumRasterBytes: byteCount,
                    maximumPayloadBytes: byteCount,
                    maximumInFlightBytes: byteCount,
                    allowedRealizations: tiled ? .tiled : .fullSurface,
                    allowedEncodings: encoding,
                    preferredRealization: realizationKind,
                    preferredEncoding: encoding
                )!
            )
        )
        var workspace = RasterPresentationResolverWorkspace()!
        guard
            case .available(let effective) = RasterPresentationResolver.resolve(
                requirement: preset.capabilityRequirement,
                contributions: contributions,
                workspace: &workspace
            )
        else {
            return nil
        }
        return effective
    }
}

private protocol HardwareFreeFactAdmission: SignalAnalyzerFactAdmission {
    func beginProducer(_ category: HostFactProducerCategory) -> Bool
    func endProducer()
    func seal() -> Bool
    func takeNextSealed() -> (UInt32, HostSequencedFactKind, SignalAnalyzerPresentationFact)?
}

extension DynamicSignalAnalyzerHostFactAdmission: HardwareFreeFactAdmission {}
extension StaticSignalAnalyzerHostFactAdmission: HardwareFreeFactAdmission {}

private struct FixedHostComponentGraph: HostComponentGraphView {
    let count = HostComponentGraphValidation.requiredRoleCount

    func record(at index: UInt8) -> HostComponentRecord? {
        guard index < count, let role = HostComponentRole(rawValue: index) else { return nil }
        let dependencies =
            index == 0
            ? HostComponentRoleSet(rawValue: 0)
            : HostComponentRoleSet(HostComponentRole(rawValue: index - 1)!)
        return HostComponentRecord(role: role, dependencies: dependencies)
    }
}
