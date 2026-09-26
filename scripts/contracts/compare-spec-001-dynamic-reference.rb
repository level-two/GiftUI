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

puts "SPEC-001 macOS Dynamic/Pi reference comparison passed: #{mac.length} ordered frames"
