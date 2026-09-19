#!/usr/bin/env ruby
# frozen_string_literal: true

PROFILE_LIMITS = {
  "macos-dynamic" => { ram: 2_048, stack: 512, code: 32 * 1024 },
  "macos-static" => { ram: 512, stack: 384, code: 24 * 1024 },
  "raspberry-pi-armv6" => { ram: 512, stack: 384, code: 24 * 1024 },
  "nrf52840-embedded" => { ram: 320, stack: 256, code: 16 * 1024, instructions: 4_096 }
}.freeze

EXCLUDED_SECTIONS = /(?:debug|symtab|strtab|shstrtab|dynsym|dynstr|gnu\.hash|gnu\.version|comment|note|linkedit|\.ARM\.exidx|\.swift_modhash|swift5_)/i

def fail_check(message)
  warn "SPEC-003 resource evidence check failed: #{message}"
  exit 1
end

def integer(token)
  token.start_with?("0x") ? Integer(token, 16) : Integer(token, 10)
end

def macho_sections(path)
  segments = {}
  sections = []
  current_segment = nil
  current_section = nil
  in_section = false
  File.foreach(path) do |line|
    stripped = line.strip
    if stripped == "cmd LC_SEGMENT_64"
      current_segment = nil
      in_section = false
    elsif stripped == "Section"
      current_section = {}
      in_section = true
    elsif in_section && (match = stripped.match(/\Asectname (\S+)/))
      current_section[:name] = match[1]
    elsif in_section && (match = stripped.match(/\Asegname (\S+)/))
      current_section[:segment] = match[1]
    elsif in_section && (match = stripped.match(/\Asize (0x[0-9a-fA-F]+)/))
      current_section[:size] = Integer(match[1], 16)
      sections << current_section if current_section[:name] && current_section[:segment]
      in_section = false
    elsif !in_section && (match = stripped.match(/\Asegname (\S+)/))
      current_segment = match[1]
    elsif !in_section && current_segment && (match = stripped.match(/\Ainitprot (.+)/))
      protection = match[1]
      segments[current_segment] = current_segment != "__DATA_CONST" &&
                                  (protection.include?("write") ||
                                   (protection.match?(/\A0x/) && (Integer(protection, 16) & 0x2) != 0))
    end
  end
  sections.map { |section| section.merge(writable: segments.fetch(section[:segment], false)) }
end

def elf_sections(path)
  sections = []
  File.foreach(path) do |line|
    match = line.match(/^\s*\[\s*\d+\]\s+(\S+)\s+\S+\s+([0-9a-fA-F]+)\s+[0-9a-fA-F]+\s+([0-9a-fA-F]+)\s+\S+\s+([A-Z]*)/)
    next unless match

    flags = match[4]
    next unless flags.include?("A")

    sections << {
      segment: "ELF", name: match[1], address: Integer(match[2], 16),
      size: Integer(match[3], 16),
      writable: flags.include?("W")
    }
  end
  sections
end

def elf_writable_load_bytes(path)
  total = 0
  File.foreach(path) do |line|
    next unless line.lstrip.start_with?("LOAD ")

    fields = line.split
    flags = fields[6..-2].join
    total += Integer(fields[5], 16) if flags.include?("W") && !flags.include?("E")
  end
  total
end

def image_accounting(root)
  format = File.read(File.join(root, "format.txt")).strip
  sections = if format == "macho"
               macho_sections(File.join(root, "load-commands.txt"))
             elsif format == "elf"
               elf_sections(File.join(root, "sections.txt"))
             else
               fail_check("unknown image format #{format.inspect}")
             end
  included = sections.reject { |section| section[:name].match?(EXCLUDED_SECTIONS) }
  writable = if format == "elf"
               elf_writable_load_bytes(File.join(root, "program-headers.txt"))
             else
               included.select { |section| section[:writable] }.sum { |section| section[:size] }
             end
  code = included.reject { |section| section[:writable] }.sum { |section| section[:size] }
  [writable, code, included]
end

def verify_armv6_readonly_metadata(candidate_root, sections)
  names = %w[.giftui_rodata .giftui_data_rel_ro]
  readonly = sections.select { |section| names.include?(section[:name]) }
  missing = names - readonly.map { |section| section[:name] }
  fail_check("ARMv6 immutable metadata sections are missing: #{missing.join(', ')}") unless missing.empty?
  fail_check("ARMv6 immutable metadata section is writable") if readonly.any? { |section| section[:writable] }

  relocation_offsets = File.readlines(File.join(candidate_root, "relocations.txt")).each_with_object([]) do |line, offsets|
    match = line.match(/^\s*([0-9a-fA-F]+)\s+[0-9a-fA-F]+\s+R_ARM_/)
    offsets << Integer(match[1], 16) if match
  end
  readonly.each do |section|
    finish = section.fetch(:address) + section.fetch(:size)
    if relocation_offsets.any? { |offset| offset >= section.fetch(:address) && offset < finish }
      fail_check("ARMv6 dynamic relocation targets read-only section #{section[:name]}")
    end
  end
