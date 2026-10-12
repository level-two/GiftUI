import P08CounterRuntime
import Darwin
@main struct Main { static func main() { setbuf(stdout, nil); print("model begin"); print(p08CounterModel()); print("semantic begin"); print(p08CounterSemantic()); print("fixed begin"); print(p08CounterFixedStorage()); print("coordinator begin"); print(p08CounterCoordinator()); print("host begin"); print(p08CounterHost()) } }
