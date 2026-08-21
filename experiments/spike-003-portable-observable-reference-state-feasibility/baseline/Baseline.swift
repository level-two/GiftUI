// Call-shaped non-observable control image for SPIKE-003.

@_silgen_name("spike003_baseline_reset") func storageReset()
@_silgen_name("spike003_baseline_identity") func modelIdentity(_ slot: UInt8) -> UInt16
@_silgen_name("spike003_baseline_control") func modelControl(_ slot: UInt8) -> Int32
@_silgen_name("spike003_baseline_capture") func modelCapture(_ slot: UInt8) -> Int32
@_silgen_name("spike003_baseline_derived") func modelDerived(_ slot: UInt8) -> Int32
@_silgen_name("spike003_baseline_add_control") func modelAddControl(_ slot: UInt8, _ delta: Int32)
@_silgen_name("spike003_baseline_add_capture") func modelAddCapture(_ slot: UInt8, _ delta: Int32)

struct BaselineModel {
    let slot: UInt8
    @inline(never) var identity: UInt16 { modelIdentity(slot) }
    @inline(never) var control: Int32 { modelControl(slot) }
    @inline(never) var capture: Int32 { modelCapture(slot) }
    @inline(never) var derived: Int32 { modelDerived(slot) }
    @inline(never) func addControl(_ delta: Int32) { modelAddControl(slot, delta) }
    @inline(never) func admitCapture(_ delta: Int32) { modelAddCapture(slot, delta) }
}

@propertyWrapper
struct State {
    var wrappedValue: BaselineModel
    init(wrappedValue: BaselineModel) { self.wrappedValue = wrappedValue }
}

struct PortableFixture {
    @State var model: BaselineModel
    init(model: BaselineModel) { _model = State(wrappedValue: model) }
    func digest() -> UInt32 {
        UInt32(bitPattern: model.control)
            ^ (UInt32(bitPattern: model.capture) << 7)
            ^ (UInt32(bitPattern: model.derived) << 15)
            ^ UInt32(model.identity)
    }
}

@_cdecl("spike003_swift_run")
public func spike003BaselineRun(_ seed: UInt32) -> UInt64 {
    storageReset()
    var fixture = PortableFixture(model: BaselineModel(slot: 0))
    var digest = seed ^ fixture.digest()
    for _ in 0..<20 {
        fixture.model.admitCapture(2)
    }
    digest ^= fixture.digest()
    fixture.model = BaselineModel(slot: 1)
    digest ^= fixture.digest()
    // Match candidate replacement/detach/stale-report control branches without
    // retaining observation state.
    digest ^= (fixture.model.identity == 2 ? 1 : 0) << 28
    digest ^= (fixture.model.control == 8 ? 1 : 0) << 27
    return UInt64(digest)
}
