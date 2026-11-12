#!/usr/bin/env ruby
# frozen_string_literal: true

def fail_check(message)
  warn "SPEC-005 canonical-byte check failed: #{message}"
  exit 1
end

source_path = ARGV.fetch(0) do
  fail_check("expected the GiftUITextResources source path")
end
source = File.read(source_path)

required_fragments = [
  "static func forEachCanonicalManifestByte<M, R>",
  "static func canonicalManifestDigest<M, R>",
  "static func sha256(",
  "private struct _TextResourceSHA256",
  "internal struct TextResourceManifestEngine",
  "UInt8(truncatingIfNeeded: pending >> (UInt32(pendingBytes) * 8))",
  "while round < 64",
  "let messageBitCount = totalByteCount &* 8",
].freeze
required_fragments.each do |fragment|
  fail_check("missing #{fragment}") unless source.include?(fragment)
end

%w[
  lineMetrics.ascent lineMetrics.descent lineMetrics.lineGap
  advanceX offsetX offsetY inkSize.width inkSize.height
].each do |field|
  fail_check("signed canonical field lacks bit-preserving emission: #{field}") unless
    source.include?("emit(UInt32(bitPattern: value.#{field}), bytes: 4)")
end
(0..7).each do |word|
  fail_check("payload digest lacks canonical word #{word}") unless
    source.include?("emit(value.payloadDigest.word#{word}, bytes: 4)")
end

prefix = "GiftUITextResources/v1".bytes
header = source[/case \.header:(.*?)case \.descriptor:/m, 1]
fail_check("canonical manifest header is missing") unless header
emitted_prefix = header.scan(/case ([0-9]+): byte = ([0-9]+)/).map do |ordinal, byte|
  [ordinal.to_i, byte.to_i]
end
unless emitted_prefix == prefix.each_with_index.map { |byte, ordinal| [ordinal, byte] }
  fail_check("schema prefix is not emitted as the exact 22 literal UTF-8 bytes")
end

constants = source.scan(/^\s*(?:case [0-9]+|default): 0x[0-9a-f]{4}_?[0-9a-f]{4}$/)
fail_check("expected all 64 SHA-256 round constants") unless constants.length == 64

forbidden = {
  "dynamic byte array" => /\[UInt8\]|Array\s*</,
  "Foundation" => /\b(?:Foundation|Data)\b/,
  "platform crypto provider" => /\b(?:CryptoKit|CommonCrypto|CC_SHA)\b/,
  "struct-memory serialization" => /withUnsafeBytes\s*\(\s*of:/,
  "host-endian serialization" => /\.(?:bigEndian|littleEndian)\b/,
}.freeze
forbidden.each do |label, pattern|
  fail_check("production seam contains #{label}") if source.match?(pattern)
end

puts "SPEC-005 canonical-byte check passed: literal prefix, fixed SHA-256 state, and no collection or host-layout serialization."
