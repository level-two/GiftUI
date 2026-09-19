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
    package let workloadDurationMilliseconds: UInt32
    package let workloadEventRate: UInt16
    package let workloadEventCount: UInt32
    package let workloadFrameRate: UInt16
    package let workloadFrameCount: UInt16
    package let workloadFactHighWater: UInt16
    package let workloadChecksum: UInt32

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
            "workload_duration_ms=\(workloadDurationMilliseconds)",
            "workload_event_rate=\(workloadEventRate)",
            "workload_events=\(workloadEventCount)",
            "workload_frame_rate=\(workloadFrameRate)",
            "workload_frames=\(workloadFrameCount)",
            "workload_fact_high_water=\(workloadFactHighWater)",
            "workload_checksum=\(workloadChecksum)",
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
        guard let workloadChecksum = sustainedWorkloadChecksum(for: preset.profile),
            capacityCorpusPasses()
        else {
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
            completionFactCount: workload.completionFactsPerOpportunity,
            workloadDurationMilliseconds: 30_000,
            workloadEventRate: 80,
            workloadEventCount: 2_400,
            workloadFrameRate: 4,
            workloadFrameCount: 120,
            workloadFactHighWater: 20,
            workloadChecksum: workloadChecksum
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

    private static func sustainedWorkloadChecksum(
        for profile: RuntimeProfileKind
    ) -> UInt32? {
        switch profile {
        case .dynamic:
            return exerciseSustained(DynamicSignalAnalyzerHostFactAdmission())
        case .static:
            var storage = StaticSignalAnalyzerHostFactAdmissionStorage()
            return withUnsafeMutablePointer(to: &storage) { pointer in
                exerciseSustained(StaticSignalAnalyzerHostFactAdmission(storage: pointer))
            }
        }
    }

    private static func exerciseSustained<Admission: HardwareFreeFactAdmission>(
        _ admission: Admission
    ) -> UInt32? {
        var expectedSequence: UInt32 = 1
        var checksum: UInt32 = 2_166_136_261
        for frame in UInt32(0) ..< 120 {
            guard admission.beginProducer(.transition) else { return nil }
            for ordinal in UInt32(0) ..< 20 {
                let state: AcquisitionState =
                    (frame &+ ordinal).isMultiple(of: 2)
                    ? .stopped : .running
                guard
                    case .accepted(sequence: expectedSequence) =
                        admission.submit(.acquisitionState(state))
                else { return nil }
                expectedSequence += 1
            }
            admission.endProducer()
            guard admission.seal() else { return nil }
            for _ in 0 ..< 20 {
                guard let next = admission.takeNextSealed(), next.0 < expectedSequence,
                    next.1 == .compact
                else { return nil }
                checksum = (checksum ^ next.0) &* 16_777_619
            }
            guard admission.takeNextSealed() == nil else { return nil }
        }
        return expectedSequence == 2_401 ? checksum : nil
    }

    private static func capacityCorpusPasses() -> Bool {
        var producerBound = HostSequencedFactAdmission<String, String, String>(
            producerLimits: HostFactProducerLimits(transition: 20, bootstrap: 2, action: 6)!
        )!
        for category in [HostFactProducerCategory.transition, .bootstrap, .action] {
            let count: UInt16 =
                switch category {
                case .transition: 20
                case .bootstrap: 2
                case .action: 6
                }
            for ordinal in UInt16(0) ..< count {
                guard
                    case .accepted = producerBound.admitCompact(
                        "\(category)-\(ordinal)", category: category)
                else { return false }
            }
        }
        guard producerBound.pendingCompactCount == 28 else { return false }

        var physicalBound = HostSequencedFactAdmission<String, String, String>(
            producerLimits: HostFactProducerLimits(transition: 32, bootstrap: 1, action: 1)!
        )!
        for ordinal in UInt16(0) ..< 32 {
            guard case .accepted = physicalBound.admitCompact("\(ordinal)", category: .transition)
            else { return false }
        }
        guard physicalBound.pendingCompactCount == 32 else { return false }
        return physicalBound.admitCompact("33", category: .transition)
            == .rejected(.producerCategoryExhausted)
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
