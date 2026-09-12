#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCES = ROOT.join("Sources/GiftUIRuntimeDynamic")
BINDING = SOURCES.join("DynamicRuntimeProfileBinding.swift")

def fail_check(message)
  warn "SPEC-013 Dynamic binding check failed: #{message}"
  exit 1
end

fail_check("production binding is missing") unless BINDING.file?

all_source = SOURCES.glob("*.swift").sort.map(&:read).join("\n")
binding = BINDING.read

forbidden_imports = %w[
  GiftUIRuntimeStatic GiftUIBackendCore GiftUIRasterCore AppKit UIKit SwiftUI
  Foundation Dispatch Glibc Darwin WinSDK
]
forbidden_imports.each do |name|
  fail_check("imports forbidden sibling/backend/host module #{name}") if
    all_source.match?(/^import\s+#{Regexp.escape(name)}\b/)
end

required_delegation = %w[
  RuntimeCoordinatorLifecycle DynamicProfileStorage
  DynamicCanvasCallableStorage lifecycle.beginOpportunity
  lifecycle.finishOpportunity lifecycle.requestQuiescence
  canvasCallables.invokeCanvas canvasCallables.releaseCanvas
]
required_delegation.each do |token|
  fail_check("binding does not delegate through #{token}") unless binding.include?(token)
end

duplicated_owner_types = %w[
  SemanticExpander LayoutEngine CombinedRenderProducer
  ObservableCandidateCoordinator InteractionDispatcher RuntimeInteractionDispatcher
]
duplicated_owner_types.each do |name|
  fail_check("binding duplicates focused owner #{name}") if
    binding.match?(/\b(?:struct|class|enum)\s+#{Regexp.escape(name)}\b/)
end

borrowed_payload_fields = [
  /private\s+var\s+\w+\s*:\s*GraphicsContext\b/,
  /private\s+var\s+\w+\s*:\s*Path\b/,
  /private\s+var\s+\w+\s*:\s*DrawingPlan\b/,
  /private\s+var\s+\w+\s*:\s*DrawingOperation\b/,
  /private\s+var\s+\w+\s*:\s*LayoutView\b/,
]
fail_check("binding retains a borrowed focused-owner payload") if
  borrowed_payload_fields.any? { |pattern| binding.match?(pattern) }

fail_check("Canvas release is not scoped across success and throw") unless
  binding.include?("defer { canvasCallables.releaseCanvas(at: identity) }")

puts "SPEC-013 Dynamic binding passed: shared lifecycle/storage delegation, " \
     "scoped Canvas release, no sibling/backend/host import, no focused-owner " \
     "redefinition, and no borrowed payload field."
