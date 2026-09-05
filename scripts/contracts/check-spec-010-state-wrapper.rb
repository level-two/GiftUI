#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
source = File.read(File.join(root, "Sources/GiftUI/ObservableState.swift"))

def fail_check(message)
  warn "SPEC-010 state wrapper check failed: #{message}"
  exit 1
end

storage = source[/private enum Storage \{(.*?)\n    \}/m, 1]
fail_check("State storage is missing") unless storage
cases = storage.scan(/^\s*case\s+([a-zA-Z]+)/).flatten
fail_check("State storage cases differ: #{cases.inspect}") unless cases == %w[initial bound]
fail_check("initial storage does not own exactly Value") unless storage.include?("case initial(Value)")
fail_check("bound storage lacks fixed read and replace routes") unless
  storage.include?("case bound(read: () -> Value, replace: (Value) -> Void)")

bind = source[/package mutating func _giftUIBind\((.*?)\n    \}/m, 0]
fail_check("package binding facility is missing") unless bind
fail_check("binding does not consume the initial case") unless
  bind.include?("guard case .initial(let initial) = storage") &&
    bind.include?("storage = .bound(read: read, replace: replace)") &&
    bind.include?("return initial")
fail_check("repeated binding does not fail closed") unless bind.include?("return nil")

sink = source[/public struct _GiftUIObservableChangeSink: ~Copyable \{(.*?)\n\}/m, 1]
fail_check("noncopyable sink is missing") unless sink
fail_check("sink does not contain one fixed attachment route") unless
  sink.scan(/private let reportRoute:/).length == 1 &&
    sink.include?("reportRoute(storedAttachment)")

forbidden = /@TaskLocal|\b(?:StateBindingContext|DynamicStateStore|StateKey|Any|Mirror)\b|^\s*(?:public|package|internal|private)?\s*static\s+var/m
fail_check("portable state contains a fallback or forbidden registry") if source.match?(forbidden)

puts "SPEC-010 state wrapper passed: two-case ownership, fixed routes, noncopyable sink, and no ambient fallback."
