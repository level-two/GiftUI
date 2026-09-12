#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures/SPEC012")
INPUT = FIXTURES.join("static-canvas-input.yaml")
MANIFEST = FIXTURES.join("static-canvas-manifest.yaml")
REJECTIONS = FIXTURES.join("static-canvas-rejection-cases.yaml")
GENERATED = ROOT.join(
  "Tests/GiftUIDrawingTests/GeneratedStaticCanvasCallableTable.swift"
)
CAPTURE_LAYOUTS = {
  "Color" => [3, 1],
  "GeometryScalar" => [4, 4],
}.freeze
CLASS_CAPTURE_TYPES = %w[FixtureModel].freeze

def fail_check(message)
  warn "SPEC-012 static Canvas manifest check failed: #{message}"
  exit 1
end

def load_yaml(path)
  document = YAML.safe_load(path.read, aliases: false)
  fail_check("#{path.basename} root is not a mapping") unless document.is_a?(Hash)
  document
end

def require_keys(value, keys, context)
  fail_check("#{context} is not a mapping") unless value.is_a?(Hash)
  actual = value.keys.sort
  expected = keys.sort
  fail_check("#{context} fields differ: #{actual.inspect}") unless actual == expected
end

def align(value, alignment)
  remainder = value % alignment
  remainder.zero? ? value : value + alignment - remainder
end

