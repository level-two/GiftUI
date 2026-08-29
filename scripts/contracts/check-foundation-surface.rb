#!/usr/bin/env ruby
# frozen_string_literal: true

PUBLIC_NAMES = %w[GeometryScalar Point ProposedSize Rect Size].freeze
PACKAGE_NAMES = %w[
  GeometryArithmetic
  InputOrdinal
  InputSourceID
  NormalizedPointerEvent
  PointerPhase
  PointerSequenceID
  PresentationRevision
].freeze

def fail_check(message)
  warn "SPEC-002 Foundation surface check failed: #{message}"
  exit 1
end

fail_check("expected public and package interface paths") unless ARGV.length == 2
public_path, package_path = ARGV

begin
  public_interface = File.read(public_path)
  package_interface = File.read(package_path)
rescue Errno::ENOENT => error
  fail_check(error.message)
end

public_names = public_interface.scan(/^public (?:typealias|struct|enum) ([A-Za-z0-9_]+)/).flatten.sort
package_names = package_interface.scan(/^package (?:typealias|struct|enum) ([A-Za-z0-9_]+)/).flatten.sort
fail_check("public owner set differs: #{public_names.inspect}") unless public_names == PUBLIC_NAMES
fail_check("package owner set differs: #{package_names.inspect}") unless package_names == PACKAGE_NAMES
fail_check("public interface exposes package SPI") if public_interface.match?(/^package /)

combined = public_interface + package_interface
forbidden = %w[
  InputEvent
  LayoutArithmetic
  requireAdd
  requireSubtract
  requireMultiply
  AppKit
  CoreGraphics
  UIKit
  Linux
  Zephyr
  Backend
  Platform
  Driver
  HAL
  Hardware
  RTOS
  evdev
]
found = forbidden.select { |name| combined.match?(/\b#{Regexp.escape(name)}\b/i) }
fail_check("forbidden compatibility or integration names: #{found.inspect}") unless found.empty?

required_fragments = [
  "package enum PointerPhase : Swift.UInt8, Swift.Equatable, Swift.Sendable",
  "package let rawValue: Swift.UInt16",
  "package struct PointerSequenceID : Swift.Equatable, Swift.Hashable, Swift.Sendable",
  "package struct InputOrdinal : Swift.Equatable, Swift.Hashable, Swift.Sendable",
  "package struct PresentationRevision : Swift.Equatable, Swift.Hashable, Swift.Sendable",
  "package let phase: GiftUI.PointerPhase",
  "package let position: GiftUI.Point",
  "package let source: GiftUI.InputSourceID",
  "package let sequence: GiftUI.PointerSequenceID",
  "package let ordinal: GiftUI.InputOrdinal",
  "package let presentationRevision: GiftUI.PresentationRevision",
  "package init(phase: GiftUI.PointerPhase, position: GiftUI.Point, source: GiftUI.InputSourceID, sequence: GiftUI.PointerSequenceID, ordinal: GiftUI.InputOrdinal, presentationRevision: GiftUI.PresentationRevision)",
]
missing = required_fragments.reject { |fragment| package_interface.include?(fragment) }
fail_check("package interface lacks #{missing.inspect}") unless missing.empty?

unless package_interface.scan("package let rawValue: Swift.UInt32").length == 3
  fail_check("expected exactly three UInt32 correlation wrappers")
end

event_body = package_interface[/package struct NormalizedPointerEvent .*?^}/m]
fail_check("normalized event declaration is missing") unless event_body
fail_check("normalized event contains optional provenance") if event_body.include?("?")

puts "SPEC-002 Foundation surface check passed: " \
     "#{PUBLIC_NAMES.length} public and #{PACKAGE_NAMES.length} package owners."
