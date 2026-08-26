func illegalPathCopy(_ path: borrowing Path) {
    let copy = path
    _ = consume copy
}

func consume(_ path: consuming Path) {}
