# frozen_string_literal: true
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"

class CurrentReferenceTracesTest < Minitest::Test
  TOOL = File.expand_path("../../scripts/contracts/current-spec-001-reference-traces.py", __dir__)

  def setup
    @root = Dir.mktmpdir("giftui-current-reference-")
    FileUtils.mkdir_p(File.join(@root, "Sources", "Probe"))
    @source = File.join(@root, "Sources", "Probe", "capture.swift")
    File.write(@source, "let horizon = 5\n")
    @log = File.join(@root, "test.log")
    @output = File.join(@root, "traces")
    counts = { "macos-dynamic" => 120, "macos-dynamic-other-frame" => 9,
               "macos-dynamic-action" => 12, "macos-static" => 818,
               "macos-static-action" => 12 }
    File.write(@log, counts.flat_map { |key, count| (0...count).map { |i| "reference=#{key}\tordinal=#{i}" } }.join("\n") + "\n")
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def call(operation)
    args = ["python3", TOOL, operation, @output, "--root", @root]
    args += ["--log", @log] if operation == "publish"
    Open3.capture3(*args)
  end

  def test_current_source_identity_and_trace_bytes_are_required
    assert call("publish").last.success?
    assert call("verify").last.success?
    File.write(@source, "let horizon = 30\n")
    refute call("verify").last.success?
    File.write(@source, "let horizon = 5\n")
    File.open(File.join(@output, "macos-dynamic-reference-trace.tsv"), "a") { |f| f.puts("old trace") }
    refute call("verify").last.success?
  end

  def test_incomplete_current_corpus_never_publishes
    File.write(@log, "reference=macos-dynamic\tordinal=1\n")
    refute call("publish").last.success?
    refute File.exist?(File.join(@output, "identity.json"))
    refute File.exist?(File.join(@output, "macos-dynamic-reference-trace.tsv"))
  end

  def test_historical_bundle_without_current_identity_is_refused
    FileUtils.mkdir_p(@output)
    history = File.join(@output, "macos-dynamic-reference-trace.tsv")
    File.write(history, "old 30-second reference\n")
    refute call("verify").last.success?
    assert_equal "old 30-second reference\n", File.read(history)
  end
end
