#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
INVENTORY = ROOT.join("Tests/ContractFixtures/SPEC010/migration-inventory.tsv")
POC_REVISION = "d5d6330432caa7c983d8dba35cf9f23c3800860b"

def fail_check(message)
  warn "SPEC-010 migration check failed: #{message}"
  exit 1
end

actual_revision, revision_error, revision_status = Open3.capture3(
  "git", "-C", ROOT.to_s, "rev-parse", "PoC^{}"
)
fail_check(revision_error) unless revision_status.success?
fail_check("PoC tag changed") unless actual_revision.chomp == POC_REVISION

rows = INVENTORY.each_line.each_with_object([]) do |line, result|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("inventory row must have five fields") unless fields.length == 5
  result << fields
end
fail_check("inventory is empty") if rows.empty?
keys = rows.map { |family, path, _count, _disposition, _owner| [family, path] }
fail_check("inventory keys are duplicated") unless keys.uniq.length == keys.length

allowed_families = %w[
  portable-state task-local-binding string-key any-store existential-storage
  runtime-state-path direct-model-mutation apple-observation spike-spelling
]
allowed_dispositions = %w[remove replace-through-owner downstream-owned evidence-only]
rows.each do |family, path, count, disposition, owner|
  fail_check("invalid family #{family}") unless allowed_families.include?(family)
  fail_check("invalid occurrence count for #{family}/#{path}") unless count.match?(/\A(?:0|[1-9][0-9]*)\z/)
  fail_check("invalid disposition for #{family}/#{path}") unless allowed_dispositions.include?(disposition)
  fail_check("missing replacement owner for #{family}/#{path}") if owner.empty?
  if count == "0" && (family != "apple-observation" || disposition != "evidence-only")
    fail_check("only evidence-only Apple Observation may have zero occurrences")
  end
end

baseline_queries = {
  "portable-state" => "@State",
  "task-local-binding" => "StateBindingContext|@TaskLocal",
  "string-key" => "StateKey",
  "any-store" => "\\[StateKey: Any\\]",
  "existential-storage" => "any StateStorage",
  "direct-model-mutation" => "target[[:space:]]*[+-]="
}

baseline_queries.each do |family, pattern|
  output, error, status = Open3.capture3(
    "git", "-C", ROOT.to_s, "grep", "-n", "-E", pattern, "PoC", "--",
    "Sources/**/*.swift", "Tests/**/*.swift"
  )
  fail_check("#{family} PoC scan failed: #{error}") unless status.success?
  expected = Hash.new(0)
  output.each_line do |line|
    match = line.match(/\APoC:(.*?):[0-9]+:/)
    fail_check("unreadable #{family} grep row") unless match
    expected[match[1]] += 1
  end
  recorded = rows.each_with_object({}) do |(row_family, path, count, _disposition, _owner), result|
    result[path] = count.to_i if row_family == family
  end
  fail_check("#{family} inventory differs: expected #{expected}, got #{recorded}") unless recorded == expected
end

runtime_paths = rows.each_with_object([]) do |(family, path, _count, _disposition, _owner), result|
  result << path if family == "runtime-state-path"
end
runtime_paths.each do |path|
  _output, error, status = Open3.capture3(
    "git", "-C", ROOT.to_s, "cat-file", "-e", "PoC:#{path}"
  )
  fail_check("missing PoC runtime state path #{path}: #{error}") unless status.success?
  fail_check("removed runtime state path returned: #{path}") if ROOT.join(path).exist?
end

apple_pattern = /(?:^|\n)\s*import\s+Observation\b|@Observable\b/
poc_files, poc_error, poc_status = Open3.capture3(
  "git", "-C", ROOT.to_s, "grep", "-l", "-E", "import Observation|@Observable", "PoC", "--",
  "Sources/**/*.swift", "Tests/**/*.swift"
)
fail_check("Apple Observation PoC scan failed: #{poc_error}") unless poc_status.exitstatus == 1
fail_check("Apple Observation unexpectedly existed in PoC: #{poc_files}") unless poc_files.empty?

maintained_sources = Dir[ROOT.join("Sources/**/*.swift"), ROOT.join("Tests/**/*Tests/*.swift")].sort
legacy_pattern = /\bStateBindingContext\b|@TaskLocal\b|\bStateKey\b|\bStateStorage\b|\bDynamicStateStore\b|\bStaticStateStorage\b|\[[^\]\n]+:\s*Any\]|
                 (?:^|\n)\s*import\s+Observation\b|@Observable\b/x
violations = maintained_sources.select { |path| File.read(path).match?(legacy_pattern) }
fail_check("legacy or Apple-only state mechanism remains: #{violations.map { |path| Pathname.new(path).relative_path_from(ROOT) }}") unless violations.empty?

spike_pattern = /@State\b|\bstruct\s+State</
expected_spikes = Dir[ROOT.join("experiments/spike-00{3,6}-*/**/*.swift")].sort.each_with_object({}) do |path, result|
  count = File.read(path).scan(spike_pattern).length
  next if count.zero?

  result[Pathname.new(path).relative_path_from(ROOT).to_s] = count
end
recorded_spikes = rows.each_with_object({}) do |(family, path, count, disposition, _owner), result|
  next unless family == "spike-spelling"
  fail_check("Spike spelling is not evidence-only: #{path}") unless disposition == "evidence-only"
  result[path] = count.to_i
end
fail_check("Spike inventory differs: expected #{expected_spikes}, got #{recorded_spikes}") unless recorded_spikes == expected_spikes

production_experiment_imports = maintained_sources.select do |path|
  File.read(path).match?(/spike-003|spike-006|SPIKE003|SPIKE006/)
end
fail_check("maintained source refers to disposable Spike code: #{production_experiment_imports}") unless production_experiment_imports.empty?

puts "SPEC-010 migration inventory passed: #{rows.length} exact rows, no maintained legacy or Apple-only mechanism."
