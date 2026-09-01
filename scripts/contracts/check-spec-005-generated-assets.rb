#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "pathname"

root = Pathname.new(File.expand_path("../..", __dir__))
inventory = root.join("Tests/ContractFixtures/SPEC005/generated-assets.tsv")

def fail_check(message)
  warn "SPEC-005 generated asset check failed: #{message}"
  exit 1
end

rows = inventory.each_line.with_index(1).each_with_object([]) do |(line, line_number), selected|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("line #{line_number} must have path and SHA-256") unless fields.length == 2
  selected << fields
end

paths = rows.map(&:first)
fail_check("generated asset paths must be unique") unless paths.uniq.length == paths.length
rows.each do |relative, expected_hash|
  path = Pathname.new(relative)
  fail_check("generated asset path must be repository-relative: #{relative}") if path.absolute? || relative.include?("..")
  fail_check("invalid generated asset SHA-256 for #{relative}") unless expected_hash.match?(/\A[0-9a-f]{64}\z/)
  absolute = root.join(path)
  fail_check("registered generated asset is missing: #{relative}") unless absolute.file?
  actual_hash = Digest::SHA256.file(absolute).hexdigest
  fail_check("stale generated asset #{relative}: expected #{expected_hash}, got #{actual_hash}") unless actual_hash == expected_hash
end

puts "SPEC-005 generated asset check passed: #{rows.length} registered assets."
