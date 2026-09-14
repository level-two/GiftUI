#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

root = Pathname.new(ARGV.fetch(0) do
  abort "Usage: check-spec-013-target-evidence.rb EVIDENCE-DIRECTORY"
end).expand_path

def fail_check(message)
  warn "SPEC-013 target evidence check failed: #{message}"
  exit 1
end

mac = root.join("macos-static")
nrf = root.join("nrf52840-embedded")
pi = root.join("raspberry-pi-armv6")
[mac, nrf, pi].each do |directory|
  fail_check("evidence directory is missing: #{directory}") unless directory.directory?
end

[mac, nrf].each do |directory|
  proof = directory.join("allocation-proof.tsv").read
  fail_check("zero-allocation proof differs for #{directory.basename}") unless proof ==
    "irPathForbiddenReferences\t0\nsilForbiddenInstructions\t0\n" \
    "heapAllocations\t0\npeakHeapBytes\t0\n"
  path_ir = directory.join("static-binding-path.ll").read
  calls = directory.join("static-binding-calls.txt").read
  owned_sil = directory.join("static-runtime-owned.sil").read
  forbidden = /@(?:swift_(?:allocObject|slowAlloc|allocBox|allocateGenericValueMetadata|reflect\w*|task\w*)|malloc|calloc|realloc|posix_memalign|aligned_alloc|objc_\w*|pthread_\w*|_swift_exceptionPersonality|__gxx_personality_v0)/
  fail_check("forbidden runtime path reference in #{directory.basename}") if
    path_ir.match?(forbidden) || calls.match?(forbidden)
  fail_check("forbidden Runtime Static SIL in #{directory.basename}") if
    owned_sil.match?(/\b(?:alloc_ref|alloc_box|alloc_existential_box|partial_apply)\b|builtin.*allocRaw/)
end

attributes = nrf.join("arm-attributes.txt").read
%w[Tag_CPU_arch:\ v7E-M Tag_FP_arch:\ VFPv4-D16 Tag_ABI_VFP_args:\ VFP\ registers].each do |attribute|
  fail_check("nRF attribute is missing: #{attribute.tr('\\', '')}") unless attributes.include?(attribute.tr("\\", ""))
end
nrf_result = nrf.join("result.tsv").read
fail_check("nRF target differs") unless nrf_result.include?("target\tarmv7em-none-none-eabi\n")
fail_check("nRF evidence is mislabeled as hardware execution") if nrf_result.match?(/connected|hardware/i)

pi_result = pi.join("result.tsv").read
fail_check("Raspberry Pi target differs") unless pi_result.include?("target\tarmv6-unknown-linux-gnueabihf\n")
pi_inputs = %w[runtime-dynamic.ll object-file.txt object-header.txt].map { |name| pi.join(name).read }.join
fail_check("Raspberry Pi evidence lacks exact LLVM triple") unless
  pi_inputs.include?('target triple = "armv6-unknown-linux-gnueabihf"')
fail_check("Raspberry Pi object is not 32-bit little-endian ARM") unless pi_inputs.include?("elf32-littlearm")
fail_check("Raspberry Pi evidence contains a substituted target") if pi_inputs.match?(/armv7|aarch64/i)

root.join("target-evidence-summary.tsv").write(
  "# profile\tmeasurement\tvalue\n" \
  "macos-static\truntimePathForbiddenReferences\t0\n" \
  "macos-static\theapAllocations\t0\n" \
  "macos-static\tpeakHeapBytes\t0\n" \
  "nrf52840-embedded\truntimePathForbiddenReferences\t0\n" \
  "nrf52840-embedded\theapAllocations\t0\n" \
  "nrf52840-embedded\tpeakHeapBytes\t0\n" \
  "nrf52840-embedded\thardFloatVFPArguments\ttrue\n" \
  "raspberry-pi-armv6\ttarget\tarmv6-unknown-linux-gnueabihf\n"
)

puts "SPEC-013 target evidence passed: macOS/nRF Static paths are allocation-free, nRF is Cortex-M4F hard-float, and Pi is exact ARMv6."
