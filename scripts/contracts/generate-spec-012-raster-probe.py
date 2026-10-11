#!/usr/bin/env python3
"""Translate immutable SPEC012 golden input/output data into an inline probe.

No expected pixels are computed by this generator or production raster code.
Both encodings and full/tiled damage regions compare every byte to the YAML.
"""
import json
import pathlib
import subprocess
import sys

source, destination = map(pathlib.Path, sys.argv[1:])
data = json.loads(subprocess.check_output(['ruby', '-rjson', '-ryaml', '-e',
    'puts YAML.load_file(ARGV[0]).to_json', str(source)], text=True))
lines = ['''import GiftUI
import GiftUICapabilities
import GiftUIRenderCore
import GiftUISurfaceCore
import GiftUIRasterCore
private struct GoldenStroke: StraightLineStrokeView {
    let header: StraightLineStrokeHeader
    var points: InlineArray<4, Point> = .init(repeating: Point(x: 0, y: 0))
    var subpaths: InlineArray<4, SubpathRange?> = .init(repeating: nil)
    func point(at index: UInt16) -> Point? { index < header.pointCount ? points[Int(index)] : nil }
    func subpath(at index: UInt16) -> SubpathRange? { index < header.subpathCount ? subpaths[Int(index)] : nil }
}
private func rectangle(_ x: Int32, _ y: Int32, _ w: Int32, _ h: Int32) -> Rect {
    Rect(origin: Point(x: x, y: y), size: Size(width: w, height: h)!)!
}
''']
for number, vector in enumerate(data['vectors']):
    x, y, width, height = vector['surface']
    # Surface descriptors are zero-origin. Translate the entire declared
    # coordinate system, never the immutable mask or palette expectations.
    lines += [f'// Golden: {vector["name"]}', f'private func vector{number}() -> UInt32 {{',
              'var checks: UInt32 = 0', 'for encoded: UInt8 in 0..<2 {',
              'let encoding: CanonicalPixelEncoding = encoded == 0 ? .rgba8888 : .rgb565BigEndian',
              'for tiled in 0..<2 {',
              f'var pixels: InlineArray<{width*height}, UInt64> = .init(repeating: .max)',
              f'let bounds = rectangle(0, 0, {width}, {height})',
              f'let rows = tiled == 0 ? {height} : 1',
              f'let descriptor = RasterSurfaceDescriptor(bounds: bounds, encoding: encoding, bytesPerRow: UInt32({width}) * (encoded == 0 ? 4 : 2), realization: tiled == 0 ? .fullSurface : .tiled, regionWidth: {width}, regionHeight: UInt16(rows))!']
    for op in vector['operations']:
        assert len(op['points']) <= 4 and len(op['subpaths']) <= 4
        origin = op.get('origin', [0, 0])
        r, g, b = op['color']
        # Unlike surface's origin/size tuple, clip contains half-open edges.
        left, top, right, bottom = op['clip']
        clip_values = [left - x, top - y, right - left, bottom - top]
        clip = ', '.join(map(str, clip_values))
        lines += ['do {', f'var stroke = GoldenStroke(header: StraightLineStrokeHeader(color: Color(red: {r}, green: {g}, blue: {b}), lineWidth: {op["lineWidth"]}, lineCap: .{op["cap"]}, lineJoin: .{op["join"]}, surfaceOrigin: Point(x: {origin[0]}, y: {origin[1]}), inheritedClip: rectangle({clip}), pointCount: {len(op["points"])}, subpathCount: {len(op["subpaths"])}))']
        for i, point in enumerate(op['points']):
            lines += [f'stroke.points[{i}] = Point(x: {point[0]-x}, y: {point[1]-y})']
        for i, subpath in enumerate(op['subpaths']):
            lines += [f'stroke.subpaths[{i}] = SubpathRange(firstPoint: {subpath[0]}, pointCount: {subpath[1]})!']
        lines += [f'for row in stride(from: 0, to: {height}, by: rows) {{',
                  f'let result = RasterStrokeCoverage.rasterize(stroke, descriptor: descriptor, damageBounds: rectangle(0, Int32(row), {width}, Int32(rows))) {{ point, pixel in',
                  'let bytes = UInt64(pixel.byte0) | (UInt64(pixel.byte1) << 8) | (UInt64(pixel.byte2) << 16) | (UInt64(pixel.byte3) << 24)',
                  f'pixels[Int(point.y) * {width} + Int(point.x)] = bytes; return true',
                  '}', 'guard case .completed = result else { preconditionFailure("raster result") }; checks += 1', '}', '}']
    for i, symbol in enumerate(''.join(vector['expectedMask'])):
        if symbol == '.':
            expected = 'UInt64.max'
        else:
            palette = vector['palette'][symbol]
            def packed(values):
                return sum(value << (8 * index) for index, value in enumerate(values))
            expected = f'UInt64(encoded == 0 ? {packed(palette["rgba8888"])} : {packed(palette["rgb565"])})'
        lines += [f'precondition(pixels[{i}] == {expected}); checks += 1']
    lines += ['}', '}', 'return checks', '}']
lines += ['public func giftuiP06Raster() -> UInt32 {', 'var checks: UInt32 = 0']
lines += [f'checks += vector{i}()' for i in range(len(data['vectors']))]
lines += ['return checks', '}']
destination.write_text('\n'.join(lines) + '\n')
