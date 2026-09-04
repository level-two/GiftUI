#!/usr/bin/env ruby
# frozen_string_literal: true

unless ARGV.length == 2
  warn "usage: check-spec-006-wrapper-sil.rb <input.sil> <output.txt>"
  exit 2
end

input_path, output_path = ARGV
sil = File.read(input_path)
forbidden = {
  "heap_allocation" => /\b(?:alloc_ref|alloc_box|swift_allocObject)\b/,
  "existential" => /\b(?:init_existential|open_existential)\b/,
  "reflection" => /\b(?:Mirror|typeByName|_typeByName)\b/,
  "runtime_discovery" => /\b(?:dlsym|swift_getTypeByMangledName)\b/
}

counts = forbidden.transform_values { |pattern| sil.scan(pattern).length }
File.open(output_path, "w") do |file|
  file.puts "schema_version=1"
  counts.each { |name, count| file.puts "#{name}_instruction_count=#{count}" }
end

violations = counts.select { |_name, count| count != 0 }
if violations.empty?
  puts "SPEC-006 wrapper SIL check passed"
  exit 0
end

violations.each { |name, count| warn "#{name} instruction count: #{count}" }
exit 1
