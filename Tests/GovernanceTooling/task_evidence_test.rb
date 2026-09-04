# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"

ROOT = File.expand_path("../..", __dir__) unless defined?(ROOT)
VALIDATOR = File.join(ROOT, "scripts/governance/check-task-evidence.rb")

class TaskEvidenceTest < Minitest::Test
  def run_validator(*arguments)
    Open3.capture3("ruby", VALIDATOR, *arguments)
  end

  def test_repository_spec_005_manifest_is_valid
    _out, error, status = run_validator("--spec", "SPEC-005", "--root", ROOT)
    assert status.success?, error
  end

  def with_fixture
    Dir.mktmpdir("giftui-task-evidence-") do |root|
      %w[docs/specs docs/implementation-plans scripts/contracts Tests/ContractFixtures/SPEC001/Evidence].each do |directory|
        FileUtils.mkdir_p(File.join(root, directory))
      end
      File.write(File.join(root, "docs/features.yaml"), "schema_version: 1\nfeatures: {}\n")
      File.write(File.join(root, "docs/specs/spec.md"), <<~MD)
        ---
        id: SPEC-001
        ---
        # Spec
        ## Acceptance Criteria
        - [ ] **AC-001:** Covered.
      MD
      tasks = %w[T1.1 T1.2 T1.3 T1.4 T1.5 T1.6 T1.7]
      dispositions = %w[completed blocked pending in_progress changed removed not_applicable]
      plan_tasks = tasks.each_with_index.map { |task, index| "- [#{index.zero? ? 'x' : ' '}] `#{task}` — Fixture task." }.join("\n")
      matrix_tasks = tasks.map { |task| "`#{task}`" }.join(", ")
      File.write(File.join(root, "docs/implementation-plans/plan.md"), <<~MD)
        # Plan
        | Criterion | Implementation tasks | Evidence | Status |
        | --- | --- | --- | --- |
        | `AC-001` — Covered | #{matrix_tasks} | Fixture | pending |
        ## Tasks
        #{plan_tasks}
      MD
      File.write(File.join(root, "scripts/contracts/driver-registry.tsv"), "SPEC-001\tdriver\tmacos-dynamic\n")
      File.write(File.join(root, "implementation.txt"), "implementation\n")
      File.write(File.join(root, "check.sh"), "check\n")
      File.write(File.join(root, "Tests/ContractFixtures/SPEC001/Evidence/result.txt"), "evidence\n")
      entries = {}
      tasks.zip(dispositions).each do |task, disposition|
        entries[task] = {
          "disposition" => disposition, "requirements" => ["AC-001"],
          "implementation" => disposition == "completed" ? ["implementation.txt"] : [],
          "checks" => disposition == "completed" ? ["check.sh"] : [], "profiles" => [],
          "evidence" => disposition == "completed" ? ["Tests/ContractFixtures/SPEC001/Evidence/result.txt"] : [],
          "blockers" => disposition == "blocked" ? ["SPEC-002"] : []
        }
      end
      manifest = { "schema_version" => 1, "spec" => "SPEC-001",
                   "plan" => "docs/implementation-plans/plan.md", "tasks" => entries }
      path = File.join(root, "Tests/ContractFixtures/SPEC001/task-evidence.yaml")
      File.write(path, manifest.to_yaml)
      yield root, path, manifest
    end
  end

  def test_all_dispositions_are_accepted
    with_fixture do |root, path, _manifest|
      _out, error, status = run_validator("--spec", "SPEC-001", "--root", root, "--manifest", path)
      assert status.success?, error
    end
  end

  def test_completed_and_blocked_tasks_fail_without_required_data
    with_fixture do |root, path, manifest|
      manifest["tasks"]["T1.1"]["evidence"] = []
      manifest["tasks"]["T1.2"]["blockers"] = []
      File.write(path, manifest.to_yaml)
      _out, error, status = run_validator("--spec", "SPEC-001", "--root", root, "--manifest", path)
      refute status.success?
      assert_includes error, "completed T1.1 has no evidence"
      assert_includes error, "blocked T1.2 has no blockers"
    end
  end
end
