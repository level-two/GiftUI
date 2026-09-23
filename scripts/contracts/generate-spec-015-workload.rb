#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
INPUT = ROOT.join("Tests/ContractFixtures/SPEC015/signal-analyzer-workload.tsv")
HIERARCHY_INPUT = ROOT.join("Tests/ContractFixtures/SPEC001/hierarchy-shape-cases.tsv")
GENERATED_DIR = ROOT.join("Tests/ContractFixtures/SPEC015/Generated")
SWIFT_OUTPUT = ROOT.join("Sources/GiftUIHostConfiguration/Generated/SignalAnalyzerPresets.generated.swift")
NRF_MODEL_OUTPUT = ROOT.join("Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFModelDescriptor.generated.swift")

def fail_generation(message)
  warn "SPEC-015 workload generation failed: #{message}"
  exit 1
end

def parse_descriptor(path, label)
  values = {}
  path.read.lines.each_with_index do |line, index|
    next if line.start_with?("#") || line.strip.empty?
    key, value, extra = line.chomp.split("\t", -1)
    fail_generation("invalid #{label} row #{index + 1}") if key.nil? || value.nil? || extra
    fail_generation("duplicate #{label} field #{key}") if values.key?(key)
    values[key] = value
  end
  values
end

def integer(values, key)
  raw = values.fetch(key) { fail_generation("missing #{key}") }
  value = Integer(raw, 10)
  fail_generation("#{key} is outside UInt16") unless value.between?(0, 65_535)
  value
rescue ArgumentError
  fail_generation("#{key} is not an integer")
end

def preset(values, key)
  fields = values.fetch(key) { fail_generation("missing #{key}") }.split(",")
  fail_generation("invalid #{key} projection") unless fields.length == 9
  {
    kind: Integer(fields[0], 10), profile: fields[1], width: Integer(fields[2], 10),
    height: Integer(fields[3], 10), region_height: Integer(fields[4], 10),
    bytes_per_row: Integer(fields[5], 10), raster_bytes: Integer(fields[6], 10),
    payload_bytes: Integer(fields[7], 10), in_flight_slots: Integer(fields[8], 10)
  }
rescue ArgumentError
  fail_generation("invalid numeric field in #{key}")
end

def swift_profile(profile)
  profile == "dynamic" ? ".dynamic" : ".static"
end

def swift_kind(name)
  {
    "macos_dynamic" => ".macOSDynamic", "macos_static" => ".macOSStatic",
    "raspberry_pi_dynamic" => ".raspberryPiDynamic", "nrf52840_static" => ".nrf52840Static"
  }.fetch(name)
end

def byte_counts(profile, structural_occurrences, layout_scopes)
  if profile == "dynamic"
    semantic_bytes = structural_occurrences * 32
    [semantic_bytes, semantic_bytes, layout_scopes * 40, layout_scopes * 64, 160, 3280, 13_536, 256, 256, 384, 384, 2176, 2176, 128, 256, 128]
  else
    semantic_bytes = structural_occurrences * 24
    [semantic_bytes, semantic_bytes, layout_scopes * 32, layout_scopes * 48, 160, 3280, 13_536, 128, 128, 256, 256, 2176, 2176, 96, 192, 96]
  end
end

values = parse_descriptor(INPUT, "workload descriptor")
hierarchy = parse_descriptor(HIERARCHY_INPUT, "portable hierarchy descriptor")
names = %w[macos_dynamic macos_static raspberry_pi_dynamic nrf52840_static]
presets = names.to_h { |name| [name, preset(values, "preset.#{name}")] }
descriptor_hash = Digest::SHA256.hexdigest(INPUT.read + "\0" + HIERARCHY_INPUT.read)
hierarchy_hash = Digest::SHA256.hexdigest(HIERARCHY_INPUT.read)
static_root_identity = hierarchy_hash[0, 8].to_i(16)
fail_generation("generated Static root identity is zero") if static_root_identity.zero?

