#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "optparse"
require "pathname"

options = {}
OptionParser.new do |parser|
  parser.banner = "Usage: publish-contract-report.rb --report-root PATH --staging PATH --destination PATH --latest PATH --run-id ID"
  %i[report_root staging destination latest run_id].each do |name|
    parser.on("--#{name.to_s.tr('_', '-')} VALUE") { |value| options[name] = value }
  end
end.parse!
abort "error: missing report publication option" unless options.values.all? && options.length == 5

report_root = Pathname.new(options[:report_root]).expand_path
staging = Pathname.new(options[:staging]).expand_path
destination = Pathname.new(options[:destination]).expand_path
latest = Pathname.new(options[:latest]).expand_path
unless staging.dirname == report_root && staging.basename.to_s.start_with?(".tmp-")
  abort "error: staging directory must be a .tmp-* child of report root"
end
abort "error: staging report is missing" unless staging.directory?
abort "error: destination must be below report root" unless destination.to_s.start_with?(report_root.to_s + File::SEPARATOR)
abort "error: latest pointer must be below report root" unless latest.to_s.start_with?(report_root.to_s + File::SEPARATOR)

def hashes(directory)
  Dir[directory.join("**/*")].select { |path| File.file?(path) && File.basename(path) != "report-hashes.tsv" }.sort.map do |path|
    file = Pathname.new(path)
    "#{file.relative_path_from(directory)}\t#{Digest::SHA256.file(file).hexdigest}\n"
  end.join
end

staged_hashes = hashes(staging)
abort "error: staged report contains no files" if staged_hashes.empty?
staging.join("report-hashes.tsv").binwrite(staged_hashes)
destination.dirname.mkpath
if destination.exist?
  existing_manifest = destination.join("report-hashes.tsv")
  existing_hashes = hashes(destination)
  unless existing_manifest.file? && existing_manifest.binread == existing_hashes && existing_hashes == staged_hashes
    abort "error: refusing to overwrite different existing report: #{destination}"
  end
  FileUtils.remove_entry(staging)
  disposition = "idempotent"
else
  File.rename(staging, destination)
  disposition = "published"
end

temporary_pointer = latest.dirname.join(".#{latest.basename}.tmp-#{Process.pid}")
temporary_pointer.write("#{options[:run_id]}\n")
File.rename(temporary_pointer, latest)
puts "#{disposition}=#{destination}"
