#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "open3"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
INVENTORY = ROOT.join("Tests/ContractFixtures/SPEC012/migration-inventory.tsv")
ALLOWED_BASELINES = %w[PoC SPIKE-004 SPIKE-007 SPIKE-008 current downstream].freeze
ALLOWED_DISPOSITIONS = %w[
  downstream-owned evidence extend maintain reject replace retire
].freeze

def fail_check(message)
  warn "SPEC-012 migration check failed: #{message}"
  exit 1
end

rows = INVENTORY.each_line.each_with_object([]) do |line, values|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("inventory row width differs") unless fields.length == 6
  values << fields
end
fail_check("migration inventory is empty") if rows.empty?
fail_check("migration inventory rows are duplicated") unless rows.uniq.length == rows.length
fail_check("migration inventory baseline differs") unless rows.all? { |row| ALLOWED_BASELINES.include?(row[0]) }
fail_check("migration disposition differs") unless rows.all? { |row| ALLOWED_DISPOSITIONS.include?(row[4]) }

rows.each do |baseline, _, path, _, _, _|
  case baseline
  when "PoC"
    _, status = Open3.capture2e("git", "cat-file", "-e", "PoC:#{path}", chdir: ROOT.to_s)
    fail_check("PoC path is missing: #{path}") unless status.success?
  when "downstream"
    fail_check("downstream row must name an absent target directory") if ROOT.join(path).exist?
  else
    fail_check("tracked inventory path is missing: #{path}") unless ROOT.join(path).file?
  end
end

maintained = ROOT.glob("Sources/**/*.swift")
forbidden_names = /\b(?:DisplayList|RGB565RetainedRenderer)\b/
fail_check("rejected retained drawing path returned to maintained sources") if
  maintained.any? { |path| path.read.match?(forbidden_names) }

experiment_sources = rows.each_with_object([]) do |(baseline, _, path, _, _, _), values|
  values << ROOT.join(path) if baseline.start_with?("SPIKE-")
end.select(&:file?)
production_digests = maintained.to_h { |path| [Digest::SHA256.file(path).hexdigest, path] }
experiment_sources.each do |path|
  copied = production_digests[Digest::SHA256.file(path).hexdigest]
  fail_check("Spike source was adopted wholesale: #{path} -> #{copied}") if copied
end

puts "SPEC-012 migration passed: #{rows.length} PoC, Spike, current, and downstream drawing surfaces have explicit dispositions."
