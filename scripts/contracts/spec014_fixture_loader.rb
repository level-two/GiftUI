# frozen_string_literal: true

require "pathname"
require "yaml"

module SPEC014
  PROFILES = %w[
    macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded
  ].freeze
  EVIDENCE_CLASSES = %w[cross-build host-execution inspection].freeze
  CRITERIA = (1..15).map { |number| format("BI-%03d", number) }.freeze

  class FixtureLoader
    attr_reader :cases_by_id, :files

    def initialize(root)
      @root = Pathname.new(root)
      @cases_by_id = {}
      @files = []
    end

    def load!
      fields = schema_fields
      manifest_rows.each do |row|
        file = row.fetch(1)
        allowed_classes = row.fetch(4).split(",", -1)
        document = YAML.safe_load(@root.join(file).read)
        assert(document.is_a?(Hash) && document.keys.sort == %w[cases schema], "#{file} top-level schema differs")
        assert(document["schema"] == "spec-014-v1", "#{file} version differs")
        assert(document["cases"].is_a?(Array), "#{file} cases must be a sequence")
        @files << file
        document.fetch("cases").each do |fixture|
          validate_case(fixture, file, fields, allowed_classes)
        end
      end
      self
    end

    private

    def manifest_rows
      rows = tsv_rows(@root.join("fixture-manifest.tsv"), 5)
      assert(rows.map { |row| row.fetch(0).to_i } == (1..5).to_a, "fixture manifest order differs")
      rows
    end

    def schema_fields
      rows = tsv_rows(@root.join("shared-field-schema.tsv"), 4)
      fields = rows.map(&:first)
      assert(fields.uniq.length == fields.length, "shared-field schema duplicates a field")
      fields
    end

    def tsv_rows(path, width)
      path.each_line.each_with_object([]) do |line, rows|
        next if line.start_with?("#") || line.strip.empty?

        fields = line.chomp.split("\t", -1)
        assert(fields.length == width, "#{path.basename} row width differs")
        rows << fields
      end
    end

    def validate_case(fixture, file, fields, allowed_classes)
      assert(fixture.is_a?(Hash), "#{file} case must be a mapping")
      assert(fixture.keys == fields, "#{file} #{fixture["fixtureID"] || "unnamed"} shared-field order or set differs")
      id = fixture.fetch("fixtureID")
      assert(id.match?(/\Aspec014-[a-z0-9]+(?:-[a-z0-9]+)*\z/), "invalid fixture ID #{id}")
      assert(!@cases_by_id.key?(id), "duplicate fixture ID #{id}")
      validate_set(id, "criteria", fixture.fetch("criteria"), CRITERIA)
      validate_set(id, "evidenceClasses", fixture.fetch("evidenceClasses"), allowed_classes & EVIDENCE_CLASSES)
      validate_set(id, "profiles", fixture.fetch("profiles"), PROFILES)
      fields.drop(4).each do |field|
        value = fixture.fetch(field)
        assert(value == "none" || value.is_a?(Hash) || value.is_a?(Array), "#{id} #{field} has invalid shape")
        reject_profile_private_expectations(id, field, value)
      end
      @cases_by_id[id] = { "file" => file, "case" => fixture }
    end

    def validate_set(id, field, values, allowed)
      assert(values.is_a?(Array) && !values.empty?, "#{id} #{field} is empty")
      assert(values.uniq.length == values.length, "#{id} #{field} contains duplicates")
      assert((values - allowed).empty?, "#{id} #{field} contains unknown values")
    end

    def reject_profile_private_expectations(id, field, value)
      case value
      when Hash
        profile_keys = value.keys.map(&:to_s) & PROFILES
        assert(profile_keys.empty?, "#{id} #{field} contains profile-private expectation keys")
        value.each_value { |nested| reject_profile_private_expectations(id, field, nested) }
      when Array
        value.each { |nested| reject_profile_private_expectations(id, field, nested) }
      end
    end

    def assert(condition, message)
      raise ArgumentError, message unless condition
    end
  end
end
