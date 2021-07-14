import 'package:flutter/material.dart';

class ChartStyle {
  final double volumeHeightFactor;
  final double priceLabelWidth;
  final double dateLabelHeight;

  final TextStyle dateLabelStyle;
  final TextStyle priceLabelStyle;
  final TextStyle overlayTextStyle;

  /// The color to use when the `close` price is higher than `open` price.
  final Color priceGainColor;

  /// The color to use when the `close` price is lower than `open` price.
  final Color priceLossColor;

  /// The color of the `volume` bars.
  final Color volumeColor;

  /// The color of the trend line, if available.
  final Color trendLineColor;
  final Color priceGridLineColor;
  final Color selectionHighlightColor;
  final Color overlayBackgroundColor;

  const ChartStyle({
    this.volumeHeightFactor = 0.2,
    this.priceLabelWidth = 48.0,
    this.dateLabelHeight = 24.0,
    this.dateLabelStyle = const TextStyle(
      fontSize: 16,
      color: Colors.grey,
    ),
    this.priceLabelStyle = const TextStyle(
      fontSize: 12,
      color: Colors.grey,
    ),
    this.overlayTextStyle = const TextStyle(
      fontSize: 16,
      color: Colors.white,
    ),
    this.priceGainColor = Colors.green,
    this.priceLossColor = Colors.red,
    this.volumeColor = Colors.grey,
    this.trendLineColor = Colors.blue,
    this.priceGridLineColor = Colors.grey,
    this.selectionHighlightColor = const Color(0x33757575),
    this.overlayBackgroundColor = const Color(0xEE757575),
  });
}
