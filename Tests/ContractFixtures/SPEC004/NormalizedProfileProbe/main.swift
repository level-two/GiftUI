let checksum = NormalizedProfileProbe.checksum()
guard checksum == 12 else { fatalError("normalized profile probe mismatch") }
print("normalized_profile_checksum=\(checksum)")
