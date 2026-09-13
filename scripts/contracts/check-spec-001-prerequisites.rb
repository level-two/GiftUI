#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"

ROOT = File.expand_path("../..", __dir__)
FIXTURES = File.join(ROOT, "Tests/ContractFixtures/SPEC001")
STATUSES = %w[available missing not-applicable].freeze

def rows(path)
  File.readlines(path, chomp: true).reject { |line| line.empty? || line.start_with?("#") }.map { |line| line.split("\t", -1) }
end

prerequisites = rows(File.join(FIXTURES, "prerequisite-registry.tsv"))
expected_specs = (2..15).map { |number| format("SPEC-%03d", number) }
abort "prerequisite registry columns differ" unless prerequisites.all? { |row| row.length == 8 }
abort "prerequisite registry is missing, duplicate, unknown, or reordered" unless prerequisites.map(&:first) == expected_specs
abort "prerequisite registry has unknown status" unless prerequisites.all? { |row| row[1, 5].all? { |status| STATUSES.include?(status) } }
prerequisites.each do |row|
  has_missing = row[1, 5].include?("missing")
  abort "#{row[0]} missing prerequisite lacks blocker" if has_missing && row[6] == "-"
  abort "#{row[0]} available prerequisites name a blocker" if !has_missing && row[6] != "-"
  abort "#{row[0]} evidence path is missing" unless File.file?(File.join(ROOT, row[7]))
end

source_truth = rows(File.join(FIXTURES, "downstream-source-truth.tsv"))
abort "source-of-truth registry columns differ" unless source_truth.all? { |row| row.length == 4 }
abort "source-of-truth registry has duplicate paths" unless source_truth.map { |row| row[1] }.uniq.length == source_truth.length
abort "source-of-truth registry owner is out of range" unless source_truth.all? { |row| expected_specs.drop(5).include?(row[0]) }
source_truth.each do |owner, path, expected_digest, use|
  absolute = File.join(ROOT, path)
  abort "#{owner} source-of-truth path is missing: #{path}" unless File.file?(absolute)
  abort "#{owner} source-of-truth use is missing: #{path}" if use.empty?
  actual_digest = Digest::SHA256.file(absolute).hexdigest
  abort "#{owner} source-of-truth drift: #{path}" unless actual_digest == expected_digest
end

puts "SPEC-001 prerequisite audit passed: 14 owner contracts and #{source_truth.length} pinned downstream inputs are registered."
