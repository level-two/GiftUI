#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
fixture = File.join(root, "Tests/ContractFixtures/SPEC001/sustained-workload-cases.tsv")
rows = File.readlines(fixture, chomp: true).reject { |line| line.empty? || line.start_with?("#") }.map { |line| line.split("\t", -1) }
abort "SPEC-001 workload columns differ" unless rows.all? { |row| row.length == 11 }
profiles = %w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded]
abort "SPEC-001 workload profiles differ" unless rows.map(&:first) == profiles
abort "SPEC-001 workload constants differ" unless rows.all? { |row| row[2..9] == %w[30000 80 2400 4 120 28 32 33-rejected] }
abort "SPEC-001 cross-target timing is inferred" unless rows.drop(2).all? { |row| row[10] == "not-collected" }

semantic = profiles.to_h do |profile|
  path = File.join(root, ".build/spec-015", profile, "semantic.tsv")
  next [profile, nil] unless File.file?(path)
  line = File.readlines(path, chomp: true).find { |candidate| !candidate.empty? && !candidate.start_with?("#") }
  [profile, line&.split("\t")&.to_h { |field| field.split("=", 2) }]
end
present = semantic.values.compact
reported = present.select { |row| row.key?("workload_duration_ms") }
unless reported.empty?
  required = {
    "workload_duration_ms" => "30000", "workload_event_rate" => "80",
    "workload_events" => "2400", "workload_frame_rate" => "4", "workload_frames" => "120",
    "workload_fact_high_water" => "20",
  }
  abort "SPEC-001 workload reports are incomplete" unless reported.length == present.length
  abort "SPEC-001 workload report differs" unless reported.all? { |row| required.all? { |key, value| row[key] == value } }
  abort "SPEC-001 workload checksums differ" unless reported.map { |row| row["workload_checksum"] }.uniq.length == 1
end
puts "SPEC-001 sustained workload passed: four presets, 2,400 events, 120 frames."
