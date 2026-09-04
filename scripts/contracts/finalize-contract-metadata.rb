#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "pathname"

options = {}
OptionParser.new do |parser|
  %i[path run_id input_hash report_directory].each do |name|
    parser.on("--#{name.to_s.tr('_', '-')} VALUE") { |value| options[name] = value }
  end
end.parse!
abort "error: incomplete metadata finalization arguments" unless options.length == 4
path = Pathname.new(options[:path])
abort "error: metadata file is missing: #{path}" unless path.file?
replaced = %w[schema_version input_set_sha256 run_id report_directory]
lines = path.readlines.reject { |line| replaced.any? { |key| line.start_with?("#{key}=") } }
header = ["schema_version=2\n", "input_set_sha256=#{options[:input_hash]}\n",
          "run_id=#{options[:run_id]}\n", "report_directory=#{options[:report_directory]}\n"]
temporary = path.dirname.join(".#{path.basename}.tmp-#{Process.pid}")
temporary.binwrite((header + lines).join)
File.rename(temporary, path)
