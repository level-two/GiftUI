#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
PACKAGE = ROOT.join("Package.swift").read
STATUS = ROOT.join("Tests/ContractFixtures/SPEC009/integration-owner-status.tsv")

def fail_check(message)
  warn "SPEC-009 owner integration check failed: #{message}"
  exit 1
end

observable = PACKAGE[/\.target\(\s*name: "GiftUIObservableState".*?\n\s*\),/m]
fail_check("SPEC-010 owner lacks its approved Execution edge") unless observable&.include?("GiftUIExecution")

adapter = ROOT.join("Sources/GiftUIObservableState/PresentationFactAdmission.swift").read
fail_check("SPEC-010 seam imports outside Execution") unless adapter.scan(/^import (\w+)/).flatten == ["GiftUIExecution"]
%w[PresentationFactAdmissionAdapter associatedtype\ Fact submit ExecutionAdmissionOutcome].each do |fragment|
  fail_check("SPEC-010 seam lacks #{fragment.tr('\\', '')}") unless adapter.match?(/#{fragment}/)
end
tests = ROOT.join("Tests/GiftUIObservableStateTests/PresentationFactAdmissionTests.swift").read
%w[presentationFactAdapterForwardsOneCompleteTypedFactAndExactOutcome presentationFactRefusalIsReturnedWithoutFallbackOrSecondQueue].each do |name|
  fail_check("SPEC-010 integration tests lack #{name}") unless tests.include?(name)
end

present_targets = %w[
  GiftUIInteraction
  GiftUIRuntimeCore
  GiftUIRuntimeDynamic
  GiftUIRuntimeStatic
  GiftUIBackendIntegration
]
present_targets.each do |target|
  fail_check("#{target} integration target is missing") unless PACKAGE.include?(%{name: "#{target}"})
end

interaction_target = PACKAGE[/\.target\(\s*name: "GiftUIInteraction".*?\n\s*\),/m]
interaction_dependencies = interaction_target&.scan(/"(GiftUI\w+)"/)&.flatten&.drop(1)&.sort
expected_interaction_dependencies = %w[GiftUIExecution GiftUILayout GiftUISemanticCore].sort
unless interaction_dependencies == expected_interaction_dependencies
  fail_check("SPEC-011 target dependencies differ: #{interaction_dependencies}")
end

gesture_adapter = ROOT.join("Sources/GiftUIInteraction/ExecutionGestureAdapter.swift").read
unless gesture_adapter.scan(/^import (\w+)/).flatten.sort == %w[GiftUI GiftUIExecution]
  fail_check("SPEC-011 Execution gesture adapter imports outside its approved owners")
end
%w[resolveDown resolveMove resolveUp PointerActionCapture].each do |fragment|
  fail_check("SPEC-011 execution seam lacks #{fragment}") unless gesture_adapter.include?(fragment)
end
if gesture_adapter.match?(/GiftUIObservableState|GiftUIRuntime|GiftUIBackend|dispatch\s*\(/)
  fail_check("SPEC-011 execution seam gained state, runtime, backend, or dispatch ownership")
end

backend_target = PACKAGE[/\.target\(\s*name: "GiftUIBackendIntegration".*?\n\s*\),/m]
expected_backend_dependencies = %w[
  GiftUICapabilities
  GiftUIDisplayCore
  GiftUIExecution
  GiftUIFailureCore
  GiftUIRasterCore
  GiftUIRenderCore
  GiftUISurfaceCore
  GiftUITextResources
].sort
backend_dependencies = backend_target&.scan(/"(GiftUI\w+)"/)&.flatten&.drop(1)&.sort
unless backend_dependencies == expected_backend_dependencies
  fail_check("SPEC-014 target dependencies differ: #{backend_dependencies}")
end

endpoint = ROOT.join("Sources/GiftUIBackendIntegration/OneShotRasterBackendEndpoint.swift").read
endpoint_protocol = ROOT.join("Sources/GiftUIBackendIntegration/RasterBackendEndpoint.swift").read
expected_endpoint_imports = expected_backend_dependencies.sort
unless endpoint.scan(/^import (\w+)/).flatten.sort == expected_endpoint_imports
  fail_check("SPEC-014 endpoint imports differ")
end
%w[OneShotRasterBackendEndpoint RasterBackendEndpoint FrameOfferResult].each do |fragment|
  fail_check("SPEC-014 endpoint seam lacks #{fragment}") unless endpoint.include?(fragment)
end
unless endpoint_protocol.include?("protocol RasterBackendEndpoint: SynchronousFrameEndpoint")
  fail_check("SPEC-014 raster endpoint no longer refines SynchronousFrameEndpoint")
end
if endpoint.match?(/GiftUIRuntime|GiftUIInteraction|GiftUIObservableState|HostPolicy|ActionModelTarget/)
  fail_check("SPEC-014 endpoint gained runtime, interaction, state, target, or host-policy ownership")
end

endpoint_tests = ROOT.join("Tests/GiftUIBackendIntegrationTests/OneShotRasterBackendEndpointTests.swift").read
%w[
  oneShotEndpointReservesExactSlotBeforeCallingBodyOnce
  reservationOutcomesMapWithoutCallingBody
  invalidEnvelopeAndNonidleSinkExitBeforeReservationAndBody
].each do |name|
  fail_check("SPEC-014 endpoint tests lack #{name}") unless endpoint_tests.include?(name)
end

rows = STATUS.each_line.reject { |line| line.start_with?("#") || line.strip.empty? }.map { |line| line.chomp.split("\t", -1) }
fail_check("owner-status registry shape differs") unless rows.length == 4 && rows.all? { |row| row.length == 4 }
expected_statuses = %w[integrated integrated blocked integrated]
fail_check("owner integration statuses differ") unless rows.map { |row| row[2] } == expected_statuses

puts "SPEC-009 owner integration passed: SPEC-010, SPEC-011, and SPEC-014 seams are integrated without transferring their storage, dispatch, raster, target, or host-policy ownership; SPEC-013 remains blocked on its production admission/opportunity coordinator surface."
