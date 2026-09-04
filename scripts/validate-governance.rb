#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("..", __dir__))
DOCS = ROOT.join("docs")

ARTIFACTS = {
  "proposals" => {
    prefix: "PROPOSAL",
    statuses: %w[draft proposed accepted rejected superseded]
  },
  "rfcs" => {
    prefix: "RFC",
    statuses: %w[draft review approved rejected superseded]
  },
  "adrs" => {
    prefix: "ADR",
    statuses: %w[proposed accepted deprecated superseded]
  },
  "specs" => {
    prefix: "SPEC",
    statuses: %w[draft review approved implementing implemented superseded]
  }
}.freeze

REQUIRED_METADATA = %w[
  id feature title status authors created updated proposal related_rfcs
  related_adrs related_specs supersedes superseded_by target_milestone
].freeze
RELATION_FIELDS = %w[
  proposal related_rfcs related_adrs related_specs supersedes superseded_by
].freeze
FEATURE_FIELDS = %w[
  title status proposal rfcs adrs specs dependencies milestone
].freeze
FEATURE_STATUSES = %w[
  proposal rfc decision specification implementation conformance implemented
  deferred
].freeze
REQUIRED_SKILLS = %w[
  feature-triage proposal-author rfc-author rfc-reviewer adr-author spec-author
  spec-reviewer lifecycle-reviewer implementation-planner
].freeze
REQUIRED_SKILL_SECTIONS = [
  "Role", "Required Inputs", "Documents To Read", "Allowed Decisions",
  "Forbidden Decisions", "Required Output", "Review Checklist",
  "Completion Criteria"
].freeze

errors = []
artifacts = {}

%w[VISION.md PRINCIPLES.md MVP_SCOPE.md].each do |project_document|
  path = DOCS.join(project_document)
  errors << "docs/#{project_document}: missing project authority document" unless path.file?
end

def load_yaml(path, errors)
  YAML.safe_load(
    path.read,
    permitted_classes: [Date],
    permitted_symbols: [],
    aliases: false
  )
rescue Psych::Exception => error
  errors << "#{path.relative_path_from(ROOT)}: invalid YAML: #{error.message}"
  nil
end

def front_matter(path, errors)
  content = path.read
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  unless match
    errors << "#{path.relative_path_from(ROOT)}: missing YAML front matter"
    return [nil, content]
  end

  metadata = YAML.safe_load(
    match[1],
    permitted_classes: [Date],
    permitted_symbols: [],
    aliases: false
  )
  unless metadata.is_a?(Hash)
    errors << "#{path.relative_path_from(ROOT)}: front matter must be a mapping"
    return [nil, content]
  end
  [metadata, content]
rescue Psych::Exception => error
  errors << "#{path.relative_path_from(ROOT)}: invalid front matter: #{error.message}"
  [nil, content]
end

manifest_path = DOCS.join("features.yaml")
manifest = load_yaml(manifest_path, errors)
features = {}
if manifest.is_a?(Hash)
  errors << "docs/features.yaml: schema_version must be 1" unless manifest["schema_version"] == 1
  if manifest["features"].is_a?(Hash)
    features = manifest["features"]
  else
    errors << "docs/features.yaml: features must be a mapping"
  end
else
  errors << "docs/features.yaml: root must be a mapping" unless manifest.nil?
end

features.each do |feature_id, entry|
  unless feature_id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
    errors << "docs/features.yaml: invalid feature ID #{feature_id.inspect}"
  end
  unless entry.is_a?(Hash)
    errors << "docs/features.yaml: #{feature_id} must be a mapping"
    next
  end

  missing = FEATURE_FIELDS.reject { |field| entry.key?(field) }
  errors << "docs/features.yaml: #{feature_id} missing #{missing.join(', ')}" unless missing.empty?
  unless FEATURE_STATUSES.include?(entry["status"])
    errors << "docs/features.yaml: #{feature_id} has invalid status #{entry['status'].inspect}"
  end
  %w[proposal rfcs adrs specs dependencies].each do |field|
    errors << "docs/features.yaml: #{feature_id}.#{field} must be an array" unless entry[field].is_a?(Array)
  end
end

