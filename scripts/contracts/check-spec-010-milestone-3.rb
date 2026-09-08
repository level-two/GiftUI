#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
EVIDENCE = ROOT.join("Tests/ContractFixtures/SPEC010/Evidence/milestone-3")
PLAN = ROOT.join("docs/implementation-plans/spec-010-implementation-plan.md")
REGISTRY = ROOT.join("Tests/ContractFixtures/SPEC010/required-evidence.tsv")

def fail_check(message)
  warn "SPEC-010 Milestone 3 check failed: #{message}"
  exit 1
end

required = %w[
  candidate-lifecycle.md
  binding-decorator.md
  structural-reconciliation.md
  reconciliation-faults.md
]
required.each do |name|
  path = EVIDENCE.join(name)
  fail_check("missing or empty #{name}") unless path.file? && !path.empty?
end

summary = EVIDENCE.join("README.md").read
required.each do |name|
  fail_check("summary does not link #{name}") unless summary.include?(name)
end
%w[T3.1 T3.2 T3.3 T3.4].each do |task|
  fail_check("summary does not map #{task}") unless summary.include?(task)
end

plan = PLAN.read
%w[T3.1 T3.2 T3.3 T3.4].each do |task|
  fail_check("#{task} is not completed in the active plan") unless plan.match?(
    /- \[x\] `#{Regexp.escape(task)}`/
  )
end

rows = REGISTRY.each_line.each_with_object([]) do |line, collected|
  next if line.start_with?("#") || line.strip.empty?

  collected << line.chomp.split("\t", -1)
end
tracked = rows.select { |row| %w[OS-002 OS-003 OS-005].include?(row[0]) }
fail_check("Milestone 3 acceptance rows differ") unless tracked.map(&:first) == %w[OS-002 OS-003 OS-005]
fail_check("dependent acceptance rows were closed early") unless tracked.all? { |row| row[3] == "pending" }

puts "SPEC-010 Milestone 3 passed: four task records are consolidated and dependent acceptance criteria remain pending."
