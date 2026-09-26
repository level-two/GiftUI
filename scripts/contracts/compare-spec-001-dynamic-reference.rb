#!/usr/bin/env ruby
# frozen_string_literal: true

abort 'usage: compare-spec-001-dynamic-reference.rb MAC_TRACE PI_TRACE' unless ARGV.length == 2

FIELDS = %w[
  ordinal facts capture_revision capture_count state window semantic_nodes
  layout_scopes drawing_strokes drawing_points render_operations
].freeze

def records(path, prefix)
  File.readlines(path, chomp: true).map do |line|
    next unless line.start_with?(prefix)

    line.split("\t").to_h { |field| field.split('=', 2) }
  end.compact
end

mac = records(ARGV.fetch(0), "reference=macos-dynamic\t")
pi = records(ARGV.fetch(1), "trace=frame\t")
abort "expected 120 frames, got mac=#{mac.length} pi=#{pi.length}" unless mac.length == 120 && pi.length == 120

mac.zip(pi).each_with_index do |(expected, actual), index|
  FIELDS.each do |field|
    next if expected.fetch(field) == actual.fetch(field)

    abort "frame #{index + 1} #{field}: mac=#{expected.fetch(field)} pi=#{actual.fetch(field)}"
  end
end

other_fields = %w[
  code capture_revision capture_count state window semantic_nodes layout_scopes
  drawing_strokes drawing_points render_operations
]
mac_other = records(ARGV.fetch(0), "reference=macos-dynamic-other-frame\t")
pi_other = records(ARGV.fetch(1), "trace=other_frame\t")
abort "expected 7 initial/action frames, got mac=#{mac_other.length} pi=#{pi_other.length}" unless mac_other.length == 7 && pi_other.length == 7
mac_other.zip(pi_other).each_with_index do |(expected, actual), index|
  other_fields.each do |field|
    next if expected.fetch(field) == actual.fetch(field)

    abort "initial/action frame #{index} #{field}: mac=#{expected.fetch(field)} pi=#{actual.fetch(field)}"
  end
  abort "initial/action frame #{index} revision mismatch" unless Integer(expected.fetch('revision')) == Integer(actual.fetch('revision')) + 1
end

action_fields = %w[code dispatched capture_count state window]
mac_actions = records(ARGV.fetch(0), "reference=macos-dynamic-action\t")
pi_actions = records(ARGV.fetch(1), "trace=action\t")
abort "expected 12 actions, got mac=#{mac_actions.length} pi=#{pi_actions.length}" unless mac_actions.length == 12 && pi_actions.length == 12
mac_actions.zip(pi_actions).each_with_index do |(expected, actual), index|
  action_fields.each do |field|
    next if expected.fetch(field) == actual.fetch(field)

    abort "action #{index} #{field}: mac=#{expected.fetch(field)} pi=#{actual.fetch(field)}"
  end
  abort "action #{index} revision mismatch" unless Integer(expected.fetch('revision')) == Integer(actual.fetch('revision')) + 1
end

puts "SPEC-001 macOS Dynamic/Pi reference comparison passed: #{mac.length} workload frames, #{mac_other.length} initial/action frames, #{mac_actions.length} actions"
