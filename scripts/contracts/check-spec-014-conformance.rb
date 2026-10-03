#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
REPORT_PATH = ROOT.join("docs/conformance/spec-014-conformance.md")
PLAN_PATH = ROOT.join("docs/implementation-plans/spec-014-implementation-plan.md")
SPEC_PATH = ROOT.join("docs/specs/spec-014-backend-integration.md")
EVIDENCE_PATH = ROOT.join("Tests/ContractFixtures/SPEC014/required-evidence.tsv")
REPORT = REPORT_PATH.read
PLAN = PLAN_PATH.read
SPEC = SPEC_PATH.read

def fail_check(message)
  warn "SPEC-014 conformance check failed: #{message}"
  exit 1
end

collecting = REPORT.match?(/\nstatus: collecting\n/)
complete = REPORT.match?(/\nstatus: complete\n/)
fail_check("report must be collecting or complete") unless collecting || complete
fail_check("plan status differs from report readiness") unless
  collecting ? PLAN.match?(/\nstatus: active\n/) : PLAN.match?(/\nstatus: completed\n/)
implemented = SPEC.match?(/\nstatus: implemented\n/)
fail_check("Specification must be implementing or implemented") unless
  implemented || SPEC.match?(/\nstatus: implementing\n/)
fail_check("reviewed revision is missing") unless REPORT.match?(/Reviewed implementation revision: `[0-9a-f]{40}`/)

(1..15).each do |ordinal|
  criterion = format("BI-%03d", ordinal)
  fail_check("#{criterion} must appear exactly once") unless REPORT.scan(/^\| `#{criterion}` \|/).length == 1
  result = REPORT[/^\| `#{criterion}` \| (pass|pending) \|/, 1]
  fail_check("#{criterion} has no valid disposition") unless result
  fail_check("#{criterion} is not passing in complete report") if complete && result != "pass"
end

EVIDENCE_PATH.each_line do |line|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  allowed = collecting ? %w[complete pending] : %w[complete]
  fail_check("#{fields.fetch(0)} evidence has invalid disposition") unless allowed.include?(fields.fetch(4))
  row_result = REPORT[/^\| `#{fields.fetch(0)}` \| (pass|pending) \|/, 1]
  fail_check("#{fields.fetch(0)} ledger/report disposition differs") unless
    row_result == (fields.fetch(4) == "complete" ? "pass" : "pending")
end
if implemented
  fail_check("implemented Specification requires a complete report") unless complete
  fail_check("report omits explicit human authorization") unless
    REPORT.include?("Eugene explicitly approved SPEC-014's `implementing → implemented` transition")
else
  fail_check("report claims transition authority") unless REPORT.include?("authorization has not been given")
end
fail_check("report omits hardware boundary") unless REPORT.match?(/does not claim target\nexecution, connected framebuffer\/PiScreen\/TFT behavior, remote access,\ndeployment, service restart, or flashing/)

REPORT.scan(/\[[^\]]+\]\((\.\.\/[^)]+)\)/).flatten.each do |relative|
  path = REPORT_PATH.dirname.join(relative).cleanpath
  fail_check("report link is missing: #{relative}") unless path.file?
end

puts "SPEC-014 conformance record passed: 15 explicit dispositions; report #{collecting ? 'collecting' : 'complete'}; pending criteria remain unfulfilled."
