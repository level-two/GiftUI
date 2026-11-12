import GiftUIFailureCore
import GiftUIHostConfiguration
import GiftUIRuntimeCore

#if GIFTUI_HOST_CALLEE_QUALIFICATION
@_noAllocation
package func p08HostAuditEquality(_ lhs: RuntimeStorageAudit, _ rhs: RuntimeStorageAudit) -> Bool {
    lhs.matchesForHostStartup(rhs)
}
@_noAllocation
package func p08HostLimitsEquality(_ lhs: RuntimeProfileLimits, _ rhs: RuntimeProfileLimits) -> Bool {
    lhs.matchesForHostStartup(rhs)
}
@_noAllocation
package func p08HostFixedPolicyAllowed(_ table: FixedMVPHostResidualPolicyTable,
    _ context: HostResidualPolicyContext) -> GiftUIAllowedDispositions {
    table.allowed(for: context)
}
@_noAllocation
package func p08HostFixedPolicySelection(_ table: FixedMVPHostResidualPolicyTable,
    _ context: HostResidualPolicyContext) -> GiftUIResidualDisposition {
    table.selection(for: context)
}
#endif
