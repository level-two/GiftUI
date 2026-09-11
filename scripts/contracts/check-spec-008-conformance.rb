#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
REPORT = ROOT.join("docs/conformance/spec-008-conformance.md").read
PLAN = ROOT.join("docs/implementation-plans/spec-008-implementation-plan.md").read
SPEC = ROOT.join("docs/specs/spec-008-rendering.md").read

def fail_check(message)
  warn "SPEC-008 conformance check failed: #{message}"
  exit 1
end

fail_check("report must be complete") unless REPORT.match?(/\nstatus: complete\n/)
fail_check("Specification must be implemented") unless SPEC.match?(/\nstatus: implemented\n/)
fail_check("plan must be completed") unless PLAN.match?(/\nstatus: completed\n/)
fail_check("reviewed revision is missing") unless
  REPORT.match?(/Reviewed implementation revision: `[0-9a-f]{40}`/)

(1..11).each do |ordinal|
  criterion = format("RD-%03d", ordinal)
  rows = REPORT.scan(/^\| `#{criterion}` \|/).length
  fail_check("#{criterion} must appear in exactly one result row") unless rows == 1
  fail_check("#{criterion} is not passing") unless REPORT.match?(/^\| `#{criterion}` \| pass \|/)
  fail_check("#{criterion} is not checked in the implemented Specification") unless
    SPEC.match?(/^- \[x\] \*\*#{criterion}:\*\*/)
end

fail_check("report omits explicit human authorization") unless
  REPORT.match?(/maintainer explicitly authorized that transition/m)
hardware_boundary = /does not claim target execution, display\/input validation, remote\s+access, deployment, service restart, or flashing/
fail_check("report omits hardware evidence boundary") unless REPORT.match?(hardware_boundary)

REPORT.scan(/\[[^\]]+\]\((\.\.\/[^)]+)\)/).flatten.each do |relative|
  path = ROOT.join("docs/conformance", relative).cleanpath
  fail_check("report link is missing: #{relative}") unless path.file?
end

puts "SPEC-008 conformance passed: all 11 criteria passing; report complete; Specification implemented."
