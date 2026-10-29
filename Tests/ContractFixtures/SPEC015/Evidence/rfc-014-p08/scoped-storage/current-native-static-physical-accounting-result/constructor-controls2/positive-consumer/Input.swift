import AccountingConstructorProducer
@_noAllocation
@inline(never)
public func importedConstructor(_ value: Int) -> ScalarConstructor {
    ScalarConstructor(value)
}
