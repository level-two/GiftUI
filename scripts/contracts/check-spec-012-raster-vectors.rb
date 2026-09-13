#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE = ROOT.join("Tests/ContractFixtures/SPEC012/raster-vectors.yaml")
SCALE_BITS = 160
SCALE = 1 << SCALE_BITS
BOUNDARY_MARGIN = 1 << (SCALE_BITS + 48)

def fail_check(message)
  warn "SPEC-012 raster oracle failed: #{message}"
  exit 1
end

def rgb565(red, green, blue)
  red5 = ((red * 31) + 127) / 255
  green6 = ((green * 63) + 127) / 255
  blue5 = ((blue * 31) + 127) / 255
  value = (red5 << 11) | (green6 << 5) | blue5
  [value >> 8, value & 0xff]
end

def segment_covers?(center_x2, center_y2, first, second, width)
  dx = second[0] - first[0]
  dy = second[1] - first[1]
  length_squared = (dx * dx) + (dy * dy)
  return false if length_squared.zero?

  relative_x2 = center_x2 - (2 * first[0])
  relative_y2 = center_y2 - (2 * first[1])
  projection2 = (dx * relative_x2) + (dy * relative_y2)
  return false if projection2.negative? || projection2 > (2 * length_squared)

  cross2 = (dx * relative_y2) - (dy * relative_x2)
  (cross2 * cross2) <= (width * width * length_squared)
end

def disk_covers?(center_x2, center_y2, point, width)
  dx2 = center_x2 - (2 * point[0])
  dy2 = center_y2 - (2 * point[1])
  ((dx2 * dx2) + (dy2 * dy2)) <= (width * width)
end

def rounded_divide(numerator, denominator)
  sign = numerator.negative? ? -1 : 1
  magnitude = numerator.abs
  sign * ((magnitude + (denominator / 2)) / denominator)
end

def offset_corner(vertex, dx, dy, width, side)
  length_squared = (dx * dx) + (dy * dy)
  root = Integer.sqrt(length_squared * SCALE * SCALE)
  fail_check("zero tangent supplied to offset calculation") if root.zero?

  normal_x = side * dy
  normal_y = side * -dx
  denominator = 2 * root
  offset_x = rounded_divide(normal_x * width * SCALE * SCALE, denominator)
  offset_y = rounded_divide(normal_y * width * SCALE * SCALE, denominator)
  [(vertex[0] * SCALE) + offset_x, (vertex[1] * SCALE) + offset_y]
end

def cross(first_x, first_y, second_x, second_y)
  (first_x * second_y) - (first_y * second_x)
end

def line_intersection(first, first_direction, second, second_direction)
  denominator = cross(*first_direction, *second_direction)
  fail_check("parallel tangents supplied to join intersection") if denominator.zero?

  delta_x = second[0] - first[0]
  delta_y = second[1] - first[1]
  numerator = cross(delta_x, delta_y, *second_direction)
  parameter = Rational(numerator, denominator)
  [
    Rational(first[0]) + (first_direction[0] * parameter),
    Rational(first[1]) + (first_direction[1] * parameter)
  ]
end

def polygon_covers?(center_x2, center_y2, vertices)
  point_x = Rational(center_x2 * SCALE, 2)
  point_y = Rational(center_y2 * SCALE, 2)
  signs = vertices.each_index.each_with_object([]) do |index, result|
    first = vertices[index]
    second = vertices[(index + 1) % vertices.length]
    edge_x = second[0] - first[0]
    edge_y = second[1] - first[1]
    relative_x = point_x - first[0]
    relative_y = point_y - first[1]
    value = cross(edge_x, edge_y, relative_x, relative_y)
    result << (value.positive? ? 1 : -1) if value.abs > BOUNDARY_MARGIN
  end
  signs.empty? || signs.uniq.length == 1
end

def miter_join_geometry(previous, vertex, following, width)
  incoming = [vertex[0] - previous[0], vertex[1] - previous[1]]
  outgoing = [following[0] - vertex[0], following[1] - vertex[1]]
  turn = cross(*incoming, *outgoing)
  return nil if turn.zero?

  exterior_side = turn.positive? ? 1 : -1
  first_corner = offset_corner(vertex, *incoming, width, exterior_side)
  second_corner = offset_corner(vertex, *outgoing, width, exterior_side)
  intersection = line_intersection(first_corner, incoming, second_corner, outgoing)
  vertex_scaled = [vertex[0] * SCALE, vertex[1] * SCALE]
  delta_x = intersection[0] - vertex_scaled[0]
  delta_y = intersection[1] - vertex_scaled[1]
  distance_squared = (delta_x * delta_x) + (delta_y * delta_y)
  limit_squared = 25 * width * width * SCALE * SCALE
  fallback = distance_squared > limit_squared
  vertices = fallback ? [vertex_scaled, first_corner, second_corner] :
                        [vertex_scaled, first_corner, intersection, second_corner]
  [vertices, fallback]
end

def join_covers?(center_x2, center_y2, previous, vertex, following, width, join)
  return disk_covers?(center_x2, center_y2, vertex, width) if join == "round"

  geometry = miter_join_geometry(previous, vertex, following, width)
  geometry && polygon_covers?(center_x2, center_y2, geometry[0])
