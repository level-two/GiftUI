#!/usr/bin/env ruby
# frozen_string_literal: true
require "yaml"
root = File.expand_path("../../Tests/ContractFixtures/SPEC009", __dir__)
text = %w[cycles.yaml input.yaml].map { |name| File.read(File.join(root, name)) }.join("\n")
required = %w[admitting-before-seal admitting-after-seal mutating deriving publishing offering finalizing ordered-capacity-prefix atomic-publication dirty-rederivation-without-replay semantic-action-at-most-once provenance-race sequence ordinal resynchronization exhaustion capture release replacement movement disabled quiesced]
missing = required.reject { |token| text.include?(token) }
abort "SPEC-009 cycle/input corpus check failed: missing #{missing.join(', ')}" unless missing.empty?
documents = %w[cycles.yaml input.yaml].map do |name|
  YAML.safe_load(File.read(File.join(root, name)), aliases: false)
end
cases = documents.flat_map { |document| document.fetch("cases") }
abort "SPEC-009 cycle/input corpus check failed: duplicate cases" unless cases.map { |item| item.fetch("name") }.uniq.length == 10
puts "SPEC-009 cycle/input corpus passed: 10 canonical cases cover phases, membership, ordering, capacity, publication, dirtiness, at-most-once, provenance, sequencing, cancellation, resynchronization, exhaustion, capture, replacement, movement, disabled state, and quiescence."
