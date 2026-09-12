#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
AUDIT = ROOT.join("Tests/ContractFixtures/SPEC006/normative-audit.tsv")
SPEC = ROOT.join("docs/specs/spec-006-declarative-view-semantics.md").read

def fail_check(message)
  warn "SPEC-006 normative audit check failed: #{message}"
  exit 1
end

required_areas = %w[
  non-goals public-contract module-contract rank-zero-apis traversal-api
  limits-summary recording-seam modifier-seam expansion-order structural-identity
  action-identity modifier-order atomicity lifecycle capabilities backends errors
  performance compatibility declaration-tests semantic-tests bounds-tests profile-tests
  primitive-container action-container migration
]
rows = AUDIT.readlines(chomp: true).each_with_object([]) do |line, result|
  next if line.empty? || line.start_with?("#")

  fields = line.split("\t", -1)
  fail_check("audit row must have five fields: #{line}") unless fields.length == 5
  result << fields
end

areas = rows.map(&:first)
fail_check("normative area inventory differs") unless areas == required_areas
fail_check("normative area inventory contains duplicates") unless areas.uniq.length == areas.length

rows.each do |area, section, evidence, checker, status|
  fail_check("#{area} is not complete") unless status == "complete"
  if area != "migration"
    fail_check("SPEC lacks section named by #{area}: #{section}") unless
      SPEC.include?(section.split(" — ").first)
  end
  fail_check("#{area} evidence is missing: #{evidence}") unless ROOT.join(evidence).file?
  fail_check("#{area} checker is missing: #{checker}") unless ROOT.join(checker).file?
end

migration = ROOT.join("Tests/ContractFixtures/SPEC006/migration-inventory.tsv").read
fail_check("migration ledger contains an unresolved disposition") unless
  migration.lines.drop(1).all? do |line|
    %w[remove replace-through-the-sealed-surface already-absent].include?(line.split("\t")[3])
  end

puts "SPEC-006 normative audit passed: 26 API, behavior, lifecycle, error, performance, compatibility, testing, non-goal, and migration areas have stable evidence and checks."
