#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "nrf-resource-data.h"

int spike005_validate(void);
int spike005_validate_inputs(
    const unsigned char *, size_t, const unsigned char[32],
    const unsigned char *, size_t, const unsigned char[32]
);

int main(void) {
    int nominal = spike005_validate();
    unsigned char *manifest = malloc(spike005_manifest_count);
    unsigned char *bitmap = malloc(spike005_bitmap_count);
    if (manifest == NULL || bitmap == NULL) {
        return 10;
    }
    memcpy(manifest, spike005_manifest, spike005_manifest_count);
    memcpy(bitmap, spike005_bitmap, spike005_bitmap_count);
    manifest[0] ^= 1;
    int manifest_tamper = spike005_validate_inputs(
        manifest, spike005_manifest_count, spike005_manifest_sha256,
        bitmap, spike005_bitmap_count, spike005_bitmap_sha256
    );
    manifest[0] ^= 1;
    bitmap[0] ^= 1;
    int bitmap_tamper = spike005_validate_inputs(
        manifest, spike005_manifest_count, spike005_manifest_sha256,
        bitmap, spike005_bitmap_count, spike005_bitmap_sha256
    );
    free(manifest);
    free(bitmap);
    printf("nominal=%d manifest_tamper=%d bitmap_tamper=%d\n",
        nominal, manifest_tamper, bitmap_tamper);
    return nominal == 0 && manifest_tamper == 2 && bitmap_tamper == 3 ? 0 : 11;
}
