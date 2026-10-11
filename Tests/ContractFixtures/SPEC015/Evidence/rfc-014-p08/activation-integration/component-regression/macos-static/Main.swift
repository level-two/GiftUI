import P08ScopedHostProbe
import RuntimeCycleProbe
@main struct Main { static func main() { print("P08 schema4 host component assertions=\(p08ScopedHostController() + p08Schema4Workload() + p08ActivationJoin()) failures=0") } }
