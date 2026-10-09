// Compiled with all 16 actual Sources/GiftUI Swift files, without transformations.
// This probes the declaration boundary, not a complete Semantic Core traversal.
struct OwnedScalarBody: View {
    let value: UInt64
    var body: some View {
        if value > 0 { Text("nonzero") } else { Text("zero") }
    }
}

func makeOwnedBody(_ owner: borrowing CaptureOwner) -> OwnedScalarBody {
    OwnedScalarBody(value: owner.withView { checksum($0) })
}

#if CAPTURE_IN_ACTUAL_CANVAS
func makeBorrowedCanvas(_ owner: borrowing CaptureOwner) -> Canvas {
    let capture = owner.view()
    return Canvas { _, _ in
        _ = checksum(capture)
    }
}
#endif
