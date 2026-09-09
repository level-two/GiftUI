#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "date"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
PLAN = ROOT.join("docs/implementation-plans/spec-006-implementation-plan.md")
SPEC = ROOT.join("docs/specs/spec-006-declarative-view-semantics.md")

def fail_check(message)
  warn "SPEC-006 deferred-work check failed: #{message}"
  exit 1
end

items = {
  "FW-017" => ROOT.join("docs/future-work/fw-017-public-binding-abstraction.md"),
  "FW-020" => ROOT.join("docs/future-work/fw-020-declarative-extensibility.md"),
}
items.each do |id, path|
  text = path.read
  front_matter = text[/\A---\n(.*?)\n---/m, 1] || fail_check("#{id} lacks front matter")
  metadata = YAML.safe_load(
    front_matter,
    permitted_classes: [Date],
    permitted_symbols: [],
    aliases: false
  )
  fail_check("#{id} identity differs") unless metadata["id"] == id
  fail_check("#{id} is not captured") unless metadata["status"] == "captured"
  fail_check("#{id} lost SPEC-006 provenance") unless metadata.fetch("source").include?("SPEC-006")
  fail_check("#{id} became a milestone commitment") unless metadata["target_milestone"].nil?
  fail_check("#{id} was promoted without a gate") unless metadata.fetch("promoted_to").empty?
  fail_check("#{id} lacks concrete revisit triggers") unless text.include?("## Revisit Triggers")
  fail_check("#{id} lacks the current continue disposition") unless
    text.include?("Continued as captured post-MVP work") &&
      text.include?("No revisit trigger has fired")
end

spec = SPEC.read
plan = PLAN.read
items.each_key do |id|
  fail_check("SPEC-006 lacks reciprocal #{id} link") unless spec.include?("[#{id}]")
  fail_check("implementation plan lacks reciprocal #{id} link") unless plan.include?("[#{id}]")
end

plan.scan(/- \[[ x]\] `(T\d+\.\d+)` — (.*?)(?=\n- \[[ x]\] `T|\n###|\z)/m).each do |task, body|
  next unless body.match?(/FW-01[7]|FW-020/)
  next if %w[T0.1 T7.2].include?(task)

  fail_check("#{task} improperly depends on deferred work")
end

fixture_inputs = Dir[ROOT.join("Tests/ContractFixtures/SPEC006/**/*").to_s].select do |path|
  File.file?(path) && !path.include?("/Evidence/")
end
fixture_inputs.each do |path|
  fail_check("fixture input depends on deferred work: #{path}") if File.read(path).match?(/FW-017|FW-020/)
end
production = Dir[ROOT.join("Sources/{GiftUI,GiftUISemanticCore}/**/*.swift").to_s]
production.each do |path|
  fail_check("production source depends on deferred work: #{path}") if File.read(path).match?(/FW-017|FW-020/)
end

puts "SPEC-006 deferred work passed: FW-017 and FW-020 remain reciprocal, unpromoted post-MVP captures with concrete triggers and no implementation or fixture dependency."
