#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
CALCULATOR = ROOT.join("Sources/GiftUIRasterCore/RasterFrameWork.swift")
ADMISSION = ROOT.join(
  "Sources/GiftUIBackendIntegration/RasterFrameWorkAdmission.swift"
)

def fail_check(message)
  warn "SPEC-014 frame-work check failed: #{message}"
  exit 1
end

fail_check("frame-work calculator is missing") unless CALCULATOR.file?
fail_check("frame-work admission mapper is missing") unless ADMISSION.file?
calculator = CALCULATOR.read
admission = ADMISSION.read

%w[
  damageHeight
  damagedPixels
  rowsForCeiling
  tileRows
  tileVisits
  regionSubmissions
].each do |fragment|
  fail_check("calculator lacks #{fragment}") unless calculator.include?(fragment)
end
fail_check("calculator lacks checked multiplication") unless calculator.scan("multipliedReportingOverflow").length == 3
fail_check("calculator lacks checked ceiling addition") unless calculator.include?("addingReportingOverflow")
fail_check("calculator uses wrapping arithmetic") if calculator.match?(/&[+*\-]/)
fail_check("calculator clamps work") if calculator.match?(/\b(?:min|max)\s*\(/)

fail_check("construction overflow mapping differs") unless admission.match?(/case \.arithmeticOverflow:\s*\.arithmeticOverflow/m)
fail_check("construction capacity mapping differs") unless admission.match?(/case \.capacityExceeded:\s*\.capacityExhausted/m)
fail_check("header failures do not map to contract violation") unless admission.match?(/case \.arithmeticOverflow, \.capacityExceeded, \.invalidHeader:\s*\.contractViolation/m)

puts "SPEC-014 frame-work check passed: checked formulas and exact construction/header mappings."
