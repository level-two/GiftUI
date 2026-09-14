#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures/SPEC013")
SCHEMA = FIXTURES.join("artificial-limit-schema.tsv")
VALUES = FIXTURES.join("artificial-limit-values.tsv")
REPORTER = ROOT.join("scripts/contracts/report-spec-013-profile.rb")
DRIVER = ROOT.join("scripts/contracts/run-spec-013.sh")

def fail_check(message)
  warn "SPEC-013 report driver check failed: #{message}"
  exit 1
end

def data_rows(path)
  path.each_line.each_with_object([]) do |line, rows|
    next if line.start_with?("#") || line.strip.empty?

    rows << line.chomp.split("\t", -1)
  end
end

schema_rows = data_rows(SCHEMA).map { |row| row.first(2) }
value_rows = data_rows(VALUES)
fail_check("artificial limit registry must contain 41 values") unless value_rows.length == 41
fail_check("artificial limit row width differs") unless value_rows.all? { |row| row.length == 3 }
fail_check("artificial limit keys differ from the schema") unless value_rows.map { |row| row.first(2) } == schema_rows
fail_check("artificial limit values must be nonnegative integers") unless value_rows.all? { |row| row[2].match?(/\A\d+\z/) }

reporter_text = REPORTER.read
%w[
  schema profile evidenceClass repositoryRevision repositoryDirty compiler sdk
  target command limits audit storageHighWater fixture fixtureResult
  transcriptDigest hardwareExecution connectedTarget
].each do |field|
  fail_check("normalized report field is missing: #{field}") unless reporter_text.include?(%(["#{field}",))
end

driver_text = DRIVER.read
%w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded].each do |profile|
  fail_check("driver profile is missing: #{profile}") unless driver_text.include?(profile)
end
%w[
  report-input-identity.rb finalize-contract-metadata.rb publish-contract-report.rb
  verify-contract-report.rb pristine-profile-collection
].each do |requirement|
  fail_check("driver requirement is missing: #{requirement}") unless driver_text.include?(requirement)
end
fail_check("driver must forbid connected-target evidence") unless driver_text.include?("connected_target_execution=false")
fail_check("driver must leave pristine profile collection explicitly blocked") unless driver_text.include?(
  "T7.4 two-build profile collection is not complete"
)

puts "SPEC-013 report driver passed: 41 numeric limits, complete normalized fields, and 4 immutable report modes."
