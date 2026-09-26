#!/usr/bin/env ruby
# frozen_string_literal: true

abort 'usage: compare-spec-001-target-actions.rb PI_LOG NRF_LOG' unless ARGV.length == 2

EXPECTED_ACTIONS = [
  [0, 0, 'running', 'twoSeconds', 359],
  [1, 1, 'stopped', 'twoSeconds', 359],
  [1, 0, 'stopped', 'twoSeconds', 359],
  [0, 1, 'running', 'twoSeconds', 359],
  [0, 0, 'running', 'twoSeconds', 359],
  [2, 1, 'running', 'twoSeconds', 0],
  [3, 1, 'running', 'oneSecond', 0],
  [3, 0, 'running', 'oneSecond', 0],
  [5, 1, 'running', 'fiveSeconds', 0],
  [5, 0, 'running', 'fiveSeconds', 0],
  [4, 1, 'running', 'twoSeconds', 0],
  [4, 0, 'running', 'twoSeconds', 0]
].freeze

def actions(path, static:)
  state_names = %w[idle running stopped failed]
  window_names = %w[oneSecond twoSeconds fiveSeconds]
  File.readlines(path, chomp: true).map do |line|
    next unless line.start_with?("trace=action\t")

    fields = line.split("\t").to_h { |field| field.split('=', 2) }
    state = static ? state_names.fetch(Integer(fields.fetch('state'))) : fields.fetch('state')
    window = static ? window_names.fetch(Integer(fields.fetch('window'))) : fields.fetch('window')
    [Integer(fields.fetch('code')), Integer(fields.fetch('dispatched')),
     state, window, Integer(fields.fetch('capture_count'))]
  end.compact
end

def frames(path)
  File.readlines(path, chomp: true).map do |line|
    next unless line.start_with?("trace=frame\t")

    line.split("\t").to_h { |field| field.split('=', 2) }
  end.compact
end

pi_frames = frames(ARGV.fetch(0))
nrf_frames = frames(ARGV.fetch(1))
abort 'Pi workload frame order mismatch' unless pi_frames.map { |frame| Integer(frame.fetch('ordinal')) } == (1..120).to_a
abort 'nRF committed frame order mismatch' unless nrf_frames.map { |frame| Integer(frame.fetch('revision')) } == (1..127).to_a
abort 'Pi workload terminal capture mismatch' unless pi_frames.last.fetch('capture_revision') == '2404' && pi_frames.last.fetch('capture_count') == '359'
abort 'nRF workload terminal capture mismatch' unless nrf_frames.fetch(120).fetch('capture_revision') == '2404' && nrf_frames.fetch(120).fetch('capture_count') == '359'

pi = actions(ARGV.fetch(0), static: false)
nrf = actions(ARGV.fetch(1), static: true)
abort "Pi action trace mismatch: #{pi.inspect}" unless pi == EXPECTED_ACTIONS
abort "nRF action trace mismatch: #{nrf.inspect}" unless nrf == EXPECTED_ACTIONS

puts "SPEC-001 target traces: 120 Pi workload frames, 127 nRF committed frames, #{pi.length} matching actions"
