#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

root = Pathname.new(__dir__).join('../..').realpath
catalogue = root.join('Sources/GiftUIReferenceTextResources/Generated/ReferenceCatalogue.generated.swift').read
destination = root.join('Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFReferenceMetrics.generated.swift')

mapping = catalogue.scan(/case (\d+): return ScalarGlyphMappingRecord\(scalarValue: 0x([0-9a-f]+), glyph: GlyphID\(rawValue: (\d+)\)\)/)
metrics = catalogue.scan(/case (\d+): return GlyphMetrics\(advanceX: (-?\d+), offsetX: (-?\d+), offsetY: (-?\d+), inkSize: Size\(width: (\d+), height: (\d+)\)!\)/)
line_metrics = catalogue.match(/lineMetrics: FontLineMetrics\(ascent: (\d+), descent: (\d+), lineGap: (\d+)\)/)
replacement = catalogue.match(/replacementGlyph: GlyphID\(rawValue: (\d+)\)/)
abort 'reference font mapping count changed' unless mapping.length == 96
abort 'reference font glyph count changed' unless metrics.length == 102
abort 'reference font line metrics missing' unless line_metrics && replacement
abort 'reference font mapping order changed' unless mapping.each_with_index.all? { |row, index| row[0].to_i == index }
abort 'reference font glyph order changed' unless metrics.each_with_index.all? { |row, index| row[0].to_i == index }

lines = [
  '// Generated from ReferenceCatalogue.generated.swift by scripts/contracts/generate-spec-001-nrf-font.rb. Do not edit.',
  'package enum StaticSignalAnalyzerNRFReferenceMetrics {',
  "    package static let ascent: Int16 = #{line_metrics[1]}",
  "    package static let descent: Int16 = #{line_metrics[2]}",
  "    package static let lineGap: Int16 = #{line_metrics[3]}",
  "    package static let replacementGlyph: UInt16 = #{replacement[1]}",
  "    package static let glyphCount: UInt16 = #{metrics.length}",
  "    package static let mappingCount: UInt16 = #{mapping.length}",
  '',
  '    package struct Metric: Equatable {',
  '        package let advanceX: Int16',
  '        package let offsetX: Int16',
  '        package let offsetY: Int16',
  '        package let width: Int16',
  '        package let height: Int16',
  '    }',
  '',
  '    package static func glyph(for scalar: UInt32) -> UInt16? {',
  '        switch scalar {'
]
mapping.each do |_index, scalar, glyph|
  lines << "        case 0x#{scalar}: return #{glyph}"
end
lines += ['        default: return nil', '        }', '    }', '',
          '    package static func metric(for glyph: UInt16) -> Metric? {',
          '        switch glyph {']
metrics.each do |glyph, advance, x, y, width, height|
  lines << "        case #{glyph}: return Metric(advanceX: #{advance}, offsetX: #{x}, offsetY: #{y}, width: #{width}, height: #{height})"
end
lines += ['        default: return nil', '        }', '    }', '}', '']
generated = lines.join("\n")

if ARGV == ['--check']
  abort 'nRF reference font projection is stale' unless destination.file? && destination.read == generated
else
  abort 'usage: generate-spec-001-nrf-font.rb [--check]' unless ARGV.empty?
  destination.write(generated)
end
