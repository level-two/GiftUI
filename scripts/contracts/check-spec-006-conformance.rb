#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
REPORT = ROOT.join("docs/conformance/spec-006-conformance.md").read
PLAN = ROOT.join("docs/implementation-plans/spec-006-implementation-plan.md").read
SPEC = ROOT.join("docs/specs/spec-006-declarative-view-semantics.md").read

def fail_check(message)
  warn "SPEC-006 conformance check failed: #{message}"
  exit 1
end

report_collecting = REPORT.match?(/\nstatus: collecting\n/)
report_complete = REPORT.match?(/\nstatus: complete\n/)
fail_check("report must be collecting or complete") unless
  report_collecting || report_complete
spec_implementing = SPEC.match?(/\nstatus: implementing\n/)
spec_implemented = SPEC.match?(/\nstatus: implemented\n/)
fail_check("Specification must be implementing or implemented") unless
  spec_implementing || spec_implemented
plan_active = PLAN.match?(/\nstatus: active\n/)
plan_completed = PLAN.match?(/\nstatus: completed\n/)
fail_check("plan must be active or completed") unless plan_active || plan_completed
fail_check("reviewed revision is missing") unless
  REPORT.match?(/Reviewed implementation revision: `[0-9a-f]{40}`/)

(1..17).each do |ordinal|
  criterion = format("DV-%03d", ordinal)
  rows = REPORT.scan(/^\| `#{criterion}` \|/).length
  fail_check("#{criterion} must appear in exactly one result row") unless rows == 1
  result_is_pass = REPORT.match?(/^\| `#{criterion}` \| pass \|/)
  result_is_pending = REPORT.match?(/^\| `#{criterion}` \| pending \|/)
  if report_complete || ordinal < 17
    fail_check("#{criterion} is not passing") unless result_is_pass
  else
    fail_check("#{criterion} has an invalid collecting result") unless
      result_is_pass || result_is_pending
  end
  if spec_implemented
    fail_check("#{criterion} is not checked in the implemented Specification") unless
      SPEC.match?(/^- \[x\] \*\*#{criterion}:\*\*/)
  end
end

if report_complete
  fail_check("report omits explicit human authorization") unless
    REPORT.match?(/maintainer explicitly authorized\s+that transition/m)
end
hardware_boundary = /No simulator, remote\s+Pi, connected board, deployment, service restart, or flashing is claimed/
fail_check("report omits hardware evidence boundary") unless REPORT.match?(hardware_boundary)

REPORT.scan(/\[[^\]]+\]\((\.\.\/[^)]+)\)/).flatten.each do |relative|
  path = ROOT.join("docs/conformance", relative).cleanpath
  fail_check("report link is missing: #{relative}") unless path.file?
end

state = spec_implemented ? "implemented" : "implementing pending renewed review"
puts "SPEC-006 conformance record passed: 17 criteria registered; report #{report_complete ? 'complete' : 'collecting'}; Specification #{state}."
