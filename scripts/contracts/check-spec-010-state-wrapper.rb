#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
source = File.read(File.join(root, "Sources/GiftUI/ObservableState.swift"))

def fail_check(message)
  warn "SPEC-010 state wrapper check failed: #{message}"
  exit 1
end

storage = source[/internal enum Storage \{(.*?)\n    \}/m, 1]
fail_check("State storage is missing") unless storage
cases = storage.scan(/^\s*case\s+([a-zA-Z]+)/).flatten
fail_check("State storage cases differ: #{cases.inspect}") unless cases == %w[initial bound]
fail_check("initial storage does not own one inert schema seed") unless
  storage.include?("case initial(_GiftUIStateInitial<Schema>)")
fail_check("bound storage does not own one checked binding record") unless
  storage.include?("case bound(_GiftUIBoundState<Schema>)")

bind = source[/package mutating func _giftUIBind\((.*?)\n    \}/m, 0]
fail_check("package binding facility is missing") unless bind
fail_check("binding does not consume the initial case") unless
  bind.include?("guard case .initial(let seed) = storage") &&
    bind.include?("storage = .bound(binding)") &&
    bind.include?("return seed")
fail_check("repeated binding does not fail closed") unless bind.include?("return nil")
bound_state = source[/package struct _GiftUIBoundState<Schema> \{(.*?)\n\}/m, 1]
fail_check("bound state record is missing") unless bound_state
%w[locationSlot declarationOrdinal registrationGeneration key].each do |field|
  fail_check("bound state record lacks #{field}") unless bound_state.include?("let #{field}:")
end

sink = source[/public struct _GiftUIObservableChangeSink: ~Copyable \{(.*?)\n\}/m, 1]
fail_check("noncopyable sink is missing") unless sink
fail_check("sink does not contain one fixed attachment route") unless
  sink.scan(/private let reportRoute:/).length == 1 &&
    sink.include?("private let storedAttachment: _GiftUIObservationAttachment") &&
    sink.include?("private let context: UnsafeMutableRawPointer") &&
    sink.include?("reportRoute(") &&
    sink.include?("context, storedAttachment.slot, storedAttachment.generation")

forbidden = /@TaskLocal|\b(?:StateBindingContext|DynamicStateStore|StateKey|Any|Mirror)\b|^\s*(?:public|package|internal|private)?\s*static\s+var/m
fail_check("portable state contains a fallback or forbidden registry") if source.match?(forbidden)

puts "SPEC-010 state wrapper passed: two-case ownership, fixed routes, noncopyable sink, and no ambient fallback."
