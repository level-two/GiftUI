#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
INVENTORY = ROOT.join("Tests/ContractFixtures/SPEC008/migration-inventory.tsv")
POC_REVISION = "d5d6330432caa7c983d8dba35cf9f23c3800860b"

def fail_check(message)
  warn "SPEC-008 migration check failed: #{message}"
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

required_families = %w[
  color raw-string-text display-list recording-backend backend-text-placement
  host-sized-counts unchecked-clip-damage retained-borrow capability-fixture-name
  parallel-render-path
]
fail_check("inventory family coverage differs") unless rows.map(&:first).uniq.sort == required_families.sort
allowed_baselines = %w[PoC current PoC-and-current]
allowed_dispositions = %w[adopt adapt replace retire already-absent]
rows.each do |family, baseline, path, count, disposition, owner|
  fail_check("invalid baseline for #{family}/#{path}") unless allowed_baselines.include?(baseline)
  fail_check("invalid count for #{family}/#{path}") unless count.match?(/\A(?:0|[1-9][0-9]*)\z/)
  fail_check("invalid disposition for #{family}/#{path}") unless allowed_dispositions.include?(disposition)
  fail_check("missing owner for #{family}/#{path}") if owner.empty?

  if baseline == "PoC"
    _output, error, status = Open3.capture3(
      "git", "-C", ROOT.to_s, "cat-file", "-e", "PoC:#{path}"
    )
    fail_check("missing PoC inventory path #{path}: #{error}") unless status.success?
  elsif baseline == "current"
    fail_check("missing current inventory path #{path}") unless ROOT.join(path).file?
  else
    valid_absence = path == "historical-and-current-maintained-source" &&
      count == "0" && disposition == "already-absent"
    fail_check("invalid absent-path row") unless valid_absence
  end
end

giftui_sources = Dir[ROOT.join("Sources/GiftUI/*.swift")].sort
color_declarations = giftui_sources.each_with_object([]) do |path, declarations|
  relative = Pathname.new(path).relative_path_from(ROOT).to_s
  declarations << relative if File.read(path).match?(/public struct Color\b/)
end
fail_check("Color owner differs") unless color_declarations == ["Sources/GiftUI/Color.swift"]

text_source = ROOT.join("Sources/GiftUI/Text.swift").read
fail_check("portable Text gained String storage or API") if text_source.match?(/\bString\b/)

style_source = ROOT.join("Sources/GiftUI/StyleModifiers.swift").read
fail_check("foreground style declaration differs") unless style_source.scan(/func foregroundStyle\(/).length == 1
fail_check("background declaration differs") unless style_source.scan(/func background\(/).length == 1

render_owners = Dir[
  ROOT.join("Sources/GiftUI/*.swift"),
  ROOT.join("Sources/GiftUISemanticCore/*.swift"),
  ROOT.join("Sources/GiftUILayout/*.swift"),
  ROOT.join("Sources/GiftUIRenderCore/*.swift"),
  ROOT.join("Sources/GiftUIRenderLowering/*.swift")
].sort
forbidden_second_path = /\b(?:DisplayList|RecordingBackend|drawText|previousRootFrame|dirtyRegion)\b/
violations = render_owners.select { |path| File.read(path).match?(forbidden_second_path) }
unless violations.empty?
  relative = violations.map { |path| Pathname.new(path).relative_path_from(ROOT).to_s }
  fail_check("parallel rendering path entered maintained owners: #{relative}")
end

capability_leaks = render_owners.select { |path| File.read(path).match?(/\bCapability[A-Z]/) }
unless capability_leaks.empty?
  relative = capability_leaks.map { |path| Pathname.new(path).relative_path_from(ROOT).to_s }
  fail_check("capability fixture names entered rendering semantics: #{relative}")
end

puts "SPEC-008 migration inventory passed: #{rows.length} rows and no maintained parallel rendering path."
