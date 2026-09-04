#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "optparse"
require "pathname"

options = {}
OptionParser.new do |parser|
  parser.banner = "Usage: report-input-identity.rb --root PATH --revision HEX --inventory PATH"
  parser.on("--root PATH") { |value| options[:root] = value }
  parser.on("--revision HEX") { |value| options[:revision] = value }
  parser.on("--inventory PATH") { |value| options[:inventory] = value }
end.parse!
abort "error: --root, --revision, and --inventory are required" unless options.values_at(:root, :revision, :inventory).all?
abort "error: revision must be a full hexadecimal Git identity" unless options[:revision].match?(/\A[0-9a-f]{40,64}\z/)

root = Pathname.new(options[:root]).expand_path
inventory = Pathname.new(options[:inventory]).expand_path
paths = $stdin.each_line.map(&:strip).reject(&:empty?).map do |value|
  path = Pathname.new(value)
  path = root.join(path) unless path.absolute?
  path = path.cleanpath.expand_path
  abort "error: input is outside repository root: #{value}" unless path.to_s.start_with?(root.to_s + File::SEPARATOR)
  abort "error: declared input is not a file: #{value}" unless path.file?
  path
end.uniq.sort_by { |path| path.relative_path_from(root).to_s }
abort "error: input inventory is empty" if paths.empty?

stream = paths.map do |path|
  relative = path.relative_path_from(root).to_s
  "#{relative}\t#{Digest::SHA256.file(path).hexdigest}\n"
end.join
inventory.dirname.mkpath
inventory.binwrite(stream)
digest = Digest::SHA256.hexdigest(stream)
puts "input_set_sha256=#{digest}"
puts "run_id=#{options[:revision]}-#{digest[0, 16]}"
