#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

def fail_check(message)
  warn "SPEC-008 render resource IR check failed: #{message}"
  exit 1
end

fail_check("usage: check-spec-008-render-resource-ir.rb IR [OUTPUT]") unless (1..2).cover?(ARGV.length)
ir_path = Pathname.new(ARGV[0])
fail_check("missing IR #{ir_path}") unless ir_path.file?
ir = ir_path.read

function_value = lambda do |suffix|
  body = ir[/define [^{]*spec008StaticRender#{suffix}[^\{]*\{(.*?)^\}/m, 1]
  fail_check("missing IR function spec008StaticRender#{suffix}") unless body
  raw = body[/ret i32 ([0-9]+)/, 1]
  fail_check("spec008StaticRender#{suffix} is not constant") unless raw
  Integer(raw, 10)
end

size = function_value.call("WorkspaceSize")
stride = function_value.call("WorkspaceStride")
alignment = function_value.call("WorkspaceAlignment")
slot_bytes = function_value.call("ForegroundSlotBytes")
fail_check("workspace stride is smaller than size") if stride < size
fail_check("workspace alignment is zero") if alignment.zero?
fail_check("foreground storage is not exactly one Color slot") unless slot_bytes == 3

capacities = {
  "operations" => "OperationCapacity",
  "positioned-glyphs" => "GlyphCapacity",
  "clip-depth" => "ClipCapacity",
  "semantic-scopes" => "SemanticCapacity",
  "layout-scopes" => "LayoutCapacity",
  "traversal-depth" => "TraversalCapacity",
  "text-lines" => "TextLineCapacity",
}.to_h { |name, suffix| [name, function_value.call(suffix)] }
fail_check("static capacity differs from one") unless capacities.values.uniq == [1]

if ARGV.length == 2
  output = Pathname.new(ARGV[1])
  output.write(
    "workspace_size\tworkspace_stride\tworkspace_alignment\tforeground_slot_bytes\n" +
      "#{size}\t#{stride}\t#{alignment}\t#{slot_bytes}\n" +
      "capacity\tvalue\n" + capacities.map { |name, value| "#{name}\t#{value}" }.join("\n") + "\n"
  )
end

puts "SPEC-008 render resource IR passed: finite workspace layout, one exact Color slot, and seven capacities are constant."
