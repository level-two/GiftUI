import GiftUI
import GiftUISemanticCore
import GiftUIRenderCore
import GiftUITextResources
import GiftUILayout
import GiftUIExecution
import GiftUIDrawing
// Scoped C drawing recorder borrowed from SPIKE-071; no traversal replacement.
struct Recorder {
    var begins: UInt32 = 0
    var ends: UInt32 = 0
    var lines: UInt32 = 0
    var sumX: Int32 = 0
    var order: UInt32 = 0
    var strokes: UInt32 = 0
}
func beginPath(_ raw: UnsafeMutableRawPointer, _ generation: UInt32,
               _ path: UnsafeMutablePointer<UInt32>) -> UInt8 {
    raw.assumingMemoryBound(to: Recorder.self).pointee.begins += 1
    path.pointee = 1
    return 0
}
func endPath(_ raw: UnsafeMutableRawPointer, _ generation: UInt32, _ path: UInt32) -> UInt8 {
    raw.assumingMemoryBound(to: Recorder.self).pointee.ends += 1
    return 0
}
func movePath(_ raw: UnsafeMutableRawPointer, _ generation: UInt32, _ path: UInt32,
              _ x: Int32, _ y: Int32) -> UInt8 { 0 }
func linePath(_ raw: UnsafeMutableRawPointer, _ generation: UInt32, _ path: UInt32,
              _ x: Int32, _ y: Int32) -> UInt8 {
    let recorder = raw.assumingMemoryBound(to: Recorder.self)
    recorder.pointee.lines += 1
    recorder.pointee.sumX += x
    recorder.pointee.order = recorder.pointee.order * 10 + UInt32(x)
    return 0
}
func strokePath(_ raw: UnsafeMutableRawPointer, _ generation: UInt32, _ path: UInt32,
                _ red: UInt8, _ green: UInt8, _ blue: UInt8, _ width: Int32,
                _ cap: UInt8, _ join: UInt8) -> UInt8 {
    raw.assumingMemoryBound(to: Recorder.self).pointee.strokes += 1
    return 0
}
func makeContext(_ raw: UnsafeMutableRawPointer) -> GraphicsContext {
    GraphicsContext(storage: raw, generation: 1, operations: _GiftUIDrawingOperations(
        beginPath: beginPath, endPath: endPath, movePath: movePath,
        addLineToPath: linePath, strokePath: strokePath))
}
func drawBar(value: UInt32, scale: UInt32, context: inout GraphicsContext) throws(DrawingError) {
    try context.withPath { (context: inout GraphicsContext, path: inout Path) throws(DrawingError) in
        try path.move(to: Point(x: 0, y: 0))
        // Deliberately fail inside an active path to exercise real cleanup.
        guard value != 99 else { throw .invalidValue }
        guard value <= 1000 && scale <= 1000 else { throw .invalidValue }
        try path.addLine(to: Point(x: Int32(value + scale), y: 1))
        try context.stroke(path, with: .color(.white), lineWidth: 1)
    }
}
