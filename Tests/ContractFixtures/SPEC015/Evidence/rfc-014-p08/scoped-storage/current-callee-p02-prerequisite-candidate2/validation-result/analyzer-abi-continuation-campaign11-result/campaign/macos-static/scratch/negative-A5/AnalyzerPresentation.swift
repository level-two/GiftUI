import AnalyzerSchema
import GiftUI
import SignalAnalyzerDomain
@usableFromInline


// P02 declaration syntax from SA01/02/14: typed nested state/capture access.
// Full application migration and capture ownership remain P03/P06/P09.
package struct AnalyzerReadProbe<D:AnalyzerReadDomain>: View {@usableFromInline package typealias Domain = D

    @usableFromInline
    package let model:_GiftUIModelKey<AnalyzerModelSchema>
    @usableFromInline
    package let index: Int
    package init(model: _GiftUIModelKey<AnalyzerModelSchema>, index: Int) { self.model = model; self.index = index }
@ViewBuilder
@inlinable
@inline(__always)
package func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>)
    throws(_GiftUIAccessFailure) -> some View<D> {
    
        let state = (try AnalyzerRead<D>(model, read: read)).state()
        Text<D>(state.acquisitionState == .running ? "RUNNING" : "STOPPED")
        Text<D>(BoundedText(Int32((try AnalyzerRead<D>(model, read: read)).state().capture().count)))
        if (try AnalyzerRead<D>(model, read: read)).state().capture().count > 0 {
            Text<D>(BoundedText(Int32(try (try AnalyzerRead<D>(model, read: read)).state().capture().transition(index).channelID.rawValue)))
        }
}
}
