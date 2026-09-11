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

fail_check("report must be complete") unless REPORT.match?(/\nstatus: complete\n/)
spec_implementing = SPEC.match?(/\nstatus: implementing\n/)
spec_implemented = SPEC.match?(/\nstatus: implemented\n/)
fail_check("Specification must be implementing or implemented") unless
  spec_implementing || spec_implemented
fail_check("plan must be completed") unless PLAN.match?(/\nstatus: completed\n/)
fail_check("reviewed revision is missing") unless
  REPORT.match?(/Reviewed implementation revision: `[0-9a-f]{40}`/)

(1..16).each do |ordinal|
  criterion = format("DV-%03d", ordinal)
  rows = REPORT.scan(/^\| `#{criterion}` \|/).length
  fail_check("#{criterion} must appear in exactly one result row") unless rows == 1
  fail_check("#{criterion} is not passing") unless REPORT.match?(/^\| `#{criterion}` \| pass \|/)
end

fail_check("report omits explicit human authorization") unless
  REPORT.match?(/maintainer explicitly authorized\s+that transition/m)
hardware_boundary = /No simulator, remote\s+Pi, connected board, deployment, service restart, or flashing is claimed/
fail_check("report omits hardware evidence boundary") unless REPORT.match?(hardware_boundary)

REPORT.scan(/\[[^\]]+\]\((\.\.\/[^)]+)\)/).flatten.each do |relative|
  path = ROOT.join("docs/conformance", relative).cleanpath
  fail_check("report link is missing: #{relative}") unless path.file?
end

state = spec_implemented ? "implemented" : "implementing pending the authorized transition"
puts "SPEC-006 conformance passed: all 16 criteria passing; report complete; Specification #{state}."
