import GiftUI

struct StyledCustomView: View {
    var body: some View {
        Text("status")
            .foregroundStyle(.green)
            .background(.black)
            .foregroundStyle(.white)
    }
}

func requireView<Content: View>(_: Content) {}

requireView(StyledCustomView())
requireView(Text(BoundedText(42)).background(Color(red: 1, green: 2, blue: 3)))
