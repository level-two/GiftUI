#!/usr/bin/env ruby

require "yaml"

root = File.expand_path("../..", __dir__)
fixtures = File.join(root, "Tests/ContractFixtures/SPEC011")
manifest_path = File.join(fixtures, "fixture-manifest.tsv")
required = %w[
  declarations.yaml candidates.yaml gestures.yaml dispatch.yaml failures.yaml
  normalized-transcript-schema.tsv resource-schema.tsv task-evidence.yaml
  migration-inventory.tsv required-evidence.tsv
]
missing = required.reject { |name| File.file?(File.join(fixtures, name)) }
abort "missing SPEC-011 fixtures: #{missing.join(', ')}" unless missing.empty?

manifest = File.readlines(manifest_path).reject { |line| line.start_with?("#") || line.strip.empty? }
orders = manifest.map { |line| line.split("\t", -1).first.to_i }
abort "fixture order is not contiguous" unless orders == (1..orders.length).to_a
paths = manifest.map { |line| line.split("\t", -1)[1] }
abort "duplicate fixture path" unless paths.uniq.length == paths.length
abort "manifest references missing fixture" unless paths.all? { |path| File.file?(File.join(fixtures, path)) }

%w[declarations candidates gestures dispatch failures].each do |name|
  document = YAML.safe_load(File.read(File.join(fixtures, "#{name}.yaml")))
  rows = document.fetch("rows")
  ids = rows.map { |row| row.fetch("id") }
  abort "#{name} has duplicate rows" unless ids.uniq.length == ids.length
end

evidence = YAML.safe_load(File.read(File.join(fixtures, "task-evidence.yaml"))).fetch("tasks")
expected_tasks = (0..9).flat_map do |milestone|
  count = { 0 => 4, 1 => 5, 2 => 5, 3 => 6, 4 => 4, 5 => 6, 6 => 4, 7 => 5, 8 => 5, 9 => 5 }.fetch(milestone)
  (1..count).map { |task| "T#{milestone}.#{task}" }
end
abort "task evidence keys differ" unless evidence.keys.sort == expected_tasks.sort

criteria = File.readlines(File.join(fixtures, "required-evidence.tsv")).reject { |line| line.start_with?("#") || line.strip.empty? }.map { |line| line.split("\t").first }
abort "acceptance criteria differ" unless criteria == (1..13).map { |value| format("IN-%03d", value) }

puts "SPEC-011 harness passed: #{manifest.length} ordered fixtures, #{evidence.length} task edges, and 13 criteria are registered."