ARTIFACTS.each do |directory, rules|
  Dir[DOCS.join(directory, "*.md")].sort.each do |filename|
    path = Pathname.new(filename)
    next if %w[README.md EXTRACTION_MAP.md].include?(path.basename.to_s)

    metadata, content = front_matter(path, errors)
    next unless metadata

    missing = REQUIRED_METADATA.reject { |field| metadata.key?(field) }
    errors << "#{path.relative_path_from(ROOT)}: missing #{missing.join(', ')}" unless missing.empty?

    id = metadata["id"]
    expected_id = /\A#{rules[:prefix]}-\d{3}\z/
    errors << "#{path.relative_path_from(ROOT)}: invalid ID #{id.inspect}" unless id.is_a?(String) && id.match?(expected_id)
    if artifacts.key?(id)
      errors << "#{path.relative_path_from(ROOT)}: duplicate ID #{id}"
    elsif id.is_a?(String)
      artifacts[id] = { path: path, metadata: metadata, content: content, type: directory }
    end

    unless rules[:statuses].include?(metadata["status"])
      errors << "#{path.relative_path_from(ROOT)}: invalid status #{metadata['status'].inspect}"
    end
    unless metadata["feature"].is_a?(String) && features.key?(metadata["feature"])
      errors << "#{path.relative_path_from(ROOT)}: feature #{metadata['feature'].inspect} is absent from manifest"
    end
    unless metadata["authors"].is_a?(Array) && !metadata["authors"].empty?
      errors << "#{path.relative_path_from(ROOT)}: authors must be a non-empty array"
    end
    %w[created updated].each do |field|
      value = metadata[field]
      errors << "#{path.relative_path_from(ROOT)}: #{field} must be YYYY-MM-DD" unless value && value.to_s.match?(/\A\d{4}-\d{2}-\d{2}\z/)
    end
    RELATION_FIELDS.each do |field|
      errors << "#{path.relative_path_from(ROOT)}: #{field} must be an array" unless metadata[field].is_a?(Array)
    end
  end
end

artifacts.each_value do |artifact|
  path = artifact[:path]
  metadata = artifact[:metadata]
  RELATION_FIELDS.each do |field|
    next unless metadata[field].is_a?(Array)
    metadata[field].each do |reference|
      errors << "#{path.relative_path_from(ROOT)}: unknown #{field} ID #{reference}" unless artifacts.key?(reference)
    end
  end

  if artifact[:type] == "rfcs"
    Array(metadata["proposal"]).each do |proposal_id|
      proposal = artifacts[proposal_id]
      unless proposal && proposal[:metadata]["status"] == "accepted"
        errors << "#{path.relative_path_from(ROOT)}: RFC requires accepted Proposal #{proposal_id}"
      end
    end
    errors << "#{path.relative_path_from(ROOT)}: RFC must reference a Proposal" if Array(metadata["proposal"]).empty?
  end

  if artifact[:type] == "adrs"
    Array(metadata["related_rfcs"]).each do |rfc_id|
      rfc = artifacts[rfc_id]
      unless rfc && rfc[:metadata]["status"] == "approved"
        errors << "#{path.relative_path_from(ROOT)}: ADR source RFC must be approved: #{rfc_id}"
      end
    end
  end

  if artifact[:type] == "specs" && %w[approved implementing implemented].include?(metadata["status"])
    adrs = Array(metadata["related_adrs"])
    errors << "#{path.relative_path_from(ROOT)}: authoritative Spec must reference an ADR" if adrs.empty?
    adrs.each do |adr_id|
      adr = artifacts[adr_id]
      unless adr && adr[:metadata]["status"] == "accepted"
        errors << "#{path.relative_path_from(ROOT)}: governing ADR must be accepted: #{adr_id}"
      end
    end
  end

  Array(metadata["supersedes"]).each do |predecessor_id|
    predecessor = artifacts[predecessor_id]
    next unless predecessor
    unless Array(predecessor[:metadata]["superseded_by"]).include?(metadata["id"])
      errors << "#{path.relative_path_from(ROOT)}: #{predecessor_id} lacks reciprocal superseded_by"
    end
  end
  if metadata["status"] == "superseded" && Array(metadata["superseded_by"]).empty?
    errors << "#{path.relative_path_from(ROOT)}: superseded artifact has no successor"
  end
end