expected_hierarchy = {
  "observable-root" => "SignalAnalyzerView",
  "direct-state-count" => "1",
  "direct-state-type" => "SignalAnalyzerViewModel",
  "header-count" => "1",
  "waveform-count" => "1",
  "time-ruler-count" => "1",
  "explicit-channel-count" => "4",
  "control-count" => "6",
  "conditional-error-region-count" => "1",
  "dynamic-collection-count" => "0",
  "platform-branch-count" => "0"
}
fail_generation("portable hierarchy descriptor is not the approved fixed hierarchy") unless hierarchy == expected_hierarchy

hierarchy_integer = ->(key) { Integer(hierarchy.fetch(key), 10) }
fail_generation("hierarchy action count differs from workload") unless
  hierarchy_integer.call("control-count") == integer(values, "host.action_cases") &&
    hierarchy_integer.call("control-count") == integer(values, "application.semantic_actions_per_opportunity")
fail_generation("hierarchy root-model count differs from workload") unless
  hierarchy_integer.call("direct-state-count") == integer(values, "host.root_model_locations")
expected_canvas_count = hierarchy_integer.call("time-ruler-count") +
  hierarchy_integer.call("explicit-channel-count")
fail_generation("hierarchy Canvas count differs from workload") unless
  expected_canvas_count == integer(values, "drawing.canvas_occurrences") &&
    expected_canvas_count == integer(values, "drawing.submitted_strokes")

ordinary = integer(values, "render.maximum_operations")
strokes = integer(values, "drawing.normalized_stroke_operations")
combined = ordinary + strokes
fail_generation("combined operation count overflows UInt16") unless combined <= 65_535
fail_generation("drawing minima changed") unless [
  integer(values, "drawing.canvas_occurrences"),
  integer(values, "drawing.maximum_live_path_points"),
  integer(values, "drawing.maximum_live_path_subpaths"),
  integer(values, "drawing.submitted_strokes"),
  integer(values, "drawing.snapshotted_points"),
  integer(values, "drawing.snapshotted_subpaths"),
  strokes
] == [5, 202, 12, 5, 832, 16, 5]

manifests = {}
presets.each do |name, projection|
  rows = [
    ["schema_version", 3], ["descriptor_sha256", descriptor_hash],
    ["host_kind", projection[:kind]], ["profile", projection[:profile]],
    ["semantic_node_occurrences", integer(values, "semantic.maximum_nodes")],
    ["semantic_structural_occurrences", integer(values, "semantic.maximum_structural_occurrences")],
    ["render_semantic_scope_occurrences", integer(values, "render.semantic_scope_occurrences")],
    ["layout_scope_occurrences", integer(values, "layout.maximum_scopes")],
    ["maximum_render_traversal_depth", integer(values, "render.maximum_traversal_depth")],
    ["render_text_line_count", integer(values, "render.maximum_text_lines")],
    ["positioned_glyph_count", integer(values, "render.maximum_positioned_glyphs")],
    ["ordinary_render_operations", ordinary],
    ["input_events_per_opportunity", integer(values, "application.input_events_per_opportunity")],
    ["semantic_actions_per_opportunity", integer(values, "application.semantic_actions_per_opportunity")],
    ["completion_facts_per_opportunity", integer(values, "application.completion_facts_per_opportunity")],
    ["canvas_occurrences", integer(values, "drawing.canvas_occurrences")],
    ["maximum_live_path_points", integer(values, "drawing.maximum_live_path_points")],
    ["maximum_live_path_subpaths", integer(values, "drawing.maximum_live_path_subpaths")],
    ["submitted_strokes", integer(values, "drawing.submitted_strokes")],
    ["snapshotted_points", integer(values, "drawing.snapshotted_points")],
    ["snapshotted_subpaths", integer(values, "drawing.snapshotted_subpaths")],
    ["normalized_stroke_operations", strokes],
    ["combined_render_operations", combined],
    ["logical_width", projection[:width]], ["logical_height", projection[:height]],
    ["region_height", projection[:region_height]], ["bytes_per_row", projection[:bytes_per_row]],
    ["maximum_raster_bytes", projection[:raster_bytes]],
    ["maximum_payload_bytes", projection[:payload_bytes]],
    ["maximum_in_flight_payloads", projection[:in_flight_slots]],
    ["static_callable_cases", projection[:profile] == "static" ? integer(values, "static_canvas.callable_cases") : "nil"],
    ["maximum_static_capture_bytes", projection[:profile] == "static" ? integer(values, "static_canvas.maximum_capture_bytes") : "nil"]
  ]
  manifests[name] = "# generated from #{descriptor_hash}\n" + rows.map { |key, value| "#{key}\t#{value}\n" }.join
