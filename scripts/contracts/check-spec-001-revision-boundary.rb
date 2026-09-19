#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
path = File.join(root, "Tests/ContractFixtures/SPEC001/revision-boundary-cases.tsv")
rows = File.readlines(path, chomp: true).reject { |line| line.empty? || line.start_with?("#") }.map { |line| line.split("\t", -1) }
abort "SPEC-001 revision boundary columns differ" unless rows.all? { |row| row.length == 10 }
abort "SPEC-001 revision operations differ" unless rows.map(&:first) == %w[transition clear]
abort "SPEC-001 max-minus-one boundary differs" unless rows.all? { |row| row[1] == "4294967294" && row[3] == "4294967295" }
abort "SPEC-001 terminal procedure differs" unless rows.all? { |row| row[4..9] == %w[captureRevisionExhausted true 1 0 0 fresh-graph-only] }
puts "SPEC-001 capture revision boundary passed for transition and Clear."