manifest_lists = {
  "proposal" => "PROPOSAL",
  "rfcs" => "RFC",
  "adrs" => "ADR",
  "specs" => "SPEC"
}
features.each do |feature_id, entry|
  next unless entry.is_a?(Hash)
  manifest_lists.each do |field, prefix|
    next unless entry[field].is_a?(Array)
    entry[field].each do |id|
      artifact = artifacts[id]
      errors << "docs/features.yaml: #{feature_id}.#{field} references unknown #{id}" unless artifact
      errors << "docs/features.yaml: #{feature_id}.#{field} has wrong artifact type #{id}" unless id.to_s.start_with?("#{prefix}-")
      if artifact && artifact[:metadata]["feature"] != feature_id
        errors << "docs/features.yaml: #{id} belongs to #{artifact[:metadata]['feature']}, not #{feature_id}"
      end
    end
  end
  Array(entry["dependencies"]).each do |dependency|
    errors << "docs/features.yaml: #{feature_id} references unknown dependency #{dependency}" unless features.key?(dependency)
  end
end

artifacts.each do |id, artifact|
  feature = features[artifact[:metadata]["feature"]]
  next unless feature.is_a?(Hash)
  field = case id
          when /\APROPOSAL-/ then "proposal"
          when /\ARFC-/ then "rfcs"
          when /\AADR-/ then "adrs"
          when /\ASPEC-/ then "specs"
          end
  errors << "docs/features.yaml: #{id} missing from feature artifact list" unless Array(feature[field]).include?(id)
end

REQUIRED_SKILLS.each do |skill_name|
  skill_path = ROOT.join(".agents", "skills", skill_name, "SKILL.md")
  unless skill_path.file?
    errors << ".agents/skills/#{skill_name}/SKILL.md: missing required skill"
    next
  end
  metadata, content = front_matter(skill_path, errors)
  errors << "#{skill_path.relative_path_from(ROOT)}: name must be #{skill_name}" if metadata && metadata["name"] != skill_name
  REQUIRED_SKILL_SECTIONS.each do |section|
    errors << "#{skill_path.relative_path_from(ROOT)}: missing #{section} section" unless content.match?(/^## #{Regexp.escape(section)}\s*$/)
  end
end

link_files = []
link_files.concat(Dir[DOCS.join("{VISION,PRINCIPLES,MVP_SCOPE}.md")])
link_files.concat(Dir[DOCS.join("engineering", "*.md")])
link_files.concat(Dir[DOCS.join("{architecture,proposals,rfcs,adrs,specs,roadmap,templates}", "*.md")])
link_files.each do |filename|
  path = Pathname.new(filename)
  path.read.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each do |target|
    next if target.match?(/\A(?:[a-z]+:|#)/i)
    local_target = target.split("#", 2).first
    next if local_target.empty?
    resolved = path.dirname.join(local_target).cleanpath
    errors << "#{path.relative_path_from(ROOT)}: broken link #{target}" unless resolved.exist?
  end
end

agent_contract = ROOT.join("AGENTS.md").read
%w[
  docs/engineering/FEATURE_LIFECYCLE.md docs/engineering/AI_AGENT_RULES.md
  docs/MVP_SCOPE.md docs/features.yaml .agents/skills/
].each do |route|
  errors << "AGENTS.md: missing governance route #{route}" unless agent_contract.include?(route)
end

if errors.empty?
  graph_check = ROOT.join("scripts", "governance", "build-authority-graph.rb")
  unless system(graph_check.to_s, "--check")
    warn "Governance validation failed: authority graph validation failed."
    exit 1
  end
  task_evidence_check = ROOT.join("scripts", "governance", "check-task-evidence.rb")
  Dir[ROOT.join("Tests", "ContractFixtures", "SPEC*", "task-evidence.yaml")].sort.each do |manifest_path|
    compact_spec = Pathname.new(manifest_path).dirname.basename.to_s
    spec_id = compact_spec.sub(/\ASPEC/, "SPEC-")
    unless system(task_evidence_check.to_s, "--spec", spec_id)
      warn "Governance validation failed: #{spec_id} task evidence validation failed."
      exit 1
    end
  end
  puts "Governance validation passed: #{features.length} feature(s), #{artifacts.length} lifecycle artifact(s), #{REQUIRED_SKILLS.length} skill(s)."
  exit 0
end

warn "Governance validation failed with #{errors.length} error(s):"
errors.each { |error| warn "- #{error}" }
exit 1
