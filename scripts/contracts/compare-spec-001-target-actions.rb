#!/usr/bin/env ruby
# frozen_string_literal: true

abort 'usage: compare-spec-001-target-actions.rb PI_LOG NRF_LOG' unless ARGV.length == 2

EXPECTED_ACTIONS = [
  [1, 1, 'stopped', 'twoSeconds', 61],
  [0, 1, 'running', 'twoSeconds', 61],
  [3, 1, 'running', 'oneSecond', 61],
  [3, 0, 'running', 'oneSecond', 61],
  [3, 0, 'running', 'oneSecond', 61],
  [4, 1, 'running', 'twoSeconds', 61],
  [5, 1, 'running', 'fiveSeconds', 61],
  [5, 0, 'running', 'fiveSeconds', 61],
  [5, 0, 'running', 'fiveSeconds', 61],
  [4, 1, 'running', 'twoSeconds', 61],
  [3, 1, 'running', 'oneSecond', 61],
  [4, 1, 'running', 'twoSeconds', 61]
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

def frames(path, prefix = "trace=frame\t")
  File.readlines(path, chomp: true).map do |line|
    next unless line.start_with?(prefix)

    line.split("\t").to_h { |field| field.split('=', 2) }
  end.compact
end

pi_frames = frames(ARGV.fetch(0))
nrf_frames = frames(ARGV.fetch(1))
abort 'Pi workload frame order mismatch' unless pi_frames.map { |frame| Integer(frame.fetch('ordinal')) } == (1..120).to_a
abort 'nRF committed frame order mismatch' unless nrf_frames.map { |frame| Integer(frame.fetch('revision')) } == (1..129).to_a
abort 'Pi workload terminal capture mismatch' unless pi_frames.last.fetch('capture_revision') == '2404' && pi_frames.last.fetch('capture_count') == '61'
abort 'nRF workload terminal capture mismatch' unless nrf_frames.fetch(120).fetch('capture_revision') == '2404' && nrf_frames.fetch(120).fetch('capture_count') == '61'

pi_other = frames(ARGV.fetch(0), "trace=other_frame\t")
abort 'Pi initial/action frame order mismatch' unless pi_other.map { |frame| Integer(frame.fetch('code')) } == [65_535, 1, 0, 3, 4, 5, 4, 3, 4]
abort 'Pi initial/action revision order mismatch' unless pi_other.map { |frame| Integer(frame.fetch('revision')) } == [0, 121, 122, 123, 124, 125, 126, 127, 128]
static_states = %w[idle running stopped failed]
static_windows = %w[oneSecond twoSeconds fiveSeconds]
nrf_other = [nrf_frames.first] + nrf_frames.last(8)
pi_other.zip(nrf_other).each_with_index do |(pi_frame, nrf_frame), index|
  %w[capture_revision capture_count layout_scopes drawing_strokes drawing_points].each do |field|
    abort "initial/action frame #{index} #{field} mismatch" unless pi_frame.fetch(field) == nrf_frame.fetch(field)
  end
  abort "initial/action frame #{index} state mismatch" unless pi_frame.fetch('state') == static_states.fetch(Integer(nrf_frame.fetch('state')))
  abort "initial/action frame #{index} window mismatch" unless pi_frame.fetch('window') == static_windows.fetch(Integer(nrf_frame.fetch('window')))
end

pi = actions(ARGV.fetch(0), static: false)
nrf = actions(ARGV.fetch(1), static: true)
abort "Pi action trace mismatch: #{pi.inspect}" unless pi == EXPECTED_ACTIONS
abort "nRF action trace mismatch: #{nrf.inspect}" unless nrf == EXPECTED_ACTIONS

puts "SPEC-001 target traces: 120 Pi workload frames, 129 nRF committed frames, 9 matching initial/action frames, #{pi.length} matching actions"
