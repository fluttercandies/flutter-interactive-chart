import 'dart:math';

import 'package:flutter/widgets.dart';

import 'candle_data.dart';
import 'painter_params.dart';

class ChartPainter extends CustomPainter {
  final PainterParams params;

  ChartPainter(this.params);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw date labels & price labels
    _drawDateLabels(canvas, params);
    _drawPriceGridAndLabels(canvas, params);

    // Draw prices, volumes & trend line
    canvas.save();
    canvas.clipRect(Offset.zero & Size(params.chartWidth, params.chartHeight));
    // canvas.drawRect(
    //   // apply yellow tint to clipped area (for debugging)
    //   Offset.zero & Size(params.chartWidth, params.chartHeight),
    //   Paint()..color = Colors.yellow[100]!,
    // );
    canvas.translate(params.xShift, 0);
    for (int i = 0; i < params.candles.length; i++) {
      _drawSingleDay(canvas, params, i);
    }
    canvas.restore();

    // Draw tap highlight & overlay
    if (params.tapPosition != null) {
      if (params.tapPosition!.dx < params.chartWidth) {
        _drawTapHighlightAndOverlay(canvas, params);
      }
    }
  }

  void _drawDateLabels(canvas, PainterParams params) {
    // We draw one date label per 90 pixels of screen width
    final lineCount = params.chartWidth ~/ 90;
    final gap = 1 / (lineCount + 1);
    for (int i = 1; i <= lineCount; i++) {
      double x = i * gap * params.chartWidth;
      final index = params.getCandleIndexFromOffset(x);
      if (index < params.candles.length) {
        final candle = params.candles[index];
        final visibleDataCount = params.candles.length;
        final dateTp = TextPainter(
          text: TextSpan(
            text: params.getDateLabel(candle.timestamp, visibleDataCount),
            style: params.style.dateLabelStyle,
          ),
        )
          ..textDirection = TextDirection.ltr
          ..layout();
        dateTp.paint(canvas, Offset(x - dateTp.width / 2, params.chartHeight));
      }
    }
  }

  void _drawPriceGridAndLabels(canvas, PainterParams params) {
    [0.0, 0.25, 0.5, 0.75, 1.0]
        .map((v) => ((params.maxPrice - params.minPrice) * v) + params.minPrice)
        .forEach((y) {
      canvas.drawLine(
        Offset(0, params.fitPrice(y)),
        Offset(params.chartWidth, params.fitPrice(y)),
        Paint()
          ..strokeWidth = 0.5
          ..color = params.style.priceGridLineColor,
      );
      final priceTp = TextPainter(
        text: TextSpan(
          text: params.getPriceLabel(y),
          style: params.style.priceLabelStyle,
        ),
      )
        ..textDirection = TextDirection.ltr
        ..layout();
      priceTp.paint(
          canvas,
          Offset(
            params.chartWidth + 4,
            params.fitPrice(y) - priceTp.height / 2,
          ));
    });
  }

  void _drawSingleDay(canvas, PainterParams params, int i) {
    final candle = params.candles[i];
    final x = i * params.candleWidth;
    final thickWidth = max(params.candleWidth * 0.8, 0.8);
    final thinWidth = max(params.candleWidth * 0.2, 0.2);
    // Draw price bar
    final open = candle.open;
    final close = candle.close;
    final high = candle.high;
    final low = candle.low;
    if (open != null && close != null) {
      final color = open > close
          ? params.style.priceLossColor
          : params.style.priceGainColor;
      canvas.drawLine(
        Offset(x, params.fitPrice(open)),
        Offset(x, params.fitPrice(close)),
        Paint()
          ..strokeWidth = thickWidth
          ..color = color,
      );
      if (high != null && low != null) {
        canvas.drawLine(
          Offset(x, params.fitPrice(high)),
          Offset(x, params.fitPrice(low)),
          Paint()
            ..strokeWidth = thinWidth
            ..color = color,
        );
      }
    }
    // Draw volume bar
    final volume = candle.volume;
    if (volume != null) {
      canvas.drawLine(
        Offset(x, params.chartHeight),
        Offset(x, params.fitVolume(volume)),
        Paint()
          ..strokeWidth = thickWidth
          ..color = params.style.volumeColor,
      );
    }
    // Draw trend line
    final trendLinePaint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = params.style.trendLineColor;
    final pt = candle.trend; // current data point
    final prevPt = params.candles.at(i - 1)?.trend;
    if (pt != null && prevPt != null) {
      canvas.drawLine(
        Offset(x - params.candleWidth, params.fitPrice(prevPt)),
        Offset(x, params.fitPrice(pt)),
        trendLinePaint,
      );
    }
    if (i == 0) {
      // In the front, draw an extra line connecting to out-of-window data
      if (pt != null && params.leadingTrend != null) {
        canvas.drawLine(
          Offset(x - params.candleWidth, params.fitPrice(params.leadingTrend!)),
          Offset(x, params.fitPrice(pt)),
          trendLinePaint,
        );
      }
    } else if (i == params.candles.length - 1) {
      // At the end, draw an extra line connecting to out-of-window data
      if (pt != null && params.trailingTrend != null) {
        canvas.drawLine(
          Offset(x, params.fitPrice(pt)),
          Offset(
            x + params.candleWidth,
            params.fitPrice(params.trailingTrend!),
          ),
          trendLinePaint,
        );
      }
    }
  }

  void _drawTapHighlightAndOverlay(canvas, PainterParams params) {
    final pos = params.tapPosition!;
    final i = params.getCandleIndexFromOffset(pos.dx);
    final candle = params.candles[i];
    canvas.save();
    canvas.translate(params.xShift, 0.0);
    // Draw highlight bar (selection box)
    canvas.drawLine(
        Offset(i * params.candleWidth, 0.0),
        Offset(i * params.candleWidth, params.chartHeight),
        Paint()
          ..strokeWidth = max(params.candleWidth * 0.88, 1.0)
          ..color = params.style.selectionHighlightColor);
    canvas.restore();
    // Draw info pane
    _drawTapInfoOverlay(canvas, params, candle);
  }

  void _drawTapInfoOverlay(canvas, PainterParams params, CandleData candle) {
    final xGap = 8.0;
    final yGap = 4.0;

    TextPainter makeTP(String text) => TextPainter(
          text: TextSpan(
            text: text,
            style: params.style.overlayTextStyle,
          ),
        )
          ..textDirection = TextDirection.ltr
          ..layout();

    final info = params.getOverlayInfo(candle);
    final labels = info.keys.map((text) => makeTP(text)).toList();
    final values = info.values.map((text) => makeTP(text)).toList();

    final labelsMaxWidth = labels.map((tp) => tp.width).reduce(max);
    final valuesMaxWidth = values.map((tp) => tp.width).reduce(max);
    final panelWidth = labelsMaxWidth + valuesMaxWidth + xGap * 3;
    final panelHeight =
        values.first.height * values.length + yGap * (values.length + 1);

    canvas.save();
    final pos = params.tapPosition!;
    final fingerSize = 32.0; // leave some margin around user's finger
    var dx, dy;
    if (pos.dx <= params.size.width / 2) {
      // If user touches the left-half of the screen,
      // we show the overlay panel near finger touch position, on the right.
      dx = pos.dx + fingerSize;
    } else {
      // Otherwise we show panel on the left of the finger touch position.
      dx = pos.dx - panelWidth - fingerSize;
    }
    dy = pos.dy - panelHeight - fingerSize;
    if (dy < 0) dy = 0.0;
    canvas.translate(dx, dy);

    // Paint overlay panel and texts
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & Size(panelWidth, panelHeight),
          Radius.circular(8),
        ),
        Paint()..color = params.style.overlayBackgroundColor);
    for (int i = 0; i < labels.length; i++) {
      labels[i].paint(
        canvas,
        Offset(xGap, (yGap + values.first.height) * i + yGap),
      );
    }
    for (int i = 0; i < values.length; i++) {
      final leading = valuesMaxWidth - values[i].width;
      values[i].paint(
        canvas,
        Offset(labelsMaxWidth + xGap * 2 + leading,
            (yGap + values.first.height) * i + yGap),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => true;
}

extension ElementAtOrNull<E> on List<E> {
  E? at(int index) {
    if (index < 0 || index >= length) return null;
    return elementAt(index);
  }
}
