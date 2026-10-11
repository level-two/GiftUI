@inline(never)
func invokeActivationCallback(_ body: () -> Int) -> Int { body() }
