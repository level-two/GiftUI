struct InvestigationControl: ~Copyable, ~Escapable {
    let pointer: UnsafeMutablePointer<CycleControl>
    @_lifetime(borrow pointer)
    init(pointer: borrowing UnsafeMutablePointer<CycleControl>) { self.pointer = copy pointer }
    @_lifetime(copy other)
    private init(other: borrowing InvestigationControl) { pointer = other.pointer }
    @_lifetime(copy self)
    borrowing func borrowed() -> InvestigationControl { InvestigationControl(other: self) }
}
