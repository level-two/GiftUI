#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
INVENTORY = ROOT.join("Tests/ContractFixtures/SPEC013/migration-inventory.tsv")
POC_REVISION = "d5d6330432caa7c983d8dba35cf9f23c3800860b"
SCOPES = %w[
  Sources/GiftUIRuntimeDynamic
  Sources/GiftUIRuntimeStatic
  Tests/GiftUIRuntimeDynamicTests
  Tests/GiftUIRuntimeStaticTests
  Tests/GiftUIRuntimeConformanceTests
].freeze
ALLOWED_DISPOSITIONS = %w[evidence-only replace-through-owner retire].freeze

def fail_check(message)
  warn "SPEC-013 migration check failed: #{message}"
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
  fail_check("inventory row must have six fields") unless fields.length == 6
  result << fields
end
fail_check("migration inventory is empty") if rows.empty?

paths = rows.map { |row| row[1] }
fail_check("inventory paths are duplicated") unless paths.uniq.length == paths.length
fail_check("unexpected baseline") unless rows.all? { |row| row[0] == "PoC" }
fail_check("unexpected disposition") unless rows.all? { |row| ALLOWED_DISPOSITIONS.include?(row[3]) }
fail_check("missing replacement owner") if rows.any? { |row| row[4].empty? }
fail_check("compatibility shim is not forbidden") unless rows.all? { |row| row[5] == "forbidden" }

tree_output, tree_error, tree_status = Open3.capture3(
  "git", "-C", ROOT.to_s, "ls-tree", "-r", "--name-only", "PoC", *SCOPES
)
fail_check(tree_error) unless tree_status.success?
expected_paths = tree_output.lines.map(&:chomp).reject(&:empty?).sort
fail_check("PoC runtime/store/test path set differs") unless paths.sort == expected_paths

paths.each do |path|
  _, error, status = Open3.capture3("git", "-C", ROOT.to_s, "cat-file", "-e", "PoC:#{path}")
  fail_check("PoC path is missing: #{path}: #{error}") unless status.success?
end

maintained = ROOT.glob("Sources/**/*.swift")
forbidden_legacy_types = /\b(?:DisplayList|DynamicLayoutSnapshot|DynamicRuntime|DynamicStateStore|GiftUIApplication|GiftUIRuntimeDynamicModule|GiftUIRuntimeStaticModule|HitTestMap|StaticRuntime|StaticStateStorage|ViewBuildContext|ViewGraph|ViewNode)\b/
violations = maintained.select { |path| path.read.match?(forbidden_legacy_types) }
unless violations.empty?
  relative = violations.map { |path| path.relative_path_from(ROOT) }
  fail_check("legacy compatibility surface returned: #{relative.join(', ')}")
end

puts "SPEC-013 migration passed: #{rows.length} removed PoC runtime, store, and test paths have explicit dispositions; no compatibility surface returned."
