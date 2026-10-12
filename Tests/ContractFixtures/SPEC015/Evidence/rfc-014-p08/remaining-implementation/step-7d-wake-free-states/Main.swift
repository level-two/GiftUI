import P08CounterRuntime
import Darwin
@main struct Main { static func main() { setbuf(stdout, nil); print("P08 counter components assertions=\(p08CounterModel() + p08CounterSemantic() + p08CounterFixedStorage() + p08CounterCoordinator() + p08CounterHost() + p08CounterDynamicHost()) failures=0") } }
