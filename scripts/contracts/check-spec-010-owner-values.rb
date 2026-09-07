#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableState/ObservableStateValues.swift")

def fail_check(message)
  warn "SPEC-010 owner value check failed: #{message}"
  exit 1
end

source = SOURCE.read
fail_check("owner value imports differ") unless source.scan(/^import (\w+)$/).flatten == %w[GiftUIExecution]

required_declarations = %w[
  ObservableStateLimits ObservableStateError ObservableStateOperational
  ObservableStateResult ObservableStateCandidateDisposition
]
required_declarations.each do |name|
  matches = Dir[ROOT.join("Sources/**/*.swift")].select do |path|
    File.read(path).match?(/package (?:struct|enum) #{name}\b/)
  end
  fail_check("#{name} ownership differs: #{matches}") unless matches == [SOURCE.to_s]
end

required_fragments = [
  "maximumRegistrations >= maximumLocations",
  "maximumStagedAssociations >= maximumLocations",
  "case success(ObservableStateOperational)",
  "case failure(ObservableStateError)",
  "case publish = 0",
  "case discard = 1",
]
required_fragments.each do |fragment|
  fail_check("owner values lack #{fragment}") unless source.include?(fragment)
end

forbidden = /\b(?:public|open|String|Array|ContiguousArray|Dictionary|Set|Any|any|class|actor|Task|throw|fatalError|GiftUIFailureCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("owner values contain a forbidden surface or facility") if source.match?(forbidden)

puts "SPEC-010 owner values passed: exact limits, raw cases, result carrier, and candidate disposition."
