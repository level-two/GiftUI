#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

root = Pathname.new(File.expand_path("../..", __dir__))
fixtures = root.join("Tests/ContractFixtures/SPEC015")

def fail_check(message)
  warn "SPEC-015 harness check failed: #{message}"
  exit 1
end

registry = fixtures.join("fixture-registry.tsv").read.lines.reject { |line| line.start_with?("#") || line.strip.empty? }
fail_check("fixture registry must contain ten ordered schemas") unless registry.length == 10
registry.each_with_index do |line, index|
  fields = line.chomp.split("\t", -1)
  fail_check("invalid fixture registry row #{index + 1}") unless fields.length == 4 && fields[0] == (index + 1).to_s
  path = fixtures.join(fields[2])
  fail_check("missing schema #{fields[2]}") unless path.file?
  rows = path.read.lines.reject { |row| row.start_with?("#") || row.strip.empty? }
  orders = rows.map { |row| row.split("\t", -1).first }
  fail_check("reordered or duplicate fields in #{fields[2]}") unless orders == (1..rows.length).map(&:to_s)
  fail_check("#{fields[2]} does not require schema_version first") unless rows.first&.split("\t", -1)&.at(1) == "schema_version"
end

criteria = fixtures.join("criterion-registry.tsv").read.scan(/^HC-(\d{3})\t/).flatten
fail_check("criterion registry must contain HC-001 through HC-018") unless criteria == (1..18).map { |value| format("%03d", value) }

kinds = fixtures.join("evidence-kinds.tsv").read.lines.reject { |line| line.start_with?("#") || line.strip.empty? }.map { |line| line.split("\t", 2).first }
fail_check("evidence kinds differ from approved set") unless kinds == %w[host-execution cross-build simulator connected-target]

puts "SPEC-015 harness check passed: 10 schemas, 18 criteria, 4 evidence kinds."

