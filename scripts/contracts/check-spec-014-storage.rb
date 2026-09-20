#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))

DECLARATIONS = {
  "CanonicalEncodedPixel" => {
    path: "Sources/GiftUISurfaceCore/SurfaceValues.swift",
    kind: "struct",
    fields: {
      "encoding" => "CanonicalPixelEncoding",
      "byteCount" => "UInt8",
      "byte0" => "UInt8",
      "byte1" => "UInt8",
      "byte2" => "UInt8",
      "byte3" => "UInt8",
    },
  },
  "RasterSurfaceDescriptor" => {
    path: "Sources/GiftUISurfaceCore/SurfaceValues.swift",
    kind: "struct",
    fields: {
      "bounds" => "Rect",
      "encoding" => "CanonicalPixelEncoding",
      "bytesPerRow" => "UInt32",
      "realization" => "RasterRealizationKind",
      "regionWidth" => "UInt16",
      "regionHeight" => "UInt16",
    },
  },
  "RasterPayloadLimits" => {
    path: "Sources/GiftUIRasterCore/RasterPayloadLimits.swift",
    kind: "struct",
    fields: {
      "maximumRasterBytes" => "UInt32",
      "maximumPayloadBytes" => "UInt32",
      "maximumRegionsPerPayload" => "UInt16",
      "maximumRegionSubmissionsPerFrame" => "UInt32",
      "maximumTileVisitsPerFrame" => "UInt32",
      "maximumInFlightPayloads" => "UInt8",
      "maximumGlyphRasterBytes" => "UInt32",
      "maximumStrokeWorkspaceBytes" => "UInt32",
    },
  },
  "DisplayReservationID" => {
    path: "Sources/GiftUIDisplayCore/DisplayContracts.swift",
    kind: "struct",
    fields: { "rawValue" => "UInt32" },
  },
  "DisplayReservationResult" => {
    path: "Sources/GiftUIDisplayCore/DisplayContracts.swift", kind: "enum", fields: {}
  },
  "DisplayTransferResult" => {
    path: "Sources/GiftUIDisplayCore/DisplayContracts.swift", kind: "enum", fields: {}
  },
  "DisplayTargetError" => {
    path: "Sources/GiftUIDisplayCore/DisplayContracts.swift", kind: "enum", fields: {}
  },
  "RasterBackendError" => {
    path: "Sources/GiftUIRasterCore/RasterPayloadLimits.swift", kind: "enum", fields: {}
  },
}.freeze

PROTOCOLS = {
  "RasterSurface" => "Sources/GiftUISurfaceCore/RasterSurface.swift",
  "RasterFrameSink" => "Sources/GiftUIRasterCore/RasterFrameSink.swift",
  "DisplayPayloadWriter" => "Sources/GiftUIDisplayCore/DisplayContracts.swift",
  "DisplayTarget" => "Sources/GiftUIDisplayCore/DisplayContracts.swift",
  "RasterBackendEndpoint" => "Sources/GiftUIBackendIntegration/RasterBackendEndpoint.swift",
}.freeze

TILED_SOURCE_PATHS = %w[
  Sources/GiftUIRasterCore/RGB565TileWorkspace.swift
  Sources/GiftUIBackendIntegration/OperationMajorTileTraversal.swift
  Sources/GiftUIBackendIntegration/OperationMajorRGB565RasterSession.swift
  Sources/GiftUIBackendIntegration/RGB565TilePayloadEmitter.swift
].freeze

FORBIDDEN_FIELD_TYPES = /\b(?:AnyObject|Unsafe[A-Za-z0-9_]*Pointer|Array|ContiguousArray|Dictionary|Set|String)\b|\bany\s+|\[[^\]]*\]|->/

def fail_check(message)
  warn "SPEC-014 storage check failed: #{message}"
  exit 1
end

def declaration_body(source, kind, name)
  match = source.match(/package\s+#{Regexp.escape(kind)}\s+#{Regexp.escape(name)}\b[^\{]*\{/m)
  fail_check("missing #{kind} #{name}") unless match
  open_index = match.end(0) - 1
  depth = 0
  source.bytes.each_with_index do |byte, index|
    next if index < open_index

    depth += 1 if byte == 123
    depth -= 1 if byte == 125
    return source[(open_index + 1)...index] if depth.zero?
  end
  fail_check("unterminated #{kind} #{name}")
end

DECLARATIONS.each do |name, declaration|
  source = ROOT.join(declaration.fetch(:path)).read
  signature = source[/package\s+#{declaration.fetch(:kind)}\s+#{Regexp.escape(name)}\b[^\{]*\{/m]
  fail_check("#{name} does not declare Sendable") unless signature&.match?(/\bSendable\b/)
  body = declaration_body(source, declaration.fetch(:kind), name)
  fields = body.scan(/^\s*package\s+let\s+([A-Za-z0-9_]+)\s*:\s*([^\n=\{]+)/).to_h do |field, type|
    [field, type.strip]
  end
  fail_check("#{name} stored fields differ: #{fields.inspect}") unless fields == declaration.fetch(:fields)
  fields.each do |field, type|
    fail_check("#{name}.#{field} uses forbidden storage #{type}") if type.match?(FORBIDDEN_FIELD_TYPES)
  end
  fail_check("#{name} contains class-owned storage") if body.match?(/^\s*(?:package|private|fileprivate|internal|public)?\s*class\s+/)
end

PROTOCOLS.each do |name, path|
  source = ROOT.join(path).read
  fail_check("missing protocol #{name}") unless source.match?(/package\s+protocol\s+#{Regexp.escape(name)}\b/)
end

forbidden_tiled_storage = /\b(?:AnyObject|Array|ContiguousArray|Dictionary|Set|Unsafe[A-Za-z0-9_]*Pointer)\b/
forbidden_producer_storage = /^\s*(?:package|private|fileprivate|internal|public)?\s*(?:let|var)\s+[A-Za-z0-9_]*producer[A-Za-z0-9_]*\s*:\s*(?!RenderProductionError\?)/i
TILED_SOURCE_PATHS.each do |path|
  source = ROOT.join(path).read
  fail_check("#{path} contains ownership-bearing or pointer storage") if source.match?(forbidden_tiled_storage)
  fail_check("#{path} stores a producer") if source.match?(forbidden_producer_storage)
  fail_check("#{path} declares a reference-owned workspace") if source.match?(/^\s*(?:package\s+)?(?:final\s+)?class\s+/)
end

puts "SPEC-014 storage check passed: #{DECLARATIONS.length} values, #{PROTOCOLS.length} protocols, and #{TILED_SOURCE_PATHS.length} tiled sources audited."