end

limit_rows = []
presets.each do |name, projection|
  static = projection[:profile] == "static"
  leaves = {
    "semantic.maximumDepth" => integer(values, "semantic.maximum_depth"),
    "semantic.maximumSemanticNodes" => integer(values, "semantic.maximum_nodes"),
    "maximumSemanticStructuralOccurrences" => integer(values, "semantic.maximum_structural_occurrences"),
    "semantic.maximumBodyEvaluations" => integer(values, "semantic.maximum_body_evaluations"),
    "semantic.maximumModifierApplications" => integer(values, "semantic.maximum_modifier_applications"),
    "semantic.maximumActionOccurrences" => integer(values, "semantic.maximum_action_occurrences"),
    "layout.maximumScopes" => integer(values, "layout.maximum_scopes"),
    "layout.maximumDepth" => integer(values, "layout.maximum_depth"),
    "layout.maximumTextScalars" => integer(values, "layout.maximum_text_scalars"),
    "layout.maximumTextLines" => integer(values, "layout.maximum_text_lines"),
    "layout.maximumPositionedGlyphs" => integer(values, "layout.maximum_positioned_glyphs"),
    "render.maximumOperations" => combined,
    "render.maximumPositionedGlyphs" => integer(values, "render.maximum_positioned_glyphs"),
    "render.maximumClipDepth" => integer(values, "render.maximum_clip_depth"),
    "renderWorkspace.maximumSemanticScopes" => integer(values, "render.semantic_scope_occurrences"),
    "renderWorkspace.maximumLayoutScopes" => integer(values, "layout.maximum_scopes"),
    "renderWorkspace.maximumTraversalDepth" => integer(values, "render.maximum_traversal_depth"),
    "renderWorkspace.maximumTextLines" => integer(values, "render.maximum_text_lines"),
    "renderSink.maximumOperations" => combined,
    "renderSink.maximumPositionedGlyphs" => integer(values, "render.maximum_positioned_glyphs"),
    "maximumOrdinaryRenderOperations" => ordinary,
    "execution.maximumInputEvents" => integer(values, "application.input_events_per_opportunity"),
    "execution.maximumStateChangeFacts" => integer(values, "execution.maximum_state_change_facts"),
    "execution.maximumCompletionFacts" => integer(values, "application.completion_facts_per_opportunity"),
    "execution.maximumSemanticActions" => integer(values, "application.semantic_actions_per_opportunity"),
    "execution.maximumActiveInputSources" => integer(values, "host.normalized_input_sources"),
    "execution.maximumCommittedActions" => integer(values, "host.action_cases"),
    "observableState.maximumLocations" => 1,
    "observableState.maximumRegistrations" => 1,
    "observableState.maximumStagedAssociations" => 1,
    "interaction.maximumActions" => 6,
    "interaction.maximumHitRegions" => 6,
    "drawing.maximumLineWidth" => integer(values, "drawing.greatest_line_width"),
    "drawing.maximumCanvasOccurrences" => integer(values, "drawing.canvas_occurrences"),
    "drawing.maximumLivePathPoints" => integer(values, "drawing.maximum_live_path_points"),
    "drawing.maximumLivePathSubpaths" => integer(values, "drawing.maximum_live_path_subpaths"),
    "drawing.maximumPlanStrokes" => integer(values, "drawing.submitted_strokes"),
    "drawing.maximumPlanPoints" => integer(values, "drawing.snapshotted_points"),
    "drawing.maximumPlanSubpaths" => integer(values, "drawing.snapshotted_subpaths"),
    "drawing.maximumNormalizedStrokeOperations" => strokes,
    "staticCanvas.maximumStaticCallableCases" => static ? integer(values, "static_canvas.callable_cases") : "nil",
    "staticCanvas.maximumStaticCaptureBytes" => static ? integer(values, "static_canvas.maximum_capture_bytes") : "nil"
  }
  leaves.each { |leaf, value| limit_rows << [name, projection[:profile], leaf, value] }
