import GiftUI

struct ControlsView: View {
    let decrement: () -> Void
    let increment: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button("-", action: decrement)
            Button("+", action: increment)
        }
    }
}
