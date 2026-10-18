import GiftUI
func scope<D: _GiftUIReadDomain>(_: D.Type, _ slots: Span<D.Slot>) { _ = _GiftUIFrameRead<D>(slots: slots) }
