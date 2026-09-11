import GiftUI

func illegalPathCopy(_ path: borrowing Path) {
    let copied = copy path
    _ = consume copied
}

func consume(_ path: consuming Path) {}