end
limit_corpus = "# generated from #{descriptor_hash}\n# preset\tprofile\tleaf\texact_value\tlowered_disposition\n"
limit_corpus += limit_rows.map { |row| "#{row.join("\t")}\tinsufficient-workload-capacity\n" }.join

chunks = descriptor_hash.scan(/.{16}/).map { |chunk| "0x#{chunk}" }
swift = +<<~SWIFT
  // Generated by scripts/contracts/generate-spec-015-workload.rb.
  // Source SHA-256: #{descriptor_hash}
  // Do not edit independently of the checked workload and hierarchy descriptors.

  import GiftUICapabilities
  import GiftUIRuntimeCore

  package struct GeneratedHostPresetIdentity: Equatable, Sendable {
      package let word0: UInt64
      package let word1: UInt64
      package let word2: UInt64
      package let word3: UInt64
  }

  package struct GeneratedHostRasterProjection: Equatable, Sendable {
      package let logicalWidth: UInt16
      package let logicalHeight: UInt16
      package let regionHeight: UInt16
      package let bytesPerRow: UInt32
      package let maximumRasterBytes: UInt32
      package let maximumPayloadBytes: UInt32
      package let maximumInFlightPayloads: UInt8
  }

  package struct GeneratedSignalAnalyzerStaticRootDescriptor: Equatable, Sendable {
      package let structuralIdentity: UInt32
      package let declarationOrdinal: UInt16
      package let modelStorageSlots: UInt16
      package let locationCapacity: UInt16
      package let registrationCapacity: UInt16
      package let replacementCapacity: UInt16
  }

  package struct GeneratedSignalAnalyzerPreset: Equatable, Sendable {
      package let identity: GeneratedHostPresetIdentity
      package let kind: MVPHostKind
      package let profile: RuntimeProfileKind
      package let runtimeLimits: RuntimeProfileLimits
      package let expectedStorageBytes: RuntimeStorageByteCounts
      package let workload: SignalAnalyzerHostWorkload
      package let capabilityRequirement: RasterPresentationRequirement
      package let cardinality: SignalAnalyzerHostCardinality
      package let pacing: HostPacingPolicy
      package let raster: GeneratedHostRasterProjection
      package let staticRoot: GeneratedSignalAnalyzerStaticRootDescriptor?

      package func validatedStorageAudit() -> RuntimeProfileValidationResult {
          let inputs = RuntimeProfileLimitInputs(
              semantic: runtimeLimits.semantic,
              maximumSemanticStructuralOccurrences:
                  runtimeLimits.maximumSemanticStructuralOccurrences,
              layout: runtimeLimits.layout,
              render: runtimeLimits.render,
              renderWorkspace: runtimeLimits.renderWorkspace,
              renderSink: runtimeLimits.renderSink,
              maximumOrdinaryRenderOperations: runtimeLimits.maximumOrdinaryRenderOperations,
              execution: runtimeLimits.execution,
              observableState: runtimeLimits.observableState,
              interaction: runtimeLimits.interaction,
              drawing: runtimeLimits.drawing,
              staticCanvas: runtimeLimits.staticCanvas,
              profile: profile
          )
          let capacities = RuntimeStorageCapacities(
              semanticCandidate: runtimeLimits.semantic,
              semanticPublished: runtimeLimits.semantic,
              semanticCandidateStructuralOccurrences:
                  runtimeLimits.maximumSemanticStructuralOccurrences,
              semanticPublishedStructuralOccurrences:
                  runtimeLimits.maximumSemanticStructuralOccurrences,
              layoutCandidate: runtimeLimits.layout,
              render: runtimeLimits.render,
              renderWorkspace: runtimeLimits.renderWorkspace,
              canvasCallableOccurrences: runtimeLimits.drawing.maximumCanvasOccurrences,
              staticCanvasCaptureBytes: workload.drawing.maximumStaticCaptureBytes,
              pathPoints: runtimeLimits.drawing.maximumLivePathPoints,
              pathSubpaths: runtimeLimits.drawing.maximumLivePathSubpaths,
              drawingPlanStrokes: runtimeLimits.drawing.maximumPlanStrokes,
              drawingPlanPoints: runtimeLimits.drawing.maximumPlanPoints,
              drawingPlanSubpaths: runtimeLimits.drawing.maximumPlanSubpaths,
              normalizedStrokeOperations: runtimeLimits.drawing.maximumNormalizedStrokeOperations,
              observableLiveLocations: runtimeLimits.observableState.maximumLocations,
              observableLiveRegistrations: runtimeLimits.observableState.maximumRegistrations,
              observableCandidateAssociations: runtimeLimits.observableState.maximumStagedAssociations,
              interactionCandidateActions: runtimeLimits.interaction.maximumActions,
              interactionCandidateHitRegions: runtimeLimits.interaction.maximumHitRegions,
              interactionCommittedActions: runtimeLimits.interaction.maximumActions,
              interactionCommittedHitRegions: runtimeLimits.interaction.maximumHitRegions,
              admissionQueue: runtimeLimits.execution,
              sealedBatch: runtimeLimits.execution,
              pointerStates: runtimeLimits.execution.maximumActiveInputSources,
              coordinatorStatePresent: true,
              failureStatePresent: true,
              byteCounts: expectedStorageBytes
          )
          switch profile {
          case .dynamic:
              return RuntimeProfileValidator.validateDynamic(inputs: inputs, capacities: capacities)
          case .static:
              let metadata = GeneratedStaticCanvasAuditMetadata(
                  callableCaseCount: workload.drawing.staticCallableCases!,
                  maximumCaptureBytes: workload.drawing.maximumStaticCaptureBytes!
              )
              return RuntimeProfileValidator.validateStatic(
                  inputs: inputs, capacities: capacities, metadata: metadata
              )
          }
      }
  }

  private struct GeneratedStaticCanvasAuditMetadata: RuntimeStaticCanvasAuditMetadata {
      let callableCaseCount: UInt16
      let maximumCaptureBytes: UInt16
      var declaredEntryCount: UInt16 { callableCaseCount }
      var maximumDeclaredID: UInt16 { callableCaseCount }
      func coverageMultiplicity(for id: UInt16) -> UInt8 {
          id > 0 && id <= callableCaseCount ? 1 : 0
      }
      func captureByteCount(for id: UInt16) -> UInt16? {
          id > 0 && id <= callableCaseCount ? maximumCaptureBytes : nil
      }
  }

  package enum GeneratedSignalAnalyzerPresets {
      package static let sourceIdentity = GeneratedHostPresetIdentity(
          word0: #{chunks[0]}, word1: #{chunks[1]},
          word2: #{chunks[2]}, word3: #{chunks[3]}
      )

SWIFT

presets.each do |name, projection|
  method_name = {
    "macos_dynamic" => "macOSDynamic", "macos_static" => "macOSStatic",
    "raspberry_pi_dynamic" => "raspberryPiDynamic", "nrf52840_static" => "nrf52840Static"
  }.fetch(name)
  static = projection[:profile] == "static"
  bytes = byte_counts(
    projection[:profile], integer(values, "semantic.maximum_structural_occurrences"),
    integer(values, "layout.maximum_scopes")
  )
  swift << <<~SWIFT
        package static func #{method_name}() -> GeneratedSignalAnalyzerPreset {
            makePreset(
                kind: #{swift_kind(name)}, profile: #{swift_profile(projection[:profile])},
                width: #{projection[:width]}, height: #{projection[:height]},
                regionHeight: #{projection[:region_height]}, bytesPerRow: #{projection[:bytes_per_row]},
                rasterBytes: #{projection[:raster_bytes]}, payloadBytes: #{projection[:payload_bytes]},
                inFlightPayloads: #{projection[:in_flight_slots]},
                staticCallableCases: #{static ? integer(values, "static_canvas.callable_cases") : "nil"},
                staticCaptureBytes: #{static ? integer(values, "static_canvas.maximum_capture_bytes") : "nil"},
                byteCounts: RuntimeStorageByteCounts(
                    semanticCandidateBytes: #{bytes[0]}, semanticPublishedBytes: #{bytes[1]},
                    layoutCandidateBytes: #{bytes[2]}, renderWorkspaceBytes: #{bytes[3]},
                    canvasCallableBytes: #{bytes[4]}, pathWorkspaceBytes: #{bytes[5]},
                    drawingPlanBytes: #{bytes[6]}, observableLiveBytes: #{bytes[7]},
                    observableCandidateBytes: #{bytes[8]}, interactionCandidateBytes: #{bytes[9]},
                    interactionCommittedBytes: #{bytes[10]}, admissionQueueBytes: #{bytes[11]},
                    sealedBatchBytes: #{bytes[12]}, pointerStateBytes: #{bytes[13]},
                    coordinatorStateBytes: #{bytes[14]}, failureStateBytes: #{bytes[15]}
                )
            )
        }

  SWIFT
