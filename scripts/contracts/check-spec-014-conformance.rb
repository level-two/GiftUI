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

fail_check("report must be complete") unless REPORT.match?(/\nstatus: complete\n/)
fail_check("plan must be completed") unless PLAN.match?(/\nstatus: completed\n/)
fail_check("Specification must remain implementing pending human authority") unless SPEC.match?(/\nstatus: implementing\n/)
fail_check("reviewed revision is missing") unless REPORT.match?(/Reviewed implementation revision: `[0-9a-f]{40}`/)

(1..15).each do |ordinal|
  criterion = format("BI-%03d", ordinal)
  fail_check("#{criterion} must appear exactly once") unless REPORT.scan(/^\| `#{criterion}` \|/).length == 1
  fail_check("#{criterion} is not passing") unless REPORT.match?(/^\| `#{criterion}` \| pass \|/)
end

EVIDENCE_PATH.each_line do |line|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("#{fields.fetch(0)} evidence is not complete") unless fields.fetch(4) == "complete"
end
fail_check("report claims transition authority") unless REPORT.include?("authorization has not been given")
fail_check("report omits hardware boundary") unless REPORT.match?(/does not claim target\nexecution, connected framebuffer\/PiScreen\/TFT behavior, remote access,\ndeployment, service restart, or flashing/)

REPORT.scan(/\[[^\]]+\]\((\.\.\/[^)]+)\)/).flatten.each do |relative|
  path = REPORT_PATH.dirname.join(relative).cleanpath
  fail_check("report link is missing: #{relative}") unless path.file?
end

puts "SPEC-014 conformance passed: all 15 criteria pass; implementation transition awaits human authorization."
