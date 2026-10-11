// Reduced control: actual supplied scopes, no runtime construction.
enum InvestigationOwner: ~Copyable, ~Escapable {
    case inert(InvestigationSupplied)
    @_lifetime(copy supplied)
    init(supplied: consuming InvestigationSupplied) { self = .inert(consume supplied) }
    mutating func activate() {}
    mutating func quiesce() {}
}
