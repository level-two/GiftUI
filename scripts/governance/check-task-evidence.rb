#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "optparse"
require "pathname"
require "yaml"

ALLOWED_DISPOSITIONS = %w[pending in_progress completed blocked changed removed not_applicable].freeze
TASK_FIELDS = %w[disposition requirements implementation checks profiles evidence blockers].freeze
HARDWARE_FREE_PROFILES = %w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded].freeze

options = {}
OptionParser.new do |parser|
  parser.banner = "Usage: check-task-evidence.rb --spec SPEC-NNN [--task Tn.n] [--root PATH] [--manifest PATH]"
  parser.on("--spec ID") { |value| options[:spec] = value }
  parser.on("--task ID") { |value| options[:task] = value }
  parser.on("--root PATH") { |value| options[:root] = value }
  parser.on("--manifest PATH") { |value| options[:manifest] = value }
end.parse!
abort "error: --spec is required" unless options[:spec]&.match?(/\ASPEC-\d{3}\z/)

root = Pathname.new(options[:root] || File.expand_path("../..", __dir__)).expand_path
compact_spec = options[:spec].delete("-")
manifest_path = Pathname.new(options[:manifest] || root.join("Tests/ContractFixtures", compact_spec, "task-evidence.yaml").to_s)
manifest_path = root.join(manifest_path) unless manifest_path.absolute?
errors = []

def yaml(path, errors, root)
  YAML.safe_load(path.read, permitted_classes: [Date], permitted_symbols: [], aliases: false)
rescue Errno::ENOENT
  errors << "#{path}: missing file"
  nil
rescue Psych::Exception => error
  errors << "#{path.relative_path_from(root)}: invalid YAML: #{error.message}"
  nil
end

manifest = yaml(manifest_path, errors, root)
unless manifest.is_a?(Hash)
  warn errors.join("\n")
  exit 1
end
%w[schema_version spec plan tasks].each { |field| errors << "#{manifest_path}: missing #{field}" unless manifest.key?(field) }
errors << "#{manifest_path}: schema_version must be 1" unless manifest["schema_version"] == 1
errors << "#{manifest_path}: spec must be #{options[:spec]}" unless manifest["spec"] == options[:spec]
tasks = manifest["tasks"]
errors << "#{manifest_path}: tasks must be a mapping" unless tasks.is_a?(Hash)
tasks = {} unless tasks.is_a?(Hash)

plan_path = root.join(manifest["plan"].to_s).cleanpath
plan_content = plan_path.file? ? plan_path.read : ""
errors << "#{manifest_path}: missing plan #{manifest['plan'].inspect}" unless plan_path.file?
plan_tasks = {}
plan_content.scan(/^- \[([ x])\] `([^`]+)` — (.*?)(?=^- \[[ x]\] `|^### |^## |\z)/m).each do |mark, id, body|
  plan_tasks[id] = { completed: mark == "x", body: body.gsub(/\s+/, " ").strip }
end

matrix = Hash.new { |hash, key| hash[key] = [] }
plan_content.each_line do |line|
  match = line.match(/^\| `([A-Z][A-Z0-9]*(?:-[A-Z0-9]+)+)` /)
  next unless match
  requirement = match[1]
  cells = line.split("|")
  Array(cells[2]).join.scan(/`(T\d+\.\d+)`/).flatten.each { |task| matrix[task] << requirement }
end

