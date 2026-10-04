# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RunnerIsolationTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)

  def fixture
    Dir.mktmpdir("giftui-runner-") do |root|
      %w[scripts/lib scripts/contracts scripts/governance .build/contract-reports].each do |path|
        FileUtils.mkdir_p(File.join(root, path))
      end
      FileUtils.cp(File.join(ROOT, "scripts/test.sh"), File.join(root, "scripts/test.sh"))
      FileUtils.cp(File.join(ROOT, "scripts/lib/serialize-validation.rb"), File.join(root, "scripts/lib/serialize-validation.rb"))
      File.write(File.join(root, "scripts/lib/swiftpm.sh"), "giftui_swiftpm() { return 0; }\n")
      # Stub costly checks, keeping the actual runner and lock unchanged.
      source = File.read(File.join(ROOT, "scripts/test.sh"))
      source.scan(/\$\{PROJECT_ROOT\}\/([\w\/.-]+\.(?:rb|sh|py))/).flatten.uniq.each do |path|
        next if %w[scripts/lib/swiftpm.sh scripts/lib/serialize-validation.rb].include?(path)
        full = File.join(root, path)
        FileUtils.mkdir_p(File.dirname(full))
        File.write(full, path.end_with?(".py") ? "print('fixture check passed')\n" : "#!/usr/bin/env bash\nexit 0\n")
        File.chmod(0o755, full)
      end
      File.write(File.join(root, "scripts/contracts/driver-registry.tsv"), "SPEC-001\tscripts/contracts/fake.sh\tmacos-dynamic\n")
      File.write(File.join(root, "scripts/contracts/fake.sh"), <<~SH)
        #!/usr/bin/env bash
        set -euo pipefail
        root="$(cd "$(dirname "$0")/../.." && pwd)"
        mkdir "$root/.build/shared-active"
        trap 'rmdir "$root/.build/shared-active"' EXIT
        printf 'active\\n' > "$root/.build/started"
        if [[ "${FIXTURE_MODE:-}" == interrupt ]]; then
          mkdir -p "$root/.build/spec-014/reports/.tmp-interrupted-$$"
          printf 'run_id=interrupted-$$\\n' > "$root/.build/spec-014/reports/.tmp-interrupted-$$/metadata.txt"
          sleep 30
        fi
        sleep 0.2
        run="child-$$"
        mkdir -p "$root/.build/contract-reports/spec-001/$run/macos-dynamic"
        printf '%s\\n' "$run" > "$root/.build/contract-reports/spec-001/latest-macos-dynamic.txt"
        printf 'published\\t%s\\t%s\\n' "$root/.build/contract-reports/spec-001/$run/macos-dynamic" "$run" >> "$GIFTUI_TEST_CHILD_REPORT_LEDGER"
        [[ "${FIXTURE_MODE:-}" != fail ]]
      SH
      File.chmod(0o755, File.join(root, "scripts/contracts/fake.sh"))
      system("git", "init", "-q", root, out: File::NULL)
      system("git", "-C", root, "-c", "user.name=Test", "-c", "user.email=test@example.test", "commit", "--allow-empty", "-qm", "fixture")
      yield root
    end
  end

  def reports(root)
    Dir[File.join(root, ".build/test-reports/macos-dynamic/run-*")].sort
  end

  def launch(root, mode = "")
    Process.spawn({ "FIXTURE_MODE" => mode, "GIFTUI_VALIDATION_LOCK_OWNER" => nil },
                  "bash", File.join(root, "scripts/test.sh"), "macos-dynamic",
                  out: File.join(root, "output-#{mode}-#{rand(100000)}.log"), err: [:child, :out])
  end

  def test_overlapping_runs_preserve_reports_and_serialize_shared_writers
    fixture do |root|
      first = launch(root)
      second = launch(root)
      assert Process.wait2(first).last.success?
      assert Process.wait2(second).last.success?
      runs = reports(root)
      assert_equal 2, runs.length
      child_ids = runs.map do |run|
        assert_includes File.read(File.join(run, "metadata.txt")), "status=complete"
        assert_includes File.read(File.join(run, "results.tsv")), "SPEC-001-macos-dynamic\t0"
        File.read(File.join(run, "child-reports.tsv")).lines.find { |line| line.start_with?("published\t") }.split("\t").last.strip
      end
      assert_equal 2, child_ids.uniq.length
      refute File.exist?(File.join(root, ".build/shared-active"))
      latest = File.read(File.join(root, ".build/test-reports/latest-macos-dynamic.txt")).strip
      assert File.directory?(File.join(root, ".build/test-reports", latest))
    end
  end

  def test_failure_keeps_evidence_and_following_run_is_available
    fixture do |root|
      refute Process.wait2(launch(root, "fail")).last.success?
      assert Process.wait2(launch(root)).last.success?
      runs = reports(root)
      assert_equal 2, runs.length
      failed = runs.find { |run| File.read(File.join(run, "metadata.txt")).include?("status=failed") }
      refute_nil failed
      assert_includes File.read(File.join(failed, "results.tsv")), "SPEC-001-macos-dynamic\t1"
      refute_empty File.read(File.join(failed, "child-reports.tsv"))
    end
  end

  def test_interruption_keeps_active_check_and_releases_lock
    fixture do |root|
      pid = launch(root, "interrupt")
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 10
      until File.exist?(File.join(root, ".build/started"))
        raise "fixture did not start" if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
        sleep 0.02
      end
      Process.kill("TERM", pid)
      refute Process.wait2(pid).last.success?
      assert Process.wait2(launch(root)).last.success?
      interrupted = reports(root).find { |run| File.read(File.join(run, "metadata.txt")).include?("status=interrupted") }
      refute_nil interrupted
      assert_includes File.read(File.join(interrupted, "results.tsv")), "SPEC-001-macos-dynamic\t143\tinterrupted"
      assert_includes File.read(File.join(interrupted, "child-reports.tsv")), "retained-staging\t.build/spec-014/reports/.tmp-interrupted-"
      refute File.exist?(File.join(root, ".build/shared-active"))
    end
  end
end