end

def disassembly_functions(path)
  functions = {}
  current = nil
  File.foreach(path) do |line|
    if (header = line.match(/^\s*([0-9a-fA-F]+)\s+<(.+)>:\s*$/))
      current = header[2]
      functions[current] ||= { address: Integer(header[1], 16), frame: 0, calls: [], indirect: false, dynamic_stack: false, instructions: 0 }
      next
    elsif (header = line.match(/^([^\s].*):\s*$/))
      current = header[1]
      functions[current] ||= { address: nil, frame: 0, calls: [], indirect: false, dynamic_stack: false, instructions: 0 }
      next
    end
    next unless current
    instruction_match = line.match(/^\s*[0-9a-fA-F]+:\s+(?:[0-9a-fA-F]{2,8}\s+)*(.*)$/)
    next unless instruction_match

    instruction = instruction_match[1].strip
    next if instruction.empty?
    function = functions.fetch(current)
    function[:address] ||= Integer(line.lstrip.split(":", 2).first, 16)
    function[:instructions] += 1
    case instruction
    when /\A(?:sub|sub\.w)\s+sp,\s*(?:sp,\s*)?#(0x[0-9a-fA-F]+|\d+)/
      function[:frame] += integer(Regexp.last_match(1))
    when /\A(?:stp|str)\s+.+\[sp,\s*#-(0x[0-9a-fA-F]+|\d+)\]!/
      function[:frame] += integer(Regexp.last_match(1))
    when /\A(?:push|stmdb\s+sp!)\s*\{([^}]+)\}/
      registers = Regexp.last_match(1).split(",").sum do |entry|
        range = entry.strip.match(/r(\d+)-r(\d+)/)
        range ? Integer(range[2]) - Integer(range[1]) + 1 : 1
      end
      function[:frame] += registers * 4
    when /\A(?:sub|sub\.w)\s+sp,\s*(?:sp,\s*)?r/
      function[:dynamic_stack] = true
    end
    if (call = instruction.match(/\A(?:bl|bl\.w|callq?)\s+(?:0x)?([0-9a-fA-F]+)\s+<([^>]+)>/))
      function[:calls] << [Integer(call[1], 16), call[2]]
    elsif (call = instruction.match(/\A(?:bl|bl\.w|callq?)\s+([^\s;]+)/))
      function[:calls] << [nil, call[1]]
    elsif instruction.match?(/\A(?:blr|blx)\s+/)
      function[:indirect] = true
    elsif (tail = instruction.match(/\A(?:b|b\.w)\s+(?:0x)?([0-9a-fA-F]+)\s+<([^>]+)>/))
      function[:calls] << [Integer(tail[1], 16), tail[2]]
    elsif (tail = instruction.match(/\A(?:b|b\.w)\s+([^\s;]+)/))
      function[:calls] << [nil, tail[1]]
    end
  end
  functions
end

def call_graph(candidate_root)
  functions = disassembly_functions(File.join(candidate_root, "disassembly.txt"))
  by_address = functions.each_with_object({}) do |(name, value), result|
    result[value[:address]] = name if value[:address]
  end
  ordered_addresses = by_address.keys.sort
  root = functions.keys.find { |name| name.delete_prefix("_") == "giftui_spec003_resource_entry" }
  root ||= functions.keys.find { |name| name.include?("giftuiSpec003ResourceEntry") }
  fail_check("production entry is missing from final-image disassembly") unless root
  reachable = {}
  visit = lambda do |name, active|
    fail_check("call-graph cycle at #{name}") if active.include?(name)
    function = functions.fetch(name)
    fail_check("dynamic stack adjustment in #{name}") if function[:dynamic_stack]
    fail_check("unresolved indirect call in #{name}") if function[:indirect]
    reachable[name] = true
    children = function[:calls].map do |address, label|
      if address
        containing_start = ordered_addresses.select { |candidate| candidate <= address }.max
        next [0, 0] if containing_start == function[:address] && address != function[:address]
      end
      next [0, 0] if label.start_with?("#{name}+")
      target = by_address[address] || functions.keys.find do |candidate|
        candidate == label || candidate == label.delete_prefix("_") ||
          candidate.delete_prefix("_") == label.delete_prefix("_")
      end
      fail_check("missing final-image body for #{label} called by #{name}") unless target
      visit.call(target, active + [name])
    end
    [function[:frame] + (children.map(&:first).max || 0), function[:instructions] + children.sum { |child| child[1] }]
  end
  stack, instructions = visit.call(root, [])
  [stack, instructions, root, functions, reachable.keys.sort]
