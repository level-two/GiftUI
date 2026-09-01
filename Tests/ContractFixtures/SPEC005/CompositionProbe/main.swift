import GiftUIReferenceTextResources
import GiftUITextResources

private func resultName(
    _ result: TextResourceValidationResult
) -> String {
    switch result {
    case .valid:
        "valid"
    case let .invalid(error):
        "invalid:\(error.rawValue)"
    }
}

let resourcePackage = GiftUIReferenceTextResources.targetPackage
let adoptedDigest = TextResourceDigest(
    word0: 0xbd14de9f,
    word1: 0xf2baaaf4,
    word2: 0x64c130d5,
    word3: 0xe2d05540,
    word4: 0x04a4055c,
    word5: 0xc57a8c16,
    word6: 0xa65fe2cc,
    word7: 0x39394910
)

print(
    "resource_matches_adopted=\(resourcePackage.metrics.descriptor.resource.rawValue == adoptedDigest)"
)
print("instance_count=\(resourcePackage.metrics.descriptor.instanceCount)")
print("realization_count=\(resourcePackage.metrics.descriptor.realizationCount)")
print(
    "bitmap_available=\(resourcePackage.raster.isPayloadAvailable(for: RasterRealizationID(rawValue: 0)))"
)
print(
    "outline_available=\(resourcePackage.raster.isPayloadAvailable(for: RasterRealizationID(rawValue: 1)))"
)
print(
    "bitmap_validation=\(resultName(TextResourceValidator.validate(resourcePackage, requiring: RasterRealizationID(rawValue: 0))))"
)
print(
    "outline_validation=\(resultName(TextResourceValidator.validate(resourcePackage, requiring: RasterRealizationID(rawValue: 1))))"
)
