#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

root = File.expand_path("../../Tests/ContractFixtures/SPEC009", __dir__)
recovery = YAML.safe_load(File.read(File.join(root, "recovery.yaml")), aliases: false).fetch("cases")
signal = YAML.safe_load(File.read(File.join(root, "signal-analyzer.yaml")), aliases: false).fetch("cases")

required = %w[backpressure retryable-refusal maximumRetries supersedes terminal unavailable quiesces checkedIncrement]
text = File.read(File.join(root, "recovery.yaml"))
missing = required.reject { |token| text.include?(token) }
abort "SPEC-009 recovery/signal corpus check failed: missing #{missing.join(', ')}" unless missing.empty?
abort "SPEC-009 recovery/signal corpus check failed: expected seven recovery cases" unless recovery.length == 7
abort "SPEC-009 recovery/signal corpus check failed: retry counts exceed configured maximum" if recovery.any? do |item|
  item.fetch("countAfter") > item.fetch("configuredMaximum")
end

workload = signal.fetch(0)
facts = workload.fetch("factTimestamps")
opportunities = workload.fetch("opportunityTimestamps")
abort "SPEC-009 recovery/signal corpus check failed: workload shape differs" unless facts.length == 80 && opportunities == [250, 500, 750, 1000]
window_counts = opportunities.each_with_index.map do |upper, index|
  lower = index.zero? ? 0 : opportunities[index - 1]
  facts.count { |timestamp| timestamp >= lower && timestamp < upper }
end
abort "SPEC-009 recovery/signal corpus check failed: expected 20 facts per opportunity" unless window_counts == [20, 20, 20, 20]
abort "SPEC-009 recovery/signal corpus check failed: coalescing differs" unless workload.values_at("expectedPublications", "expectedOffers", "expectedWakes") == [4, 4, 4]
abort "SPEC-009 recovery/signal corpus check failed: pending high-water differs" unless workload.dig("expectedHighWater", "pendingIntents") == 1

puts "SPEC-009 recovery/signal corpus passed: finite retry, pacing, supersession, terminal recovery, and four exact 20-fact coalescing windows are covered."
