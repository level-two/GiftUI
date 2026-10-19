func copyOwner<M: ~Copyable, S>(_ owner: borrowing ScopedOwner<M, S>) { let other = copy owner; _ = other }
