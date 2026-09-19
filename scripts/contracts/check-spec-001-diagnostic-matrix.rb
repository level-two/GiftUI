#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
path = File.join(root, "Tests/ContractFixtures/SPEC001/diagnostic-profile-matrix.tsv")
rows = File.readlines(path, chomp: true).reject { |line| line.empty? || line.start_with?("#") }.map { |line| line.split("\t", -1) }
abort "SPEC-001 diagnostic matrix columns differ" unless rows.all? { |row| row.length == 8 }
abort "SPEC-001 diagnostic modes differ" unless rows.map { |row| row[1] } == %w[omitted enabled filtered saturated dropped failing]
abort "SPEC-001 diagnostic matrix changes authoritative outcomes" unless rows.map { |row| row[3] }.uniq.length == 1
abort "SPEC-001 diagnostic bytes differ" unless rows.all? { |row| row[4] == row[5] && row[5] == row[6] }
abort "SPEC-001 diagnostic profiles differ" unless rows.all? { |row| row[7] == "true" }
puts "SPEC-001 diagnostic profile matrix passed: #{rows.length} projection modes."
