#!/usr/bin/env ruby
# frozen_string_literal: true

CORE_VALUES = {
  "GiftUIConditionID" => ["conditionID", { size: 2 }],
  "GiftUIFailureOrigin" => ["failureOrigin", {}],
  "GiftUIAffectedScope" => ["affectedScope", {}],
  "GiftUIContainment" => ["containment", {}],
  "GiftUIFailureFact" => ["failureFact", { maximum_size: 8 }],
  "GiftUIOperationalKind" => ["operationalKind", {}],
  "GiftUIOperationalFact" => ["operationalFact", { maximum_size: 4 }],
  "GiftUIOutcome<UInt32>" => ["outcome", {}],
  "GiftUIFailureAnnotation" => ["failureAnnotation", { maximum_size: 8 }],
  "GiftUIFailureAnnotations" => ["failureAnnotations", { maximum_size: 20 }],
  "GiftUIResidualDisposition" => ["residualDisposition", {}],
  "GiftUIAllowedDispositions" => ["allowedDispositions", {}],
  "GiftUIResidualPolicyInput<UInt32>" => ["residualPolicyInput", {}],
  "GiftUIOperationalHealthState" => ["operationalHealthState", {}],
  "GiftUIOperationalHealth" => ["operationalHealth", { maximum_size: 20 }],
  "GiftUIDiagnosticKind" => ["diagnosticKind", {}],
  "GiftUIDiagnosticSeverity" => ["diagnosticSeverity", {}],
  "GiftUIDiagnosticSelection" => ["diagnosticSelection", {}],
  "GiftUIDiagnosticRecord" => ["diagnosticRecord", { maximum_size: 24 }],
  "GiftUIDiagnosticSinkResult" => ["diagnosticSinkResult", {}],
}.freeze

DIAGNOSTIC_VALUES = {
  "GiftUIDiagnosticDeliveryCounters" => ["deliveryCounters", {}],
  "GiftUIDiagnosticProjector<GiftUIFixedDiagnosticBuffer>" => ["diagnosticProjector", {}],
  "GiftUIFixedDiagnosticBuffer" => ["fixedDiagnosticBuffer", {}],
}.freeze

PROFILES = {
  "macos-dynamic" => { capacity: 64, ram: 2_048 },
  "macos-static" => { capacity: 16, ram: 512 },
  "raspberry-pi-armv6" => { capacity: 16, ram: 512 },
  "nrf52840-embedded" => { capacity: 8, ram: 320 },
}.freeze

def fail_check(message)
  warn "SPEC-003 layout check failed: #{message}"
  exit 1
end

fail_check("expected Core IR, diagnostics IR, output, and profile") unless ARGV.length == 4
core_path, diagnostics_path, output_path, profile = ARGV
limits = PROFILES[profile] || fail_check("unknown profile #{profile}")
core_ir = File.read(core_path)
diagnostics_ir = File.read(diagnostics_path)

def constant_return(ir, function_name, type)
  body = ir[/define [^{]+#{function_name}[^\{]*\{(.*?)^\}/m, 1]
  fail_check("missing IR function #{function_name}") unless body
  value = body[/ret #{type} ([0-9]+)/, 1]
  fail_check("#{function_name} is not a constant #{type} return") unless value
  Integer(value, 10)
end

rows = []
(CORE_VALUES.map { |name, value| [name, value, core_ir] } +
 DIAGNOSTIC_VALUES.map { |name, value| [name, value, diagnostics_ir] }).each do |name, (prefix, bounds), ir|
  measurements = %w[size stride alignment].to_h do |measurement|
    [measurement, constant_return(ir, "#{prefix}#{measurement.capitalize}", "i32")]
  end
  fail_check("#{name} size differs from #{bounds[:size]}") if
    bounds[:size] && measurements["size"] != bounds[:size]
  fail_check("#{name} exceeds #{bounds[:maximum_size]} bytes") if
    bounds[:maximum_size] && measurements["size"] > bounds[:maximum_size]
  fail_check("#{name} has zero stride or alignment") if
    measurements["stride"].zero? || measurements["alignment"].zero?
  rows << [name, measurements["size"], measurements["stride"], measurements["alignment"]]
end

capacity = constant_return(diagnostics_ir, "fixedDiagnosticBufferCapacity", "i8")
fail_check("capacity #{capacity} differs from #{limits[:capacity]}") unless capacity == limits[:capacity]
sizes = rows.to_h { |name, size, _stride, _alignment| [name, size] }
owned_ram = sizes.fetch("GiftUIOperationalHealth") +
  sizes.fetch("GiftUIDiagnosticDeliveryCounters") +
  sizes.fetch("GiftUIFixedDiagnosticBuffer")
fail_check("owned state #{owned_ram} exceeds #{limits[:ram]}") if owned_ram > limits[:ram]

File.open(output_path, "w") do |output|
  output.puts("value\tsize\tstride\talignment")
  rows.each { |row| output.puts(row.join("\t")) }
  output.puts("default_buffer_capacity\t#{capacity}")
  output.puts("named_owned_state\tGiftUIOperationalHealth,GiftUIDiagnosticDeliveryCounters,GiftUIFixedDiagnosticBuffer")
  output.puts("owned_state_bytes\t#{owned_ram}")
  output.puts("writable_ram_limit\t#{limits[:ram]}")
end

puts "SPEC-003 layout check passed: #{rows.length} values, capacity #{capacity}, owned state #{owned_ram}/#{limits[:ram]} bytes."