end

swift << <<~SWIFT
      private static func makePreset(
          kind: MVPHostKind,
          profile: RuntimeProfileKind,
          width: UInt16,
          height: UInt16,
          regionHeight: UInt16,
          bytesPerRow: UInt32,
          rasterBytes: UInt32,
          payloadBytes: UInt32,
          inFlightPayloads: UInt8,
          staticCallableCases: UInt16?,
          staticCaptureBytes: UInt16?,
          byteCounts: RuntimeStorageByteCounts
      ) -> GeneratedSignalAnalyzerPreset {
          let limits = RuntimeProfileLimits(
              semantic: .init(
                  maximumDepth: #{integer(values, "semantic.maximum_depth")},
                  maximumSemanticNodes: #{integer(values, "semantic.maximum_nodes")},
                  maximumBodyEvaluations: #{integer(values, "semantic.maximum_body_evaluations")},
                  maximumModifierApplications: #{integer(values, "semantic.maximum_modifier_applications")},
                  maximumActionOccurrences: #{integer(values, "semantic.maximum_action_occurrences")}
              )!,
              maximumSemanticStructuralOccurrences: #{integer(values, "semantic.maximum_structural_occurrences")},
              layout: .init(
                  maximumScopes: #{integer(values, "layout.maximum_scopes")},
                  maximumDepth: #{integer(values, "layout.maximum_depth")},
                  maximumTextScalars: #{integer(values, "layout.maximum_text_scalars")},
                  maximumTextLines: #{integer(values, "layout.maximum_text_lines")},
                  maximumPositionedGlyphs: #{integer(values, "layout.maximum_positioned_glyphs")}
              )!,
              render: .init(
                  maximumOperations: #{combined},
                  maximumPositionedGlyphs: #{integer(values, "render.maximum_positioned_glyphs")},
                  maximumClipDepth: #{integer(values, "render.maximum_clip_depth")}
              )!,
              renderWorkspace: .init(
                  maximumSemanticScopes: #{integer(values, "render.semantic_scope_occurrences")},
                  maximumLayoutScopes: #{integer(values, "layout.maximum_scopes")},
                  maximumTraversalDepth: #{integer(values, "render.maximum_traversal_depth")},
                  maximumTextLines: #{integer(values, "render.maximum_text_lines")}
              )!,
              renderSink: .init(maximumOperations: #{combined}, maximumPositionedGlyphs: #{integer(values, "render.maximum_positioned_glyphs")}),
              maximumOrdinaryRenderOperations: #{ordinary},
              execution: .init(
                  maximumInputEvents: #{integer(values, "application.input_events_per_opportunity")},
                  maximumStateChangeFacts: #{integer(values, "execution.maximum_state_change_facts")},
                  maximumCompletionFacts: #{integer(values, "application.completion_facts_per_opportunity")},
                  maximumSemanticActions: #{integer(values, "application.semantic_actions_per_opportunity")},
                  maximumActiveInputSources: #{integer(values, "host.normalized_input_sources")},
                  maximumCommittedActions: #{integer(values, "host.action_cases")}
              )!,
              observableState: .init(maximumLocations: 1, maximumRegistrations: 1, maximumStagedAssociations: 1)!,
              interaction: .init(maximumActions: 6, maximumHitRegions: 6)!,
              drawing: .init(
                  maximumLineWidth: #{integer(values, "drawing.greatest_line_width")},
                  maximumCanvasOccurrences: #{integer(values, "drawing.canvas_occurrences")},
                  maximumLivePathPoints: #{integer(values, "drawing.maximum_live_path_points")},
                  maximumLivePathSubpaths: #{integer(values, "drawing.maximum_live_path_subpaths")},
                  maximumPlanStrokes: #{integer(values, "drawing.submitted_strokes")},
                  maximumPlanPoints: #{integer(values, "drawing.snapshotted_points")},
                  maximumPlanSubpaths: #{integer(values, "drawing.snapshotted_subpaths")},
                  maximumNormalizedStrokeOperations: #{integer(values, "drawing.normalized_stroke_operations")}
              )!,
              staticCanvas: staticCallableCases.map { cases in
                  .init(maximumStaticCallableCases: cases, maximumStaticCaptureBytes: staticCaptureBytes!)!
              },
              profile: profile
          )!
          let drawing = SignalAnalyzerDrawingWorkload(
              canvasOccurrences: 5, maximumLivePathPoints: 202,
              maximumLivePathSubpaths: 12, submittedStrokes: 5,
              snapshottedPoints: 832, snapshottedSubpaths: 16,
              normalizedStrokeOperations: 5, greatestLineWidth: 1,
              staticCallableCases: staticCallableCases,
              maximumStaticCaptureBytes: staticCaptureBytes
          )
          let workload = SignalAnalyzerHostWorkload(
              schemaVersion: 3, requiredRuntimeLimits: limits,
              semanticNodeOccurrences: #{integer(values, "semantic.maximum_nodes")},
              semanticStructuralOccurrences: #{integer(values, "semantic.maximum_structural_occurrences")},
              renderSemanticScopeOccurrences: #{integer(values, "render.semantic_scope_occurrences")},
              layoutScopeOccurrences: #{integer(values, "layout.maximum_scopes")},
              maximumRenderTraversalDepth: #{integer(values, "render.maximum_traversal_depth")},
              renderTextLineCount: #{integer(values, "render.maximum_text_lines")},
              positionedGlyphCount: #{integer(values, "render.maximum_positioned_glyphs")},
              ordinaryRenderOperations: #{ordinary},
              inputEventsPerOpportunity: #{integer(values, "application.input_events_per_opportunity")},
              semanticActionsPerOpportunity: #{integer(values, "application.semantic_actions_per_opportunity")},
              completionFactsPerOpportunity: #{integer(values, "application.completion_facts_per_opportunity")},
              drawing: drawing
          )
          return GeneratedSignalAnalyzerPreset(
              identity: sourceIdentity, kind: kind, profile: profile,
              runtimeLimits: limits, expectedStorageBytes: byteCounts,
              workload: workload,
              capabilityRequirement: RasterPresentationRequirement(
                  operations: [
                      .opaqueRectangles, .positionedText, .straightLineStrokes,
                      .clipping, .damage,
                  ],
                  extent: CapabilityExtent(width: width, height: height)!,
                  operationStream: .synchronousBorrowedOneShot,
                  acceptedEncodings: kind == .macOSDynamic || kind == .macOSStatic
                      ? .rgba8888 : .rgb565BigEndian,
                  acceptedSubmissionLifetimes: [
                      .synchronousBorrow, .synchronousCopy, .ownershipTransfer,
                  ],
                  maximumRasterBytes: CapabilityByteCount(rawValue: rasterBytes),
                  maximumPayloadBytes: CapabilityByteCount(rawValue: payloadBytes),
                  maximumInFlightBytes: CapabilityByteCount(
                      rawValue: payloadBytes * UInt32(inFlightPayloads)
                  ),
                  absence: .required
              )!,
              cardinality: SignalAnalyzerHostCardinality(
                  actionCaseCount: 6, rootModelLocationCount: 1,
                  activeRegistrationCount: 1, stagedAssociationCount: 1,
                  snapshotFactCapacity: 1, compactFactCapacity: 32,
                  reservedFailureFactCapacity: 1, normalizedInputSourceCapacity: 1
              ),
              pacing: HostPacingPolicy(
                  minimumFrameIntervalMicroseconds: 250_000,
                  maximumFactServiceLatencyMicroseconds: 250_000,
                  minimumAcceptedTransitionSpacingMicroseconds: 50_000,
                  maximumTransitionFactsPerServiceWindow: 20,
                  maximumBootstrapFactsPerServiceWindow: 2,
                  maximumActionInducedFactsPerServiceWindow: 6,
                  maximumRetryableRefusals: 3
              )!,
              raster: GeneratedHostRasterProjection(
                  logicalWidth: width, logicalHeight: height,
                  regionHeight: regionHeight, bytesPerRow: bytesPerRow,
                  maximumRasterBytes: rasterBytes, maximumPayloadBytes: payloadBytes,
                  maximumInFlightPayloads: inFlightPayloads
              ),
              staticRoot: profile == .static
                  ? GeneratedSignalAnalyzerStaticRootDescriptor(
                      structuralIdentity: #{static_root_identity},
                      declarationOrdinal: 0,
                      modelStorageSlots: 2,
                      locationCapacity: 1,
                      registrationCapacity: 1,
                      replacementCapacity: 1
                  )
                  : nil
          )
      }
  }
