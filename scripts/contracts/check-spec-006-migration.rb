#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
INVENTORY = ROOT.join("Tests/ContractFixtures/SPEC006/migration-inventory.tsv")
POC_REVISION = "d5d6330432caa7c983d8dba35cf9f23c3800860b"

def fail_check(message)
  warn "SPEC-006 migration check failed: #{message}"
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

allowed_dispositions = %w[remove replace-through-the-sealed-surface already-absent]
rows.each do |family, path, count, disposition, owner|
  fail_check("invalid family #{family}") unless %w[traversal string-identity wrapper-exposure builder-surface].include?(family)
  fail_check("invalid occurrence count for #{family}/#{path}") unless count.match?(/\A[1-9][0-9]*\z/)
  fail_check("invalid disposition for #{family}/#{path}") unless allowed_dispositions.include?(disposition)
  fail_check("missing replacement owner for #{family}/#{path}") if owner.empty?
end

queries = {
  "traversal" => ["_visit|ViewVisitor", %w[Sources Tests]],
  "string-identity" => ["path: String|path = \"root\"|withPathComponent|StateKey\\(", %w[Sources Tests]],
  "wrapper-exposure" => [
    "public (let value|enum Storage|init\\(\\)|init\\(storage:|let storage|let content)|package (let storage|let content|init\\(\\)|init\\(_|init\\(storage:)",
    %w[Sources/GiftUI/Composition Sources/GiftUI/View]
  ],
  "builder-surface" => ["public static func build(Block|Either|Optional)", %w[Sources/GiftUI/View/ViewBuilder.swift]],
}

queries.each do |family, (pattern, paths)|
  output, error, status = Open3.capture3(
    "git", "-C", ROOT.to_s, "grep", "-n", "-E", pattern, "PoC", "--", *paths
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

maintained_sources = Dir[ROOT.join("Sources/**/*.swift"), ROOT.join("Tests/**/*Tests/*.swift")].sort
forbidden = /\bViewVisitor\b|\b_visit\b|\bStateKey\b.*\bString\b|\bpath:\s*String\b/
violations = maintained_sources.select { |path| File.read(path).match?(forbidden) }
fail_check("legacy surface remains in maintained source: #{violations.map { |path| Pathname.new(path).relative_path_from(ROOT) }}") unless violations.empty?

puts "SPEC-006 migration inventory passed: #{rows.length} exact PoC path/family rows, no maintained compatibility shim."
