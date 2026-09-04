#if GIFTUI_SPEC005_CANDIDATE
    @_cdecl("giftui_spec005_resource_probe")
    public func giftuiSpec005ResourceProbe(_ seed: UInt32) -> UInt32 {
        let resourcePackage = GiftUIReferenceTextResources.targetPackage
        guard
            TextResourceValidator.validate(
                resourcePackage,
                requiring: RasterRealizationID(rawValue: 0)
            ) == .valid,
            let instance = resourcePackage.metrics.instance(at: 0),
            let mapping = resourcePackage.metrics.mapScalar(
                0x41,
                in: instance.id
            )
        else { return UInt32.max }

        let glyph: GlyphID
        switch mapping {
        case let .exact(value), let .replacement(value):
            glyph = value
        }
        guard
            let metrics = resourcePackage.metrics.metrics(
                for: glyph,
                in: instance.id
            ),
            let record = resourcePackage.raster.record(
                for: glyph,
                realization: RasterRealizationID(rawValue: 0)
            )
        else { return UInt32.max }
        return resourcePackage.raster.withPayload(
            for: record,
            realization: RasterRealizationID(rawValue: 0)
        ) { bytes in
            seed &+ UInt32(glyph.rawValue) &+ UInt32(metrics.advanceX)
                &+ UInt32(bytes.count)
        } ?? UInt32.max
    }
#else
    @_cdecl("giftui_spec005_resource_probe")
    public func giftuiSpec005ResourceProbe(_ seed: UInt32) -> UInt32 {
        seed
    }
#endif
