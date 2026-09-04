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
end
