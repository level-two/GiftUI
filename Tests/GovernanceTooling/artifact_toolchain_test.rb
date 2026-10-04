# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

class ArtifactToolchainTest < Minitest::Test
  HELPER = File.expand_path("../../scripts/contracts/artifact-toolchain.sh", __dir__)

  def test_actual_cross_compiler_and_sdk_are_separate_from_native_checks
    Dir.mktmpdir("giftui-toolchain-") do |root|
      %w[bin scripts/raspberry-pi scripts/nrf52840 sdk].each { |path| FileUtils.mkdir_p(File.join(root, path)) }
      { "swiftc" => "echo 'Swift version native-9'", "paired" => "echo 'Swift version paired-6.3.2'",
        "xcrun" => "if [[ $* == *version* ]]; then echo 26.5; else echo /fixture/macos-sdk; fi",
        "git" => "echo fixture-zephyr-revision" }.each do |name, body|
        path = File.join(root, "bin", name)
        File.write(path, "#!/usr/bin/env bash\n#{body}\n")
        File.chmod(0o755, path)
      end
      File.write(File.join(root, "sdk/destination.json"), '{"target":"armv6"}')
      File.write(File.join(root, "sdk/sdk_version"), "0.17.4\n")
      File.write(File.join(root, "scripts/raspberry-pi/common.sh"), <<~SH)
        giftui_pi_host_swift() { printf '%s\\n' '#{root}/bin/paired'; }
        GIFTUI_PI_STATIC_DESTINATION='#{root}/sdk/destination.json'
      SH
      File.write(File.join(root, "scripts/nrf52840/common.sh"), <<~SH)
        GIFTUI_NRF_SWIFTC='#{root}/bin/paired'
        GIFTUI_NRF_SDK_DIR='#{root}/sdk'
        GIFTUI_NRF_ZEPHYR_BASE='#{root}'
      SH
      %w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded].each do |profile|
        out, error, status = Open3.capture3({ "PATH" => "#{root}/bin:#{ENV.fetch('PATH')}" }, "bash", "-c",
                                           'source "$1"; giftui_artifact_toolchain_metadata "$2" "$3"', "fixture", HELPER, profile, root)
        assert status.success?, error
        fields = out.lines.to_h { |line| line.strip.split("=", 2) }
        assert_includes fields.fetch("native_check_compiler_identity"), "native-9"
        assert_includes fields.fetch("compiler_identity"), profile.start_with?("macos") ? "native-9" : "paired-6.3.2"
        refute_empty fields.fetch("sdk_identity")
        refute_empty fields.fetch("sdk_version_or_destination_sha256")
        assert_equal "fixture-zephyr-revision", fields["zephyr_revision"] if profile == "nrf52840-embedded"
      end
    end
  end
end