def rejection_for(candidate, limits)
  ids = candidate.fetch("callable_ids")
  coverage = candidate.fetch("switch_coverage")
  captures = candidate.fetch("captures")
  return "callable ID is zero" if ids.any? { |id| id == 0 }
  return "callable ID exceeds UInt16" if ids.any? { |id| id > 65_535 }
  if ids.length > limits.fetch("maximum_callable_cases")
    return "callable case count exceeds limit"
  end
  return "switch coverage is duplicated" unless coverage.uniq == coverage
  return "switch coverage is incomplete" unless coverage.sort == ids.sort

  captures.each do |capture|
    return "dynamic collection capture is prohibited" if capture.match?(/\A\[|\AArray</)
    return "existential capture is prohibited" if capture.match?(/\A(?:any|some)\s/)
    return "weak capture is prohibited" if capture.start_with?("weak ")
    return "unowned capture is prohibited" if capture.start_with?("unowned ")
    if capture.match?(/\A(?:HeapBox|ManagedBuffer|String)(?:<|\z)/)
      return "heap-owned box capture is prohibited"
    end
    return "class reference capture is prohibited" if CLASS_CAPTURE_TYPES.include?(capture)
    return "closure capture is prohibited" if capture.include?("->") || capture.include?("@escaping")
    return "unsupported capture type" unless CAPTURE_LAYOUTS.key?(capture)
  end

  cursor = 0
  record_alignment = 1
  captures.each do |capture|
    size, alignment = CAPTURE_LAYOUTS.fetch(capture)
    cursor = align(cursor, alignment) + size
    record_alignment = [record_alignment, alignment].max
  end
  return "capture bytes exceed limit" if
    align(cursor, record_alignment) > limits.fetch("maximum_capture_bytes")

  nil
end

input = load_yaml(INPUT)
manifest = load_yaml(MANIFEST)
require_keys(input, %w[expressions occurrences schema source], "input")
fail_check("input schema differs") unless input["schema"] == "spec-012-static-canvas-input-v1"

source = ROOT.join(input.fetch("source"))
fail_check("input source is outside the repository") unless source.to_s.start_with?(ROOT.to_s + "/")
fail_check("input source is missing") unless source.file?
source_text = source.read

expressions = input.fetch("expressions")
fail_check("expressions are empty") unless expressions.is_a?(Array) && !expressions.empty?
expected_orders = (1..expressions.length).to_a
fail_check("expression order is not dense") unless expressions.map { |item| item["order"] } == expected_orders
expression_keys = expressions.map { |item| item["key"] }
fail_check("expression keys are duplicated") unless expression_keys.uniq.length == expression_keys.length

callable_cases = expressions.each_with_index.map do |expression, index|
  require_keys(expression, %w[captures key order], "expression #{index + 1}")
  key = expression.fetch("key")
  marker = "giftui-static-canvas-expression: #{key}"
  fail_check("source marker for #{key} is not unique") unless source_text.scan(marker).length == 1

  fields = expression.fetch("captures")
  fail_check("captures for #{key} are not a sequence") unless fields.is_a?(Array)
  names = fields.map { |field| field["name"] }
  fail_check("capture names for #{key} are duplicated") unless names.uniq.length == names.length

  cursor = 0
  record_alignment = 1
  laid_out_fields = fields.map.with_index do |field, field_index|
    require_keys(field, %w[name type], "capture #{key}[#{field_index}]")
    size, alignment = CAPTURE_LAYOUTS[field.fetch("type")]
    fail_check("fixture capture type #{field['type']} has no checked layout") unless size
    cursor = align(cursor, alignment)
    offset = cursor
    cursor += size
    record_alignment = [record_alignment, alignment].max
    { "name" => field.fetch("name"), "type" => field.fetch("type"), "offset" => offset }
  end

  callable_id = index + 1
  fail_check("callable ID exceeds UInt16") if callable_id > 65_535
  {
    "id" => callable_id,
    "expression" => key,
    "capture_record_type" => "StaticCanvasCapture#{callable_id}",
    "capture_byte_count" => align(cursor, record_alignment),
    "capture_alignment" => record_alignment,
    "fields" => laid_out_fields,
  }
end

case_by_expression = callable_cases.to_h { |item| [item.fetch("expression"), item] }
occurrences = input.fetch("occurrences")
fail_check("occurrences are empty") unless occurrences.is_a?(Array) && !occurrences.empty?
fail_check("occurrence order is not dense") unless
  occurrences.map { |item| item["order"] } == (1..occurrences.length).to_a
occurrence_keys = occurrences.map { |item| item["key"] }
capture_records = occurrences.map { |item| item["capture_record"] }
fail_check("occurrence keys are duplicated") unless occurrence_keys.uniq.length == occurrence_keys.length
fail_check("capture records are not occurrence-owned") unless capture_records.uniq.length == capture_records.length

manifest_occurrences = occurrences.map.with_index do |occurrence, index|
  require_keys(
    occurrence,
    %w[capture_record captured_values expression key order],
    "occurrence #{index + 1}"
  )
  callable_case = case_by_expression[occurrence.fetch("expression")]
  fail_check("occurrence #{occurrence['key']} names an unknown expression") unless callable_case
  values = occurrence.fetch("captured_values")
  fail_check("captured values for #{occurrence['key']} are not a mapping") unless values.is_a?(Hash)
  field_names = callable_case.fetch("fields").map { |field| field.fetch("name") }
  fail_check("captured fields for #{occurrence['key']} differ") unless values.keys == field_names
  occurrence.merge("callable_id" => callable_case.fetch("id"))
end

expected_manifest = {
  "schema" => "spec-012-static-canvas-manifest-v1",
  "source_schema" => input.fetch("schema"),
  "callable_case_count" => callable_cases.length,
  "greatest_capture_byte_count" => callable_cases.map { |item| item.fetch("capture_byte_count") }.max,
  "callable_cases" => callable_cases,
  "switch_coverage" => callable_cases.map { |item| item.fetch("id") },
  "occurrences" => manifest_occurrences,
}

fail_check("checked manifest differs from canonical input lowering") unless manifest == expected_manifest
fail_check("callable IDs contain zero") if manifest.fetch("switch_coverage").include?(0)
fail_check("switch coverage is incomplete") unless
  manifest.fetch("switch_coverage") == manifest.fetch("callable_cases").map { |item| item.fetch("id") }

trace_occurrences = manifest_occurrences.select { |item| item.fetch("expression") == "trace" }
fail_check("repeated-expression fixture is missing") unless trace_occurrences.length == 2
fail_check("repeated expression did not reuse its callable ID") unless
  trace_occurrences.map { |item| item.fetch("callable_id") }.uniq.length == 1
fail_check("repeated expression reused capture storage") unless
  trace_occurrences.map { |item| item.fetch("capture_record") }.uniq.length == trace_occurrences.length

fail_check("generated callable table is missing") unless GENERATED.file?
generated = GENERATED.read
fail_check("generated source does not name its manifest") unless
  generated.include?("Generated from Tests/ContractFixtures/SPEC012/static-canvas-manifest.yaml.")
fail_check("generated table does not conform") unless
  generated.include?("struct GeneratedStaticCanvasCallableTable: StaticCanvasCallableTable")
fail_check("generated case count differs") unless
  generated.include?("let callableCaseCount: UInt16 = #{manifest.fetch('callable_case_count')}")
manifest.fetch("callable_cases").each do |callable_case|
  id = callable_case.fetch("id")
  bytes = callable_case.fetch("capture_byte_count")
  fail_check("generated capture record #{id} is missing") unless
    generated.include?("struct GeneratedStaticCanvasCapture#{id}")
  fail_check("generated byte count for case #{id} differs") unless
    generated.include?("case #{id}: #{bytes}")
  fail_check("generated dispatch does not cover case #{id} exactly once") unless
    generated.scan(/^        case #{id}:$/).length == 1
end
fail_check("generated dispatch does not borrow capture storage") unless
  generated.include?("captures: borrowing GeneratedStaticCanvasCaptureStorage")
fail_check("generated table copies the complete capture storage") if
  generated.match?(/\bcopy\s+captures\b|=\s*captures\b(?!\.)/)
fail_check("generated table retains a closure fallback") if
  generated.match?(/@escaping|\[\s*GeneratedStaticCanvasCaptureStorage\s*\]/)

rejections = load_yaml(REJECTIONS)
require_keys(rejections, %w[cases limits schema], "rejection corpus")
fail_check("rejection schema differs") unless
  rejections["schema"] == "spec-012-static-canvas-rejections-v1"
limits = rejections.fetch("limits")
require_keys(
  limits,
  %w[maximum_callable_cases maximum_capture_bytes],
  "rejection limits"
)
cases = rejections.fetch("cases")
fail_check("rejection cases are empty") unless cases.is_a?(Array) && !cases.empty?
keys = cases.map { |item| item["key"] }
fail_check("rejection case keys are duplicated") unless keys.uniq.length == keys.length
cases.each do |candidate|
  require_keys(
    candidate,
    %w[callable_ids captures expected key switch_coverage],
    "rejection #{candidate['key']}"
  )
  actual = rejection_for(candidate, limits)
  fail_check("rejection #{candidate['key']} differed: #{actual.inspect}") unless
    actual == candidate.fetch("expected")
end

puts "SPEC-012 static Canvas manifest passed: three generated cases, greatest-case capture storage, four occurrence records, and #{cases.length} exact build-time rejections."
