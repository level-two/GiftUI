#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../..", __dir__)
DOMAIN = File.join(ROOT, "Sources/SignalAnalyzerDomain")
FIXTURE = File.join(ROOT, "Tests/ContractFixtures/SPEC001/domain-contract-cases.tsv")

paths = Dir[File.join(DOMAIN, "**/*.swift")].sort
abort "SignalAnalyzerDomain has no sources" if paths.empty?

source = paths.map { |path| File.read(path) }.join("\n")
required = [
  "protocol SignalCaptureSink",
  "protocol AcquisitionStateSink",
  "protocol SignalAcquisitionRepository",
  "protocol SignalTransitionSink",
  "protocol SignalDataSource",
  "struct ObserveSignalCaptureUseCase",
  "struct ObserveAcquisitionStateUseCase",
  "struct StartSignalAcquisitionUseCase",
  "struct StopSignalAcquisitionUseCase",
  "struct ClearSignalCaptureUseCase"
].freeze
missing = required.reject { |declaration| source.include?(declaration) }
abort "missing Domain contracts: #{missing.join(', ')}" unless missing.empty?

forbidden = {
  "@MainActor" => /@MainActor/,
  "Foundation import" => /^\s*import\s+Foundation\b/,
  "UI import" => /^\s*import\s+(?:GiftUI|SwiftUI|UIKit|AppKit)\b/,
  "platform import" => /^\s*import\s+(?:Darwin|Glibc|WinSDK)\b/,
  "task facility" => /\bTask\s*[<{.(]/,
  "dispatch facility" => /\bDispatch(?:Queue|Source|Semaphore|Group)\b/,
  "clock facility" => /\b(?:ContinuousClock|SuspendingClock|Clock)\b/
}.freeze
violations = forbidden.each_with_object([]) do |(label, pattern), found|
  found << label if paths.any? { |path| File.read(path).match?(pattern) }
end
abort "forbidden Domain facilities: #{violations.join(', ')}" unless violations.empty?

fixtures = File.readlines(FIXTURE, chomp: true)
  .reject { |line| line.empty? || line.start_with?("#") }
  .map { |line| line.split("\t", -1) }
abort "domain contract fixture columns differ" unless fixtures.all? { |row| row.length == 4 }
abort "domain contract fixture IDs are duplicated" unless fixtures.map(&:first).uniq.length == fixtures.length

puts "SPEC-001 Domain contract audit passed: #{required.length} declarations, #{forbidden.length} forbidden facilities, and #{fixtures.length} cases."
