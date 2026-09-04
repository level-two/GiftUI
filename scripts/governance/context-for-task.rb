#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "digest"
require "fileutils"
require "json"
require "open3"
require "optparse"
require "pathname"
require "tmpdir"
require "yaml"

options = { format: "markdown", check: false, stdout: false, max_bytes: 524_288 }
OptionParser.new do |parser|
  parser.banner = "Usage: context-for-task.rb --spec SPEC-NNN --task Tn.n [--format markdown|json] [--stdout|--check]"
  parser.on("--spec ID") { |value| options[:spec] = value }
  parser.on("--task ID") { |value| options[:task] = value }
  parser.on("--format FORMAT") { |value| options[:format] = value }
  parser.on("--stdout") { options[:stdout] = true }
  parser.on("--check") { options[:check] = true }
  parser.on("--output PATH") { |value| options[:output] = value }
  parser.on("--max-bytes BYTES", Integer) { |value| options[:max_bytes] = value }
  parser.on("--root PATH") { |value| options[:root] = value }
end.parse!
abort "error: --spec must be SPEC-NNN" unless options[:spec]&.match?(/\ASPEC-\d{3}\z/)
abort "error: --task must be Tn.n" unless options[:task]&.match?(/\AT\d+\.\d+\z/)
abort "error: --format must be markdown or json" unless %w[markdown json].include?(options[:format])
abort "error: --stdout and --check are mutually exclusive" if options[:stdout] && options[:check]

root = Pathname.new(options[:root] || File.expand_path("../..", __dir__)).expand_path
extension = options[:format] == "markdown" ? "md" : "json"
output = Pathname.new(options[:output] || root.join(".build/governance/context-packs", options[:spec], "#{options[:task]}.#{extension}").to_s)
output = root.join(output) unless output.absolute?

def yaml(path)
  YAML.safe_load(path.read, permitted_classes: [Date], permitted_symbols: [], aliases: false)
rescue Psych::Exception => error
  abort "error: #{path}: invalid YAML: #{error.message}"
end

def source_section(path, start_index, end_index, heading, root)
  lines = path.readlines
  text = lines[start_index...end_index].join
  {
    "path" => path.relative_path_from(root).to_s,
    "heading" => heading,
    "lineStart" => start_index + 1,
    "lineEnd" => end_index,
    "sha256" => Digest::SHA256.file(path).hexdigest,
    "text" => text
  }
end

