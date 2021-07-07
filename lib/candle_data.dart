class CandleData {
  final int timestamp;
  final double? open;
  final double? high;
  final double? low;
  final double? close;
  final double? volume;

  double? priceMA; // moving average of [close]

  CandleData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  static void computeMA(List<CandleData> data, [int period = 7]) {
    if (data.length < period * 2) return;
    final first = data.take(period).map((d) => d.close).whereType<double>();
    double ma = first.reduce((a, b) => a + b) / first.length;

    for (int i = period; i < data.length; i++) {
      final curr = data[i].close;
      final prev = data[i - period].close;
      if (curr != null && prev != null) {
        ma = (ma * period + curr - prev) / period;
        data[i].priceMA = ma;
      }
    }
  }

  static void deleteMA(List<CandleData> data) {
    data.forEach((element) => element.priceMA = null);
  }

  @override
  String toString() => "$timestamp: $close";
}
