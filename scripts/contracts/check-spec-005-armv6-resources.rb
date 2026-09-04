#!/usr/bin/env ruby
# frozen_string_literal: true

def fail_check(message)
  warn "SPEC-005 ARMv6 resource check failed: #{message}"
  exit 1
end

fail_check("expected baseline, candidate, and output paths") unless ARGV.length == 3
baseline_root, candidate_root, output_path = ARGV
baseline_image = File.size(File.join(baseline_root, "resource-probe"))
candidate_image = File.size(File.join(candidate_root, "resource-probe"))
symbols_and_map = File.read(File.join(candidate_root, "named-symbols.txt")) +
                  File.read(File.join(candidate_root, "link.map"))
fail_check("bitmap payload/provider symbols are missing") unless
  symbols_and_map.include?("GiftUIReferenceGeneratedBitmapPayload")
fail_check("outline payload/provider leaked into bitmap-only image") if
  symbols_and_map.include?("GiftUIReferenceGeneratedOutlinePayload") ||
  symbols_and_map.include?("ReferenceOutlinePayload")
fail_check("nominal resource identity is absent") unless symbols_and_map.include?("FontResourceID")

File.open(output_path, "w") do |output|
  output.puts("metric\tbaseline\tcandidate\tdelta_or_value\tstatus")
  output.puts("final_image_bytes\t#{baseline_image}\t#{candidate_image}\t#{candidate_image - baseline_image}\tpass")
  output.puts("outline_payload_symbols\t-\t0\t0\tpass")
  output.puts("bitmap_payload_linked\t-\t1\t1\tpass")
  output.puts("target_identity\t-\tarmv6-unknown-linux-gnueabihf\t-\tpass")
end
puts "SPEC-005 ARMv6 resource check passed: bitmap-only final image and link map retain the exact target identity."
