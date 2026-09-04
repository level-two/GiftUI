# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "fileutils"
require "yaml"

ROOT = File.expand_path("../..", __dir__)
GENERATOR = File.join(ROOT, "scripts/governance/build-authority-graph.rb")

class AuthorityGraphTest < Minitest::Test
  def fixture(extra: {}, mutate: nil)
    Dir.mktmpdir("giftui-authority-") do |root|
      FileUtils.mkdir_p(File.join(root, "docs", "proposals"))
      FileUtils.mkdir_p(File.join(root, "docs", "rfcs"))
      FileUtils.mkdir_p(File.join(root, "docs", "adrs"))
      FileUtils.mkdir_p(File.join(root, "docs", "specs"))
      FileUtils.mkdir_p(File.join(root, "docs", "future-work"))
      File.write(File.join(root, "docs/features.yaml"), <<~YAML)
        schema_version: 1
        features:
          example:
            title: Example
            status: implementation
            proposal: [PROPOSAL-001]
            rfcs: [RFC-001]
            adrs: [ADR-001]
            specs: [SPEC-001]
            dependencies: []
            milestone: MVP
      YAML
      write_artifact(root, "proposals/proposal.md", "PROPOSAL-001", "example", "Proposal", "accepted")
      write_artifact(root, "rfcs/rfc.md", "RFC-001", "example", "RFC", "approved", proposal: ["PROPOSAL-001"])
      write_artifact(root, "adrs/adr.md", "ADR-001", "example", "ADR", "accepted", related_rfcs: ["RFC-001"])
      write_artifact(root, "specs/spec.md", "SPEC-001", "example", "Spec", "implementing", related_adrs: ["ADR-001"])
      extra.each { |path, content| FileUtils.mkdir_p(File.dirname(File.join(root, path))); File.write(File.join(root, path), content) }
      mutate&.call(root)
      yield root
    end
  end

  def write_artifact(root, path, id, feature, title, status, relationships = {})
    metadata = { "id" => id, "feature" => feature, "title" => title, "status" => status,
                 "authors" => ["test"], "created" => "2026-09-04", "updated" => "2026-09-04",
                 "proposal" => [], "related_rfcs" => [], "related_adrs" => [], "related_specs" => [],
                 "supersedes" => [], "superseded_by" => [], "target_milestone" => "MVP" }.merge(relationships.transform_keys(&:to_s))
    File.write(File.join(root, "docs", path), "---\n#{metadata.to_yaml.sub(/\A---\s*\n/, "")}---\n\n# #{title}\n")
  end

  def run_generator(root, *args)
    Open3.capture3("ruby", GENERATOR, "--root", root, *args)
  end

  def test_stable_graph_and_authority_classification
    fixture do |root|
      first = File.join(root, "first.json")
      second = File.join(root, "second.json")
      assert run_generator(root, "--output", first).last.success?
      assert run_generator(root, "--output", second).last.success?
      assert_equal File.binread(first), File.binread(second)
      nodes = JSON.parse(File.read(first)).fetch("nodes").to_h { |node| [node.fetch("id"), node] }
      assert_equal true, nodes.fetch("ADR-001").fetch("authoritative")
      assert_equal true, nodes.fetch("SPEC-001").fetch("authoritative")
      assert_equal false, nodes.fetch("PROPOSAL-001").fetch("authoritative")
      assert_equal false, nodes.fetch("RFC-001").fetch("authoritative")
    end
  end

  def test_duplicate_unknown_and_invalid_status_fail
    fixture(mutate: lambda { |root|
      write_artifact(root, "specs/duplicate.md", "SPEC-001", "example", "Duplicate", "invented", related_adrs: ["ADR-999"])
    }) do |root|
      _out, error, status = run_generator(root, "--check")
      refute status.success?
      assert_includes error, "duplicate ID"
      assert_includes error, "invalid status"
      assert_includes error, "unknown related_adrs ID"
    end
  end

  def test_supersession_and_deferred_reciprocity_fail_closed
    fixture(mutate: lambda { |root|
      write_artifact(root, "future-work/old.md", "FW-001", "example", "Old", "superseded", superseded_by: ["FW-002"], related_future_work: ["FW-002"])
      write_artifact(root, "future-work/new.md", "FW-002", "example", "New", "captured", supersedes: [], related_future_work: [])
    }) do |root|
      _out, error, status = run_generator(root, "--check")
      refute status.success?
      assert_includes error, "lacks reciprocal deferred-work link"
    end
  end
end
