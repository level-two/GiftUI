#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/RunCycleValues.swift")

def fail_check(message)
  warn "SPEC-009 run-cycle value check failed: #{message}"
  exit 1
end

source = SOURCE.read
imports = source.scan(/^import (\w+)$/).flatten
fail_check("run-cycle imports differ") unless imports == %w[GiftUI GiftUIRenderCore]

required_declarations = %w[
  ExecutionError SemanticCycleDisposition ExecutionOperational
  ExecutionOperationalEvents PresentationIntentState RunCycleFailure
  RunCycleSummary RunCycleResult
]
required_declarations.each do |name|
  matches = Dir[ROOT.join("Sources/**/*.swift")].select do |path|
    File.read(path).match?(/package (?:struct|enum) #{name}\b/)
  end
  fail_check("#{name} ownership differs: #{matches}") unless matches == [SOURCE.to_s]
end

required_fragments = [
  "package enum RunCycleFailure<OwnerFailure: Equatable & Sendable>: Equatable, Sendable",
  "case renderProduction(RenderProductionError)",
  "case focusedOwner(OwnerFailure)",
  "self.rawValue = rawValue & 0x1F",
  "package static let noChange = Self(rawValue: 0x01)",
  "package static let backpressured = Self(rawValue: 0x02)",
  "package static let retryableRefusal = Self(rawValue: 0x04)",
  "package static let superseded = Self(rawValue: 0x08)",
  "package static let deferredToLaterAdmission = Self(rawValue: 0x10)",
  "package enum RunCycleResult<OwnerFailure: Equatable & Sendable>: Equatable, Sendable",
  "case operational(ExecutionOperational, RunCycleSummary)",
  "RunCycleFailure<OwnerFailure>",
]
required_fragments.each do |fragment|
  fail_check("run-cycle values lack #{fragment}") unless source.include?(fragment)
end

fail_check("owner failure is inspected") if source.match?(/switch\s+.*OwnerFailure|OwnerFailure\s*\./)
forbidden = /\b(?:public|open|any|Any|String|Array|ContiguousArray|class|actor|closure|diagnostic|GiftUISemanticCore|GiftUILayout|GiftUIRenderLowering|GiftUIFailureCore|GiftUICapabilities|GiftUIRuntime)\b/
fail_check("run-cycle values contain existential, diagnostic, dynamic, or upward coupling") if source.match?(forbidden)

puts "SPEC-009 run-cycle values passed: exact finite failures, masked operational events, and validated generic results."
