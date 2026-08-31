#!/usr/bin/env ruby

require "digest"
require "open3"

ROOT = File.expand_path("../..", __dir__)
LEDGER = File.join(ROOT, "Tests/ContractFixtures/SPEC002/migration-ledger.md")
FOUNDATION = File.join(ROOT, "Sources/GiftUI/GiftUI.swift")

def fail!(message)
  warn "error: #{message}"
  exit 1
end

def git(*arguments)
  output, error, status = Open3.capture3("git", "-C", ROOT, *arguments)
  fail!("git #{arguments.join(' ')} failed: #{error}") unless status.success?
  output
end

expected_tag = "2b2837a66b94df38c7b74ead33ebbb54aa08a06d"
expected_commit = "d5d6330432caa7c983d8dba35cf9f23c3800860b"
fail!("PoC tag object changed") unless git("rev-parse", "PoC").strip == expected_tag
fail!("PoC peeled commit changed") unless git("rev-parse", "PoC^{}").strip == expected_commit

queries = {
  "Point" => [53, "6979992f8927344a293456c59b51037e8d75d33cffd9968788c5480bfabbad62"],
  "Size" => [51, "557ebd6bf9ecb209ec61c764e7098a20b199efaa183b04efc454befc525e1ed7"],
  "Rect" => [32, "eaea6d1fe367369346f207a5488bdacdc952cb9841fca6c901eeff9b45601416"],
  "ProposedSize" => [7, "b3770fa50575bb9cacdd4da8967c01956c182a1ed5f16b4565e46b2e8e4de5f0"],
  "LayoutArithmetic" => [8, "e9b491c5d2b4ad79159cc86f93c175cc9de413303295c40d8c82df00bc6e9b58"],
  "InputEvent" => [14, "a7f2e09e5f5277983f18768022a7c8324c2a10c169be02b13f4f653f7440de28"]
}

queries.each do |name, (expected_count, expected_hash)|
  output = git("grep", "-l", name, "PoC", "--", "Sources", "Tests", "firmware", "scripts")
  count = output.lines.length
  hash = Digest::SHA256.hexdigest(output)
  fail!("#{name} inventory count changed: #{count}") unless count == expected_count
  fail!("#{name} inventory hash changed: #{hash}") unless hash == expected_hash
end

ledger = File.read(LEDGER)
closure = ledger[/## Final row closure audit\n(.*?)\n## /m, 1]
fail!("final row closure audit is missing") unless closure
expected_ids = (1..19).map { |value| format("PF008-GS-%03d", value) } +
  (1..5).map { |value| format("PF008-IN-%03d", value) }
closed_ids = closure.scan(/\| `(PF008-(?:GS|IN)-\d{3})` \|.*\| closed \|/).flatten
fail!("closure rows differ from the 24 ledger IDs") unless closed_ids == expected_ids

source = File.read(FOUNDATION)
required_fragments = [
  "public typealias GeometryScalar = Int32",
  "public init?(width: GeometryScalar, height: GeometryScalar)",
  "public init?(origin: Point, size: Size)",
  "package static func add(",
  "package static func subtract(",
  "package static func multiply(",
  "package enum PointerPhase: UInt8",
  "package struct InputSourceID",
  "package let rawValue: UInt16",
  "package struct PointerSequenceID",
  "package struct InputOrdinal",
  "package struct PresentationRevision",
  "package struct NormalizedPointerEvent",
  "package let presentationRevision: PresentationRevision"
]
required_fragments.each do |fragment|
  fail!("Foundation closure lacks: #{fragment}") unless source.include?(fragment)
end

forbidden_patterns = {
  /^\s*public\s+var\s+\w+\s*:[^{\n]+$/ => "mutable public Foundation storage",
  /\b(?:precondition|preconditionFailure|fatalError)\s*\(/ => "trapping Foundation path",
  /\bLayoutArithmetic(?:Error)?\b/ => "legacy arithmetic shim",
  /\brequire(?:Add|Subtract|Multiply)\b/ => "trapping arithmetic helper",
  /\bpublic\s+(?:enum|struct|typealias)\s+InputEvent\b/ => "public raw input shim"
}
forbidden_patterns.each do |pattern, label|
  fail!("Foundation closure contains #{label}") if source.match?(pattern)
end

swift_sources = Dir.glob(File.join(ROOT, "Sources/GiftUI/**/*.swift")).sort
fail!("GiftUI Foundation source inventory is not exact") unless swift_sources == [FOUNDATION]

puts "SPEC-002 migration closure passed: 24 rows, 6 immutable PoC inventories, exact bounded Foundation source."
