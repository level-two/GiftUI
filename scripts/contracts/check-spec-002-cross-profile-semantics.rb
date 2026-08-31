#!/usr/bin/env ruby

def fail!(message)
  warn "error: #{message}"
  exit 1
end

path = ARGV.fetch(0) do
  fail!("usage: check-spec-002-cross-profile-semantics.rb <optimized-ir>")
end
fail!("optimized IR is missing: #{path}") unless File.file?(path)

ir = File.read(path)
functions = ir.scan(/define\b[^@]*@[^\n]*GiftUIFoundationProfileCorpusProbe[^\n]*checksum[^\n]*\{(.*?)^\}/m)
fail!("checksum function is missing from optimized target IR") unless functions.length == 1
body = functions.first.first
fail!("checksum did not reduce to the expected target result") unless body.match?(/^\s*ret i32 28\s*$/)
fail!("checksum retains a failure result") if body.match?(/^\s*ret i32 0\s*$/)

puts "SPEC-002 target semantic IR passed: complete profile corpus reduces to checksum 28."
