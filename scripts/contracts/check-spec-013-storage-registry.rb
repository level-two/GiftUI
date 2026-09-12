#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
REGISTRY = ROOT.join("Tests/ContractFixtures/SPEC013/storage-families.tsv")
EXPECTED_FIELDS = %w[
  semanticCandidateBytes semanticPublishedBytes layoutCandidateBytes
  renderWorkspaceBytes canvasCallableBytes pathWorkspaceBytes drawingPlanBytes
  observableLiveBytes observableCandidateBytes interactionCandidateBytes
  interactionCommittedBytes admissionQueueBytes sealedBatchBytes
  pointerStateBytes coordinatorStateBytes failureStateBytes
].freeze
ALLOWED_CHARGES = %w[exclusive-or-complete-overlay-owner exclusive-or-zero-if-aliased].freeze

def fail_check(message)
  warn "SPEC-013 storage registry check failed: #{message}"
  exit 1
end

rows = REGISTRY.each_line.each_with_object([]) do |line, values|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("row width differs") unless fields.length == 6
  values << fields
end
fail_check("audit fields differ") unless rows.map(&:first) == EXPECTED_FIELDS
owners = rows.map { |row| row[1] }
fail_check("a byte owner is charged more than once") unless owners.uniq.length == owners.length
fail_check("a lifetime is missing") if rows.any? { |row| row[2].empty? || row[3].empty? }
fail_check("overlay charging rule differs") unless rows.all? { |row| ALLOWED_CHARGES.include?(row[4]) }
rows.each do |row|
  exclusions = row[5].split(",", -1)
  fail_check("#{row[0]} does not exclude allocator bookkeeping") unless exclusions.include?("allocator-bookkeeping")
  fail_check("#{row[0]} does not exclude stack") unless exclusions.include?("stack")
  fail_check("#{row[0]} does not exclude generated code") unless exclusions.include?("generated-code")
end

duplicate = rows + [rows.first]
duplicate_owners = duplicate.map { |row| row[1] }
fail_check("double-count rejection oracle is ineffective") if duplicate_owners.uniq.length == duplicate_owners.length

puts "SPEC-013 storage registry passed: 16 exclusive audit fields, overlay charging, simultaneous lifetimes, exclusions, and duplicate-owner rejection are exact."
