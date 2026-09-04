import GiftUI

struct ExternalLeaf: View {
    var body: Never {
        fatalError("compile-only leaf")
    }
}

struct ExternalCustomView: View {
    var body: some View {
        ExternalLeaf()
    }
}

func acceptExternalCustomView(_ view: ExternalCustomView) {
    _ = view
}
