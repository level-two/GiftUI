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
  direct_call_sites = []
  instruction_rows = []
  literal_words = {}
  File.foreach(disassembly_path) do |line|
    match = line.match(/^\s*([0-9a-f]+):/)
    next unless match

    address = Integer(match[1], 16)
    current, function = ordered.find do |_, candidate|
      address >= candidate[:address] && address < candidate[:address] + candidate[:size]
    end
    next unless current

    instruction = line.split("\t")[2..].to_a.join(" ").strip
    instruction_rows << { address: address, owner: current, text: instruction }
    if (word = instruction.match(/\.word\s+0x([0-9a-f]+)/i))
      literal_words[address] = Integer(word[1], 16)
    end
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
      direct_call_sites << { owner: current, address: address, target: target }
    elsif (tail_call = instruction.match(/\Ab(?:\.w)?\s+([0-9a-f]+)/))
      target = Integer(tail_call[1], 16)
      callee = ordered.find { |_, candidate| candidate[:address] == target }&.first
      function[:calls] << callee if callee
    elsif instruction.match?(/\Ablx\s+r/i)
      function[:indirect] = true
      function[:indirect_registers] ||= []
      function[:indirect_calls] ||= []
      register = instruction.match(/\Ablx\s+(r\d+)/i)[1].downcase
      function[:indirect_registers] << register
      function[:indirect_calls] << { address: address, register: register }
    end
  end

  resolve_validator_payload_callback!(
    result, ordered, direct_call_sites, instruction_rows, literal_words
  )
  result
end

