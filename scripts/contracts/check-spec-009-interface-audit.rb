#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
PACKAGE = ROOT.join("Package.swift").read
EXECUTION = ROOT.join("Sources/GiftUIExecution")

def fail_check(message)
  warn "SPEC-009 interface audit failed: #{message}"
  exit 1
end

execution_target = PACKAGE[/\.target\(\s*name: "GiftUIExecution".*?\n\s*\),/m]
failure_target = PACKAGE[/\.target\(\s*name: "GiftUIFailureExecution".*?\n\s*\),/m]
fail_check("Execution target dependency set differs") unless execution_target&.match?(/dependencies: \["GiftUI", "GiftUIRenderCore"\]/)
fail_check("Failure Execution target dependency set differs") unless failure_target&.match?(/dependencies: \["GiftUIFailureCore", "GiftUIExecution"\]/)
fail_check("Execution was exposed as a library product") if PACKAGE.match?(/\.library\([^\n]*GiftUIExecution/)

manifest = YAML.safe_load(ROOT.join("Tests/ContractFixtures/SPEC002/target-dependencies.yaml").read, aliases: false)
targets = manifest.fetch("targets")
fail_check("dependency registry Execution row differs") unless targets.dig("GiftUIExecution", "dependencies") == %w[GiftUI GiftUIRenderCore]
fail_check("dependency registry Failure Execution row differs") unless targets.dig("GiftUIFailureExecution", "dependencies") == %w[GiftUIExecution GiftUIFailureCore]

sources = EXECUTION.glob("*.swift").sort
fail_check("Execution source set is empty") if sources.empty?
source_text = sources.to_h { |path| [path, path.read] }
source_text.each do |path, text|
  imports = text.scan(/^import (\w+)/).flatten
  fail_check("#{path.basename} imports outside its approved owners") unless (imports - %w[GiftUI GiftUIRenderCore]).empty?
  fail_check("#{path.basename} exposes a public/open declaration") if text.match?(/^\s*(?:public|open)\b/)
end

forbidden_owners = %w[
  GiftUIFailureCore GiftUIFailureDiagnostics GiftUIFailureExecution GiftUISemanticCore
  GiftUILayout GiftUIInteraction GiftUIRuntime GiftUIBackend GiftUIPlatform
]
fail_check("Execution imports a failure, semantic-storage, runtime, downstream, or backend owner") if source_text.values.join("\n").match?(/^import (?:#{forbidden_owners.join('|')})$/)

portable = ROOT.join("Sources/GiftUI").glob("*.swift").map(&:read).join("\n")
fail_check("portable declarations observe Execution") if portable.match?(/\b(?:import\s+GiftUIExecution|RunCycleID|SemanticRevision|CandidateFrameID|ExecutionContext)\b/)

input_files = %w[ExecutionAdmissionController.swift InputSourceSequenceState.swift PointerActionCapture.swift]
input_text = input_files.map { |name| EXECUTION.join(name).read }.join("\n")
fail_check("input adapter imports semantic storage") if input_text.include?("GiftUISemanticCore")

negative = ROOT.join("Tests/ContractFixtures/SPEC004/Fixtures/Negative/forbidden-execution-import")
fail_check("portable negative fixture does not import the real target") unless negative.join("main.swift").read == "import GiftUIExecution\n"
fail_check("portable negative fixture diagnostic differs") unless negative.join("expected-diagnostic-patterns.txt").read.include?("no such module 'GiftUIExecution'")
fixture_manifest = ROOT.join("Tests/ContractFixtures/SPEC004/fixture-manifest.tsv").read
fail_check("portable negative fixture is not registered") unless fixture_manifest.include?("forbidden-execution-import\tfail\tpublic")

failure_negatives = {
  "SPEC003" => "import GiftUIFailureExecution\n",
  "SPEC004" => "import GiftUIFailureExecution\n",
  "SPEC005" => "import GiftUITextResources\nimport GiftUIFailureExecution\n",
}
failure_negatives.each do |spec, expected_source|
  fixture_name = spec == "SPEC003" ? "forbidden-execution-import" : "forbidden-failure-execution-import"
  fixture = ROOT.join("Tests/ContractFixtures/#{spec}/Fixtures/Negative/#{fixture_name}")
  fail_check("#{spec} negative fixture does not reject the real failure target") unless fixture.join("main.swift").read == expected_source
  fail_check("#{spec} failure diagnostic differs") unless fixture.join("expected-diagnostic-patterns.txt").read.include?("no such module 'GiftUIFailureExecution'")
end

maintained = ([ROOT.join("Package.swift")] + ROOT.glob("{Sources,Tests}/**/*.swift")).map(&:read).join("\n")
obsolete_placeholder = "GiftUIExecution" + "Contract"
fail_check("obsolete placeholder target remains") if maintained.include?(obsolete_placeholder)
fail_check("Execution compatibility shim exists") if source_text.values.join("\n").match?(/typealias\s+\w*Execution\w*\s*=/)

puts "SPEC-009 interface audit passed: exact internal targets, imports, portable opacity, input isolation, negative fixture, migration, and no placeholder/shim/second execution surface."
