// Generated-handle candidate for SPIKE-003. Disposable evidence only.

@_silgen_name("spike003_reset") func storageReset()
@_silgen_name("spike003_model_identity") func modelIdentity(_ slot: UInt8) -> UInt16
@_silgen_name("spike003_model_control") func modelControl(_ slot: UInt8) -> Int32
@_silgen_name("spike003_model_capture") func modelCapture(_ slot: UInt8) -> Int32
@_silgen_name("spike003_model_derived") func modelDerived(_ slot: UInt8) -> Int32
@_silgen_name("spike003_model_add_control") func modelAddControl(_ slot: UInt8, _ delta: Int32)
@_silgen_name("spike003_model_add_capture") func modelAddCapture(_ slot: UInt8, _ delta: Int32)
@_silgen_name("spike003_materialize") func materialize(_ location: UInt8, _ model: UInt8) -> UInt32
@_silgen_name("spike003_replace") func replace(_ location: UInt8, _ model: UInt8) -> UInt32
@_silgen_name("spike003_detach") func detach(_ location: UInt8)
@_silgen_name("spike003_report") func cReport(_ token: UInt32) -> UInt8
@_silgen_name("spike003_take_dirty") func takeDirty(_ location: UInt8) -> UInt8
@_silgen_name("spike003_read_counters") func readCounters() -> UInt64

@propertyWrapper
struct State<Value> {
    var wrappedValue: Value
    init(wrappedValue: Value) { self.wrappedValue = wrappedValue }
}

struct ObservableModel {
    let slot: UInt8
    var identity: UInt16 { modelIdentity(slot) }
    var control: Int32 { modelControl(slot) }
    var capture: Int32 { modelCapture(slot) }
    var derived: Int32 { modelDerived(slot) }

    @inline(never) func addControl(_ delta: Int32) { modelAddControl(slot, delta) }
    @inline(never) func admitCapture(_ delta: Int32) { modelAddCapture(slot, delta) }
}

@inline(never)
func reportToken(_ token: UInt32) -> UInt8 { cReport(token) }

struct PortableFixture {
    @State var model: ObservableModel

    init(model: ObservableModel) {
        _model = State(wrappedValue: model)
    }

    func digest() -> UInt32 {
        UInt32(bitPattern: model.control)
            ^ (UInt32(bitPattern: model.capture) << 7)
            ^ (UInt32(bitPattern: model.derived) << 15)
            ^ UInt32(model.identity)
    }
}

@_cdecl("spike003_swift_run")
public func spike003GeneratedHandleRun(_ seed: UInt32) -> UInt64 {
    storageReset()
    var fixture = PortableFixture(model: ObservableModel(slot: 0))
    let firstToken = materialize(0, fixture.model.slot)
    var digest = seed ^ fixture.digest()

    for _ in 0..<20 {
        fixture.model.admitCapture(2)
    }
    digest ^= UInt32(takeDirty(0)) << 30

    let replacement = ObservableModel(slot: 1)
    let replacementToken = replace(0, replacement.slot)
    fixture.model = replacement
    digest ^= fixture.digest()
    digest ^= UInt32(reportToken(firstToken)) << 29
    digest ^= UInt32(reportToken(replacementToken)) << 28
    detach(0)
    digest ^= UInt32(reportToken(replacementToken)) << 27
    return (readCounters() & 0xffff_ffff_0000_0000) ^ UInt64(digest)
}
