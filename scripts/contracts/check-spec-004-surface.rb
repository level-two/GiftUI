#!/usr/bin/env ruby
# frozen_string_literal: true

EXPECTED_PUBLIC_TYPES = %w[
  CapabilityAbsence
  CapabilityByteCount
  CapabilityExtent
  CapabilitySnapshot
  CanonicalPixelEncoding
  CanonicalPixelEncodingSet
  EffectiveRasterPresentation
  OperationStreamLifetime
  RasterBackendContribution
  RasterOperationSet
  RasterPresentationContribution
  RasterPresentationContributionInsertion
  RasterPresentationContributions
  RasterPresentationCapacity
  RasterPresentationContributorRole
  RasterPresentationMalformedField
  RasterPresentationPolicy
  RasterPresentationRequirement
  RasterPresentationResolution
  RasterPresentationResolver
  RasterPresentationResolverWorkspace
  RasterPresentationUnavailable
  RasterRealizationContribution
  RasterRealizationKind
  RasterRealizationKindSet
  RenderProducerContribution
  SubmissionHandoff
  SubmissionHandoffSet
  SubmissionLifetime
  SubmissionLifetimeSet
  SurfaceDisplayContribution
].sort.freeze

def fail_check(message)
  warn "SPEC-004 surface check failed: #{message}"
  exit 1
end

fail_check("expected one public interface path") unless ARGV.length == 1
begin
  interface = File.read(ARGV.fetch(0))
rescue Errno::ENOENT => error
  fail_check(error.message)
end

public_types = interface.scan(/^public (?:struct|enum) ([A-Za-z0-9_]+)/).flatten.sort
fail_check("public type set differs: #{public_types.inspect}") unless public_types == EXPECTED_PUBLIC_TYPES

snapshot = interface[/public struct CapabilitySnapshot .*?^}/m]
fail_check("CapabilitySnapshot declaration is missing") unless snapshot
snapshot_fields = snapshot.scan(/^  public let ([A-Za-z0-9_]+):/).flatten
fail_check("public catalogue differs: #{snapshot_fields.inspect}") unless snapshot_fields == ["rasterPresentation"]
fail_check("snapshot initializer is missing") unless
  snapshot.include?("public init(rasterPresentation: GiftUICapabilities.EffectiveRasterPresentation?)")

required_t12_fragments = [
  "case synchronousBorrowedOneShot",
  "case incompatibleWithSynchronousBorrowedOneShot",
  "case renderProducer(GiftUICapabilities.RenderProducerContribution)",
  "case rasterBackend(GiftUICapabilities.RasterBackendContribution)",
  "case surfaceDisplay(GiftUICapabilities.SurfaceDisplayContribution)",
  "case hostResourcePolicy(GiftUICapabilities.RasterPresentationPolicy)",
  "public static let capacity: Swift.UInt8",
  "public init()",
  "public mutating func insert(_ contribution: GiftUICapabilities.RasterPresentationContribution) -> GiftUICapabilities.RasterPresentationContributionInsertion",
  "case inserted",
  "case rejected(GiftUICapabilities.RasterPresentationUnavailable)",
  "public static let candidateCapacity: Swift.UInt8",
  "public let usableCandidateCapacity: Swift.UInt8",
  "public init?(usableCandidateCapacity: Swift.UInt8 = 2)",
  "public enum RasterPresentationResolver",
  "public static func resolve(requirement: GiftUICapabilities.RasterPresentationRequirement, contributions: borrowing GiftUICapabilities.RasterPresentationContributions, workspace: inout GiftUICapabilities.RasterPresentationResolverWorkspace) -> GiftUICapabilities.RasterPresentationResolution",
]
missing_t12_fragments = required_t12_fragments.reject { |fragment| interface.include?(fragment) }
fail_check("T1.2 declarations differ: #{missing_t12_fragments.inspect}") unless missing_t12_fragments.empty?

fail_check("public interface contains an exported import") if interface.match?(/@_exported\s+import/)

puts "SPEC-004 surface check passed: #{public_types.length} exact public types and " \
     "one rasterPresentation catalogue family."
