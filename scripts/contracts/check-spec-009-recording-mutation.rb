#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/RecordingMutationBatch.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/RecordingMutationBatchTests.swift")

def fail_check(message)
  warn "SPEC-009 recording mutation check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("mutation batch must import no other owner") unless source.scan(/^import /).empty?
fail_check("mutation batch must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) RecordingMutation/
)

%w[
  RecordingSemanticAction
  RecordingMutationOwner
  firstStateChange
  secondStateChange
  firstCompletion
  secondCompletion
  firstAction
  secondAction
  wasApplied
  actionGeneration
  isActionEnabled
  targetGeneration
  dispatch
].each do |fragment|
  fail_check("mutation batch lacks #{fragment}") unless source.include?(fragment)
end

state_index = source.index("owner.apply(stateChange: firstStateChange)")
completion_index = source.index("owner.apply(completion: firstCompletion)")
action_index = source.index("owner.dispatch")
unless state_index && completion_index && action_index &&
    state_index < completion_index && completion_index < action_index
  fail_check("mutation category order differs")
end

%w[
  sealedMutationAppliesEachCategoryExactlyOnceInOrder
  constructionAndAdmissionNeverDispatchAnAction
  actionDispatchRequiresEveryCurrentIdentityAndGenerationProof
  boundedCategoryStorageRejectsEveryNonPrefixShape
].each do |name|
  fail_check("mutation fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|GiftUIInteraction|GiftUIRenderCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("mutation batch selects storage or a prohibited owner") if source.match?(forbidden)

puts "SPEC-009 recording mutation passed: exact category order, one-shot effects, four-part action revalidation, and no admission dispatch are covered."
