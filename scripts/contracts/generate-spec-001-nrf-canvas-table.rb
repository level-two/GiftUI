#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'yaml'

root = Pathname.new(__dir__).join('../..').realpath
manifest = YAML.safe_load(
  root.join('Tests/ContractFixtures/SPEC001/nrf-static-canvas-manifest.yaml').read,
  aliases: false
)
destination = root.join(
  'Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFEmbeddedCanvasTable.generated.swift'
)
cases = manifest.fetch('callable_cases')
occurrences = manifest.fetch('occurrences')
abort 'nRF Canvas case IDs changed' unless cases.map { |entry| entry.fetch('id') } == [1, 2]
abort 'nRF Canvas capture sizes changed' unless cases.map { |entry| entry.fetch('capture_byte_count') } == [0, 32]
abort 'nRF Canvas occurrence order changed' unless occurrences.map { |entry| entry.fetch('order') } == [1, 2, 3, 4, 5]
abort 'nRF Canvas occurrence cases changed' unless occurrences.map { |entry| entry.fetch('callable_id') } == [1, 2, 2, 2, 2]
abort 'nRF Canvas channel order changed' unless occurrences.map { |entry| entry.fetch('channel', 0) } == [0, 1, 2, 3, 4]

lines = [
  '// Generated from nrf-static-canvas-manifest.yaml by scripts/contracts/generate-spec-001-nrf-canvas-table.rb. Do not edit.',
  'package enum StaticSignalAnalyzerNRFEmbeddedCanvasTable {',
  "    package static let callableCaseCount: UInt8 = #{cases.length}",
  "    package static let occurrenceCount: UInt16 = #{occurrences.length}",
  '',
  '    package static func callableID(at occurrence: UInt16) -> UInt8? {',
  '        switch occurrence {'
]
occurrences.each_with_index do |entry, index|
  lines << "        case #{index}: return #{entry.fetch('callable_id')}"
end
lines += ['        default: return nil', '        }', '    }', '',
          '    package static func channel(at occurrence: UInt16) -> UInt8? {',
          '        switch occurrence {']
occurrences.each_with_index do |entry, index|
  lines << "        case #{index}: return #{entry.fetch('channel', 0)}"
end
lines += ['        default: return nil', '        }', '    }', '',
          '    package static func captureByteCount(for callableID: UInt8) -> UInt8? {',
          '        switch callableID {']
cases.each do |entry|
  lines << "        case #{entry.fetch('id')}: return #{entry.fetch('capture_byte_count')}"
end
lines += ['        default: return nil', '        }', '    }', '}', '']
generated = lines.join("\n")

if ARGV == ['--check']
  abort 'nRF Canvas target table is stale' unless destination.file? && destination.read == generated
else
  abort 'usage: generate-spec-001-nrf-canvas-table.rb [--check]' unless ARGV.empty?
  destination.write(generated)
end
