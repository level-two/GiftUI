#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../..", __dir__)
FIXTURES = File.join(ROOT, "Tests/ContractFixtures/SPEC001")

def rows(path)
  File.readlines(path, chomp: true).reject { |line| line.empty? || line.start_with?("#") }
end

inventory_path = File.join(FIXTURES, "migration-inventory.tsv")
inventory = rows(inventory_path).map { |line| line.split("\t", -1) }
abort "migration inventory columns differ" unless inventory.all? { |row| row.length == 4 }
abort "migration inventory contains duplicate paths" unless inventory.map(&:first).uniq.length == inventory.length
allowed = %w[preserve-as-evidence adapt replace downstream-owned]
abort "migration inventory contains unknown disposition" unless inventory.all? { |row| allowed.include?(row[2]) }
abort "migration inventory references a missing path" unless inventory.all? { |row| File.file?(File.join(ROOT, row[0])) }

demo_files = Dir[File.join(ROOT, "demo/SignalAnalyzer/{Sources,Tests}/**/*.swift")].sort.map { |path| path.delete_prefix("#{ROOT}/") }
recorded_demo = inventory.select { |row| %w[source test].include?(row[1]) }.map(&:first)
abort "demo source/test inventory is incomplete or stale" unless recorded_demo == demo_files

downstream_roots = (7..15).map { |number| File.join(ROOT, format("Tests/ContractFixtures/SPEC%03d", number)) }
downstream_files = downstream_roots.flat_map do |directory|
  Dir[File.join(directory, "**/*")].select do |path|
    File.file?(path) && (path.match?(/signal[ -]?analyzer/i) || File.read(path).match?(/signal[ -]?analyzer/i))
  end
end.sort.map { |path| path.delete_prefix("#{ROOT}/") }
recorded_downstream = inventory.select { |row| row[1] == "fixture" }.map(&:first)
abort "downstream analyzer fixture inventory is incomplete or stale" unless recorded_downstream == downstream_files

boundaries = rows(File.join(FIXTURES, "module-boundaries.tsv")).map { |line| line.split("\t", -1) }
abort "module boundary columns differ" unless boundaries.all? { |row| row.length == 4 }
abort "logical module boundary order differs" unless boundaries.map(&:first) == %w[SignalAnalyzerDomain SignalAnalyzerData SignalAnalyzerPresentation SignalAnalyzerHost]
abort "Data dependency rule differs" unless boundaries[1][2] == "SignalAnalyzerDomain"
abort "Presentation dependency rule differs" unless boundaries[2][2] == "SignalAnalyzerDomain,GiftUI,GiftUIFailureCore"

static_rows = rows(File.join(FIXTURES, "generated-static-equivalents.tsv")).map { |line| line.split("\t", -1) }
abort "generated-static equivalent columns differ" unless static_rows.all? { |row| row.length == 4 }
abort "generated-static owners differ" unless static_rows.map(&:first) == boundaries.map(&:first)

puts "SPEC-001 migration audit passed: #{recorded_demo.length} demo sources/tests and #{recorded_downstream.length} downstream fixtures are classified."
