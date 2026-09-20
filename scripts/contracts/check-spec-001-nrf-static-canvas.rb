#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
MANIFEST_PATH = ROOT.join("Tests/ContractFixtures/SPEC001/nrf-static-canvas-manifest.yaml")

def fail_check(message)
  warn "SPEC-001 nRF Static Canvas manifest check failed: #{message}"
  exit 1
end

manifest = YAML.safe_load(MANIFEST_PATH.read, aliases: false)
fail_check("schema differs") unless manifest["schema"] == "spec-001-nrf-static-canvas-manifest-v1"
fail_check("callable count differs") unless manifest["callable_case_count"] == 2
fail_check("greatest capture differs") unless manifest["greatest_capture_byte_count"] == 32

cases = manifest.fetch("callable_cases")
fail_check("case IDs are not dense") unless cases.map { |entry| entry.fetch("id") } == [1, 2]
fail_check("switch coverage differs") unless manifest.fetch("switch_coverage") == [1, 2]
fail_check("occurrence order differs") unless manifest.fetch("occurrences").map { |entry| entry.fetch("order") } == [1, 2, 3, 4, 5]
fail_check("occurrence IDs differ") unless manifest.fetch("occurrences").map { |entry| entry.fetch("callable_id") } == [1, 2, 2, 2, 2]

grid, trace = cases
fail_check("grid capture differs") unless grid.fetch("capture_byte_count") == 0 && grid.fetch("fields").empty?
fail_check("trace capture differs") unless trace.fetch("capture_byte_count") == 32 && trace.fetch("capture_alignment") == 8
expected_fields = [
  ["model", "StaticCanvasObservableModelHandle<SignalAnalyzerViewModel>", 0],
  ["channelRawValue", "Int64", 8],
  ["visibleLowerMilliseconds", "Int64", 16],
  ["visibleUpperMilliseconds", "Int64", 24]
]
actual_fields = trace.fetch("fields").map { |field| [field.fetch("name"), field.fetch("type"), field.fetch("offset")] }
fail_check("trace fields differ") unless actual_fields == expected_fields

source = ROOT.join(manifest.fetch("source")).read
fail_check("grid source expression is missing") unless source.include?("package func makeSignalAnalyzerGridCanvas() -> Canvas")
fail_check("trace source expression is missing") unless source.include?("package func makeSignalAnalyzerTraceCanvas(")
fail_check("portable hierarchy no longer has five Canvas occurrences") unless source.scan(/makeSignalAnalyzerTraceCanvas\(/).length == 2 && source.include?("SignalAnalyzerGridView()")

generated = ROOT.join(manifest.fetch("generated_source")).read
required_tokens = [
  "struct StaticSignalAnalyzerNRFGridCanvasCapture",
  "struct StaticSignalAnalyzerNRFTraceCanvasCapture",
  "struct StaticSignalAnalyzerNRFCanvasCaptureStorage",
  "struct StaticSignalAnalyzerNRFCanvasCallableTable: StaticCanvasCallableTable",
  "let callableCaseCount: UInt16 = 2",
  "case 1:",
  "case 2:",
  "drawSignalAnalyzerGrid(context: &context, size: size)",
  "drawSignalAnalyzerTrace(",
  "try model.withModel { model throws(DrawingError) in"
]
missing = required_tokens.reject { |token| generated.include?(token) }
fail_check("generated source tokens are missing: #{missing.join(', ')}") unless missing.empty?
fail_check("generated source retains a Canvas closure") if generated.match?(/Canvas\s*\{/)
fail_check("generated source has dynamic capture storage") if generated.match?(/\bAny\b|\[[^\]]+\]|@escaping/)

puts "SPEC-001 nRF Static Canvas manifest passed: two dense cases, five occurrences, and one exact 32-byte trace record."
