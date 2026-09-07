#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/IdentityAllocators.swift")

def fail_check(message)
  warn "SPEC-009 identity allocator check failed: #{message}"
  exit 1
end

source = SOURCE.read
fail_check("identity allocator imports differ") unless source.scan(/^import (\w+)$/).flatten == %w[GiftUI]

allocators = %w[
  RunCycleIDAllocator SemanticRevisionAllocator CandidateFrameIDAllocator
  PresentationRevisionAllocator ActionGenerationAllocator
]
allocators.each do |name|
  declaration = "package struct #{name}: Equatable, Sendable"
  fail_check("#{name} declaration differs") unless source.include?(declaration)
end

fail_check("allocator count differs") unless source.scan(/^package struct \w+Allocator:/).length == 5
fail_check("checked cursor count differs") unless source.scan(/^private struct CheckedIdentityCursor:/).length == 1
fail_check("successor is not checked") unless source.include?("reserved.addingReportingOverflow(1)")
fail_check("overflow does not permanently exhaust") unless source.include?("successor.overflow ? nil : successor.partialValue")
fail_check("zero is not the first reservation") unless source.include?("nextRawValue = 0")
fail_check("observable target gained an allocator") if source.include?("ObservableTargetGenerationAllocator")
fail_check("identity raw value became a sentinel") if source.match?(/UInt32\.max\s*[-=]>|sentinel|wrapping|&\+/)

forbidden = /\b(?:public|open|String|Array|ContiguousArray|class|actor|GiftUISemanticCore|GiftUILayout|GiftUIRenderLowering|GiftUIFailureCore|GiftUICapabilities|GiftUIRuntime)\b/
fail_check("identity allocators contain dynamic or upward coupling") if source.match?(forbidden)

puts "SPEC-009 identity allocators passed: five checked monotonic namespaces and no observable-target allocator."
