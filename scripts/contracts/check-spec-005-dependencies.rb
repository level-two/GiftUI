#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

root = File.expand_path("../..", __dir__)
contract_path = File.join(root, "Tests/ContractFixtures/SPEC005/target-boundaries.yaml")

def fail_check(message)
  warn "SPEC-005 dependency check failed: #{message}"
  exit 1
end

begin
  contract = YAML.safe_load(File.read(contract_path), aliases: false)
  package = JSON.parse($stdin.read)
rescue Errno::ENOENT, JSON::ParserError, Psych::Exception => error
  fail_check(error.message)
end

fail_check("schema_version must be 1") unless contract["schema_version"] == 1
active = contract["active"]
forbidden = contract["forbidden_text_resource_imports"]
reserved = contract["reserved_consumers"]
compositions = contract["reference_compositions"]
fail_check("active targets must be a mapping") unless active.is_a?(Hash)
fail_check("reserved consumers must be a mapping") unless reserved.is_a?(Hash)
fail_check("forbidden imports must be unique strings") unless
  forbidden.is_a?(Array) && forbidden.all? { |name| name.is_a?(String) } &&
    forbidden.uniq.length == forbidden.length

expected_compositions = {
  "common_sources" => [
    "Sources/GiftUIReferenceTextResources/Generated/ReferenceCatalogue.generated.swift",
    "Sources/GiftUIReferenceTextResources/GiftUIReferenceTextResources.swift"
  ],
  "complete" => {
    "payload_sources" => [
      "Sources/GiftUIReferenceTextResources/Generated/ReferenceBitmapPayload.generated.swift",
      "Sources/GiftUIReferenceTextResources/Generated/ReferenceOutlinePayload.generated.swift"
    ],
    "available_realizations" => [0, 1],
    "required_realizations" => [0, 1]
  },
  "bitmap-only" => {
    "compilation_condition" => "GIFTUI_REFERENCE_BITMAP_ONLY",
    "payload_sources" => [
      "Sources/GiftUIReferenceTextResources/Generated/ReferenceBitmapPayload.generated.swift"
    ],
    "available_realizations" => [0],
    "required_realizations" => [0],
    "target_profile" => "nrf52840-embedded"
  },
  "outline-only" => {
    "compilation_condition" => "GIFTUI_REFERENCE_OUTLINE_ONLY",
    "payload_sources" => [
      "Sources/GiftUIReferenceTextResources/Generated/ReferenceOutlinePayload.generated.swift"
    ],
    "available_realizations" => [1],
    "required_realizations" => [1],
    "target_profile" => "contract-fixture-only"
  }
}
fail_check("reference compositions differ") unless compositions == expected_compositions
compositions.fetch("common_sources").each do |relative|
  fail_check("reference composition source is missing: #{relative}") unless File.file?(File.join(root, relative))
end
%w[complete bitmap-only outline-only].each do |name|
  compositions.fetch(name).fetch("payload_sources").each do |relative|
    fail_check("reference payload source is missing: #{relative}") unless File.file?(File.join(root, relative))
  end
end

targets = package.fetch("targets", []).to_h { |target| [target.fetch("name"), target] }
products = package.fetch("products", []).to_h { |product| [product.fetch("name"), product] }

active.each do |name, expected|
  target = targets[name] || fail_check("active target is missing: #{name}")
  dependencies = target.fetch("dependencies", []).map do |dependency|
    declaration = dependency.fetch("target", dependency["byName"])
    declaration.is_a?(Array) ? declaration.first : declaration
  end
  fail_check("#{name} type differs") unless target["type"] == expected["type"]
  fail_check("#{name} dependencies differ") unless dependencies.sort == expected["dependencies"].sort
end

fail_check("GiftUITextResources must not be a standalone product") if products.key?("GiftUITextResources")
reserved.each do |name, state|
  fail_check("#{name} has unknown reservation state #{state.inspect}") unless state == "pending"
  fail_check("reserved consumer #{name} exists without an activated audit row") if targets.key?(name)
end

puts "SPEC-005 dependency check passed: #{active.length} active targets, " \
     "#{reserved.length} reserved consumers, no standalone product."
