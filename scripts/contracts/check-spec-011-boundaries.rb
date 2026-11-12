#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
GRAPH = YAML.safe_load(
  ROOT.join("Tests/ContractFixtures/SPEC002/target-dependencies.yaml").read,
  aliases: false
).fetch("targets")

def fail_check(message)
  warn "SPEC-011 boundary check failed: #{message}"
  exit 1
end

def swift_without_comments(source)
  characters = source.each_char.to_a
  output = +""
  state = :code
  block_depth = 0
  string_quote_count = 0
  string_hash_count = 0
  index = 0

  sequence_at = lambda do |position, character, count|
    count.positive? && characters[position, count] == Array.new(count, character)
  end
  string_end_at = lambda do |position|
    sequence_at.call(position, '"', string_quote_count) &&
      characters[position + string_quote_count, string_hash_count] == Array.new(string_hash_count, "#")
  end

  while index < characters.length
    character = characters[index]
    following = characters[index + 1]

    case state
    when :line_comment
      if character == "\n"
        output << "\n"
        state = :code
      else
        output << " "
      end
      index += 1
    when :block_comment
      if character == "/" && following == "*"
        block_depth += 1
        output << "  "
        index += 2
      elsif character == "*" && following == "/"
        block_depth -= 1
        output << "  "
        index += 2
        state = :code if block_depth.zero?
      else
        output << (character == "\n" ? "\n" : " ")
        index += 1
      end
    when :string
      if string_end_at.call(index)
        output.concat(characters[index, string_quote_count + string_hash_count])
        index += string_quote_count + string_hash_count
        state = :code
      elsif character == "\\"
        escaped_length = 1
        if string_hash_count.zero?
          escaped_length += 1 if following
        elsif characters[index + 1, string_hash_count] == Array.new(string_hash_count, "#")
          escaped_length += string_hash_count + 1 if index + string_hash_count + 1 < characters.length
        end
        output.concat(characters[index, escaped_length])
        index += escaped_length
      else
        output << character
        index += 1
      end
    else
      if character == "/" && following == "/"
        output << "  "
        index += 2
        state = :line_comment
      elsif character == "/" && following == "*"
        output << "  "
        index += 2
        block_depth = 1
        state = :block_comment
      else
        hash_count = 0
        hash_count += 1 while characters[index + hash_count] == "#"
        quote_index = index + hash_count
        if characters[quote_index] == '"'
          quote_count = sequence_at.call(quote_index, '"', 3) ? 3 : 1
          output.concat(characters[index, hash_count + quote_count])
          index += hash_count + quote_count
          string_hash_count = hash_count
          string_quote_count = quote_count
          state = :string
        else
          output << character
          index += 1
        end
      end
    end
  end
  output
end

expected_interaction = %w[GiftUI GiftUIExecution GiftUILayout GiftUISemanticCore]
fail_check("Interaction dependencies differ") unless
  GRAPH.dig("GiftUIInteraction", "dependencies") == expected_interaction
expected_adapter = %w[GiftUIFailureCore GiftUIFailureExecution GiftUIInteraction]
fail_check("failure adapter dependencies differ") unless
  GRAPH.dig("GiftUIInteractionFailureAdapterFixture", "dependencies") == expected_adapter
expected_tests = %w[
  GiftUIExecution GiftUIFailureCore GiftUIFailureDiagnostics GiftUIFailureExecution
  GiftUIInteraction GiftUIInteractionFailureAdapterFixture
]
fail_check("failure adapter test dependencies differ") unless
  GRAPH.dig("GiftUIInteractionFailureAdapterTests", "dependencies") == expected_tests

%w[GiftUI GiftUIExecution GiftUILayout GiftUISemanticCore].each do |owner|
  fail_check("forbidden reverse edge from #{owner}") if
    GRAPH.fetch(owner).fetch("dependencies").include?("GiftUIInteraction")
end

interaction_sources = ROOT.glob("Sources/GiftUIInteraction/*.swift").sort
fail_check("Interaction source is missing") if interaction_sources.empty?
interaction_text = interaction_sources.map(&:read).join("\n")
imports = interaction_text.scan(/^import (\w+)/).flatten.uniq.sort
fail_check("Interaction imports outside approved owners: #{imports.inspect}") unless
  (imports - expected_interaction).empty?
forbidden = /@_exported\s+import|\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|Allocator|malloc|calloc|realloc)\b/
fail_check("Interaction contains a forbidden dependency or mechanism") if
  swift_without_comments(interaction_text).match?(forbidden)

adapter = ROOT.join(
  "Sources/GiftUIInteractionFailureAdapterFixture/InteractionFailureAdapter.swift"
).read
fail_check("failure adapter imports differ") unless
  adapter.scan(/^import (\w+)/).flatten == expected_adapter
%w[
  capacityExhausted invalidIdentity invalidGeometry invalidPhase
  reentrancyViolation invariantViolation incompatibleActionDomain
  invalidActionValue missingModelTarget interaction coordinator
  observableState candidateFrame activeCycle runtime contained safetyNotProven
  mandatoryEffectsComplete localError detector
].each do |fragment|
  fail_check("failure adapter lacks #{fragment}") unless adapter.include?(fragment)
end

puts "SPEC-011 boundaries passed: exact Interaction and failure-adapter graph, imports, reverse edges, and finite mapping surface."
