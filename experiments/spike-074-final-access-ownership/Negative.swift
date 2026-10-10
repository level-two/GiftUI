import GiftUI
import SignalAnalyzerDomain
import ApplicationSchema
import HostBridge
#if NEG_ESCAPE
struct InvalidStoredRead { let read: FrameRead<AnalyzerDomain> }
#endif
#if NEG_OVERLAP
func invalid(_ owner: inout Owner) throws(AccessFailure) -> UInt16 {
    let key = owner.key(0)
    let read = try owner.read()
    try owner.finish()
    let model = try AnalyzerRead(key, read: read)
    return model.count
}
#endif
