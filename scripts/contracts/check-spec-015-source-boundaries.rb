#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

root = Pathname.new(File.expand_path("../..", __dir__))
host_root = root.join("Sources/GiftUIHostConfiguration")
owner_registry = root.join("Tests/ContractFixtures/SPEC015/module-owners.tsv")

def fail_check(message)
  warn "SPEC-015 source boundary check failed: #{message}"
  exit 1
end

registry_row = owner_registry.each_line.find do |line|
  line.start_with?("GiftUIHostConfiguration\tregular\tactive\t")
end
fail_check("active host owner registry row is missing") unless registry_row

fields = registry_row.strip.split("\t", -1)
allowed_imports = fields.fetch(3).split(",").sort.freeze
forbidden_imports = fields.fetch(4).split(",").sort.freeze
host_files = host_root.glob("**/*.swift").sort
fail_check("host source set is empty") if host_files.empty?

violations = []
observed_imports = []
host_files.each do |file|
  file.each_line.with_index(1) do |line, line_number|
    imported = line[/^\s*import\s+([A-Za-z0-9_]+)/, 1]
    next unless imported

    observed_imports << imported
    unless allowed_imports.include?(imported)
      violations << "#{file}:#{line_number}: unregistered host import #{imported}"
    end
    if forbidden_imports.include?(imported)
      violations << "#{file}:#{line_number}: forbidden host import #{imported}"
    end
  end
end

protected_roots = %w[
  GiftUI
  GiftUIBackendIntegration
  GiftUICapabilities
  GiftUIDisplayCore
  GiftUIDrawing
  GiftUIExecution
  GiftUIFailureCore
  GiftUIInteraction
  GiftUILayout
  GiftUIObservableState
  GiftUIRasterCore
  GiftUIRenderCore
  GiftUIRenderLowering
  GiftUIRuntimeCore
  GiftUIRuntimeDynamic
  GiftUIRuntimeStatic
  GiftUISemanticCore
  GiftUISurfaceCore
  GiftUITextResources
  SignalAnalyzerData
  SignalAnalyzerDomain
  SignalAnalyzerPresentation
].freeze

protected_file_count = 0
protected_roots.each do |directory|
  root.join("Sources", directory).glob("**/*.swift").sort.each do |file|
    protected_file_count += 1
    file.each_line.with_index(1) do |line, line_number|
      next unless line.match?(/^\s*import\s+GiftUIHostConfiguration\b/)

      violations << "#{file}:#{line_number}: protected owner imports host configuration"
    end
  end
end

ambient_tokens = %w[ProcessInfo UserDefaults getenv dlopen NSClassFromString].freeze
host_files.each do |file|
  source = file.read
  ambient_tokens.each do |token|
    violations << "#{file}: ambient lookup token #{token}" if source.match?(/\b#{token}\b/)
  end
end

fail_check(violations.join("; ")) unless violations.empty?

puts "SPEC-015 source boundaries passed: #{host_files.length} host files, " \
     "#{observed_imports.uniq.length} registered imports, " \
     "#{protected_file_count} protected owner files, zero ambient lookup."
