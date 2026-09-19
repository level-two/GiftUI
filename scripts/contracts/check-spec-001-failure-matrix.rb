#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
path = File.join(root, "Tests/ContractFixtures/SPEC001/exhaustive-failure-cases.tsv")
rows = File.readlines(path, chomp: true).reject { |line| line.empty? || line.start_with?("#") }
fields = rows.map { |line| line.split("\t", -1) }
abort "SPEC-001 failure matrix columns differ" unless fields.all? { |row| row.length == 10 }
abort "SPEC-001 failure matrix order differs" unless fields.map { |row| row[0].to_i } == (1..19).to_a
abort "SPEC-001 failure matrix has duplicate conditions" unless fields.map { |row| row[2] }.uniq.length == 19

required = %w[
  snapshotCapacityExhausted factCapacityExhausted runtimeUnavailable sequenceExhausted
  reservedFailureRejected stateLocationCapacityExhausted registrationCapacityExhausted
  replacementStagingExhausted duplicateModelOwner incompatibleStateAssociation
  staleRegistrationReport identityGenerationExhausted captureRevisionMismatch
  reservedFailureCapacityExhausted mutationPhaseViolation-contained
  mutationPhaseViolation-unsafe observableStateReentrancyViolation
  observableStateInvariantViolation captureRevisionExhausted
]
abort "SPEC-001 failure matrix is not exhaustive" unless fields.map { |row| row[2] } == required
abort "SPEC-001 failure matrix has invalid booleans" unless fields.all? { |row| %w[true false].include?(row[3]) && %w[true false].include?(row[4]) && %w[true false].include?(row[9]) }
abort "SPEC-001 failure matrix has invalid policy count" unless fields.all? { |row| %w[0 1].include?(row[6]) }
abort "SPEC-001 no-policy rows call policy" unless fields.select { |row| row[7] == "none" || row[7] == "coordinator-retry" }.all? { |row| row[6] == "0" }

puts "SPEC-001 exhaustive failure matrix passed: #{fields.length} normalized rows."
