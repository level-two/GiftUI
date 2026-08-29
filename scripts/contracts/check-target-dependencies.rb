#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = File.expand_path("../..", __dir__)
DEFAULT_ALLOW_LIST = File.join(
  ROOT,
  "Tests/ContractFixtures/SPEC002/target-dependencies.yaml"
)

def fail_check(message)
  warn "SPEC-002 dependency check failed: #{message}"
  exit 1
end

def target_dependency_name(dependency)
  keys = dependency.keys & %w[byName target]
  fail_check("unsupported dependency declaration #{dependency.inspect}") unless keys.length == 1

  value = dependency.fetch(keys.first)
  name = value.is_a?(Array) ? value.first : value
  fail_check("dependency has no target name: #{dependency.inspect}") unless name.is_a?(String)

  name
end

def find_cycle(edges)
  state = {}
  path = []

  visit = lambda do |name|
    case state[name]
    when :visiting
      start = path.index(name)
      return path[start..] + [name]
    when :visited
      return nil
    end

    state[name] = :visiting
    path << name
    edges.fetch(name).sort.each do |dependency|
      cycle = visit.call(dependency)
      return cycle if cycle
    end
    path.pop
    state[name] = :visited
    nil
  end

  edges.keys.sort.each do |name|
    cycle = visit.call(name)
    return cycle if cycle
  end
  nil
end

allow_list_path = ARGV.fetch(0, DEFAULT_ALLOW_LIST)
fail_check("unexpected arguments") if ARGV.length > 1

begin
  allow_list = YAML.safe_load(File.read(allow_list_path), aliases: false)
  package = JSON.parse($stdin.read)
rescue Errno::ENOENT, JSON::ParserError, Psych::Exception => error
  fail_check(error.message)
end

fail_check("schema_version must be 1") unless allow_list["schema_version"] == 1
expected = allow_list["targets"]
fail_check("targets must be a mapping") unless expected.is_a?(Hash)

actual_targets = package["targets"]
fail_check("dump-package JSON has no targets array") unless actual_targets.is_a?(Array)

actual = actual_targets.to_h do |target|
  name = target["name"]
  fail_check("target name must be a string") unless name.is_a?(String)
  dependencies = target.fetch("dependencies", []).map do |dependency|
    target_dependency_name(dependency)
  end
  [name, { "type" => target["type"], "dependencies" => dependencies }]
end

fail_check("dump-package contains duplicate target names") unless actual.length == actual_targets.length

expected_names = expected.keys.sort
actual_names = actual.keys.sort
unless expected_names == actual_names
  fail_check("target set differs: expected #{expected_names.inspect}, got #{actual_names.inspect}")
end

expected_edges = {}
actual_edges = {}

expected_names.each do |name|
  declaration = expected[name]
  fail_check("#{name} declaration must be a mapping") unless declaration.is_a?(Hash)
  fail_check("#{name} has unknown keys") unless (declaration.keys - %w[type dependencies]).empty?

  expected_type = declaration["type"]
  expected_dependencies = declaration["dependencies"]
  fail_check("#{name} type must be a string") unless expected_type.is_a?(String)
  fail_check("#{name} dependencies must be an array") unless expected_dependencies.is_a?(Array)
  fail_check("#{name} dependencies must be unique strings") unless
    expected_dependencies.all? { |dependency| dependency.is_a?(String) } &&
      expected_dependencies.uniq.length == expected_dependencies.length

  unknown_expected = expected_dependencies - expected_names
  fail_check("#{name} names unknown dependencies #{unknown_expected.inspect}") unless unknown_expected.empty?

  actual_dependencies = actual.fetch(name).fetch("dependencies")
  unknown_actual = actual_dependencies - actual_names
  fail_check("#{name} has unknown direct dependencies #{unknown_actual.inspect}") unless unknown_actual.empty?

  unless expected_type == actual.fetch(name).fetch("type")
    fail_check("#{name} type differs: expected #{expected_type.inspect}, got #{actual[name]["type"].inspect}")
  end
  unless expected_dependencies.sort == actual_dependencies.sort
    fail_check("#{name} direct dependencies differ: expected #{expected_dependencies.sort.inspect}, got #{actual_dependencies.sort.inspect}")
  end

  expected_edges[name] = expected_dependencies
  actual_edges[name] = actual_dependencies
end

if (cycle = find_cycle(expected_edges))
  fail_check("allow-list cycle detected: #{cycle.join(" -> ")}")
end
if (cycle = find_cycle(actual_edges))
  fail_check("package cycle detected: #{cycle.join(" -> ")}")
end

puts "SPEC-002 dependency check passed: #{actual_names.length} targets, " \
     "#{actual_edges.values.sum(&:length)} direct edges, acyclic."