end

fail_check("expected PROFILE BASELINE_ROOT CANDIDATE_ROOT OUTPUT") unless ARGV.length == 4
profile, baseline_root, candidate_root, output_path = ARGV
limits = PROFILE_LIMITS[profile] || fail_check("unknown profile #{profile}")
baseline_ram, baseline_code, baseline_sections = image_accounting(baseline_root)
candidate_ram, candidate_code, candidate_sections = image_accounting(candidate_root)
verify_armv6_readonly_metadata(candidate_root, candidate_sections) if profile == "raspberry-pi-armv6"
ram_delta = candidate_ram - baseline_ram
code_delta = candidate_code - baseline_code
stack, instructions, root, functions, reachable = call_graph(candidate_root)

libraries_baseline = File.read(File.join(baseline_root, "libraries.tsv"))
libraries_candidate = File.read(File.join(candidate_root, "libraries.tsv"))
fail_check("baseline and candidate shared-library sets differ") unless libraries_baseline == libraries_candidate
symbols = File.read(File.join(candidate_root, "named-symbols.txt"))
%w[giftuiSpec003Health giftuiSpec003DiagnosticBuffer giftuiSpec003DiagnosticCounters].each do |symbol|
  fail_check("named production symbol #{symbol} is missing") unless symbols.include?(symbol)
end
unless symbols.include?("giftui_spec003_resource_sink") || symbols.include?("giftuiSpec003ResourceSink")
  fail_check("named resource sink symbol is missing")
end
fail_check("baseline contains production health storage") if File.read(File.join(baseline_root, "named-symbols.txt")).include?("giftuiSpec003Health")
fail_check("writable RAM delta #{ram_delta} exceeds #{limits[:ram]}") if ram_delta > limits[:ram]
fail_check("linked code delta #{code_delta} exceeds #{limits[:code]}") if code_delta > limits[:code]
fail_check("stack bound #{stack} exceeds #{limits[:stack]}") if stack > limits[:stack]
if limits[:instructions] && instructions > limits[:instructions]
  fail_check("reachable instruction count #{instructions} exceeds #{limits[:instructions]}")
end

File.open(output_path, "w") do |output|
  output.puts("metric\tbaseline\tcandidate\tdelta_or_value\tlimit\tstatus")
  output.puts("writable_ram_bytes\t#{baseline_ram}\t#{candidate_ram}\t#{ram_delta}\t#{limits[:ram]}\tpass")
  output.puts("linked_code_bytes\t#{baseline_code}\t#{candidate_code}\t#{code_delta}\t#{limits[:code]}\tpass")
  output.puts("worst_stack_bytes\t-\t#{stack}\t#{stack}\t#{limits[:stack]}\tpass")
  output.puts("reachable_instructions\t-\t#{instructions}\t#{instructions}\t#{limits[:instructions] || '-'}\tpass")
end

sections_path = File.join(File.dirname(output_path), "sections.tsv")
File.open(sections_path, "w") do |output|
  output.puts("image\tclass\tsegment\tsection\tbytes")
  { "baseline" => baseline_sections, "candidate" => candidate_sections }.each do |image, sections|
    sections.sort_by { |section| [section[:segment], section[:name]] }.each do |section|
      output.puts([image, section[:writable] ? "writable" : "code-or-read-only", section[:segment], section[:name], section[:size]].join("\t"))
    end
  end
end

graph_path = File.join(File.dirname(output_path), "call-graph.tsv")
File.open(graph_path, "w") do |output|
  output.puts("function\tframe_bytes\treachable_direct_callees\tinstructions\troot")
  reachable.each do |name|
    function = functions.fetch(name)
    callees = function[:calls].map do |address, label|
      functions.find { |candidate_name, candidate| candidate[:address] == address || candidate_name == label }&.first
    end.compact
    output.puts([name, function[:frame], callees.sort.join(","), function[:instructions], name == root].join("\t"))
  end
end

puts "SPEC-003 #{profile} resource evidence passed: RAM delta #{ram_delta}, code delta #{code_delta}, stack #{stack}."
