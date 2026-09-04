#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"

def fail_check(message)
  warn "SPEC-005 pristine rebuild comparison failed: #{message}"
  exit 1
end

fail_check("expected two checkout roots and an output path") unless ARGV.length == 3
checkout_roots = ARGV.take(2).map { |path| File.expand_path(path) }
output_path = File.expand_path(ARGV.fetch(2))
profiles = %w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded]

def report_directory(checkout_root, profile)
  report_root = File.join(checkout_root, ".build/contract-reports/spec-005")
  pointer = File.join(report_root, "latest-#{profile}.txt")
  fail_check("missing report pointer #{pointer}") unless File.file?(pointer)
  run_id = File.read(pointer).strip
  report = File.join(report_root, run_id, profile)
  fail_check("missing immutable report #{report}") unless File.directory?(report)
  report
end

def normalized_content(path, checkout_root, profile)
  content = File.binread(path)
  return content unless %w[commands.txt metadata.txt image-hashes.tsv].include?(File.basename(path))

  content.gsub(checkout_root, "<CHECKOUT>")
         .gsub(/\.tmp-#{Regexp.escape(profile)}-\d+/, ".tmp-#{profile}-<PID>")
end

common_files = [
  "commands.txt",
  "metadata.txt",
  "input-hashes.tsv",
  "semantics/profile-semantics.tsv"
]
profile_files = {
  "macos-dynamic" => ["semantics/allocation-probe.txt"],
  "macos-static" => ["semantics/allocation-probe.txt"],
  "raspberry-pi-armv6" => [
    "resources/armv6/armv6-resource-summary.tsv",
    "resources/armv6/baseline/sections.txt",
    "resources/armv6/candidate/sections.txt"
  ],
  "nrf52840-embedded" => [
    "resources/build-1/nrf-resource-summary.tsv",
    "resources/build-1/nrf-validation-call-graph.tsv",
    "resources/build-1/baseline/sections.txt",
    "resources/build-1/candidate/sections.txt",
    "resources/build-2/nrf-resource-summary.tsv",
    "resources/build-2/nrf-validation-call-graph.tsv"
  ]
}

rows = []
profiles.each do |profile|
  reports = checkout_roots.map { |root| report_directory(root, profile) }
  (common_files + profile_files.fetch(profile)).each do |relative_path|
    paths = reports.map { |report| File.join(report, relative_path) }
    paths.each { |path| fail_check("missing comparison input #{path}") unless File.file?(path) }
    contents = paths.each_with_index.map do |path, index|
      normalized_content(path, checkout_roots.fetch(index), profile)
    end
    fail_check("normalized mismatch for #{profile}/#{relative_path}") unless contents.uniq.one?
    rows << [profile, relative_path, Digest::SHA256.hexdigest(contents.first)]
  end
end

FileUtils.mkdir_p(File.dirname(output_path))
File.open(output_path, "w") do |output|
  output.puts("profile\tartifact\tnormalized_sha256\tstatus")
  rows.each { |profile, artifact, digest| output.puts("#{profile}\t#{artifact}\t#{digest}\tpass") }
end
puts "SPEC-005 pristine rebuild comparison passed: #{rows.length} normalized artifacts match."
