#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "digest"
require "fileutils"
require "json"
require "optparse"
require "pathname"
require "yaml"

KINDS = {
  "proposals" => ["proposal", "PROPOSAL", %w[draft proposed accepted rejected superseded]],
  "rfcs" => ["rfc", "RFC", %w[draft review approved rejected superseded]],
  "adrs" => ["adr", "ADR", %w[proposed accepted deprecated superseded]],
  "specs" => ["specification", "SPEC", %w[draft review approved implementing implemented superseded]],
  "future-work" => ["future_work", "FW", %w[captured promoted closed superseded]],
  "explorations" => ["exploration", "EXP", %w[draft active paused concluded abandoned superseded]],
  "spikes" => ["spike", "SPIKE", %w[planned active completed abandoned superseded]]
}.freeze

IMPLEMENTATION_KINDS = {
  "implementation-plans" => ["implementation_plan", %w[draft ready active completed superseded]],
  "implementation-designs" => ["implementation_design", %w[draft current superseded]],
  "conformance" => ["conformance_report", %w[collecting review complete superseded]]
}.freeze

ID_RELATIONSHIPS = %w[
  proposal related_rfcs related_adrs related_specs related_future_work
  related_explorations related_spikes source promoted_to supersedes superseded_by
].freeze
PATH_RELATIONSHIPS = %w[
  implementation_plan related_design_notes conformance_report
].freeze

options = { check: false }
OptionParser.new do |parser|
  parser.banner = "Usage: build-authority-graph.rb [--check] [--root PATH] [--output PATH]"
  parser.on("--check", "Validate without writing output") { options[:check] = true }
  parser.on("--root PATH", "Repository root (test support)") { |value| options[:root] = value }
  parser.on("--output PATH", "Output path") { |value| options[:output] = value }
end.parse!

root = Pathname.new(options[:root] || File.expand_path("../..", __dir__)).expand_path
docs = root.join("docs")
output = Pathname.new(options[:output] || root.join(".build/governance/authority-graph.json").to_s)
errors = []

def relative(path, root)
  path.relative_path_from(root).to_s
end

def load_yaml(path, errors, root)
  YAML.safe_load(path.read, permitted_classes: [Date], permitted_symbols: [], aliases: false)
rescue Psych::Exception => error
  errors << "#{relative(path, root)}: invalid YAML: #{error.message}"
  nil
end

def front_matter(path, errors, root)
  match = path.read.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  unless match
    errors << "#{relative(path, root)}: missing YAML front matter"
    return nil
  end
  value = YAML.safe_load(match[1], permitted_classes: [Date], permitted_symbols: [], aliases: false)
  unless value.is_a?(Hash)
    errors << "#{relative(path, root)}: front matter must be a mapping"
    return nil
  end
  value
rescue Psych::Exception => error
  errors << "#{relative(path, root)}: invalid front matter: #{error.message}"
  nil
end

def authority?(kind, status)
  (kind == "adr" && status == "accepted") ||
    (kind == "specification" && %w[approved implementing implemented].include?(status))
end

manifest_path = docs.join("features.yaml")
manifest = manifest_path.file? ? load_yaml(manifest_path, errors, root) : nil
unless manifest.is_a?(Hash) && manifest["schema_version"] == 1 && manifest["features"].is_a?(Hash)
  errors << "docs/features.yaml: expected schema_version 1 and a features mapping"
end
features = manifest.is_a?(Hash) && manifest["features"].is_a?(Hash) ? manifest["features"] : {}

records = {}
path_to_id = {}
source_paths = [manifest_path].select(&:file?)

