let checksum = GiftUIFoundationProfileCorpusProbe.checksum()
print("profile_corpus_checksum=\(checksum)")
precondition(checksum == 28)
