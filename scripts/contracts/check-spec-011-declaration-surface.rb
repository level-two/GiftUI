#!/usr/bin/env ruby

root = File.expand_path("../..", __dir__)
button = File.read(File.join(root, "Sources/GiftUI/Button.swift"))
disabled = File.read(File.join(root, "Sources/GiftUI/Disabled.swift"))
handler = File.read(File.join(root, "Sources/GiftUI/ActionHandler.swift"))
positive = File.read(File.join(root, "Tests/ContractFixtures/SPEC011/Positive/declarations/main.swift"))
negative = File.read(File.join(root, "Tests/ContractFixtures/SPEC011/Negative/declarations.tsv"))

required = {
  "generic Button" => /public struct Button<Action: GiftUIAction, Label: View>: View/,
  "builder initializer" => /public init\(action: Action, @ViewBuilder label: \(\) -> Label\)/,
  "StaticString title" => /init\(_ title: StaticString, action: Action\)/,
  "BoundedText title" => /init\(_ title: BoundedText, action: Action\)/,
  "disabled modifier" => /func disabled\(_ disabled: Bool\) -> some View/,
  "handler protocol" => /public protocol GiftUIActionHandler/,
  "borrowing model" => /model: borrowing Model/,
}
sources = button + disabled + handler
missing = required.reject { |_, expression| sources.match?(expression) }.keys
abort "missing declarations: #{missing.join(', ')}" unless missing.empty?
abort "six-action fixture incomplete" unless positive.scan(/^    case /).length == 6
abort "negative declaration corpus incomplete" unless negative.lines.grep(/^[a-z]/).length == 7
forbidden = /@escaping.*label|AnyHashable|ObjectIdentifier/
abort "forbidden portable storage token" if sources.match?(forbidden)

puts "SPEC-011 declaration surface passed: exact portable APIs, six actions, and seven negative shapes are registered."
