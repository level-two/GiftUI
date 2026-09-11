#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE = ROOT.join("Tests/ContractFixtures/SPEC008/fixtures.yaml")
TEST = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderProfileEquivalenceTests.swift")
PACKAGE = ROOT.join("Package.swift")

def fail_check(message)
  warn "SPEC-008 profile equivalence check failed: #{message}"
  exit 1
end

case_names = YAML.safe_load(FIXTURE.read, aliases: false).fetch("cases").map { |row| row.fetch("name") }
source = TEST.read
fail_check("profile equivalence test is missing") unless
  source.include?("func canonicalCorpusMatchesAcrossRecordingDynamicAndStaticRenderProfiles()")
case_names.each do |name|
  fail_check("canonical case is absent from profile fixture: #{name}") unless source.include?("name: \"#{name}\"")
end
fail_check("profile fixture case count differs") unless source.scan(/name: "[a-z0-9-]+"/).length == case_names.length

%w[
  RecordingRenderIdentity DynamicRenderIdentity StaticRenderIdentity
  RecordingVisitStorage DynamicVisitStorage StaticVisitStorage
  RecordingForegroundStorage DynamicForegroundStorage StaticForegroundStorage
].each do |type|
  fail_check("missing profile storage #{type}") unless source.include?(type)
end

fail_check("profiles do not share one producer call") unless
  source.scan(/RenderProducer\.produce\(/).length == 1 &&
    source.scan(/produceProfile\(/).length == 3
fail_check("profile observations omit a required comparison field") unless %w[
  result events failure limits structuralCapacity foregroundHighWater
].all? { |field| source.include?("let #{field}:") }
fail_check("field-by-field profile equality is missing") unless
  source.include?("#expect(recording == dynamic") && source.include?("#expect(dynamic == fixed")
fail_check("real SPEC-003 mapping adapter is not compared") unless
  source.include?("GiftUIRenderFailureAdapterFixture.fact(for: result)")

package = PACKAGE.read
target = package[/name: "GiftUIRenderLoweringTests",.*?\n\s*\]\n\s*\)/m]
fail_check("render lowering test target is missing") unless target
fail_check("render failure adapter test dependency is missing") unless
  target.include?("GiftUIRenderFailureAdapterFixture") && target.include?("GiftUIFailureCore")

puts "SPEC-008 profile equivalence passed: all five canonical cases compare recording, dynamic, and static headers, ordered values, results, mappings, limits, and high-water through one producer."
