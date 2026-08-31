#!/usr/bin/env ruby
# frozen_string_literal: true

VALUES = {
  "geometryScalar" => { size: 4 },
  "point" => { maximum_size: 8 },
  "size" => { maximum_size: 8 },
  "rect" => { maximum_size: 16 },
  "proposedSize" => {
    maximum_size: 16,
    functions: {
      size: "proposedByteSize",
      stride: "proposedStride",
      alignment: "proposedAlignment",
    },
  },
  "pointerPhase" => {},
  "inputSourceID" => { size: 2 },
  "pointerSequenceID" => { size: 4 },
  "inputOrdinal" => { size: 4 },
  "presentationRevision" => { size: 4 },
  "normalizedPointerEvent" => { maximum_size: 32 },
}.freeze

def fail_check(message)
  warn "SPEC-002 layout check failed: #{message}"
  exit 1
end

fail_check("expected LLVM IR and output paths") unless ARGV.length == 2
ir_path, output_path = ARGV

begin
  ir = File.read(ir_path)
rescue Errno::ENOENT => error
  fail_check(error.message)
end

rows = []
VALUES.each do |name, limits|
  measurements = {}
  %w[size stride alignment].each do |measurement|
    function_name = limits.fetch(:functions, {}).fetch(
      measurement.to_sym,
      "#{name}#{measurement.capitalize}"
    )
    body = ir[/define [^{]+#{function_name}[^\{]*\{(.*?)^\}/m, 1]
    fail_check("missing IR function #{function_name}") unless body
    value = body[/ret i32 ([0-9]+)/, 1]
    fail_check("#{function_name} is not a constant i32 return") unless value
    measurements[measurement.to_sym] = Integer(value, 10)
  end

  if limits[:size] && measurements[:size] != limits[:size]
    fail_check("#{name} size #{measurements[:size]} differs from #{limits[:size]}")
  end
  if limits[:maximum_size] && measurements[:size] > limits[:maximum_size]
    fail_check("#{name} size #{measurements[:size]} exceeds #{limits[:maximum_size]}")
  end
  fail_check("#{name} has zero stride or alignment") if
    measurements[:stride].zero? || measurements[:alignment].zero?
  rows << [name, measurements[:size], measurements[:stride], measurements[:alignment]]
end

File.open(output_path, "w") do |output|
  output.puts("value\tsize\tstride\talignment")
  rows.each { |row| output.puts(row.join("\t")) }
end

puts "SPEC-002 layout check passed: #{rows.length} owned values."
