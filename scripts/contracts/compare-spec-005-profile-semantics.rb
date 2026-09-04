#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
report_root = ARGV.fetch(0, File.join(root, ".build/contract-reports/spec-005"))
profiles = %w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded]

def read_rows(path)
  File.readlines(path, chomp: true).drop(1)
end

rows = profiles.to_h do |profile|
  path = File.join(report_root, profile, "semantics/profile-semantics.tsv")
  abort "missing semantic transcript: #{path}" unless File.file?(path)
  [profile, read_rows(path)]
end

input_hashes = profiles.to_h do |profile|
  path = File.join(report_root, profile, "input-hashes.tsv")
  abort "missing input hash inventory: #{path}" unless File.file?(path)
  [profile, File.readlines(path, chomp: true)]
end
baseline_inputs = input_hashes.fetch("macos-dynamic")
profiles.each do |profile|
  abort "input hash inventory mismatch for #{profile}" unless
    input_hashes.fetch(profile) == baseline_inputs
end

revisions = profiles.map do |profile|
  metadata = File.read(File.join(report_root, profile, "metadata.txt"))
  metadata[/^repository_revision=(.+)$/, 1]
end
abort "profile reports use different repository revisions" unless revisions.uniq.length == 1

baseline = rows.fetch("macos-dynamic").select { |row| row.start_with?("logical\t") }
profiles.each do |profile|
  logical = rows.fetch(profile).select { |row| row.start_with?("logical\t") }
  abort "logical semantic mismatch for #{profile}" unless logical == baseline
end

expected = {
  "macos-dynamic" => ["0,1", "0,1"],
  "macos-static" => ["0,1", "0,1"],
  "raspberry-pi-armv6" => ["0,1", "0,1"],
  "nrf52840-embedded" => ["0", "0"]
}
expected.each do |profile, (required, available)|
  profile_rows = rows.fetch(profile)
  abort "required realization mismatch for #{profile}" unless
    profile_rows.include?("profile\tavailability\trequired-realizations\t#{required}")
  abort "available realization mismatch for #{profile}" unless
    profile_rows.include?("profile\tavailability\tavailable-realizations\t#{available}")
end

puts "SPEC-005 four-profile semantic comparison passed: identical revision/input hashes, #{baseline.length} logical rows equal; only declared nRF payload availability differs."
