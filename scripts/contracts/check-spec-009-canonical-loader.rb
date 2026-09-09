#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "open3"
require "pathname"
require "tmpdir"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures/SPEC009")
HARNESS = ROOT.join("scripts/contracts/check-spec-009-harness.rb")

def fail_check(message)
  warn "SPEC-009 canonical loader check failed: #{message}"
  exit 1
end

def run_harness(root)
  Open3.capture3({ "SPEC009_FIXTURE_ROOT" => root.to_s }, HARNESS.to_s)
end

summary = {
  "cycle" => "cycle:0",
  "admission" => { "inputEvents" => 0, "stateChangeFacts" => 0, "completionFacts" => 0, "semanticActions" => 0, "semanticDirty" => false, "presentationPending" => false },
  "semanticRevision" => "none", "semanticDisposition" => "unchanged",
  "logicalFrameDisposition" => "not-produced", "committedPresentationRevision" => "none",
  "presentationIntentState" => "satisfied", "presentationPending" => "none",
  "operationalEvents" => { "rawValue" => 1, "events" => ["no-change"] }
}
shared = {
  "name" => "loader-reference-case", "initialState" => {}, "limits" => {},
  "preOpportunityAdmissions" => "none", "phaseInjections" => "none", "endpointScript" => "none",
  "expectedPhaseTranscript" => "none", "expectedAdmissionSummary" => "none",
  "expectedResult" => { "kind" => "operational", "primary" => "no-change", "summary" => summary },
  "expectedAuthoritativeState" => {}, "expectedWakeTransitions" => "none",
  "expectedFailureOrOperationalMapping" => "none", "criteria" => ["EX-002"],
  "evidenceClasses" => ["host-execution"], "entryWakeReasons" => "none",
  "expectedSealedMembership" => "none", "expectedAppliedEffects" => "none",
  "expectedPublication" => "none"
}

Dir.mktmpdir("spec-009-loader") do |directory|
  root = Pathname.new(directory)
  FileUtils.cp_r(FIXTURES.children, root)
  baseline_cases = YAML.safe_load(root.join("cycles.yaml").read, aliases: false).fetch("cases")
  root.join("cycles.yaml").write(YAML.dump("schema" => "spec-009-v1", "cases" => baseline_cases + [shared]))
  evidence = root.join("required-evidence.tsv").read.sub(
    /^EX-002\t([^\t]+)\t([^\t]+)\t([^\t]+)\tpending$/
  ) do
    cases = (Regexp.last_match(3).split(",") + ["loader-reference-case"]).sort.join(",")
    "EX-002\t#{Regexp.last_match(1)}\t#{Regexp.last_match(2)}\t#{cases}\tpending"
  end
  root.join("required-evidence.tsv").write(evidence)
  _out, error, status = run_harness(root)
  fail_check("valid reference case failed: #{error}") unless status.success?

  mutations = {
    "implicit none" => ->(value) { value.delete("endpointScript") },
    "unstable identity" => ->(value) { value["initialState"] = { "pointer:12" => true } },
    "wrong primary" => ->(value) { value["expectedResult"]["primary"] = "superseded" },
    "illegal summary" => ->(value) { value["expectedResult"]["summary"]["semanticDisposition"] = "published" },
    "malformed endpoint" => ->(value) { value["endpointScript"] = { "bodyCalled" => true } },
  }
  mutations.each do |label, mutation|
    candidate = Marshal.load(Marshal.dump(shared))
    mutation.call(candidate)
    root.join("cycles.yaml").write(YAML.dump("schema" => "spec-009-v1", "cases" => baseline_cases + [candidate]))
    _mutation_out, _mutation_error, mutation_status = run_harness(root)
    fail_check("loader accepted #{label}") if mutation_status.success?
  end
end

puts "SPEC-009 canonical loader passed: shared fields, explicit none, stable identities, precedence, summary, endpoint, and reciprocal evidence validation are fail-closed."
