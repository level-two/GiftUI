package enum LayoutArithmeticError: Error, Equatable {
    case overflow
}

package enum LayoutArithmetic {
    package static func add(
        _ lhs: Int,
        _ rhs: Int
    ) throws(LayoutArithmeticError) -> Int {
        let (result, overflow) = lhs.addingReportingOverflow(rhs)
        guard !overflow else {
            throw .overflow
        }
        return result
    }

    package static func subtract(
        _ lhs: Int,
        _ rhs: Int
    ) throws(LayoutArithmeticError) -> Int {
        let (result, overflow) = lhs.subtractingReportingOverflow(rhs)
        guard !overflow else {
            throw .overflow
        }
        return result
    }

    package static func multiply(
        _ lhs: Int,
        _ rhs: Int
    ) throws(LayoutArithmeticError) -> Int {
        let (result, overflow) = lhs.multipliedReportingOverflow(by: rhs)
        guard !overflow else {
            throw .overflow
        }
        return result
    }

    package static func requireAdd(
        _ lhs: Int,
        _ rhs: Int,
        operation: StaticString
    ) -> Int {
        require(try? add(lhs, rhs), operation: operation)
    }

    package static func requireSubtract(
        _ lhs: Int,
        _ rhs: Int,
        operation: StaticString
    ) -> Int {
        require(try? subtract(lhs, rhs), operation: operation)
    }

    package static func requireMultiply(
        _ lhs: Int,
        _ rhs: Int,
        operation: StaticString
    ) -> Int {
        require(try? multiply(lhs, rhs), operation: operation)
    }

    private static func require(
        _ result: Int?,
        operation: StaticString
    ) -> Int {
        guard let result else {
            preconditionFailure("Layout arithmetic overflow while \(operation)")
        }
        return result
    }
}
