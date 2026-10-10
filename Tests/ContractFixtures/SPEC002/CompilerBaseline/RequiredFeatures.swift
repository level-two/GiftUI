#if !hasFeature(LifetimeDependence)
#error("RFC-014 requires LifetimeDependence")
#endif
#if !hasFeature(Lifetimes)
#error("RFC-014 requires Lifetimes")
#endif

struct RequiredScopedRead<Element>: ~Escapable {
    let elements: Span<Element>

    @_lifetime(copy elements)
    init(_ elements: Span<Element>) {
        self.elements = elements
    }
}
