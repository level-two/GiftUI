#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

root = Pathname.new(File.expand_path("../..", __dir__))
runtime_source = root.join("Sources/GiftUIRuntimeCore").glob("**/*.swift").map(&:read).join("\n")
host_source = root.join("Sources/GiftUIHostConfiguration").glob("**/*.swift").map(&:read).join("\n")
assembly_source = root.join("Sources/SignalAnalyzerHost").glob("**/*.swift").map(&:read).join("\n")

def fail_check(message)
  warn "SPEC-013 downstream integration failed: #{message}"
  exit 1
end

%w[GiftUIBackendIntegration GiftUIHostConfiguration GiftUIRuntimeDynamic GiftUIRuntimeStatic].each do |name|
  fail_check("Runtime Core references downstream owner #{name}") if runtime_source.include?(name)
end
%w[raspberry nrf52840 PiScreen TFT HostResidualPolicy].each do |token|
  fail_check("Runtime Core contains concrete host token #{token}") if runtime_source.match?(/#{Regexp.escape(token)}/i)
end

fail_check("host configuration does not consume Runtime Core contract") unless
  host_source.match?(/^import GiftUIRuntimeCore$/)
fail_check("host configuration does not consume backend-integration contract") unless
  host_source.match?(/^import GiftUIBackendIntegration$/)
%w[GiftUIRuntimeDynamic GiftUIRuntimeStatic].each do |profile|
  fail_check("host configuration imports concrete profile #{profile}") if host_source.match?(/^import #{profile}$/)
  fail_check("application assembly does not select #{profile}") unless assembly_source.match?(/^import #{profile}$/)
end

required_tests = %w[
  Tests/GiftUIRuntimeCoreTests/RuntimeCompletePipelineTests.swift
  Tests/GiftUIHostConfigurationTests/SignalAnalyzerIntegratedCycleTests.swift
  Tests/GiftUIHostConfigurationTests/HostEndpointStartupValidationTests.swift
  Tests/GiftUIHostConfigurationTests/GeneratedSignalAnalyzerPresetTests.swift
]
required_tests.each do |relative|
  fail_check("missing integration fixture #{relative}") unless root.join(relative).file?
end

puts "SPEC-013 downstream integration passed: Runtime Core remains neutral; host/backend and profile selection meet only in approved downstream owners."
