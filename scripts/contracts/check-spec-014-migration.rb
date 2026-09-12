#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
INVENTORY = ROOT.join("Tests/ContractFixtures/SPEC014/migration-inventory.tsv")
ALLOWED_DISPOSITIONS = %w[
  adopt-through-owner replace retire downstream-owned evidence-only already-absent
].freeze

def fail_check(message)
  warn "SPEC-014 migration check failed: #{message}"
  exit 1
end

rows = INVENTORY.each_line.each_with_object([]) do |line, values|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("migration row width differs") unless fields.length == 6
  values << fields
end
fail_check("migration inventory is empty") if rows.empty?
fail_check("migration IDs are duplicated") unless rows.map(&:first).uniq.length == rows.length
fail_check("migration source is unknown") unless rows.all? { |row| %w[working-tree PoC].include?(row[1]) }
fail_check("migration disposition is unknown") unless rows.all? { |row| ALLOWED_DISPOSITIONS.include?(row[4]) }

poc_paths, status = Open3.capture2("git", "-C", ROOT.to_s, "ls-tree", "-r", "--name-only", "PoC")
fail_check("cannot inspect PoC tree") unless status.success?
poc_inventory = poc_paths.lines.map(&:chomp)

rows.each do |id, source, relative, _category, disposition, owner|
  fail_check("#{id} has unsafe path") if Pathname.new(relative).absolute? || relative.split("/").include?("..")
  fail_check("#{id} has no replacement/evidence owner") if owner.empty?

  if source == "PoC"
    matched = if relative.end_with?("/")
                poc_inventory.any? { |path| path.start_with?(relative) }
              else
                poc_inventory.include?(relative)
              end
    fail_check("#{id} does not exist in PoC: #{relative}") unless matched
    next
  end

  exists = ROOT.join(relative).exist?
  if disposition == "already-absent"
    fail_check("#{id} legacy path returned to maintained source: #{relative}") if exists
  else
    fail_check("#{id} maintained path is missing: #{relative}") unless exists
  end
end

source_roots = %w[
  Sources/GiftUISurfaceCore Sources/GiftUIRasterCore Sources/GiftUIDisplayCore
  Sources/GiftUIBackendIntegration
].map { |path| ROOT.join(path) }.select(&:directory?)
backend_source = source_roots.flat_map { |root| root.glob("**/*.swift") }.map(&:read).join("\n")
nrf_roots = [ROOT.join("firmware/nrf52840/applications/spec014-backend")].select(&:directory?)
nrf_source = nrf_roots.flat_map { |root| root.glob("**/*.{swift,c,h}") }.map(&:read).join("\n")
non_encoding_roots = source_roots.reject do |root|
  %w[GiftUIRasterCore GiftUISurfaceCore].include?(root.basename.to_s)
end
non_encoding_source = non_encoding_roots.flat_map { |root| root.glob("**/*.swift") }.map(&:read).join("\n")

regressions = {
  "closure-per-tile replay" => [backend_source, /renderTiles\s*\([^)]*(?:drawing|producer|body)\s*:/m],
  "retained render-operation list" => [backend_source, /\[(?:any\s+)?RenderOperation\]/],
  "target identity branch" => [backend_source, /(?:#if\s+(?:os|canImport)|nrf52840|raspberry\s*pi|piscreen|ili9[34]4[16])/i],
  "nRF complete display list" => [nrf_source, /DisplayList|\[(?:any\s+)?RenderOperation\]/],
  "nRF complete framebuffer" => [nrf_source, /Frame[Bb]uffer|480\s*\*\s*320\s*\*\s*2/],
  "parallel RGB565 quantization" => [non_encoding_source, /(?:red|\.red)\s*\*\s*31\s*\+\s*127/]
}.freeze

regressions.each do |name, (source, pattern)|
  fail_check("forbidden #{name} detected") if source.match?(pattern)
end

synthetic = {
  "closure-per-tile replay" => "renderTiles(drawing: producer)",
  "retained render-operation list" => "let values: [RenderOperation] = []",
  "target identity branch" => "#if os(Linux) // Raspberry Pi",
  "nRF complete display list" => "var operations: [RenderOperation]",
  "nRF complete framebuffer" => "let bytes = 480 * 320 * 2",
  "parallel RGB565 quantization" => "let r5 = (red * 31 + 127) / 255"
}.freeze
regressions.each do |name, (_source, pattern)|
  fail_check("#{name} regression pattern does not reject its synthetic fixture") unless synthetic.fetch(name).match?(pattern)
end

puts "SPEC-014 migration check passed: #{rows.length} dispositions and #{regressions.length} forbidden-shape regressions."
