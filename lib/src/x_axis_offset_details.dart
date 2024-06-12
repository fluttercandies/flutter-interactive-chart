class XAxisOffsetDetails {
  XAxisOffsetDetails({
    required this.offset,
    required this.maxOffset,
  });

  final double offset;
  final double maxOffset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XAxisOffsetDetails &&
          runtimeType == other.runtimeType &&
          offset == other.offset &&
          maxOffset == other.maxOffset;

  @override
  int get hashCode => offset.hashCode ^ maxOffset.hashCode;

  @override
  String toString() {
    return 'XAxisOffsetDetails{offset: $offset, maxOffset: $maxOffset}';
  }
}
