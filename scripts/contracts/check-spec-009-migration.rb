#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
INVENTORY = ROOT.join("Tests/ContractFixtures/SPEC009/migration-inventory.tsv")
POC_REVISION = "d5d6330432caa7c983d8dba35cf9f23c3800860b"

def fail_check(message)
  warn "SPEC-009 migration check failed: #{message}"
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
fail_check("inventory is empty") if rows.empty?
keys = rows.map { |family, baseline, path, _count, _disposition, _owner| [family, baseline, path] }
fail_check("inventory keys are duplicated") unless keys.uniq.length == keys.length

baseline_queries = {
  "immediate-invalidation" => "isInvalid|invalidationGeneration|invalidate\\(|markRendered",
  "direct-action-dispatch" => "func dispatch\\(|interaction\\.perform\\(|identifiedActionHandler\\(|callback\\(\\)",
  "unsealed-reentrancy" => "isRendering|isDispatching|must not be reentrant",
  "runtime-render-operation" => "DisplayList|renderOperations|makeDisplayList|appendRenderOperations",
  "retained-replayed-frame" => "previousRootFrame|RGB565RetainedRenderer|Replays render operations",
  "closure-model-capture" => "private let root: Root|identifiedActionHandler|case callback\\(\\(\\) -> Void\\)|\\[weak self\\]",
  "stale-hit-map-route" => "InteractionSnapshot|HitTestMap|pressedAction|focusedIndex",
}.freeze

allowed_families = baseline_queries.keys + %w[
  unbounded-queue backend-platform-action-path execution-placeholder
]
allowed_baselines = %w[PoC current PoC-and-current]
allowed_dispositions = %w[
  adopt replace-through-owner retire downstream-owned evidence-only already-absent
]
rows.each do |family, baseline, path, count, disposition, owner|
  fail_check("invalid family #{family}") unless allowed_families.include?(family)
  fail_check("invalid baseline for #{family}/#{path}") unless allowed_baselines.include?(baseline)
  fail_check("invalid count for #{family}/#{path}") unless count.match?(/\A(?:0|[1-9][0-9]*)\z/)
  fail_check("invalid disposition for #{family}/#{path}") unless allowed_dispositions.include?(disposition)
  fail_check("missing owner for #{family}/#{path}") if owner.empty?
  next unless count == "0"

  expected_zero = family == "unbounded-queue" && baseline == "PoC-and-current" &&
    disposition == "already-absent"
  fail_check("only the absent unbounded queue row may have zero occurrences") unless expected_zero
end

def path_counts(output, family)
  output.each_line.each_with_object(Hash.new(0)) do |line, counts|
    match = line.match(/\APoC:(.*?):[0-9]+:/)
    fail_check("unreadable #{family} grep row") unless match
    counts[match[1]] += 1
  end
end

baseline_queries.each do |family, pattern|
  output, error, status = Open3.capture3(
    "git", "-C", ROOT.to_s, "grep", "-n", "-E", pattern, "PoC", "--",
    "Sources/**/*.swift", "Tests/**/*.swift"
  )
  fail_check("#{family} PoC scan failed: #{error}") unless status.success?
  expected = path_counts(output, family)
  recorded = rows.each_with_object({}) do |(row_family, baseline, path, count, _disposition, _owner), result|
    result[path] = count.to_i if row_family == family && baseline == "PoC"
  end
  fail_check("#{family} inventory differs: expected #{expected}, got #{recorded}") unless recorded == expected
end

platform_output, platform_error, platform_status = Open3.capture3(
  "git", "-C", ROOT.to_s, "grep", "-n", "-E", "application\\.send\\(", "PoC", "--",
  "Sources/GiftUIPlatformLinux", "Sources/GiftUIPlatformRaspberryPi", "Sources/GiftUISimulatorMac"
)
fail_check("backend/platform action PoC scan failed: #{platform_error}") unless platform_status.success?
expected_platform = path_counts(platform_output, "backend-platform-action-path")
recorded_platform = rows.each_with_object({}) do |(family, baseline, path, count, _disposition, _owner), result|
  result[path] = count.to_i if family == "backend-platform-action-path" && baseline == "PoC"
end
fail_check("backend/platform action inventory differs") unless recorded_platform == expected_platform

queue_pattern = "inputQueue|eventQueue|pendingEvents|stateChangeQueue|completionQueue|actionQueue"
queue_output, queue_error, queue_status = Open3.capture3(
  "git", "-C", ROOT.to_s, "grep", "-n", "-E", queue_pattern, "PoC", "--",
  "Sources/**/*.swift", "Tests/**/*.swift"
)
fail_check("unbounded queue PoC scan failed: #{queue_error}") unless [0, 1].include?(queue_status.exitstatus)
fail_check("unbounded queue unexpectedly existed in PoC: #{queue_output}") unless queue_output.empty?
current_queue = Dir[ROOT.join("Sources/**/*.swift"), ROOT.join("Tests/**/*Tests/*.swift")].select do |path|
  File.read(path).match?(/\b(?:inputQueue|eventQueue|pendingEvents|stateChangeQueue|completionQueue|actionQueue)\b/)
end
fail_check("unbounded execution queue entered maintained Swift: #{current_queue}") unless current_queue.empty?

placeholder_output, placeholder_error, placeholder_status = Open3.capture3(
  "rg", "-n", "GiftUIExecutionContract",
  ROOT.join("scripts/contracts").to_s,
  ROOT.join("Tests/ContractFixtures/SPEC002").to_s,
  ROOT.join("Tests/ContractFixtures/SPEC003").to_s,
  ROOT.join("Tests/ContractFixtures/SPEC004").to_s,
  ROOT.join("Tests/ContractFixtures/SPEC005").to_s
)
fail_check("execution placeholder scan failed: #{placeholder_error}") unless [0, 1].include?(placeholder_status.exitstatus)
expected_placeholders = placeholder_output.each_line.each_with_object(Hash.new(0)) do |line, result|
  path, = line.split(":", 2)
  relative = Pathname.new(path).relative_path_from(ROOT).to_s
  next if relative == "scripts/contracts/check-spec-009-migration.rb"

  result[relative] += 1
end
fail_check("obsolete execution placeholder remains: #{expected_placeholders}") unless expected_placeholders.empty?

maintained_swift = Dir[ROOT.join("Sources/**/*.swift"), ROOT.join("Tests/**/*Tests/*.swift")].sort
legacy_execution = /\b(?:GiftUIApplication|DynamicRuntime|DisplayList|InteractionSnapshot|HitTestMap|ActionID|ButtonAction|RGB565RetainedRenderer)\b|\bpreviousRootFrame\b|\bidentifiedActionHandler\b/
violations = maintained_swift.select { |path| File.read(path).match?(legacy_execution) }
unless violations.empty?
  relative = violations.map { |path| Pathname.new(path).relative_path_from(ROOT) }
  fail_check("legacy second execution path remains in maintained Swift: #{relative}")
end

puts "SPEC-009 migration inventory passed: #{rows.length} exact rows, no maintained second execution path."
