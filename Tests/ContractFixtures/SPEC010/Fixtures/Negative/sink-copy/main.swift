func consumeSink(_ sink: consuming _GiftUIObservableChangeSink) {}

func attemptCopy(_ sink: consuming _GiftUIObservableChangeSink) {
    consumeSink(consume sink)
    consumeSink(consume sink)
}
