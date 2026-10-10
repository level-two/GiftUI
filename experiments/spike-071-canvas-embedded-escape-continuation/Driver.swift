func check(_ condition: Bool, _ bit: UInt32, _ failures: inout UInt32) {
    if !condition { failures |= 1 << bit }
}
func scalarFailure(_ read: borrowing FrameRead, _ key: ModelKey, _ field: UInt16 = 0) -> AccessFailure? {
    do { _ = try read.scalar(key, field: field); return nil }
    catch { return error }
}
func testFrame(_ owner: borrowing ModelOwner, _ key: ModelKey,
               _ recorder: UnsafeMutablePointer<Recorder>, expected: UInt32,
               scale: UInt32, old: ModelKey?, failures: inout UInt32) {
    let read = owner.read()
    do {
        let observedValue = try read.scalar(key, field: 0)
        let observedScale = try read.scalar(key, field: 1)
        check(observedValue == expected && observedScale == scale, 2, &failures)
        check(try traceLevel_read(model: AnalyzerModel(key: key), index: 17, read: read) == 42, 3, &failures)
    } catch { failures |= (1 << 2) | (1 << 3) }
    check(scalarFailure(read, ModelKey(owner: key.owner + 1, generation: 1, epoch: key.epoch)) == .wrongOwner, 4, &failures)
    check(scalarFailure(read, ModelKey(owner: key.owner, generation: 2, epoch: key.epoch)) == .staleGeneration, 5, &failures)
    check(scalarFailure(read, key, 7) == .invalidField, 6, &failures)
    if let old { check(scalarFailure(read, old) == .staleFrame, 7, &failures) }
    var visitor = StagedVisitor()
    do {
        let body = try CounterScreen(model: CounterModel(key: key)).evaluate(read: read)
        body._giftUITraverse(&visitor)
    } catch { failures |= 1 << 8 }
    check(visitor.canvases == 2 && visitor.customBodies == 0 && visitor.text == counterText(expected), 8, &failures)
    check(recorder.pointee.begins == 0 && visitor.invoked == 0, 9, &failures)
    var context = makeContext(UnsafeMutableRawPointer(recorder))
    do { try visitor.draw(read: read, context: &context); failures |= 1 << 10 }
    catch { check(error == .invalidPhase && visitor.first != nil, 10, &failures) }
    visitor.layoutComplete = true // Synthetic layout boundary, not real Layout.
    do { try visitor.draw(read: read, context: &context) }
    catch { failures |= 1 << 11 }
    check(visitor.invoked == 2 && recorder.pointee.sumX == Int32(2 * (expected + scale)), 11, &failures)
    check(visitor.first == nil && visitor.second == nil && recorder.pointee.begins == 2 && recorder.pointee.ends == 2, 12, &failures)
    TraceCanvas(model: AnalyzerModel(key: key))._giftUITraverse(&visitor)
    do { try visitor.draw(read: read, context: &context) }
    catch { failures |= 1 << 13 }
    check(visitor.invoked == 3 && recorder.pointee.sumX == Int32(2 * (expected + scale) + 43), 13, &failures)
    context.invalidate()
    var rejected = StagedVisitor()
    do {
        let body = try CounterScreen(model: CounterModel(key: ModelKey(owner: key.owner + 1, generation: 1, epoch: key.epoch))).evaluate(read: read)
        body._giftUITraverse(&rejected)
        failures |= 1 << 14
    } catch { check(error == .wrongOwner && rejected.canvases == 0, 14, &failures) }
}
func testDrawFailure(_ owner: borrowing ModelOwner, _ key: ModelKey,
                     _ recorder: UnsafeMutablePointer<Recorder>, failures: inout UInt32) {
    let read = owner.read()
    var visitor = StagedVisitor()
    CounterCanvas(model: CounterModel(key: key))._giftUITraverse(&visitor)
    CounterCanvas(model: CounterModel(key: key))._giftUITraverse(&visitor)
    visitor.layoutComplete = true
    var context = makeContext(UnsafeMutableRawPointer(recorder))
    do { try visitor.draw(read: read, context: &context); failures |= 1 << 17 }
    catch { check(error == .invalidValue, 17, &failures) }
    check(visitor.first == nil && visitor.second == nil && visitor.invoked == 0 && recorder.pointee.begins == 1 && recorder.pointee.ends == 1, 18, &failures)
    context.invalidate()
}
@_cdecl("spike071_driver")
func driver(_ raw: UnsafeMutableRawPointer, _ output: UnsafeMutableRawPointer) -> UInt32 {
    let values = raw.assumingMemoryBound(to: Transition.self)
    let recorder = output.assumingMemoryBound(to: Recorder.self)
    var owner = ModelOwner(current: UnsafeMutableBufferPointer(start: values, count: 404),
                           frozen: UnsafeMutableBufferPointer(start: values + 404, count: 404), identity: 7)
    var failures: UInt32 = 0
    check(MemoryLayout<Transition>.stride == 16, 0, &failures)
    check(scalarFailure(owner.read(), ModelKey(owner: 7, generation: 1, epoch: 0)) == .invalidPhase, 1, &failures)
    let initial = owner.freeze()!
    do {
        let read = owner.read()
        let initialValue = try read.scalar(initial, field: 0)
        let initialScale = try read.scalar(initial, field: 1)
        check(initialValue == CounterModel.initial0 && initialScale == CounterModel.initial1, 20, &failures)
    } catch { failures |= 1 << 20 }
    owner.finish(published: true)
    _ = owner.write(value: 2, scale: 8)
    _ = owner.writeTransition(at: 17, level: 42)
    let first = owner.freeze()!
    check(owner.freeze() == nil && owner.writeValue(70) == .invalidPhase && owner.writeTransition(at: 17, level: 77) == .invalidPhase, 15, &failures)
    check(owner.frozenRevision == owner.revision, 16, &failures)
    recorder.pointee = Recorder()
    testFrame(owner, first, recorder, expected: 2, scale: 8, old: nil, failures: &failures)
    owner.finish(published: true)
    check(!owner.dirty, 19, &failures)
    _ = owner.writeValue(3)
    let second = owner.freeze()!
    recorder.pointee = Recorder()
    testFrame(owner, second, recorder, expected: 3, scale: 8, old: first, failures: &failures)
    owner.finish(published: true)
    _ = owner.writeValue(99)
    let failing = owner.freeze()!
    recorder.pointee = Recorder()
    testDrawFailure(owner, failing, recorder, failures: &failures)
    owner.finish(published: false)
    check(owner.dirty && !owner.isFrozen, 19, &failures)
    return failures
}
