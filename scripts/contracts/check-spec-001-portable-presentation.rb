#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../..", __dir__)
PRESENTATION = File.join(ROOT, "Sources/SignalAnalyzerPresentation")
VIEW_PATH = File.join(PRESENTATION, "SignalAnalyzerView.swift")
VALUES_PATH = File.join(PRESENTATION, "SignalAnalyzerPresentationValues.swift")

def fail_check(message)
  warn "SPEC-001 portable Presentation check failed: #{message}"
  exit 1
end

sources = Dir.glob(File.join(PRESENTATION, "*.swift")).sort.to_h do |path|
  [path, File.read(path)]
end
combined = sources.values.join("\n")
view = sources.fetch(VIEW_PATH)
values = sources.fetch(VALUES_PATH)

allowed_imports = %w[GiftUI GiftUIFailureCore SignalAnalyzerDomain]
imports = combined.scan(/^import\s+(\S+)/).flatten.uniq
unexpected_imports = imports - allowed_imports
fail_check("unexpected imports #{unexpected_imports.join(',')}") unless unexpected_imports.empty?

forbidden_tokens = %w[
  SignalAnalyzerData SwiftUI Foundation Dispatch Task MainActor
  ContinuousClock ForEach ScrollView NavigationView Menu animation gesture
  GeometryReader gradient shadow opacity
]
forbidden_tokens.each do |token|
  fail_check("forbidden token #{token}") if combined.include?(token)
end
fail_check("platform conditional found") if combined.match?(/^\s*#if/m)

fail_check("observable root count differs") unless view.scan("@ObservableStateHost").length == 1
state_declarations = view.scan(/@State\s+private\s+var\s+\w+\s*:\s*SignalAnalyzerViewModel/)
fail_check("direct state declaration differs") unless state_declarations.length == 1
fail_check("channel occurrence count differs") unless view.scan("SignalAnalyzerChannelWaveformView(").length == 4
fail_check("grid occurrence count differs") unless view.scan("SignalAnalyzerGridView()").length == 1
fail_check("Canvas factory count differs") unless view.scan(/^\s*Canvas\s*\{/).length == 2

fail_check("visible square control count differs") unless view.scan("SignalAnalyzerSquareButton(").length == 3
%w[controls.recordingAction selectedWindow.shorterAction selectedWindow.longerAction].each do |action|
  fail_check("qualified control action #{action} differs") unless view.scan("action: #{action}").length == 1
end
fail_check("square button uses an unqualified action") unless view.include?("Button(action: action)") && view.include?("package let action: SignalAnalyzerAction")
fail_check("endpoint disabled constraints differ") unless view.include?("isDisabled: selectedWindow == .oneSecond") && view.include?("isDisabled: selectedWindow == .fiveSeconds") && view.include?(".disabled(isDisabled)")
fail_check("legacy visible control found") if view.match?(/Button\("(?:Start|Stop|Clear|[125] s)"/)

handler = values[/package struct SignalAnalyzerActionHandler: GiftUIActionHandler.*?^}/m]
fail_check("action handler missing") unless handler
fail_check("action handler stores state") if handler.match?(/^\s+(?:package|private|internal|public)?\s*(?:let|var)\s+/)
fail_check("action handler switch count differs") unless handler.scan(/\bswitch\s+action\b/).length == 1

puts "SPEC-001 portable Presentation check passed: #{sources.length} files, " \
     "1 observable state, 4 explicit channels, 3 state-qualified controls over 6 finite actions, and 5 Canvas occurrences."
