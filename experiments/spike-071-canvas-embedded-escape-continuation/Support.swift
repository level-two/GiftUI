// Finite disposable traversal/draw owner, not production SemanticCore/Layout.
struct Recorder {
    var begins: UInt32 = 0
    var ends: UInt32 = 0
    var lines: UInt32 = 0
    var sumX: Int32 = 0
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
func counterText(_ value: UInt32) -> BoundedText {
    switch value {
    case 0: return BoundedText("0")!
    case 2: return BoundedText("2")!
    case 3: return BoundedText("3")!
    default: return BoundedText("?")!
    }
}
struct StagedVisitor: _GiftUISemanticTraversalVisitor {
    var first: CounterCanvas?
    var second: CounterCanvas?
    var trace: TraceCanvas?
    var text: BoundedText?
    var canvases: UInt32 = 0
    var customBodies: UInt32 = 0
    var invoked: UInt32 = 0
    var layoutComplete = false
    mutating func visitCustomView<D: View>(_ declaration: borrowing D, body: () -> D.Body) {
        customBodies += 1
        body()._giftUITraverse(&self)
    }
    mutating func visitStatefulCustomView<D: View & _GiftUIObservableStateHost>(
        _ declaration: borrowing D, body: (borrowing D) -> D.Body) {
        customBodies += 1
        body(declaration)._giftUITraverse(&self)
    }
    mutating func visitEmpty() {}
    mutating func visitFixed<A: View, B: View>(_ a: borrowing A, _ b: borrowing B) {
        a._giftUITraverse(&self); b._giftUITraverse(&self)
    }
    mutating func visitFixed<A: View, B: View, C: View>(_ a: borrowing A, _ b: borrowing B, _ c: borrowing C) {
        visitFixed(a, b); c._giftUITraverse(&self)
    }
    mutating func visitFixed<A: View, B: View, C: View, D: View>(_ a: borrowing A, _ b: borrowing B, _ c: borrowing C, _ d: borrowing D) {
        visitFixed(a, b, c); d._giftUITraverse(&self)
    }
    mutating func visitFixed<A: View, B: View, C: View, D: View, E: View>(_ a: borrowing A, _ b: borrowing B, _ c: borrowing C, _ d: borrowing D, _ e: borrowing E) {
        visitFixed(a, b, c, d); e._giftUITraverse(&self)
    }
    mutating func visitConditionalFirst<A: View, B: View>(_ content: borrowing A, second: B.Type) { content._giftUITraverse(&self) }
    mutating func visitConditionalSecond<A: View, B: View>(first: A.Type, _ content: borrowing B) { content._giftUITraverse(&self) }
    mutating func visitOptionalAbsent<C: View>(_ content: C.Type) {}
    mutating func visitOptionalPresent<C: View>(_ content: borrowing C) { content._giftUITraverse(&self) }
    mutating func visitPrimitive<P: _GiftUISemanticPrimitivePayload>(_ payload: borrowing P) {
        let owned = copy payload
        if let canvas = owned as? CounterCanvas {
            if first == nil { first = canvas } else { precondition(second == nil); second = canvas }
            canvases += 1
        } else if let canvas = owned as? TraceCanvas {
            precondition(trace == nil); trace = canvas; canvases += 1
        } else if let label = owned as? _GiftUITextPayload {
            if case .admitted(let value) = label.content { text = value }
        }
    }
    mutating func visitPrimitive<C: View, P: _GiftUISemanticPrimitivePayload>(content: borrowing C, payload: borrowing P) {
        visitPrimitive(payload); content._giftUITraverse(&self)
    }
    mutating func visitActionPrimitive<P: _GiftUISemanticActionPayload>(_ payload: borrowing P) {}
    mutating func visitActionPrimitive<C: View, P: _GiftUISemanticActionPayload>(content: borrowing C, payload: borrowing P) { content._giftUITraverse(&self) }
    mutating func visitModifier<C: View, P: _GiftUISemanticModifierPayload>(content: borrowing C, payload: borrowing P) { content._giftUITraverse(&self) }
    mutating func clear() { first = nil; second = nil; trace = nil }
    mutating func draw(read: borrowing FrameRead, context: inout GraphicsContext) throws(DrawingError) {
        guard layoutComplete else { throw .invalidPhase }
        defer { clear() }
        let bounds = Rect(origin: Point(x: 0, y: 0), size: Size(width: 100, height: 10)!)!
        if let first { try first.draw(in: bounds, context: &context, read: read); invoked += 1 }
        if let second { try second.draw(in: bounds, context: &context, read: read); invoked += 1 }
        if let trace { try trace.draw(in: bounds, context: &context, read: read); invoked += 1 }
    }
}
