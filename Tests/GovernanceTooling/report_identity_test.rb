# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

ROOT = File.expand_path("../..", __dir__) unless defined?(ROOT)
IDENTITY = File.join(ROOT, "scripts/contracts/report-input-identity.rb")
PUBLISH = File.join(ROOT, "scripts/contracts/publish-contract-report.rb")
VERIFY = File.join(ROOT, "scripts/contracts/verify-contract-report.rb")
COMPARE = File.join(ROOT, "scripts/contracts/compare-spec-005-profile-semantics.rb")
REPORT_PATH = File.join(ROOT, "scripts/contracts/report-path.sh")
REVISION = "a" * 40

class ReportIdentityTest < Minitest::Test
  def identity(root, inventory, paths)
    Open3.capture3("ruby", IDENTITY, "--root", root, "--revision", REVISION,
                   "--inventory", inventory, stdin_data: paths.join("\n") + "\n")
  end

  def test_identity_is_stable_and_changes_with_content
    Dir.mktmpdir("giftui-report-input-") do |root|
      File.write(File.join(root, "a"), "one\n")
      first, error, status = identity(root, File.join(root, "first.tsv"), ["a"])
      assert status.success?, error
      second = identity(root, File.join(root, "second.tsv"), ["a"]).first
      assert_equal first, second
      File.write(File.join(root, "a"), "two\n")
      refute_equal first, identity(root, File.join(root, "third.tsv"), ["a"]).first
    end
  end

  def test_atomic_publication_is_idempotent_and_refuses_different_report
    Dir.mktmpdir("giftui-report-publish-") do |root|
      report_root = File.join(root, "reports")
      destination = File.join(report_root, "run", "profile")
      latest = File.join(report_root, "latest-profile.txt")
      FileUtils.mkdir_p(report_root)
      publish = lambda do |name, content|
        staging = File.join(report_root, ".tmp-#{name}")
        FileUtils.mkdir_p(staging)
        File.write(File.join(staging, "metadata.txt"), content)
        Open3.capture3("ruby", PUBLISH, "--report-root", report_root, "--staging", staging,
                       "--destination", destination, "--latest", latest, "--run-id", "run")
      end
      assert publish.call("one", "same\n").last.success?
      assert Open3.capture3("ruby", VERIFY, destination).last.success?
      assert publish.call("two", "same\n").last.success?
      _out, error, status = publish.call("three", "different\n")
      refute status.success?
      assert_includes error, "refusing to overwrite"
      assert_equal "run\n", File.read(latest)
      File.open(File.join(destination, "metadata.txt"), "a") { |file| file.write("corrupt\n") }
      refute Open3.capture3("ruby", VERIFY, destination).last.success?
    end
  end


  def test_cross_profile_comparison_rejects_mixed_run_identities_first
    Dir.mktmpdir("giftui-report-compare-") do |root|
      profiles = %w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded]
      profiles.each_with_index do |profile, index|
        run_id = "#{index.zero? ? 'a' : 'b'}#{'0' * 39}-#{'1' * 16}"
        directory = File.join(root, run_id, profile, "semantics")
        FileUtils.mkdir_p(directory)
        File.write(File.join(root, "latest-#{profile}.txt"), "#{run_id}\n")
      end
      _out, error, status = Open3.capture3("ruby", COMPARE, root)
      refute status.success?
      assert_includes error, "mixed run identities"
      refute_includes error, "missing semantic transcript"
    end
  end

  def test_report_lookup_rejects_legacy_profile_only_directories
    Dir.mktmpdir("giftui-report-path-") do |root|
      FileUtils.mkdir_p(File.join(root, "macos-dynamic"))
      command = 'source "$1"; giftui_contract_profile_report "$2" macos-dynamic'
      _output, _error, status = Open3.capture3("bash", "-c", command, "_", REPORT_PATH, root)
      refute status.success?

      run_id = "#{REVISION}-#{'1' * 16}"
      FileUtils.mkdir_p(File.join(root, run_id, "macos-dynamic"))
      File.write(File.join(root, "latest-macos-dynamic.txt"), "#{run_id}\n")
      output, error, status = Open3.capture3("bash", "-c", command, "_", REPORT_PATH, root)
      assert status.success?, error
      assert_equal "#{File.join(root, run_id, 'macos-dynamic')}\n", output
    end
  end

  def test_every_registered_driver_uses_immutable_publication
    registry = File.join(ROOT, "scripts/contracts/driver-registry.tsv")
    File.foreach(registry) do |line|
      next if line.start_with?("#") || line.strip.empty?
      _spec, relative_driver, = line.chomp.split("\t")
      driver = File.read(File.join(ROOT, relative_driver))
      generic_wrapper = driver.include?("run-immutable-contract-driver.sh") &&
                        driver.include?("GIFTUI_CONTRACT_REPORT_DIR")
      native_publication = driver.include?("canonical_report_dir=") &&
                           driver.include?("publish-contract-report.rb")
      assert generic_wrapper || native_publication,
             "#{relative_driver} does not use an immutable report publication path"
    end
  end
end
