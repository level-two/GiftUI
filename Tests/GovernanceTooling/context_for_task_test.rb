# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

ROOT = File.expand_path("../..", __dir__) unless defined?(ROOT)
CONTEXT = File.join(ROOT, "scripts/governance/context-for-task.rb")

class ContextForTaskTest < Minitest::Test
  def run_context(*arguments)
    Open3.capture3("ruby", CONTEXT, "--root", ROOT, *arguments)
  end

  def test_json_pack_contains_exact_task_requirement_authority_and_evidence
    output, error, status = run_context("--spec", "SPEC-005", "--task", "T5.1", "--format", "json", "--stdout")
    assert status.success?, error
    pack = JSON.parse(output)
    assert_equal "T5.1", pack.fetch("task")
    assert_includes pack.fetch("requirements"), "TR-003"
    assert pack.fetch("authority").any? { |node| node["id"] == "SPEC-005" && node["authoritative"] }
    assert pack.fetch("evidence").any? { |item| item["path"].end_with?("four-profile-semantic-corpus.md") }
    task_source = pack.fetch("sources").find { |source| source["heading"] == "Task T5.1" }
    assert_includes task_source.fetch("text"), "Run the identical normalized identity"
    assert task_source.fetch("lineStart") < task_source.fetch("lineEnd")
  end

  def test_blocked_task_exposes_declared_prerequisites_and_blockers
    output, error, status = run_context("--spec", "SPEC-005", "--task", "T4.4", "--format", "json", "--stdout")
    assert status.success?, error
    pack = JSON.parse(output)
    assert_equal "blocked", pack.fetch("disposition")
    assert_equal %w[SPEC-007 SPEC-008 SPEC-014 SPEC-015], pack.fetch("blockers")
    assert pack.fetch("prerequisites").any? { |item| item["id"] == "SPEC-007" }
  end

  def test_outputs_are_stable_and_check_detects_staleness
    Dir.mktmpdir("giftui-context-output-") do |directory|
      first = File.join(directory, "first.md")
      second = File.join(directory, "second.md")
      assert run_context("--spec", "SPEC-005", "--task", "T5.1", "--output", first).last.success?
      assert run_context("--spec", "SPEC-005", "--task", "T5.1", "--output", second).last.success?
      assert_equal File.binread(first), File.binread(second)
      assert run_context("--spec", "SPEC-005", "--task", "T5.1", "--output", first, "--check").last.success?
      File.open(first, "ab") { |file| file.write("stale\n") }
      refute run_context("--spec", "SPEC-005", "--task", "T5.1", "--output", first, "--check").last.success?
    end
  end

  def test_fails_instead_of_truncating
    _output, error, status = run_context("--spec", "SPEC-005", "--task", "T5.1", "--format", "json", "--stdout", "--max-bytes", "20")
    refute status.success?
    assert_includes error, "above limit"
  end
end
