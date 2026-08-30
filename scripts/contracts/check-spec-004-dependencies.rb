#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

root = File.expand_path("../..", __dir__)
contract_path = File.join(root, "Tests/ContractFixtures/SPEC004/target-boundaries.yaml")

def fail_check(message)
  warn "SPEC-004 dependency check failed: #{message}"
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
forbidden = contract["forbidden_capability_imports"]
fail_check("active targets must be a mapping") unless active.is_a?(Hash)
fail_check("forbidden imports must be unique strings") unless
  forbidden.is_a?(Array) && forbidden.all? { |name| name.is_a?(String) } &&
    forbidden.uniq.length == forbidden.length

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

product = products["GiftUICapabilities"] || fail_check("GiftUICapabilities product is missing")
fail_check("GiftUICapabilities product must be a library") unless product["type"].key?("library")
fail_check("GiftUICapabilities product target differs") unless product["targets"] == ["GiftUICapabilities"]

puts "SPEC-004 dependency check passed: #{active.length} active targets and " \
     "#{forbidden.length} forbidden imports."
