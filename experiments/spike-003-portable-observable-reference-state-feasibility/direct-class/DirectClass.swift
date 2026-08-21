// Direct Swift-reference candidate. Its Embedded compile/link result is evidence.

@propertyWrapper
struct State<Value> {
    var wrappedValue: Value
    init(wrappedValue: Value) { self.wrappedValue = wrappedValue }
}

final class ObservableModel {
    var control: Int32
    var capture: Int32
    var dirty = false

    init(control: Int32, capture: Int32) {
        self.control = control
        self.capture = capture
    }

    func addControl(_ delta: Int32) {
        control &+= delta
        dirty = true
    }

    func admitCapture(_ delta: Int32) {
        capture &+= delta
        dirty = true
    }
}

struct PortableFixture {
    @State var model: ObservableModel
    init(model: ObservableModel) { _model = State(wrappedValue: model) }
}

@inline(never)
func makeObservableModel() -> ObservableModel {
    ObservableModel(control: 1, capture: 2)
}

@inline(never)
func applyCapture(_ fixture: PortableFixture) {
    fixture.model.admitCapture(2)
}

@_cdecl("spike003_swift_run")
public func spike003DirectClassRun(_ seed: UInt32) -> UInt64 {
    let model = makeObservableModel()
    let fixture = PortableFixture(model: model)
    for _ in 0..<20 {
        applyCapture(fixture)
    }
    return UInt64(seed ^ UInt32(bitPattern: fixture.model.control)
        ^ (UInt32(bitPattern: fixture.model.capture) << 8)
        ^ (fixture.model.dirty ? 1 << 30 : 0))
}
