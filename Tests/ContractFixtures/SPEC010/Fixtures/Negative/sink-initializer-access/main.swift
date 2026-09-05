import GiftUI

let sink = _GiftUIObservableChangeSink(
    attachment: _GiftUIObservationAttachment(slot: 0, generation: 0),
    reportRoute: { _ in .dirtied }
)
