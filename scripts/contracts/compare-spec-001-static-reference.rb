#!/usr/bin/env ruby
# frozen_string_literal: true

abort 'usage: compare-spec-001-static-reference.rb MAC_TRACE NRF_TRACE' unless ARGV.length == 2

def records(path, prefix)
  File.readlines(path, chomp: true).map do |line|
    next unless line.start_with?(prefix)

    line.split("\t").to_h { |field| field.split('=', 2) }
  end.compact
end

mac = records(ARGV.fetch(0), "reference=macos-static\t")
nrf = records(ARGV.fetch(1), "trace=frame\t")
abort "expected 129 frames, got mac=#{mac.length} nrf=#{nrf.length}" unless mac.length == 129 && nrf.length == 129

mac.zip(nrf).each_with_index do |(expected, actual), index|
  abort "frame #{index} revision mismatch" unless Integer(actual.fetch('revision')) == index + 1

  %w[capture_revision capture_count semantic_scopes layout_scopes drawing_strokes drawing_points render_operations].each do |field|
    next if expected.fetch(field) == actual.fetch(field)

    abort "frame #{index} #{field}: mac=#{expected.fetch(field)} nrf=#{actual.fetch(field)}"
  end
  state = { 'idle' => '0', 'running' => '1', 'stopped' => '2' }.fetch(expected.fetch('state'))
  window = { 'oneSecond' => '0', 'twoSeconds' => '1', 'fiveSeconds' => '2' }.fetch(expected.fetch('window'))
  abort "frame #{index} state mismatch" unless actual.fetch('state') == state
  abort "frame #{index} window mismatch" unless actual.fetch('window') == window
  abort "frame #{index} missing physical hash" unless Integer(actual.fetch('frame_hash')).positive?
end

mac_actions = records(ARGV.fetch(0), "reference=macos-static-action\t")
nrf_actions = records(ARGV.fetch(1), "trace=action\t")
abort "expected 12 actions, got mac=#{mac_actions.length} nrf=#{nrf_actions.length}" unless mac_actions.length == 12 && nrf_actions.length == 12

mac_actions.zip(nrf_actions).each_with_index do |(expected, actual), index|
  %w[code dispatched revision capture_count].each do |field|
    next if expected.fetch(field) == actual.fetch(field)

    abort "action #{index} #{field}: mac=#{expected.fetch(field)} nrf=#{actual.fetch(field)}"
  end
  state = { 'idle' => '0', 'running' => '1', 'stopped' => '2' }.fetch(expected.fetch('state'))
  window = { 'oneSecond' => '0', 'twoSeconds' => '1', 'fiveSeconds' => '2' }.fetch(expected.fetch('window'))
  abort "action #{index} state mismatch" unless actual.fetch('state') == state
  abort "action #{index} window mismatch" unless actual.fetch('window') == window
end

puts "SPEC-001 macOS Static/nRF reference comparison passed: #{mac.length} ordered frames, #{mac_actions.length} actions"
