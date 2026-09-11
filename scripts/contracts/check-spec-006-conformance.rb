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

fail_check("report must remain collecting") unless REPORT.match?(/\nstatus: collecting\n/)
fail_check("Specification must remain implementing") unless SPEC.match?(/\nstatus: implementing\n/)
active_amendment = PLAN.match?(/\nstatus: active\n/)
completed_amendment = PLAN.match?(/\nstatus: completed\n/)
fail_check("plan must be active or completed") unless active_amendment || completed_amendment
fail_check("reviewed revision is missing") unless
  REPORT.match?(/Reviewed implementation revision: `[0-9a-f]{40}`/)

(1..16).each do |ordinal|
  criterion = format("DV-%03d", ordinal)
  rows = REPORT.scan(/^\| `#{criterion}` \|/).length
  fail_check("#{criterion} must appear in exactly one result row") unless rows == 1
  if active_amendment && ordinal == 16
    fail_check("DV-016 must remain pending while the amendment plan is active") unless
      REPORT.match?(/^\| `DV-016` \| pending \|/)
  else
    fail_check("#{criterion} is not passing") unless REPORT.match?(/^\| `#{criterion}` \| pass \|/)
  end
end

fail_check("report claims an implemented transition") if REPORT.match?(/status: implemented/)
fail_check("report omits human authorization gate") unless
  REPORT.include?("explicit human authorization")
hardware_boundary = /No simulator, remote\s+Pi, connected board, deployment, service restart, or flashing is claimed/
fail_check("report omits hardware evidence boundary") unless REPORT.match?(hardware_boundary)

REPORT.scan(/\[[^\]]+\]\((\.\.\/[^)]+)\)/).flatten.each do |relative|
  path = ROOT.join("docs/conformance", relative).cleanpath
  fail_check("report link is missing: #{relative}") unless path.file?
end

state = active_amendment ? "15 passing criteria and DV-016 pending" : "all 16 criteria passing"
puts "SPEC-006 conformance passed: #{state}; the report remains collecting and the human implemented-transition gate remains open."
