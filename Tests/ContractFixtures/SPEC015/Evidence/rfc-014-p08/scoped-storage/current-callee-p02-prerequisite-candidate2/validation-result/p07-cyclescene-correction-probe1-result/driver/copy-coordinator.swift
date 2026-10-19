func copyCoordinator<M: ~Copyable, S>(_ coordinator: borrowing ScopedCoordinator<M, S>) { let other = copy coordinator; _ = other }