KINDS.each do |directory, (kind, prefix, statuses)|
  Dir[docs.join(directory, "*.md")].sort.each do |filename|
    path = Pathname.new(filename)
    next if path.basename.to_s == "README.md"
    source_paths << path
    metadata = front_matter(path, errors, root)
    next unless metadata
    id = metadata["id"]
    unless id.is_a?(String) && id.match?(/\A#{Regexp.escape(prefix)}-\d{3}\z/)
      errors << "#{relative(path, root)}: invalid #{kind} ID #{id.inspect}"
      next
    end
    errors << "#{relative(path, root)}: duplicate ID #{id}" if records.key?(id)
    status = metadata["status"]
    errors << "#{relative(path, root)}: invalid status #{status.inspect}" unless statuses.include?(status)
    feature = metadata["feature"]
    errors << "#{relative(path, root)}: feature #{feature.inspect} is absent from docs/features.yaml" unless features.key?(feature)
    records[id] ||= { id: id, kind: kind, feature: feature, title: metadata["title"], status: status,
                      path: path, metadata: metadata }
    path_to_id[path.expand_path.to_s] = id
  end
end

IMPLEMENTATION_KINDS.each do |directory, (kind, statuses)|
  Dir[docs.join(directory, "*.md")].sort.each do |filename|
    path = Pathname.new(filename)
    next if path.basename.to_s == "README.md"
    source_paths << path
    metadata = front_matter(path, errors, root)
    next unless metadata
    spec = metadata["spec"]
    id = case kind
         when "implementation_plan" then "PLAN-#{spec}"
         when "conformance_report" then "CONFORMANCE-#{spec}"
         else "DESIGN-#{path.basename(".md")}"
         end
    errors << "#{relative(path, root)}: missing governing Specification" unless spec.is_a?(String)
    errors << "#{relative(path, root)}: duplicate generated ID #{id}" if records.key?(id)
    status = metadata["status"]
    errors << "#{relative(path, root)}: invalid status #{status.inspect}" unless statuses.include?(status)
    feature = metadata["feature"]
    errors << "#{relative(path, root)}: feature #{feature.inspect} is absent from docs/features.yaml" unless features.key?(feature)
    records[id] ||= { id: id, kind: kind, feature: feature, title: metadata["title"], status: status,
                      path: path, metadata: metadata, spec: spec }
    path_to_id[path.expand_path.to_s] = id
  end
end

# Lifecycle artifacts are registered; implementation and deferred records are not.
manifest_fields = { "proposal" => "proposal", "rfc" => "rfcs", "adr" => "adrs", "specification" => "specs" }
records.each_value do |record|
  field = manifest_fields[record[:kind]]
  next unless field
  entry = features[record[:feature]]
  errors << "#{relative(record[:path], root)}: #{record[:id]} missing from docs/features.yaml" unless entry.is_a?(Hash) && Array(entry[field]).include?(record[:id])
end
features.each do |feature, entry|
  next unless entry.is_a?(Hash)
  { "proposal" => "PROPOSAL", "rfcs" => "RFC", "adrs" => "ADR", "specs" => "SPEC" }.each_key do |field|
    Array(entry[field]).each do |id|
      record = records[id]
      errors << "docs/features.yaml: #{feature}.#{field} references unknown #{id}" unless record
      errors << "docs/features.yaml: #{id} belongs to #{record[:feature]}, not #{feature}" if record && record[:feature] != feature
    end
  end
end

edges = []
records.each_value do |record|
  metadata = record[:metadata]
  ID_RELATIONSHIPS.each do |field|
    next unless metadata.key?(field)
    values = metadata[field].nil? ? [] : Array(metadata[field])
    values.each do |target|
      unless target.is_a?(String) && records.key?(target)
        errors << "#{relative(record[:path], root)}: unknown #{field} ID #{target.inspect}"
        next
      end
      edges << { "from" => record[:id], "to" => target, "relationship" => field,
                 "declaredBy" => relative(record[:path], root) }
    end
  end
  PATH_RELATIONSHIPS.each do |field|
    next unless metadata.key?(field)
    values = metadata[field].nil? ? [] : Array(metadata[field])
    values.each do |target_path|
      resolved = record[:path].dirname.join(target_path).cleanpath.expand_path.to_s
      target = path_to_id[resolved]
      if target
        edges << { "from" => record[:id], "to" => target, "relationship" => field,
                   "declaredBy" => relative(record[:path], root) }
      else
        errors << "#{relative(record[:path], root)}: unknown #{field} path #{target_path.inspect}"
      end
    end
  end
  if record[:spec]
    if records.key?(record[:spec])
      edges << { "from" => record[:id], "to" => record[:spec], "relationship" => "governing_spec",
                 "declaredBy" => relative(record[:path], root) }
    else
      errors << "#{relative(record[:path], root)}: unknown governing Specification #{record[:spec].inspect}"
    end
  end
end

records.each_value do |record|
  metadata = record[:metadata]
  Array(metadata["supersedes"]).each do |target|
    predecessor = records[target]
    next unless predecessor
    errors << "#{relative(record[:path], root)}: #{target} lacks reciprocal superseded_by" unless Array(predecessor[:metadata]["superseded_by"]).include?(record[:id])
  end
  if metadata["status"] == "superseded" && Array(metadata["superseded_by"]).empty?
    errors << "#{relative(record[:path], root)}: superseded record has no successor"
  end
  %w[related_future_work related_explorations related_spikes].each do |field|
    Array(metadata[field]).each do |target|
      other = records[target]
      next unless other && %w[future_work exploration spike].include?(record[:kind]) &&
        %w[future_work exploration spike].include?(other[:kind])
      reciprocal = other[:metadata].values_at("related_future_work", "related_explorations", "related_spikes").compact.flatten
      errors << "#{relative(record[:path], root)}: #{target} lacks reciprocal deferred-work link" unless reciprocal.include?(record[:id])
    end
  end
end

unless errors.empty?
  warn "Authority graph validation failed with #{errors.length} error(s):"
  errors.sort.each { |error| warn "- #{error}" }
  exit 1
end

generated_from = source_paths.uniq.sort_by { |path| relative(path, root) }.map do |path|
  { "path" => relative(path, root), "sha256" => Digest::SHA256.file(path).hexdigest }
end
nodes = records.values.sort_by { |record| record[:id] }.map do |record|
  { "id" => record[:id], "kind" => record[:kind], "feature" => record[:feature],
    "title" => record[:title], "status" => record[:status], "path" => relative(record[:path], root),
    "sha256" => Digest::SHA256.file(record[:path]).hexdigest,
    "authoritative" => authority?(record[:kind], record[:status]) }
end
edges.sort_by! { |edge| [edge["from"], edge["relationship"], edge["to"], edge["declaredBy"]] }
graph = { "schemaVersion" => 1, "generatedFrom" => generated_from, "nodes" => nodes, "edges" => edges }
json = JSON.pretty_generate(graph) + "\n"

unless options[:check]
  FileUtils.mkdir_p(output.dirname)
  temporary = output.dirname.join(".#{output.basename}.tmp-#{Process.pid}")
  temporary.write(json)
  File.rename(temporary, output)
end

puts "Authority graph validation passed: #{nodes.length} nodes, #{edges.length} edges."
