#!/usr/bin/env ruby

root = File.expand_path("../..", __dir__)
inventory = File.read(File.join(root, "Tests/ContractFixtures/SPEC011/migration-inventory.tsv"))
required = %w[
  untyped-action-id escaping-button-closure direct-model-capture
  direct-use-case-capture runtime-hit-map backend-hit-test platform-hit-test
  historical-hit-map deferred-event callback-registry execution-capture
  captured-action legacy-test-oracles
]
missing = required.reject { |token| inventory.include?(token) }
abort "missing migration rows: #{missing.join(', ')}" unless missing.empty?

source_roots = Dir.glob(File.join(root, "Sources", "**", "*.swift"))
forbidden = /\b(?:ActionID|HitTestMap|CallbackRegistry|identifiedActionHandler)\b/
violations = source_roots.each_with_object([]) do |path, found|
  next if path.end_with?("GiftUIExecution/AdmissionValues.swift")
  match = File.read(path).match(forbidden)
  found << "#{path.sub(root + '/', '')}:#{match[0]}" if match
end
abort "legacy interaction paths present: #{violations.join(', ')}" unless violations.empty?

puts "SPEC-011 migration inventory passed: #{required.length} legacy concepts have one disposition and no forbidden production path."
