// The selected Embedded static store/transfer path is materialized separately
// from golden pixel controls and any non-Embedded dynamic test branches.
@_cdecl("giftui_p06_static_components")
public func giftuiP06StaticComponents() -> UInt32 { giftuiP06Stores(dynamic: false) }

@_cdecl("giftui_p06_other_components")
public func giftuiP06OtherComponents() -> UInt32 {
    giftuiP06ErrorMappings() + giftuiP06FiniteTables() + giftuiP06Geometry() + giftuiP06Raster()
}