end

def nonzero_segments(points, subpath)
  start, count = subpath
  return [] if count < 2

  (start...(start + count - 1)).each_with_object([]) do |index, result|
    first = points.fetch(index)
    second = points.fetch(index + 1)
    result << [first, second] unless first == second
  end
end

def operation_covers?(operation, x, y)
  clip = operation.fetch("clip")
  return false unless x >= clip[0] && x < clip[2] && y >= clip[1] && y < clip[3]

  center_x2 = (2 * x) + 1
  center_y2 = (2 * y) + 1
  width = operation.fetch("lineWidth")
  points = operation.fetch("points")
  operation.fetch("subpaths").any? do |subpath|
    segments = nonzero_segments(points, subpath)
    next false if segments.empty?

    covered = segments.any? do |first, second|
      segment_covers?(center_x2, center_y2, first, second, width)
    end
    if !covered && operation.fetch("cap") == "round"
      covered = disk_covers?(center_x2, center_y2, segments.first[0], width) ||
                disk_covers?(center_x2, center_y2, segments.last[1], width)
    end
    if !covered
      segments.each_cons(2) do |first_segment, second_segment|
        next unless first_segment[1] == second_segment[0]

        if join_covers?(
          center_x2, center_y2, first_segment[0], first_segment[1],
          second_segment[1], width, operation.fetch("join")
        )
          covered = true
          break
        end
      end
    end
    covered
  end
end

def rasterize(vector)
  min_x, min_y, width, height = vector.fetch("surface")
  Array.new(height) do |row|
    y = min_y + row
    Array.new(width) do |column|
      x = min_x + column
      winner = vector.fetch("operations").reverse.find { |operation| operation_covers?(operation, x, y) }
      winner ? winner.fetch("symbol") : "."
    end.join
  end
end

document = YAML.safe_load(FIXTURE.read, aliases: false)
fail_check("schema differs") unless document.fetch("schema") == "spec-012-raster-vectors-v1"
vectors = document.fetch("vectors")
fail_check("vector corpus is empty") if vectors.empty?

vectors.each do |vector|
  name = vector.fetch("name")
  min_x, min_y, width, height = vector.fetch("surface")
  fail_check("#{name} invalid surface") unless [min_x, min_y, width, height].all? { |value| value.is_a?(Integer) } && width.positive? && height.positive?
  fail_check("#{name} must cite DR-006") unless vector.fetch("criteria") == ["DR-006"]
  operations = vector.fetch("operations")
  fail_check("#{name} operations are empty") if operations.empty?
  operations.each do |operation|
    line_width = operation.fetch("lineWidth")
    fail_check("#{name} line width is not positive") unless line_width.is_a?(Integer) && line_width.positive?
    fail_check("#{name} cap differs") unless %w[butt round].include?(operation.fetch("cap"))
    fail_check("#{name} join differs") unless %w[miter round].include?(operation.fetch("join"))
    clip = operation.fetch("clip")
    fail_check("#{name} clip differs") unless clip.length == 4 && clip.all? { |value| value.is_a?(Integer) }
    points = operation.fetch("points")
    fail_check("#{name} point differs") unless points.all? { |point| point.length == 2 && point.all? { |value| value.is_a?(Integer) } }
    operation.fetch("subpaths").each do |start, count|
      fail_check("#{name} subpath differs") unless start.is_a?(Integer) && count.is_a?(Integer) && start >= 0 && count >= 0 && (start + count) <= points.length
    end
  end

  if vector.fetch("covers").include?("miter-limit-fallback")
    fallback = operations.any? do |operation|
      operation.fetch("subpaths").any? do |subpath|
        nonzero_segments(operation.fetch("points"), subpath).each_cons(2).any? do |first, second|
          next false unless first[1] == second[0]

          geometry = miter_join_geometry(first[0], first[1], second[1], operation.fetch("lineWidth"))
          geometry && geometry[1]
        end
      end
    end
    fail_check("#{name} does not exercise the miter-limit fallback") unless fallback
  end

  expected = vector.fetch("expectedMask")
  actual = rasterize(vector)
  if ENV["SPEC012_EMIT_RASTER_MASKS"] == "1"
    puts "#{name}:"
    actual.each { |row| puts "  - #{row}" }
    next
  end
  fail_check("#{name} mask differs\nexpected: #{expected.inspect}\nactual:   #{actual.inspect}") unless actual == expected

  palette = vector.fetch("palette")
  vector.fetch("operations").each do |operation|
    symbol = operation.fetch("symbol")
    color = operation.fetch("color")
    entry = palette.fetch(symbol)
    fail_check("#{name} palette RGB differs for #{symbol}") unless entry.fetch("rgb") == color
    fail_check("#{name} RGBA8888 differs for #{symbol}") unless entry.fetch("rgba8888") == color + [255]
    fail_check("#{name} RGB565 differs for #{symbol}") unless entry.fetch("rgb565") == rgb565(*color)
  end
end

unless ENV["SPEC012_EMIT_RASTER_MASKS"] == "1"
  puts "SPEC-012 raster oracle passed: #{vectors.length} golden masks and exact encodings match."
end
