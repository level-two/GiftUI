#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
report_root = File.join(root, ".build/contract-reports/spec-001")
profiles = %w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded]

def normalized_row(path)
  line = File.readlines(path, chomp: true).find { |candidate| !candidate.empty? && !candidate.start_with?("#") }
  abort "missing normalized row in #{path}" unless line
  line.split("\t").to_h { |field| field.split("=", 2) }
end

rows = profiles.to_h do |profile|
  latest = File.join(report_root, "latest-#{profile}.txt")
  abort "missing latest SPEC-001 report for #{profile}" unless File.file?(latest)
  run_id = File.read(latest).strip
  path = File.join(report_root, run_id, profile, "host-transcript.tsv")
  abort "missing SPEC-001 host transcript for #{profile}" unless File.file?(path)
  [profile, normalized_row(path)]
end

common = %w[
  semantic_checksum actions compact_facts canvases live_points plan_points graph_roles
  semantic_nodes render_semantic_scopes layout_scopes traversal_depth text_lines glyphs
  ordinary_operations drawing_operations input_events completion_facts workload_duration_ms
  workload_event_rate workload_events workload_frame_rate workload_frames
  workload_fact_high_water workload_checksum
]
common.each do |field|
  values = rows.values.map { |row| row[field] }
  abort "SPEC-001 profile field #{field} differs: #{values.inspect}" unless values.none?(&:nil?) && values.uniq.length == 1
end
abort "SPEC-001 workload duration differs" unless rows.values.all? { |row| row["workload_duration_ms"] == "30000" }
abort "SPEC-001 workload count differs" unless rows.values.all? { |row| row["workload_events"] == "2400" && row["workload_frames"] == "120" }

puts "SPEC-001 four-profile comparison passed: #{common.length} normalized semantic/workload fields are equal."
