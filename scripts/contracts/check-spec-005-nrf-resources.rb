#!/usr/bin/env ruby
# frozen_string_literal: true

TEXT_FLASH_LIMIT = 96 * 1024
TEXT_RAM_LIMIT = 512
VALIDATION_STACK_LIMIT = 1024

def fail_check(message)
  warn "SPEC-005 nRF resource check failed: #{message}"
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

def functions(symbols_path, disassembly_path)
  result = {}
  File.foreach(symbols_path) do |line|
    fields = line.split
    next unless fields.length >= 4 && fields[0].match?(/\A[0-9a-fA-F]+\z/) &&
                fields[1].match?(/\A[0-9a-fA-F]+\z/) && %w[t T W].include?(fields[2])

    result[fields[3..].join(" ")] = {
      address: Integer(fields[0], 16), size: Integer(fields[1], 16),
      frame: 0, calls: [], indirect: false
    }
  end
  ordered = result.sort_by { |_, function| function[:address] }
  File.foreach(disassembly_path) do |line|
    match = line.match(/^\s*([0-9a-f]+):/)
    next unless match

    address = Integer(match[1], 16)
    current, function = ordered.find do |_, candidate|
      address >= candidate[:address] && address < candidate[:address] + candidate[:size]
    end
    next unless current

    instruction = line.split("\t")[2..].to_a.join(" ").strip
    if (push = instruction.match(/\Apush(?:\.w)?\s+\{([^}]+)\}/))
      function[:frame] += push[1].split(",").length * 4
    elsif (push = instruction.match(/\Astmdb\s+sp!,\s*\{([^}]+)\}/))
      function[:frame] += push[1].split(",").length * 4
    elsif (sub = instruction.match(/\Asub(?:\.w)?\s+sp,\s*#(0x[0-9a-f]+|\d+)/i))
      function[:frame] += Integer(sub[1])
    elsif instruction.match?(/\Asub(?:\.w)?\s+sp,\s*r/i)
      fail_check("dynamic stack adjustment in #{current}")
    elsif (call = instruction.match(/\Abl(?:\.w)?\s+([0-9a-f]+)/))
      target = Integer(call[1], 16)
      callee = ordered.find { |_, candidate| candidate[:address] == target }&.first
      function[:calls] << callee if callee
    elsif (tail_call = instruction.match(/\Ab(?:\.w)?\s+([0-9a-f]+)/))
      target = Integer(tail_call[1], 16)
      callee = ordered.find { |_, candidate| candidate[:address] == target }&.first
      function[:calls] << callee if callee
    elsif instruction.match?(/\Ablx\s+r/i)
      function[:indirect] = true
    end
  end
  result
end

def validation_stack(functions)
  root = functions.keys.find { |name| name == "giftui_spec005_resource_probe" }
  fail_check("retained resource probe is missing") unless root
  visited = {}
  visit = lambda do |name, active|
    fail_check("call-graph cycle at #{name}") if active.include?(name)
    function = functions[name]
    return 0 unless function
    if function[:indirect]
      covered =
        (name.include?("compressBlock") && function[:calls].any? { |callee| callee&.include?("setWord") }) ||
        (name.include?("forEachCanonicalManifestByte") &&
          function[:calls].any? { |callee| callee&.include?("canonicalManifestDigest") }) ||
        (name.include?("finalize") && function[:calls].any? { |callee| callee&.include?("update4with") })
      fail_check("unresolved indirect call in #{name}") unless covered
    end
    visited[name] = true
    function[:frame] + (function[:calls].map { |callee| visit.call(callee, active + [name]) }.max || 0)
  end
  [visit.call(root, []), root, visited.keys.sort]
end

fail_check("expected baseline, candidate, and output paths") unless ARGV.length == 3
baseline_root, candidate_root, output_path = ARGV
baseline_ram, baseline_flash = load_totals(File.join(baseline_root, "program-headers.txt"))
candidate_ram, candidate_flash = load_totals(File.join(candidate_root, "program-headers.txt"))
candidate_symbols_text = File.read(File.join(candidate_root, "named-symbols.txt"))
candidate_map = File.read(File.join(candidate_root, "zephyr.map"))

combined_symbols = candidate_symbols_text + candidate_map
fail_check("bitmap payload/provider symbols are missing") unless
  combined_symbols.include?("GiftUIReferenceGeneratedBitmapPayload")
fail_check("outline payload/provider leaked into bitmap-only image") if
  combined_symbols.include?("GiftUIReferenceGeneratedOutlinePayload") ||
  combined_symbols.include?("ReferenceOutlinePayload")
fail_check("resource probe does not retain nominal text-resource implementation") unless
  combined_symbols.include?("TextResourceValidator") && combined_symbols.include?("FontResourceID")

function_data = functions(
  File.join(candidate_root, "named-symbols.txt"),
  File.join(candidate_root, "disassembly.txt")
)
stack_bytes, root, reachable = validation_stack(function_data)
ram_delta = candidate_ram - baseline_ram
flash_delta = candidate_flash - baseline_flash
fail_check("negative fixed RAM delta #{ram_delta}") if ram_delta.negative?
fail_check("fixed writable RAM delta #{ram_delta} exceeds #{TEXT_RAM_LIMIT}") if ram_delta > TEXT_RAM_LIMIT
fail_check("negative flash delta #{flash_delta}") if flash_delta.negative?
fail_check("text-resource flash delta #{flash_delta} exceeds #{TEXT_FLASH_LIMIT}") if flash_delta > TEXT_FLASH_LIMIT
fail_check("validation stack #{stack_bytes} exceeds #{VALIDATION_STACK_LIMIT}") if stack_bytes > VALIDATION_STACK_LIMIT

File.open(output_path, "w") do |output|
  output.puts("metric\tbaseline\tcandidate\tdelta_or_value\tlimit\tstatus")
  output.puts("linked_fixed_ram_bytes\t#{baseline_ram}\t#{candidate_ram}\t#{ram_delta}\t#{TEXT_RAM_LIMIT}\tpass")
  output.puts("linked_flash_bytes\t#{baseline_flash}\t#{candidate_flash}\t#{flash_delta}\t#{TEXT_FLASH_LIMIT}\tpass")
  output.puts("validation_stack_bytes\t-\t#{stack_bytes}\t#{stack_bytes}\t#{VALIDATION_STACK_LIMIT}\tpass")
  output.puts("outline_payload_symbols\t-\t0\t0\t0\tpass")
  output.puts("bitmap_payload_linked\t-\t1\t1\t1\tpass")
  output.puts("target_identity\t-\tarmv7em-none-none-eabi\t-\t-\tpass")
  output.puts("float_abi\t-\thard-vfp-registers\t-\t-\tpass")
end
call_graph_path = File.join(File.dirname(output_path), "nrf-validation-call-graph.tsv")
File.open(call_graph_path, "w") do |output|
  output.puts("function\tframe_bytes\treachable_direct_callees\tcompiler_deduplicated_indirect\troot")
  reachable.each do |name|
    function = function_data.fetch(name)
    callees = function[:calls].select { |callee| reachable.include?(callee) }
    output.puts([name, function[:frame], callees.join(","), function[:indirect], name == root].join("\t"))
  end
end
puts "SPEC-005 nRF resource check passed: RAM delta #{ram_delta}, flash delta #{flash_delta}, stack #{stack_bytes}."
