#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"

def fail_check(message)
  warn "SPEC-013 pristine build comparison failed: #{message}"
  exit 1
end

fail_check("expected two checkout roots and an output path") unless ARGV.length == 3
checkout_roots = ARGV.take(2).map { |path| File.expand_path(path) }
output_path = File.expand_path(ARGV.fetch(2))
profiles = %w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded]
portable_files = %w[
  transcript-input-digests.tsv audit.tsv storage-high-water.tsv limits.tsv fixture-results.tsv
].freeze

def report_directory(checkout_root, profile)
  report_root = File.join(checkout_root, ".build/contract-reports/spec-013")
  pointer = File.join(report_root, "latest-#{profile}.txt")
  fail_check("missing report pointer #{pointer}") unless File.file?(pointer)

  run_id = File.read(pointer).strip
  report = File.join(report_root, run_id, profile)
  fail_check("missing immutable report #{report}") unless File.directory?(report)
  report
end

def profile_fields(report)
  File.readlines(File.join(report, "profile-report.tsv"), chomp: true).to_h do |line|
    line.split("\t", 2)
  end
end

rows = []
profile_digests = {}
profiles.each do |profile|
  reports = checkout_roots.map { |root| report_directory(root, profile) }
  portable_files.each do |relative_path|
    paths = reports.map { |report| File.join(report, relative_path) }
    paths.each { |path| fail_check("missing comparison input #{path}") unless File.file?(path) }
    contents = paths.map { |path| File.binread(path) }
    fail_check("pristine mismatch for #{profile}/#{relative_path}") unless contents.uniq.one?
    rows << [profile, relative_path, Digest::SHA256.hexdigest(contents.first), "identical"]
  end

  fields = reports.map { |report| profile_fields(report) }
  %w[schema profile evidenceClass target transcriptDigest hardwareExecution connectedTarget].each do |field|
    values = fields.map { |item| item.fetch(field) }
    fail_check("pristine #{field} mismatch for #{profile}") unless values.uniq.one?
  end
  fail_check("hardware execution claimed for #{profile}") unless fields.first.fetch("hardwareExecution") == "false"
  fail_check("connected target claimed for #{profile}") unless fields.first.fetch("connectedTarget") == "none"
  profile_digests[profile] = fields.first.fetch("transcriptDigest")
end

fail_check("cross-profile transcript digests differ") unless profile_digests.values.uniq.one?
rows << ["all-profiles", "transcriptDigest", profile_digests.values.first, "identical"]

FileUtils.mkdir_p(File.dirname(output_path))
File.open(output_path, "w") do |output|
  output.puts("profile\tartifact\tsha256\tcomparison")
  rows.each { |row| output.puts(row.join("\t")) }
end
puts "SPEC-013 pristine build comparison passed: #{rows.length} portable transcript/resource rows match."
