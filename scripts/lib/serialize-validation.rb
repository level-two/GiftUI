#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

root = File.expand_path("../..", __dir__)
lock_path = File.join(root, ".build", "validation.lock")
abort "error: validation command is required" if ARGV.empty?
FileUtils.mkdir_p(File.dirname(lock_path))
# Keep the inode permanently: unlinking a lock can admit a second writer.
File.open(lock_path, File::RDWR | File::CREAT, 0o600) do |lock|
  lock.flock(File::LOCK_EX)
  lock.close_on_exec = false
  child = Process.spawn({ "GIFTUI_VALIDATION_LOCK_OWNER" => Process.pid.to_s }, *ARGV, pgroup: true, lock.fileno => lock)
  %w[INT TERM HUP].each do |signal|
    Signal.trap(signal) do
      begin
        Process.kill(signal, -child)
      rescue Errno::ESRCH
        # The child may have finished just before the signal arrived.
      end
    end
  end
  _, status = Process.wait2(child)
  exit(status.exitstatus || 128 + status.termsig)
end
