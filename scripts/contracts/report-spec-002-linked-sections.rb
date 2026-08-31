#!/usr/bin/env ruby

require "open3"

def fail!(message)
  warn "error: #{message}"
  exit 1
end

format, inspector, baseline, candidate, baseline_map, candidate_map, output = ARGV
fail!("usage: report-spec-002-linked-sections.rb <macho|elf> <inspector> <baseline> <candidate> <baseline-map> <candidate-map> <output>") unless output

[inspector, baseline, candidate, baseline_map, candidate_map].each do |path|
  fail!("required input is missing or empty: #{path}") unless File.file?(path) && File.size(path).positive?
end

def inspect_sections(format, inspector, image)
  command = format == "macho" ? [inspector, "-m", "-l", image] : [inspector, "-h", image]
  stdout, stderr, status = Open3.capture3(*command)
  fail!("section inspection failed for #{image}: #{stderr}") unless status.success?

  totals = { "code" => 0, "read_only" => 0, "initialized" => 0, "zero_initialized" => 0 }
  if format == "macho"
    segment = nil
    stdout.each_line do |line|
      segment = Regexp.last_match(1) if line =~ /^Segment (\S+):/
      next unless line =~ /^\s+Section (\S+):\s+(\d+)\s+\(.*?(zerofill)?\)?\s*$/

      name = Regexp.last_match(1)
      bytes = Integer(Regexp.last_match(2), 10)
      zero_fill = !Regexp.last_match(3).nil? || line.include?("zerofill")
      category = if zero_fill
        "zero_initialized"
      elsif segment == "__TEXT" && name.match?(/\A__(?:text|stubs|auth_stubs|stub_helper|init|fini)\z/)
        "code"
      elsif segment == "__TEXT" || segment == "__DATA_CONST"
        "read_only"
      else
        "initialized"
      end
      totals[category] += bytes
    end
  elsif format == "elf"
    pending_gnu_section = nil
    stdout.each_line do |line|
      if line =~ /^\s*\d+\s+(\S+)\s+([0-9a-fA-F]+)\s+[0-9a-fA-F]+\s+[0-9a-fA-F]+\s+[0-9a-fA-F]+\s+2\*\*\d+/
        pending_gnu_section = [Regexp.last_match(1), Integer(Regexp.last_match(2), 16)]
        next
      end
      if pending_gnu_section && line =~ /^\s+(.+)$/
        name, bytes = pending_gnu_section
        pending_gnu_section = nil
        flags = Regexp.last_match(1).split(/,\s*/)
        next unless flags.include?("ALLOC")
        category = if flags.include?("CODE")
          "code"
        elsif !flags.include?("CONTENTS")
          "zero_initialized"
        elsif flags.include?("READONLY")
          "read_only"
        else
          "initialized"
        end
        totals[category] += bytes
        next
      end

      next unless line =~ /^\s*\d+\s+(\S*)\s+([0-9a-fA-F]+)\s+[0-9a-fA-F]+\s+(TEXT|DATA|BSS)\s*$/
      name = Regexp.last_match(1)
      bytes = Integer(Regexp.last_match(2), 16)
      type = Regexp.last_match(3)
      category = if type == "TEXT"
                   "code"
                 elsif type == "BSS"
                   "zero_initialized"
                 elsif name.match?(/(?:^|\.)data(?:$|\.)|^datas$|device_states|\.got|\.dynamic|\.init_array|\.fini_array/)
                   "initialized"
                 else
                   "read_only"
                 end
      totals[category] += bytes
    end
  else
    fail!("unknown image format: #{format}")
  end
  [totals, stdout]
end

baseline_totals, baseline_raw = inspect_sections(format, inspector, baseline)
candidate_totals, candidate_raw = inspect_sections(format, inspector, candidate)
File.write("#{output}.baseline-sections.txt", baseline_raw)
File.write("#{output}.candidate-sections.txt", candidate_raw)

File.open(output, "w") do |file|
  file.puts "category\tbaseline_bytes\tcandidate_bytes\tdelta_bytes"
  %w[code read_only initialized zero_initialized].each do |category|
    before = baseline_totals.fetch(category)
    after = candidate_totals.fetch(category)
    file.puts [category, before, after, after - before].join("\t")
  end
  before = File.size(baseline)
  after = File.size(candidate)
  file.puts ["file_size", before, after, after - before].join("\t")
end
