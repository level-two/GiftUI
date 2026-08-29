#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

root = Pathname.new(File.expand_path("../..", __dir__))
registry = root.join("scripts/contracts/driver-registry.tsv")
allowed_profiles = %w[
  macos-dynamic
  macos-static
  raspberry-pi-armv6
  nrf52840-embedded
].freeze

def fail_check(message)
  warn "contract driver registry check failed: #{message}"
  exit 1
end

rows = []
registry.each_line.with_index(1) do |line, line_number|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("line #{line_number} must have three tab-separated fields") unless fields.length == 3
  rows << fields
end

fail_check("registry must not be empty") if rows.empty?
ids = rows.map(&:first)
paths = rows.map { |row| row[1] }
fail_check("driver identifiers must be unique") unless ids.uniq.length == ids.length
fail_check("driver paths must be unique") unless paths.uniq.length == paths.length

rows.each do |id, path, profile_list|
  fail_check("invalid driver identifier #{id.inspect}") unless id.match?(/\A[A-Z]+-[0-9]{3}\z/)
  fail_check("driver path must be repository-relative") if Pathname.new(path).absolute? || path.include?("..")
  driver = root.join(path)
  fail_check("#{id} driver is missing: #{path}") unless driver.file?
  fail_check("#{id} driver is not executable: #{path}") unless driver.executable?

  profiles = profile_list.split(",", -1)
  fail_check("#{id} profiles must be unique") unless profiles.uniq.length == profiles.length
  unknown = profiles - allowed_profiles
  fail_check("#{id} has unknown profiles #{unknown.inspect}") unless unknown.empty?
  fail_check("#{id} must register at least one profile") if profiles.empty?
end

puts "Contract driver registry check passed: #{rows.length} driver(s)."