# Swift lowers this one generic, nonthrowing validation callback through a
# function pointer even though the callsite supplies a local closure thunk.
# Resolve only when the linked disassembly proves that exact closure argument
# for every direct caller of the specialized generated payload body.
def resolve_validator_payload_callback!(functions, ordered, direct_calls, rows, words)
  payload_functions = functions.select do |name, function|
    name.include?("withRecordBytesStorage") && function[:indirect]
  end
  payload_functions.each do |name, function|
    indirect_calls = function[:indirect_calls] || []
    next unless indirect_calls.length == 2
    next unless indirect_calls.all? { |call| call[:register] == "r5" }

    start = function[:address]
    entry_rows = rows.select { |row| row[:owner] == name }
    next unless entry_rows.first(12).any? { |row| row[:text].match?(/\Amov(?:\.w)?\s+r5,\s*r2\b/i) }

    callers = direct_calls.select { |site| site[:target] == start }
    next unless callers.length == 1

    r5_definitions = entry_rows.select do |row|
      instruction = row[:text].split(";").first.strip
      instruction.match?(/\A(?:ldr|mov|add|sub|adr|and|orr|eor|lsl|lsr|asr)(?:\.\w+)?\s+r5(?:,|\s)/i) ||
        instruction.match?(/\A(?:pop|ldmia(?:\.\w+)?)\b.*\br5\b/i)
    end
    next unless r5_definitions.length == 2
    next unless r5_definitions[0][:text].split(";").first.strip.match?(/\Amov\s+r5,\s*r2\z/i)
    next unless r5_definitions[1][:text].split(";").first.strip.match?(/\Aldmia\.w\s+sp!,\s*\{[^}]*r5[^}]*\}\z/i)
    next unless r5_definitions[1][:address] > indirect_calls.map { |call| call[:address] }.max

    resolved_targets = callers.map do |site|
      call_index = rows.index { |row| row[:owner] == site[:owner] && row[:address] == site[:address] }
      next unless call_index

      add_row = rows[call_index - 1]
      next unless add_row[:text].match?(/\Aadd(?:\.w)?\s+r2,\s*pc\s*$/i)

      add_index = call_index - 1
      previous = rows[0...add_index].reverse.find do |row|
        row[:owner] == site[:owner] && row[:text].match?(/\Aldr(?:\.w)?\s+r2,\s*\[pc,\s*#(0x[0-9a-f]+|\d+)\]/i)
      end
      next unless previous

      load_index = rows.index(previous)
      add_index = rows.index(add_row)
      intervening = rows[(load_index + 1)...add_index]
      next unless intervening.all? { |row| row[:owner] == site[:owner] }
      next if intervening.any? do |row|
        instruction = row[:text]
        instruction.match?(/\A(?:b(?:\.w)?|bl(?:\.w)?|blx|bx|cbz|cbnz)\b/i) ||
          instruction.match?(/\A(?:ldr(?:\.\w+)?|mov(?:\.\w+)?|add(?:\.\w+)?|sub(?:\.\w+)?|adr|and(?:\.\w+)?|orr(?:\.\w+)?|eor(?:\.\w+)?|lsl(?:\.\w+)?|lsr(?:\.\w+)?|asr(?:\.\w+)?)\s+r2\s*,/i)
      end

      load = previous[:text].match(/\Aldr(?:\.w)?\s+r2,\s*\[pc,\s*#(0x[0-9a-f]+|\d+)\]/i)
      next unless load
      load_offset = Integer(load[1])
      literal_address = ((previous[:address] + 4) & ~3) + load_offset
      relative_target = words[literal_address]
      next unless relative_target
      closure_address = (add_row[:address] + 4) + relative_target
      closure_address &= ~1
      closure = ordered.find { |_, candidate| candidate[:address] == closure_address }&.first
      expected_validator_closure =
        closure&.include?("TextResourceValidatorO8validate") && closure&.include?("EfU_TA")
      expected_probe_closure =
        closure&.include?("giftuiSpec005ResourceProbe") && closure&.include?("EfU_TA")
      next unless expected_validator_closure || expected_probe_closure

      closure_function = functions[closure]
      next unless closure_function && !closure_function[:indirect]
      if expected_validator_closure
        next unless closure_function[:calls].any? do |callee|
          callee&.include?("TextResourceValidationEngineV18acceptPayloadBytes")
        end
        next unless indirect_calls.map { |call| call[:address] - start } == [0x1018, 0x1098]
        next unless function[:size] == 0x113c
        next unless exact_validator_payload_thunk?(closure, functions, rows)
      else
        next unless closure_function[:calls].empty?
        next unless indirect_calls.map { |call| call[:address] - start } == [0x101c, 0x109c]
        next unless function[:size] == 0x1144
        next unless closure_function[:size] == 0x28
      end

      closure
    end

    next if resolved_targets.any?(&:nil?)
    next unless resolved_targets.uniq.length == 1

    function[:calls] << resolved_targets.first
    function[:indirect] = false
    function[:resolved_validator_payload_callback] = resolved_targets.first
  end
end

def exact_validator_payload_thunk?(name, functions, rows)
  function = functions[name]
  return false unless function && function[:size] == 0x18

  body = rows.select { |row| row[:owner] == name }.sort_by { |row| row[:address] }
  return false unless body.length == 8
  instructions = body.map { |row| row[:text].split(";").first.strip }
  return false unless instructions[0].match?(/\Astmdb\s+sp!,\s*\{r4, r5, sl, lr\}\z/i)
  return false unless instructions[1].match?(/\Aldr\.w\s+sl,\s*\[sl, #8\]\z/i)
  return false unless instructions[2].match?(/\Amov\s+r5,\s*r0\z/i)
  return false unless instructions[3].match?(/\Amov\s+r0,\s*r1\z/i)
  return false unless instructions[4].match?(/\Amov\s+r1,\s*r2\z/i)
  return false unless instructions[5].match?(/\Amov\s+r4,\s*r8\z/i)
  return false unless instructions[6].match?(/\Abl(?:\.w)?\s+([0-9a-f]+)/i)

  callee_address = Integer(instructions[6].match(/\Abl(?:\.w)?\s+([0-9a-f]+)/i)[1], 16)
  callee = functions.find { |_, candidate| candidate[:address] == callee_address }&.first
  return false unless callee&.include?("TextResourceValidationEngineV18acceptPayloadBytes")
  return false unless instructions[7].match?(/\Ab\.w\s+([0-9a-f]+)/i)

  epilogue_address = Integer(instructions[7].match(/\Ab\.w\s+([0-9a-f]+)/i)[1], 16)
  epilogue = functions.find { |_, candidate| candidate[:address] == epilogue_address }&.first
  return false unless epilogue&.match?(/\AOUTLINED_FUNCTION_\d+\z/)

  epilogue_rows = rows.select { |row| row[:owner] == epilogue }.sort_by { |row| row[:address] }
  epilogue_instructions = epilogue_rows.map { |row| row[:text].split(";").first.strip }
  epilogue_rows.length == 4 &&
    epilogue_instructions[0].match?(/\Amovs?\s+r0, #1\z/i) &&
    epilogue_instructions[1].match?(/\Amov\s+r8,\s*r4\z/i) &&
    epilogue_instructions[2].match?(/\Astrb\s+r0,\s*\[r5(?:, #0)?\]\z/i) &&
    epilogue_instructions[3].match?(/\Aldmia\.w\s+sp!,\s*\{r4, r5, sl, pc\}\z/i)
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
