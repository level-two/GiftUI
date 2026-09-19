#!/usr/bin/env ruby

require "fileutils"
require "pathname"

ROOT = Pathname.new(__dir__).join("../..").expand_path
REPORT_ROOT = ROOT.join(".build/spec-015")
PROFILES = %w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded].freeze

def fail_check(message)
  warn "SPEC-015 preset comparison failed: #{message}"
  exit 1
end

def fields(path)
  line = path.read.lines.find { |candidate| !candidate.start_with?("#") && !candidate.strip.empty? }
  fail_check("missing normalized row in #{path}") unless line
  line.strip.split("\t").to_h do |field|
    key, value = field.split("=", 2)
    fail_check("malformed field #{field.inspect} in #{path}") unless key && value
    [key, value]
  end
end

def assignments(path)
  path.read.lines.each_with_object({}) do |line, result|
    key, value = line.strip.split("=", 2)
    result[key] = value if key && value
  end
end

semantic = PROFILES.to_h do |profile|
  path = REPORT_ROOT.join(profile, "semantic.tsv")
  fail_check("missing #{path}; run the four SPEC-015 profiles first") unless path.file?
  [profile, fields(path)]
end

common = %w[
  semantic_checksum actions compact_facts canvases live_points plan_points
  graph_roles semantic_nodes render_semantic_scopes layout_scopes traversal_depth
  text_lines glyphs ordinary_operations drawing_operations input_events completion_facts
  workload_duration_ms workload_event_rate workload_events workload_frame_rate workload_frames
  workload_fact_high_water workload_checksum
]
common.each do |field|
  values = semantic.values.map { |row| row.fetch(field, :missing) }.uniq
  fail_check("#{field} differs across presets: #{values.inspect}") unless values.length == 1
end

expected = {
  "macos-dynamic" => %w[dynamic 320x240 240 1280 307200 30416],
  "macos-static" => %w[static 320x240 240 1280 307200 28016],
  "raspberry-pi-armv6" => %w[dynamic 240x240 16 480 7680 30416],
  "nrf52840-embedded" => %w[static 480x320 4 960 3840 28016],
}
physical_fields = %w[profile extent region_height bytes_per_row raster_bytes profile_storage_bytes]
expected.each do |profile, values|
  physical_fields.zip(values).each do |field, value|
    fail_check("#{profile} #{field} is #{semantic[profile][field].inspect}, expected #{value}") unless semantic[profile][field] == value
  end
  fail_check("#{profile} did not complete") unless semantic[profile]["status"] == "complete"
  fail_check("#{profile} resolved after startup") unless semantic[profile]["resolver_calls"] == "1"
end

nrf_memory = assignments(REPORT_ROOT.join("nrf52840-embedded", "memory-summary.txt"))
flash = Integer(nrf_memory.fetch("FLASH_BYTES"), 10)
ram = Integer(nrf_memory.fetch("RAM_BYTES"), 10)
fail_check("nRF flash exceeds limit") unless flash <= Integer(nrf_memory.fetch("FLASH_LIMIT_BYTES"), 10)
fail_check("nRF RAM exceeds approved application limit") unless ram <= Integer(nrf_memory.fetch("RAM_LIMIT_BYTES"), 10)

nrf_attributes = REPORT_ROOT.join("nrf52840-embedded", "arm-attributes.txt").read
fail_check("nRF CPU ABI differs") unless nrf_attributes.include?("Tag_CPU_arch: v7E-M")
fail_check("nRF hard-float ABI differs") unless nrf_attributes.include?("Tag_ABI_VFP_args: VFP registers")

nrf_symbols = REPORT_ROOT.join("nrf52840-embedded", "symbols.txt").read
forbidden = %w[malloc calloc realloc aligned_alloc k_malloc k_calloc k_realloc swift_task_create swift_allocObject objc_msgSend]
symbol_names = nrf_symbols.lines.map { |line| line.split.last }
present = forbidden & symbol_names
fail_check("nRF prohibited symbols present: #{present.join(', ')}") unless present.empty?
runtime_symbols = symbol_names.compact.grep(/(?:swift.*(?:reflect|task)|^objc|^pthread)/i)
fail_check("nRF prohibited runtime symbols present: #{runtime_symbols.join(', ')}") unless runtime_symbols.empty?

nrf_config = ROOT.join(".build/nrf52840/signal-analyzer-static/zephyr/.config").read
%w[CONFIG_HEAP_MEM_POOL_SIZE=0 CONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0].each do |setting|
  fail_check("nRF configuration lacks #{setting}") unless nrf_config.lines.map(&:strip).include?(setting)
end
fail_check("nRF multithreading is enabled") unless nrf_config.include?("# CONFIG_MULTITHREADING is not set")

allocation_evidence = [
  ROOT.join("Tests/ContractFixtures/SPEC004/Evidence/milestone-5/static-path-and-semantic-equivalence.md"),
  ROOT.join("Tests/ContractFixtures/SPEC008/Evidence/milestone-8/nrf-render-inspection.md"),
  ROOT.join("Tests/ContractFixtures/SPEC013/Evidence/milestone-7/target-inspection.md"),
]
missing_allocation_evidence = allocation_evidence.reject(&:file?)
fail_check("static allocation evidence is missing: #{missing_allocation_evidence.join(', ')}") unless missing_allocation_evidence.empty?

capability_evidence = ROOT.join("Tests/ContractFixtures/SPEC004/Evidence/milestone-5/nrf-resource-boundary.md").read
%w[+252 +4,768 202 3,840 80].each do |measurement|
  fail_check("nRF capability evidence lacks #{measurement}") unless capability_evidence.include?(measurement)
end

output_dir = REPORT_ROOT.join("comparison")
FileUtils.mkdir_p(output_dir)
output = output_dir.join("report.tsv")
output.write(<<~TSV)
  dimension\tmacos-dynamic\tmacos-static\traspberry-pi-armv6\tnrf52840-embedded\tresult
  semantics\t#{semantic["macos-dynamic"]["semantic_checksum"]}\t#{semantic["macos-static"]["semantic_checksum"]}\t#{semantic["raspberry-pi-armv6"]["semantic_checksum"]}\t#{semantic["nrf52840-embedded"]["semantic_checksum"]}\tequal
  profile-storage-bytes\t30416\t28016\t30416\t28016\tprofile-bounded
  raster-staging-bytes\t307200\t307200\t7680\t3840\texact
  resolver-calls-startup\t1\t1\t1\t1\texact
  resolver-calls-post-startup\t0\t0\t0\t0\texact
  abi\tnative-macos\tnative-macos\tarmv6-hard-float\tarmv7e-m-vfp-hard-float\tverified
  linked-ram-bytes\tnot-collected\tnot-collected\tnot-collected\t#{ram}\twithin-limit
  linked-flash-bytes\tnot-applicable\tnot-applicable\tnot-collected\t#{flash}\twithin-limit
  nrf-named-application-storage\tnot-applicable\tnot-applicable\tnot-applicable\t147248\texact
  static-heap-allocation\tnot-applicable\tcomposed-zero-allocation-owner-evidence\tnot-applicable\tzero-heap-linked-image\tverified
  connected-execution\thost\thost\tnot-collected\tnot-collected\tproperly-labeled
TSV

puts "SPEC-015 four-preset comparison passed: #{output}"
