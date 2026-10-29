// Same-module boundary checks; never used as the production module proof.
#if GIFTUI_NAMESPACE_IMPORTED_CHECK
    import GiftUISemanticCore
    import GiftUIObservableState

    @_noAllocation
    @inline(never)
    package func namespaceImportedCaller(_ twice: Bool) -> UInt32 {
        var model = ObservableModelOwnerNamespace()
        var semantic = SemanticRecordOwnerNamespace()
        let modelValue: UInt32
        do {
            modelValue = try model.issue().rawValue
            if twice { _ = try model.issue() }
        } catch {
            guard case .modelGenerationExhausted = error else { return 101 }
            return 102
        }
        do {
            let semanticValue = try semantic.issue().rawValue
            if twice { _ = try semantic.issue() }
            return modelValue &+ semanticValue
        } catch {
            guard case .invalidIdentity = error else { return 103 }
            return 104
        }
    }
#elseif GIFTUI_SEMANTIC_NAMESPACE_TEST
    @main
    enum NamespaceQualification {
        static func main() {
            var ordinary = SemanticRecordOwnerNamespace()
            do {
                let identity = try ordinary.issue()
                precondition(identity.rawValue == 0)
                let identity = try ordinary.issue()
                precondition(identity.rawValue == 1)
            } catch { preconditionFailure("ordinary semantic issuance") }
            var boundary = SemanticRecordOwnerNamespace(nextValue: .max)
            do {
                let identity = try boundary.issue()
                precondition(identity.rawValue == .max)
            } catch { preconditionFailure("semantic maximum once") }
            for _ in 0 ..< 2 {
                do {
                    _ = try boundary.issue()
                    preconditionFailure("semantic exhaustion")
                } catch {
                    guard case .invalidIdentity = error else {
                        preconditionFailure("semantic typed error")
                    }
                }
            }
            var exhausted = SemanticRecordOwnerNamespace(nextValue: nil)
            do {
                _ = try exhausted.issue()
                preconditionFailure("semantic initially exhausted")
            } catch {
                guard case .invalidIdentity = error else {
                    preconditionFailure("semantic initial typed error")
                }
            }
            do {
                let identity = try ordinary.issue()
                precondition(identity.rawValue == 2)
            } catch { preconditionFailure("semantic independent cursor") }
            print(
                "semantic namespace: zero, sequential, max-once, sticky exhaustion twice, initially exhausted, independent cursor PASS"
            )
        }
    }
#elseif GIFTUI_MODEL_NAMESPACE_TEST
    @main
    enum NamespaceQualification {
        static func main() {
            var ordinary = ObservableModelOwnerNamespace()
            precondition(!ordinary.isExhausted)
            do {
                let identity = try ordinary.issue()
                precondition(identity.rawValue == 0)
                let identity = try ordinary.issue()
                precondition(identity.rawValue == 1)
            } catch { preconditionFailure("ordinary model issuance") }
            var boundary = ObservableModelOwnerNamespace(nextValue: .max)
            precondition(!boundary.isExhausted)
            do {
                let identity = try boundary.issue()
                precondition(identity.rawValue == .max)
            } catch { preconditionFailure("model maximum once") }
            precondition(boundary.isExhausted)
            for _ in 0 ..< 2 {
                do {
                    _ = try boundary.issue()
                    preconditionFailure("model exhaustion")
                } catch {
                    guard case .modelGenerationExhausted = error else {
                        preconditionFailure("model typed error")
                    }
                }
            }
            var exhausted = ObservableModelOwnerNamespace(nextValue: nil)
            precondition(exhausted.isExhausted)
            do {
                _ = try exhausted.issue()
                preconditionFailure("model initially exhausted")
            } catch {
                guard case .modelGenerationExhausted = error else {
                    preconditionFailure("model initial typed error")
                }
            }
            do {
                let identity = try ordinary.issue()
                precondition(identity.rawValue == 2)
            } catch { preconditionFailure("model independent cursor") }
            precondition(!ordinary.isExhausted)
            print(
                "model namespace: zero, sequential, max-once, sticky exhaustion twice, initially exhausted, independent cursor, exhaustion status PASS"
            )
        }
    }
#endif
