#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
report_root = ARGV.fetch(0, File.join(root, ".build/contract-reports/spec-005"))
profiles = %w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded]

def profile_directory(report_root, profile)
  pointer = File.join(report_root, "latest-#{profile}.txt")
  if File.file?(pointer)
    run_id = File.read(pointer).strip
    abort "invalid run pointer: #{pointer}" unless run_id.match?(/\A[0-9a-f]{40,64}-[0-9a-f]{16}\z/)
    path = File.join(report_root, run_id, profile)
    abort "run pointer target is missing: #{path}" unless File.directory?(path)
    return [path, run_id]
  end
  abort "missing immutable report pointer for #{profile}: #{pointer}"
end

def read_rows(path)
  File.readlines(path, chomp: true).drop(1)
end

directories = profiles.to_h { |profile| [profile, profile_directory(report_root, profile)] }
immutable_ids = directories.values.map(&:last)
abort "profile reports use mixed run identities" unless immutable_ids.uniq.length == 1

rows = profiles.to_h do |profile|
  path = File.join(directories.fetch(profile).first, "semantics/profile-semantics.tsv")
  abort "missing semantic transcript: #{path}" unless File.file?(path)
  [profile, read_rows(path)]
end

input_hashes = profiles.to_h do |profile|
  path = File.join(directories.fetch(profile).first, "input-hashes.tsv")
  abort "missing input hash inventory: #{path}" unless File.file?(path)
  [profile, File.readlines(path, chomp: true)]
end
baseline_inputs = input_hashes.fetch("macos-dynamic")
profiles.each do |profile|
  abort "input hash inventory mismatch for #{profile}" unless
    input_hashes.fetch(profile) == baseline_inputs
end

revisions = profiles.map do |profile|
  metadata = File.read(File.join(directories.fetch(profile).first, "metadata.txt"))
  metadata[/^repository_revision=(.+)$/, 1]
end
abort "profile reports use different repository revisions" unless revisions.uniq.length == 1

input_set_hashes = profiles.map do |profile|
  metadata = File.read(File.join(directories.fetch(profile).first, "metadata.txt"))
  metadata[/^input_set_sha256=(.+)$/, 1]
end
abort "profile reports use different input-set hashes" if input_set_hashes.any?(&:nil?) || input_set_hashes.uniq.length != 1

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
