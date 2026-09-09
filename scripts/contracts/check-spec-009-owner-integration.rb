#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
PACKAGE = ROOT.join("Package.swift").read
STATUS = ROOT.join("Tests/ContractFixtures/SPEC009/integration-owner-status.tsv")

def fail_check(message)
  warn "SPEC-009 owner integration check failed: #{message}"
  exit 1
end

observable = PACKAGE[/\.target\(\s*name: "GiftUIObservableState".*?\n\s*\),/m]
fail_check("SPEC-010 owner lacks its approved Execution edge") unless observable&.include?("GiftUIExecution")

adapter = ROOT.join("Sources/GiftUIObservableState/PresentationFactAdmission.swift").read
fail_check("SPEC-010 seam imports outside Execution") unless adapter.scan(/^import (\w+)/).flatten == ["GiftUIExecution"]
%w[PresentationFactAdmissionAdapter associatedtype\ Fact submit ExecutionAdmissionOutcome].each do |fragment|
  fail_check("SPEC-010 seam lacks #{fragment.tr('\\', '')}") unless adapter.match?(/#{fragment}/)
end
tests = ROOT.join("Tests/GiftUIObservableStateTests/PresentationFactAdmissionTests.swift").read
%w[presentationFactAdapterForwardsOneCompleteTypedFactAndExactOutcome presentationFactRefusalIsReturnedWithoutFallbackOrSecondQueue].each do |name|
  fail_check("SPEC-010 integration tests lack #{name}") unless tests.include?(name)
end

missing_targets = %w[GiftUIInteraction GiftUIRuntimeDynamic GiftUIRuntimeStatic GiftUIBackend]
missing_targets.each do |target|
  fail_check("#{target} unexpectedly exists; integration status must be revisited") if PACKAGE.include?(%{name: "#{target}"})
end

rows = STATUS.each_line.reject { |line| line.start_with?("#") || line.strip.empty? }.map { |line| line.chomp.split("\t", -1) }
fail_check("owner-status registry shape differs") unless rows.length == 4 && rows.all? { |row| row.length == 4 }
fail_check("SPEC-010 must be the only integrated owner") unless rows.map { |row| row[2] } == %w[integrated blocked blocked blocked]

puts "SPEC-009 owner integration passed: SPEC-010 admission is exact; SPEC-011, SPEC-013, and SPEC-014 remain explicitly blocked with no substitute target."
