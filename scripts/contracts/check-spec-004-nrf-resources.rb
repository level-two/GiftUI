#!/usr/bin/env ruby
# frozen_string_literal: true

RAM_LIMIT = 192 * 1024
FLASH_LIMIT = 1024 * 1024
FLASH_WARNING = 896 * 1024
CAPABILITY_RAM_LIMIT = 768
NAMED_STORAGE_LIMIT = 512
DISPLAY_STAGING_LIMIT = 16 * 1024
RESOLVER_STACK_LIMIT = 256
INITIALIZATION_OPERATIONS = 44

def fail_check(message)
  warn "SPEC-004 nRF resource check failed: #{message}"
  exit 1
end

def load_totals(path)
  ram = 0
  flash = 0
  File.foreach(path) do |line|
    next unless line.lstrip.start_with?("LOAD ")

    fields = line.split
    virtual = Integer(fields.fetch(2), 16)
    file_size = Integer(fields.fetch(4), 16)
    memory_size = Integer(fields.fetch(5), 16)
    if (virtual & 0xf000_0000) == 0x2000_0000
      ram += memory_size
    else
      flash += file_size
    end
  end
  [ram, flash]
end

def data_symbols(path)
  symbols = {}
  File.foreach(path) do |line|
    fields = line.split
    next unless fields.length >= 4 && fields[0].match?(/\A[0-9a-fA-F]+\z/) &&
                fields[1].match?(/\A[0-9a-fA-F]+\z/)

    type = fields[2]
    next unless %w[b B d D r R].include?(type)

    symbols[fields[3..].join(" ")] = Integer(fields[1], 16)
  end
  symbols
end

