#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "pathname"

directory = Pathname.new(ARGV.fetch(0) { abort "Usage: verify-contract-report.rb REPORT-DIRECTORY" }).expand_path
abort "error: report directory is missing: #{directory}" unless directory.directory?
manifest = directory.join("report-hashes.tsv")
abort "error: report hash manifest is missing: #{manifest}" unless manifest.file?

expected = manifest.each_line.to_h do |line|
  path, digest = line.chomp.split("\t", 2)
  abort "error: malformed report hash row: #{line.inspect}" unless path && digest&.match?(/\A[0-9a-f]{64}\z/)
  abort "error: unsafe report hash path: #{path.inspect}" if Pathname.new(path).absolute? || path.split("/").include?("..")
  [path, digest]
end
actual_paths = Dir[directory.join("**/*")].select { |path| File.file?(path) && File.basename(path) != "report-hashes.tsv" }.map do |path|
  Pathname.new(path).relative_path_from(directory).to_s
end.sort
abort "error: report file inventory differs from hash manifest" unless expected.keys.sort == actual_paths
expected.each do |path, digest|
  actual = Digest::SHA256.file(directory.join(path)).hexdigest
  abort "error: report hash mismatch: #{path}" unless actual == digest
end
puts "Contract report integrity passed: #{directory}"
