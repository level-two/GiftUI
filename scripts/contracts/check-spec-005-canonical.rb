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
  "UInt32(bitPattern: value)",
  "emitUInt32(digest.word0)",
  "emitUInt32(digest.word7)",
  "while round < 64",
  "let messageBitCount = totalByteCount &* 8",
].freeze
required_fragments.each do |fragment|
  fail_check("missing #{fragment}") unless source.include?(fragment)
end

prefix = "GiftUITextResources/v1".bytes
emitted_prefix = source.scan(/emit\(0x([0-9a-f]{2})\) \/\//).flatten.map { |hex| hex.to_i(16) }
unless emitted_prefix.take(prefix.length) == prefix
  fail_check("schema prefix is not emitted as the exact 22 literal UTF-8 bytes")
end

constants = source.scan(/^\s*(?:case [0-9]+|default): 0x[0-9a-f]{8}$/)
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