feature_manifest = yaml(root.join("docs/features.yaml"), errors, root)
spec_path = nil
if feature_manifest.is_a?(Hash)
  Dir[root.join("docs/specs/*.md")].sort.each do |filename|
    content = File.read(filename)
    if content.match?(/\Aid:\s*#{Regexp.escape(options[:spec])}\s*$/m) || content.match?(/^id:\s*#{Regexp.escape(options[:spec])}\s*$/)
      spec_path = Pathname.new(filename)
      break
    end
  end
end
errors << "#{options[:spec]}: governing Specification not found" unless spec_path
requirements = spec_path ? spec_path.read.scan(/^\s*- \[[ x]\] \*\*([A-Z][A-Z0-9]*(?:-[A-Z0-9]+)+):\*\*/).flatten.uniq : []

registry = root.join("scripts/contracts/driver-registry.tsv")
registered_profiles = {}
if registry.file?
  registry.each_line do |line|
    next if line.start_with?("#") || line.strip.empty?
    id, _driver, profiles = line.strip.split("\t", 3)
    registered_profiles[id] = profiles.to_s.split(",")
  end
end

selected_tasks = options[:task] ? { options[:task] => tasks[options[:task]] } : tasks
errors << "#{manifest_path}: unknown task #{options[:task]}" if options[:task] && !tasks.key?(options[:task])
selected_tasks.each do |id, entry|
  unless entry.is_a?(Hash)
    errors << "#{manifest_path}: #{id} must be a mapping"
    next
  end
  missing = TASK_FIELDS.reject { |field| entry.key?(field) }
  errors << "#{manifest_path}: #{id} missing #{missing.join(', ')}" unless missing.empty?
  disposition = entry["disposition"]
  errors << "#{manifest_path}: #{id} has invalid disposition #{disposition.inspect}" unless ALLOWED_DISPOSITIONS.include?(disposition)
  TASK_FIELDS.drop(1).each do |field|
    errors << "#{manifest_path}: #{id}.#{field} must be an array" unless entry[field].is_a?(Array)
  end
  plan_task = plan_tasks[id]
  errors << "#{manifest_path}: #{id} is absent from the plan" unless plan_task
  if plan_task
    if plan_task[:completed] && disposition != "completed"
      errors << "#{manifest_path}: #{id} is checked in the plan but disposition is #{disposition.inspect}"
    elsif !plan_task[:completed] && disposition == "completed"
      errors << "#{manifest_path}: #{id} is unchecked in the plan but disposition is completed"
    end
  end
  expected_requirements = matrix[id].sort
  actual_requirements = Array(entry["requirements"]).sort
  errors << "#{manifest_path}: #{id} requirement mapping differs from the plan matrix" unless expected_requirements == actual_requirements
  actual_requirements.each { |requirement| errors << "#{manifest_path}: #{id} references unknown criterion #{requirement}" unless requirements.include?(requirement) }
  if disposition == "completed"
    %w[implementation checks evidence].each do |field|
      errors << "#{manifest_path}: completed #{id} has no #{field}" if Array(entry[field]).empty?
      Array(entry[field]).each do |path|
        errors << "#{manifest_path}: completed #{id} references missing #{field.to_s.sub(/s\z/, '')} #{path}" unless root.join(path).exist?
      end
    end
  end
  if disposition == "blocked"
    errors << "#{manifest_path}: blocked #{id} has no blockers" if Array(entry["blockers"]).empty?
    Array(entry["blockers"]).each do |blocker|
      errors << "#{manifest_path}: blocked #{id} has unverifiable blocker #{blocker.inspect}" unless blocker.to_s.match?(/\A(?:SPEC|ADR|RFC|PROPOSAL|FW|EXP|SPIKE)-\d{3}\z|\AT\d+\.\d+\z|\A[^\s]+\/[^\s]+\z/)
    end
  elsif !Array(entry["blockers"]).empty?
    errors << "#{manifest_path}: non-blocked #{id} has blockers"
  end
  Array(entry["profiles"]).each do |profile|
    errors << "#{manifest_path}: #{id} has unsupported profile #{profile}" unless HARDWARE_FREE_PROFILES.include?(profile)
    errors << "#{manifest_path}: #{id} profile #{profile} lacks a registered #{options[:spec]} driver" unless Array(registered_profiles[options[:spec]]).include?(profile)
  end
end

unless options[:task]
  (plan_tasks.keys - tasks.keys).each { |id| errors << "#{manifest_path}: plan task #{id} is missing" }
  (tasks.keys - plan_tasks.keys).each { |id| errors << "#{manifest_path}: manifest task #{id} is not in the plan" }
  covered = tasks.values.flat_map { |entry| entry.is_a?(Hash) ? Array(entry["requirements"]) : [] }.uniq
  (requirements - covered).each { |requirement| errors << "#{manifest_path}: acceptance criterion #{requirement} has no task" }
  referenced_evidence = tasks.values.flat_map { |entry| entry.is_a?(Hash) ? Array(entry["evidence"]) : [] }
  evidence_root = manifest_path.dirname.join("Evidence")
  if evidence_root.directory?
    Dir[evidence_root.join("**/*")].select { |path| File.file?(path) }.each do |path|
      relative_path = Pathname.new(path).relative_path_from(root).to_s
      errors << "#{manifest_path}: evidence file #{relative_path} is referenced by no task" unless referenced_evidence.include?(relative_path)
    end
  end
end

if errors.empty?
  puts "Task evidence validation passed: #{options[:spec]} #{options[:task] || "all tasks"} (#{selected_tasks.length} task(s))."
  exit 0
end
warn "Task evidence validation failed with #{errors.length} error(s):"
errors.sort.each { |error| warn "- #{error}" }
exit 1
