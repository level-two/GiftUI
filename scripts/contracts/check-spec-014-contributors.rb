#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
ADAPTERS = {
  "raster backend" => ROOT.join(
    "Sources/GiftUIRasterCore/RasterBackendContributionAdapter.swift"
  ),
  "surface/display" => ROOT.join(
    "Sources/GiftUIDisplayCore/SurfaceDisplayContributionAdapter.swift"
  ),
}.freeze

def fail_check(message)
  warn "SPEC-014 contributor check failed: #{message}"
  exit 1
end

ADAPTERS.each do |owner, path|
  fail_check("missing #{owner} adapter") unless path.file?
  source = path.read
  imports = source.scan(/^import\s+([A-Za-z0-9_]+)/).flatten
  fail_check("#{owner} adapter imports differ: #{imports.inspect}") unless imports == ["GiftUICapabilities"]
  {
    "resolver call" => /RasterPresentationResolver/,
    "end-to-end Boolean" => /package\s+static\s+func[^\{]+->\s*Bool\b/m,
    "display-target probe" => /\bDisplayTarget\b/,
    "surface probe" => /\bRasterSurface(?:Descriptor)?\b/,
    "health-derived fact" => /\bhealth\b|GiftUIOperationalHealth/,
    "target identity" => /\bTargetID\b|targetIdentity/,
  }.each do |description, pattern|
    fail_check("#{owner} adapter contains #{description}") if source.match?(pattern)
  end
end

puts "SPEC-014 contributor check passed: two fact-only adapters and no forbidden authority."