SWIFT

outputs = manifests.transform_keys { |name| GENERATED_DIR.join("#{name}.workload.generated.tsv") }
outputs[GENERATED_DIR.join("runtime-limit-leaves.generated.tsv")] = limit_corpus
outputs[SWIFT_OUTPUT] = swift
outputs[NRF_MODEL_OUTPUT] = <<~SWIFT
  // Generated by scripts/contracts/generate-spec-015-workload.rb.
  // Descriptor SHA-256: #{descriptor_hash}; hierarchy SHA-256: #{hierarchy_hash}.
  package enum StaticSignalAnalyzerNRFModelDescriptor {
      package static let structuralIdentity: UInt32 = #{static_root_identity}
      package static let declarationOrdinal: UInt16 = 0
      package static let modelStorageSlots: UInt16 = 2
      package static let locationCapacity: UInt16 = 1
      package static let registrationCapacity: UInt16 = 1
      package static let replacementCapacity: UInt16 = 1
  }
SWIFT

if ARGV == ["--check"]
  outputs.each do |path, content|
    fail_generation("missing generated output #{path.relative_path_from(ROOT)}") unless path.file?
    fail_generation("stale generated output #{path.relative_path_from(ROOT)}") unless path.read == content
  end
  puts "SPEC-015 generated workload is fresh (#{descriptor_hash})."
  exit 0
end
fail_generation("usage: generate-spec-015-workload.rb [--check]") unless ARGV.empty?
GENERATED_DIR.mkpath
SWIFT_OUTPUT.dirname.mkpath
NRF_MODEL_OUTPUT.dirname.mkpath
outputs.each { |path, content| path.write(content) }
puts "Generated four SPEC-015 manifests and Swift presets (#{descriptor_hash})."