def markdown_section(path, heading_pattern, root)
  lines = path.readlines
  start_index = lines.index { |line| line.match?(heading_pattern) }
  return nil unless start_index
  level = lines[start_index][/\A#+/].length
  end_index = ((start_index + 1)...lines.length).find do |index|
    marker = lines[index][/\A#+/]
    marker && marker.length <= level
  end || lines.length
  source_section(path, start_index, end_index, lines[start_index].sub(/\A#+\s*/, "").strip, root)
end

def item_section(path, start_pattern, stop_pattern, heading, root)
  lines = path.readlines
  start_index = lines.index { |line| line.match?(start_pattern) }
  return nil unless start_index
  end_index = ((start_index + 1)...lines.length).find { |index| lines[index].match?(stop_pattern) } || lines.length
  source_section(path, start_index, end_index, heading, root)
end

manifest_path = root.join("Tests/ContractFixtures", options[:spec].delete("-"), "task-evidence.yaml")
abort "error: task evidence manifest is missing: #{manifest_path}" unless manifest_path.file?
manifest = yaml(manifest_path)
task = manifest.fetch("tasks", {})[options[:task]]
abort "error: #{options[:task]} is not declared by #{manifest_path.relative_path_from(root)}" unless task.is_a?(Hash)

graph_builder = root.join("scripts/governance/build-authority-graph.rb")
Dir.mktmpdir("giftui-context-graph-") do |temporary_root|
  graph_path = File.join(temporary_root, "authority-graph.json")
  _out, error, status = Open3.capture3(graph_builder.to_s, "--root", root.to_s, "--output", graph_path)
  abort "error: authority graph generation failed:\n#{error}" unless status.success?
  graph = JSON.parse(File.read(graph_path))
  nodes = graph.fetch("nodes").to_h { |node| [node.fetch("id"), node] }
  edges = graph.fetch("edges")
  spec_node = nodes[options[:spec]] or abort "error: #{options[:spec]} is absent from the authority graph"
  abort "error: #{options[:spec]} is not an authoritative current Specification" unless spec_node["authoritative"]
  plan_node = nodes["PLAN-#{options[:spec]}"] or abort "error: #{options[:spec]} has no implementation plan"

  sources = []
  plan_path = root.join(plan_node.fetch("path"))
  task_source = item_section(plan_path, /^- \[[ x]\] `#{Regexp.escape(options[:task])}` — /,
                             /^- \[[ x]\] `|^### |^## /, "Task #{options[:task]}", root)
  abort "error: #{options[:task]} has no exact task text in #{plan_node['path']}" unless task_source
  sources << task_source

  Array(task["requirements"]).sort.each do |requirement|
    spec_path = root.join(spec_node.fetch("path"))
    item = item_section(spec_path, /^- \[[ x]\] \*\*#{Regexp.escape(requirement)}:\*\*/,
                        /^- \[[ x]\] \*\*[A-Z][A-Z0-9]*(?:-[A-Z0-9]+)+:\*\*|^## /,
                        "Acceptance criterion #{requirement}", root)
    abort "error: #{requirement} is not present in #{spec_node['path']}" unless item
    sources << item
  end

  manifest_source = item_section(manifest_path, /^  #{Regexp.escape(options[:task])}:/,
                                 /^  T\d+\.\d+:/, "Task evidence #{options[:task]}", root)
  sources << manifest_source if manifest_source

  related = lambda do |relationship|
    edges.select { |edge| edge["from"] == options[:spec] && edge["relationship"] == relationship }
         .map { |edge| nodes.fetch(edge["to"]) }.sort_by { |node| node["id"] }
  end
  adrs = related.call("related_adrs").select { |node| node["authoritative"] }
  adrs.each do |node|
    section = markdown_section(root.join(node.fetch("path")), /^## Decision\s*$/, root)
    sources << section if section
  end

  designs = nodes.values.select do |node|
    node["kind"] == "implementation_design" &&
      edges.any? { |edge| edge["from"] == node["id"] && edge["relationship"] == "governing_spec" && edge["to"] == options[:spec] } &&
      root.join(node["path"]).read.include?(options[:task])
  end.sort_by { |node| node["id"] }
  designs.each do |node|
    section = markdown_section(root.join(node.fetch("path")), /^## Governing Contract\s*$/, root)
    sources << section if section
  end

  deferred = %w[related_future_work related_explorations related_spikes].flat_map { |field| related.call(field) }.uniq { |node| node["id"] }.sort_by { |node| node["id"] }
  deferred.each do |node|
    path = root.join(node.fetch("path"))
    section = markdown_section(path, /^## (?:Revisit Triggers|Revisit Trigger|Disposition)\s*$/, root)
    sources << section if section
  end

  contextual = (related.call("proposal") + related.call("related_rfcs")).uniq { |node| node["id"] }.sort_by { |node| node["id"] }
  prerequisites = related.call("related_specs")
  evidence = Array(task["evidence"]).sort.map do |path|
    file = root.join(path)
    abort "error: declared evidence is missing: #{path}" unless file.file?
    { "path" => path, "sha256" => Digest::SHA256.file(file).hexdigest }
  end

  sources.compact!
  sources.sort_by! { |source| [source["path"], source["lineStart"], source["heading"]] }
  normative_bytes = sources.sum { |source| source.fetch("text").bytesize }
  abort "error: selected normative content is #{normative_bytes} bytes, above limit #{options[:max_bytes]}; narrow the task or selection" if normative_bytes > options[:max_bytes]

  input_paths = (sources.map { |source| source["path"] } + evidence.map { |item| item["path"] } +
    ["docs/features.yaml", manifest_path.relative_path_from(root).to_s]).uniq.sort
  input_inventory = input_paths.map do |path|
    file = root.join(path)
    { "path" => path, "sha256" => Digest::SHA256.file(file).hexdigest }
  end
  input_stream = input_inventory.map { |item| "#{item['path']}\t#{item['sha256']}\n" }.join
  input_hash = Digest::SHA256.hexdigest(input_stream)
  feature_manifest = yaml(root.join("docs/features.yaml"))
  feature_stage = feature_manifest.fetch("features").fetch(spec_node.fetch("feature")).fetch("status")

  pack = {
    "schemaVersion" => 1,
    "spec" => options[:spec],
    "task" => options[:task],
    "feature" => spec_node.fetch("feature"),
    "featureStage" => feature_stage,
    "inputSetSha256" => input_hash,
    "authority" => ([spec_node] + adrs).map { |node| node.slice("id", "kind", "title", "status", "path", "sha256", "authoritative") },
    "context" => contextual.map { |node| node.slice("id", "kind", "title", "status", "path", "sha256", "authoritative") },
    "prerequisites" => prerequisites.map { |node| node.slice("id", "title", "status", "path", "authoritative") },
    "designNotes" => designs.map { |node| node.slice("id", "title", "status", "path") },
    "deferred" => deferred.map { |node| node.slice("id", "kind", "title", "status", "path") },
    "requirements" => Array(task["requirements"]).sort,
    "disposition" => task["disposition"],
    "blockers" => Array(task["blockers"]).sort,
    "evidence" => evidence,
    "inputs" => input_inventory,
    "sources" => sources
  }

  if options[:format] == "json"
    rendered = JSON.pretty_generate(pack) + "\n"
  else
    lines = ["# Task Context: #{options[:spec]} / #{options[:task]}", "", "> Generated navigation. Source artifacts remain authoritative.", "",
             "- Feature: `#{pack['feature']}` (`#{feature_stage}`)", "- Disposition: `#{task['disposition']}`",
             "- Input set SHA-256: `#{input_hash}`", ""]
    { "Implementation authority" => pack["authority"], "Historical design context" => pack["context"],
      "Downstream prerequisites" => pack["prerequisites"], "Current design notes" => pack["designNotes"],
      "Deferred records" => pack["deferred"] }.each do |title, items|
      lines << "## #{title}" << ""
      if items.empty?
        lines << "- None." << ""
      else
        items.each { |item| lines << "- `#{item['id']}` — #{item['title']} (`#{item['status']}`), `#{item['path']}`" }
        lines << ""
      end
    end
    lines << "## Evidence" << ""
    evidence.each { |item| lines << "- `#{item['path']}` — `#{item['sha256']}`" }
    lines << "- None." if evidence.empty?
    lines << "" << "## Exact source sections" << ""
    sources.each do |source|
      lines << "### #{source['heading']}" << "" <<
        "Generated navigation: `#{source['path']}:#{source['lineStart']}`–`#{source['lineEnd']}`, SHA-256 `#{source['sha256']}`." << "" <<
        "```text" << source["text"].sub(/\n\z/, "") << "```" << ""
    end
    rendered = lines.join("\n") + "\n"
  end

  if options[:stdout]
    print rendered
  elsif options[:check]
    unless output.file? && Digest::SHA256.hexdigest(output.binread) == Digest::SHA256.hexdigest(rendered)
      existing_hash = output.file? ? Digest::SHA256.hexdigest(output.binread) : "missing"
      generated_hash = Digest::SHA256.hexdigest(rendered)
      abort "error: stale or missing context pack: #{output} (existing #{existing_hash}, generated #{generated_hash})"
    end
    puts "Context pack is current: #{output.relative_path_from(root)}"
  else
    FileUtils.mkdir_p(output.dirname)
    temporary = output.dirname.join(".#{output.basename}.tmp-#{Process.pid}")
    temporary.binwrite(rendered)
    File.rename(temporary, output)
    puts "Wrote #{output.relative_path_from(root)} (input #{input_hash})."
  end
end
