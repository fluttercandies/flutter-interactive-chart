class CandleData {
  /// The timestamp of this data point, in milliseconds since epoch.
  final int timestamp;

  /// The "open" price of this data point. It's acceptable to have null here for
  /// a few data points, but they must not all be null. If either [open] or
  /// [close] is null for a data point, it will appear as a gap in the chart.
  final double? open;

  /// The "high" price. If either one of [high] or [low] is null, we won't
  /// draw the narrow part of the candlestick for that data point.
  final double? high;

  /// The "low" price. If either one of [high] or [low] is null, we won't
  /// draw the narrow part of the candlestick for that data point.
  final double? low;

  /// The "close" price of this data point. It's acceptable to have null here
  /// for a few data points, but they must not all be null. If either [open] or
  /// [close] is null for a data point, it will appear as a gap in the chart.
  final double? close;

  /// The volume information of this data point.
  final double? volume;

  /// Optional data holder for drawing a trend line, e.g. moving average.
  double? trend;

  CandleData({
    required this.timestamp,
    required this.open,
    required this.close,
    required this.volume,
    this.high,
    this.low,
  });

  static void computeMA(List<CandleData> data, [int period = 7]) {
    if (data.length < period * 2) return;
    final firstPeriod =
        data.take(period).map((d) => d.close).whereType<double>();
    double ma = firstPeriod.reduce((a, b) => a + b) / firstPeriod.length;

    for (int i = period; i < data.length; i++) {
      final curr = data[i].close;
      final prev = data[i - period].close;
      if (curr != null && prev != null) {
        ma = (ma * period + curr - prev) / period;
        data[i].trend = ma;
      }
    }
  }

  static void deleteMA(List<CandleData> data) {
    data.forEach((element) => element.trend = null);
  }

  @override
  String toString() => "<CandleData ($timestamp: $close)>";
}
