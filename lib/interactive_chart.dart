import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'candle_data.dart';
import 'chart_painter.dart';
import 'painter_params.dart';

class InteractiveChart extends StatefulWidget {
  final List<CandleData> candles;

  const InteractiveChart({Key? key, required this.candles})
      : assert(candles.length >= 3,
            "InteractiveChart requires at least 3 data points"),
        super(key: key);

  @override
  _InteractiveChartState createState() => _InteractiveChartState();
}

class _InteractiveChartState extends State<InteractiveChart> {
  // The width of an individual bar in the chart.
  late double _candleWidth;

  // The x offset (in px) of current visible chart window,
  // measured against the beginning of the chart.
  // i.e. a value of 0.0 means we are displaying data for the very first day,
  // and a value of 2 * _candleWidth would be skipping the first 2 days.
  late double _startOffset;

  // The position that user is currently tapping, null if user let go.
  Offset? _tapPosition;

  double? _prevChartWidth; // used by _handleResize
  late double _prevCandleWidth;
  late double _prevStartOffset;
  late Offset _initialFocalPoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final size = constraints.biggest;
        final w = size.width - PainterParams.priceLabelWidth;
        _handleResize(w);

        // Find the visible data range
        final int start = (_startOffset / _candleWidth).floor();
        final int count = (w / _candleWidth).ceil();
        final int end = (start + count).clamp(start, widget.candles.length);
        final candlesInRange = widget.candles.getRange(start, end).toList();
        if (end < widget.candles.length) {
          final nextItem = widget.candles[end];
          candlesInRange.add(nextItem);
        }

        // If possible, find neighbouring "moving average" data,
        // so the chart could draw better-connected lines
        final maLeading = widget.candles.at(start - 1)?.priceMA;
        final maTrailing = widget.candles.at(end + 1)?.priceMA;

        // Find the horizontal shift needed when drawing the candles
        final xShift = _candleWidth / 2 - (_startOffset - start * _candleWidth);

        // Calculate min and max among the visible data
        final maxPrice =
            candlesInRange.map((c) => c.high).whereType<double>().reduce(max);
        final minPrice =
            candlesInRange.map((c) => c.low).whereType<double>().reduce(min);
        final maxVol =
            candlesInRange.map((c) => c.volume).whereType<double>().reduce(max);
        final minVol =
            candlesInRange.map((c) => c.volume).whereType<double>().reduce(min);

        return GestureDetector(
          // Tap and hold to view candle details
          onTapDown: (details) {
            setState(() => _tapPosition = details.localPosition);
          },
          onTapCancel: () => setState(() => _tapPosition = null),
          onTapUp: (_) => setState(() => _tapPosition = null),
          // Pan and zoom
          onScaleStart: (details) {
            _prevCandleWidth = _candleWidth;
            _prevStartOffset = _startOffset;
            _initialFocalPoint = details.localFocalPoint;
          },
          onScaleUpdate: (details) => _onScaleUpdate(details, w),
          child: TweenAnimationBuilder(
            tween: PainterParamsTween(
              end: PainterParams(
                candles: candlesInRange,
                size: size,
                candleWidth: _candleWidth,
                startOffset: _startOffset,
                maxPrice: maxPrice,
                minPrice: minPrice,
                maxVol: maxVol,
                minVol: minVol,
                xShift: xShift,
                tapPosition: _tapPosition,
                maLeading: maLeading,
                maTrailing: maTrailing,
              ),
            ),
            // duration: Duration.zero,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder:
                (BuildContext context, PainterParams params, Widget? child) {
              return CustomPaint(
                size: size,
                painter: ChartPainter(params),
              );
            },
          ),
        );
      },
    );
  }

  _onScaleUpdate(details, double w) {
    // Handle zoom
    final candleWidth = (_prevCandleWidth * details.scale)
        .clamp(_getMaxCandleWidth(w), _getMinCandleWidth(w));
    final clampedScale = candleWidth / _prevCandleWidth;
    var startOffset = _prevStartOffset * clampedScale;
    // Handle pan
    final dx = (details.localFocalPoint - _initialFocalPoint).dx * -1;
    startOffset += dx;
    // Adjust pan when zooming
    final focalPointFactor = details.localFocalPoint.dx / w;
    final double prevCount = w / _prevCandleWidth;
    final double currCount = w / _candleWidth;
    final zoomAdjustment = (currCount - prevCount) * _candleWidth;
    startOffset -= zoomAdjustment * focalPointFactor;
    startOffset = startOffset.clamp(
      0,
      _getMaxStartOffset(w, candleWidth),
    );
    // Apply changes
    setState(() {
      _candleWidth = candleWidth;
      _startOffset = startOffset;
    });
  }

  _handleResize(double w) {
    if (w == _prevChartWidth) return;
    if (_prevChartWidth != null) {
      // Re-clamp when size changes (e.g. screen rotation)
      _candleWidth = _candleWidth.clamp(
        _getMaxCandleWidth(w),
        _getMinCandleWidth(w),
      );
      _startOffset = _startOffset.clamp(
        0,
        _getMaxStartOffset(w, _candleWidth),
      );
    } else {
      // Default 90 day chart. If data is shorter, we use the whole range.
      final count = min(widget.candles.length, 90);
      _candleWidth = w / count;
      // Default show the latest available data, e.g. the most recent 90 days.
      _startOffset = (widget.candles.length - count) * _candleWidth;
    }
    _prevChartWidth = w;
  }

  double _getMaxCandleWidth(double w) => w / widget.candles.length;

  double _getMinCandleWidth(double w) => w / min(14, widget.candles.length);

  double _getMaxStartOffset(double w, double candleWidth) {
    final count = w / candleWidth; // visible candles in the window
    final start = widget.candles.length - count;
    return max(0, candleWidth * start);
  }
}
