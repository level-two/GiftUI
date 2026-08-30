let checksum = GiftUIFailureProfileCorpusProbe.checksum()
guard checksum == 69 else { fatalError("profile corpus probe mismatch") }
print("profile_corpus_checksum=\(checksum)")
