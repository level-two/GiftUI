# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

ROOT = File.expand_path("../..", __dir__) unless defined?(ROOT)

class GatesTest < Minitest::Test
  def test_focused_gate_runs_only_direct_task_checks
    output, error, status = Open3.capture3(File.join(ROOT, "scripts/check-task.sh"), "--spec", "SPEC-005", "--task", "T4.2")
    assert status.success?, error
    assert_includes output, "gate-level=focused-task"
    assert_includes output, "check-spec-005-synchronous-offer.rb"
    refute_includes output, "raspberry-pi"
    refute_includes output, "nrf52840"
  end

  def test_specification_gate_rejects_unknown_profile_without_running_driver
    _output, error, status = Open3.capture3(File.join(ROOT, "scripts/check-spec.sh"), "--spec", "SPEC-005", "--profile", "unknown")
    refute status.success?
    assert_includes error, "unsupported profile"
  end

  def test_swiftpm_wrapper_classifies_permission_failure
    Dir.mktmpdir("giftui-swiftpm-wrapper-") do |directory|
      fake = File.join(directory, "fake-swift")
      File.write(fake, "#!/usr/bin/env bash\necho 'sandbox_apply: Operation not permitted' >&2\nexit 1\n")
      FileUtils.chmod(0o755, fake)
      command = 'source "$1"; giftui_swiftpm --package-path "$2" --cache-root "$3" -- test'
      _output, error, status = Open3.capture3({ "GIFTUI_SWIFT_EXECUTABLE" => fake }, "bash", "-c", command, "_",
                                             File.join(ROOT, "scripts/lib/swiftpm.sh"), ROOT, File.join(directory, "cache"))
      refute status.success?
      assert_includes error, "swiftpm-command:"
      assert_includes error, "swiftpm-failure-class=host-permission-or-sandbox"
    end
  end
end
