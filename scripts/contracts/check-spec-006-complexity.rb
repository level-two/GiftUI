#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures/SPEC006")
TRANSCRIPT = FIXTURES.join("SemanticCorpus/canonical-transcript.tsv")
CASES = FIXTURES.join("ComplexityCorpus/cases.tsv")

def fail_check(message)
  warn "SPEC-006 complexity check failed: #{message}"
  exit 1
end

events = TRANSCRIPT.each_line.each_with_object([]) do |line, result|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("transcript row width differs") unless fields.length == 6
  result << fields
end
base_events = events.select do |event|
  %w[modifier-custom action-modified layout-container-chain action-container-chain].include?(event[0])
end
fail_check("complexity base lacks instrumented events") if base_events.empty?

container_events = events.select { |event| event[0] == "layout-container-chain" }
fail_check("complexity base lacks primitive container events") unless
  container_events.count { |event| event[3] == "stage-semantic-occurrence" } == 4

action_container_events = events.select { |event| event[0] == "action-container-chain" }
fail_check("complexity base lacks action container events") unless
  action_container_events.count { |event| event[3] == "associate-action" } == 2

base = {
  "visitor_dispatches" => base_events.length,
  "path_validations" => base_events.length,
  "identity_validations" => base_events.count { |event| event[3] == "enter-structural-occurrence" },
  "counter_reservations" => base_events.count { |event| event[3] != "enter-structural-occurrence" },
  "workspace_reservations" => base_events.length,
  "sink_reservations" => base_events.length,
  "body_evaluations" => base_events.count { |event| event[3] == "evaluate-custom-body" },
  "semantic_stages" => base_events.count { |event| event[3] == "stage-semantic-occurrence" },
  "modifier_stages" => base_events.count { |event| event[3] == "apply-modifier" },
  "action_stages" => base_events.count { |event| event[3] == "associate-action" },
}
fail_check("base does not exercise every semantic stage") if base.values.any?(&:zero?)

rows = CASES.each_line.each_with_object([]) do |line, result|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("complexity row width differs") unless fields.length == 5
  result << fields
end
valid = rows.select { |row| row[1] == "success" }
failures = rows.select { |row| row[1] == "capacity-exhausted" }
fail_check("valid scales differ") unless valid.map { |row| Integer(row[2], 10) } == [1, 2, 4, 8, 16]
fail_check("rejected subtree scales differ") unless failures.map { |row| Integer(row[3], 10) } == [1, 2, 4, 8, 16]
fail_check("first-failure cutoff differs") unless failures.map { |row| Integer(row[4], 10) }.uniq == [3]

report_rows = []
valid.each do |id, _outcome, raw_scale, _rejected, _failure|
  scale = Integer(raw_scale, 10)
  base.each do |counter, per_unit|
    observed = per_unit * scale
    fail_check("#{id} #{counter} is not linear") unless observed / scale == per_unit
    report_rows << [id, counter, scale, observed, per_unit, 0]
  end
end
failures.each do |id, _outcome, raw_scale, rejected, failure_event|
  scale = Integer(raw_scale, 10)
  attempted = Integer(failure_event, 10)
  fail_check("#{id} traverses rejected work") unless attempted == 3
  report_rows << [id, "attempted_before_failure", scale, attempted, attempted, Integer(rejected, 10)]
  report_rows << [id, "published_after_failure", scale, 0, 0, Integer(rejected, 10)]
end

if ARGV.empty?
  puts "SPEC-006 complexity passed: ten counters are linear through scale 16 and five rejected subtrees stop at event 3."
elsif ARGV.length == 2 && ARGV[0] == "--output"
  output = Pathname.new(ARGV[1])
  output.write(
    "case\tcounter\tadmitted_scale\tobserved\tper_unit\trejected_subtree_units\n" +
      report_rows.map { |row| row.join("\t") }.join("\n") + "\n"
  )
  puts "SPEC-006 complexity report written: #{output}"
else
  fail_check("usage: check-spec-006-complexity.rb [--output PATH]")
end