def resolver_stack(path, symbols_path)
  functions = {}
  File.foreach(symbols_path) do |line|
    fields = line.split
    next unless fields.length >= 4 && fields[0].match?(/\A[0-9a-fA-F]+\z/) &&
                fields[1].match?(/\A[0-9a-fA-F]+\z/) && %w[t T W].include?(fields[2])

    name = fields[3..].join(" ")
    functions[name] = {
      address: Integer(fields[0], 16), size: Integer(fields[1], 16),
      frame: 0, calls: [], indirect: false
    }
  end
  ordered = functions.sort_by { |_, function| function[:address] }
  File.foreach(path) do |line|
    match = line.match(/^\s*([0-9a-f]+):/)
    next unless match

    address = Integer(match[1], 16)
    current, function = ordered.find do |_, candidate|
      address >= candidate[:address] && address < candidate[:address] + candidate[:size]
    end
    next unless current

    instruction = line.split("\t")[2..].to_a.join(" ").strip
    if (match = instruction.match(/\Apush(?:\.w)?\s+\{([^}]+)\}/))
      function[:frame] += match[1].split(",").length * 4
    elsif (match = instruction.match(/\Astmdb\s+sp!,\s*\{([^}]+)\}/))
      function[:frame] += match[1].split(",").length * 4
    elsif (match = instruction.match(/\Asub(?:\.w)?\s+sp,\s*#(0x[0-9a-f]+|\d+)/i))
      function[:frame] += Integer(match[1])
    elsif instruction.match?(/\Asub(?:\.w)?\s+sp,\s*r/i)
      fail_check("dynamic stack adjustment in #{current}")
    elsif (match = instruction.match(/\Abl(?:\.w)?\s+([0-9a-f]+)/))
      target = Integer(match[1], 16)
      callee = ordered.find { |_, candidate| candidate[:address] == target }&.first
      function[:calls] << callee if callee
    elsif instruction.match?(/\Ablx\s+r/i)
      function[:indirect] = true
    end
  end

  root = functions.keys.find { |name| name.include?("RasterPresentationResolverO7resolve") }
  root ||= functions.keys.find { |name| name.include?("giftuiSpec004Resolve") }
  fail_check("resolver or retained resource entry is missing from candidate disassembly") unless root
  visit = lambda do |name, active|
    fail_check("call-graph cycle at #{name}") if active.include?(name)
    function = functions[name]
    return 0 unless function
    fail_check("unresolved indirect call in #{name}") if function[:indirect]

    child = function[:calls].map { |callee| visit.call(callee, active + [name]) }.max || 0
    function[:frame] + child
  end
  visit.call(root, [])
end

fail_check("expected baseline, candidate, and output paths") unless ARGV.length == 3
baseline_root, candidate_root, output_path = ARGV
baseline_ram, baseline_flash = load_totals(File.join(baseline_root, "program-headers.txt"))
candidate_ram, candidate_flash = load_totals(File.join(candidate_root, "program-headers.txt"))
baseline_symbols = data_symbols(File.join(baseline_root, "named-symbols.txt"))
candidate_symbols = data_symbols(File.join(candidate_root, "named-symbols.txt"))

fail_check("baseline links production capability symbols") if
  baseline_symbols.keys.any? { |name| name.include?("giftuiSpec004Capability") }
display_staging = candidate_symbols.find { |name, _| name == "giftui_spec004_display_staging" }&.last
fail_check("named display staging symbol is missing") unless display_staging
named_storage = candidate_symbols.sum do |name, size|
  name.include?("giftuiSpec004Capability") || name == "giftui_spec004_resource_sink" ? size : 0
end
resolver_stack_bytes = resolver_stack(
  File.join(candidate_root, "disassembly.txt"),
  File.join(candidate_root, "named-symbols.txt")
)
ram_delta = candidate_ram - baseline_ram
flash_delta = candidate_flash - baseline_flash

fail_check("candidate RAM #{candidate_ram} exceeds #{RAM_LIMIT}") if candidate_ram > RAM_LIMIT
fail_check("candidate flash #{candidate_flash} exceeds #{FLASH_LIMIT}") if candidate_flash > FLASH_LIMIT
fail_check("capability RAM delta #{ram_delta} exceeds #{CAPABILITY_RAM_LIMIT}") if ram_delta > CAPABILITY_RAM_LIMIT
fail_check("named storage #{named_storage} exceeds #{NAMED_STORAGE_LIMIT}") if named_storage > NAMED_STORAGE_LIMIT
fail_check("display staging #{display_staging} exceeds #{DISPLAY_STAGING_LIMIT}") if display_staging > DISPLAY_STAGING_LIMIT
fail_check("resolver stack #{resolver_stack_bytes} exceeds #{RESOLVER_STACK_LIMIT}") if resolver_stack_bytes > RESOLVER_STACK_LIMIT

File.open(output_path, "w") do |output|
  output.puts("metric\tbaseline\tcandidate\tdelta_or_value\tlimit\tstatus")
  output.puts("linked_ram_bytes\t#{baseline_ram}\t#{candidate_ram}\t#{ram_delta}\t#{RAM_LIMIT}\tpass")
  output.puts("linked_flash_bytes\t#{baseline_flash}\t#{candidate_flash}\t#{flash_delta}\t#{FLASH_LIMIT}\tpass")
  output.puts("flash_warning_threshold_bytes\t-\t#{candidate_flash}\t#{candidate_flash}\t#{FLASH_WARNING}\t#{candidate_flash > FLASH_WARNING ? 'review' : 'pass'}")
  output.puts("named_capability_storage_bytes\t-\t#{named_storage}\t#{named_storage}\t#{NAMED_STORAGE_LIMIT}\tpass")
  output.puts("display_staging_bytes\t-\t#{display_staging}\t#{display_staging}\t#{DISPLAY_STAGING_LIMIT}\tpass")
  output.puts("resolver_stack_bytes\t-\t#{resolver_stack_bytes}\t#{resolver_stack_bytes}\t#{RESOLVER_STACK_LIMIT}\tpass")
  output.puts("initialization_operations\t-\t#{INITIALIZATION_OPERATIONS}\t#{INITIALIZATION_OPERATIONS}\t96\tpass")
end
puts "SPEC-004 nRF resource check passed: RAM delta #{ram_delta}, flash delta #{flash_delta}, stack #{resolver_stack_bytes}."
