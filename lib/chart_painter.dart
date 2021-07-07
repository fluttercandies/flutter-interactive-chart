import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

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

    // Draw prices, volumes & moving averages
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
    final count = params.candles.length;

    String getDate(int timestamp) {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
          .toIso8601String()
          .split("T")
          .first
          .split("-");

      if (count < 20) return "${date[1]}-${date[2]}"; // mm-dd
      return "${date[0]}-${date[1]}"; // yyyy-mm
    }

    final lineCount = params.chartWidth ~/ 90;
    final gap = 1 / (lineCount + 1);
    for (int i = 1; i <= lineCount; i++) {
      double x = i * gap * params.chartWidth;
      final index = params.getCandleIndexFromOffset(x);
      if (index < params.candles.length) {
        final candle = params.candles[index];
        final dateTp = TextPainter(
          text: TextSpan(
            text: getDate(candle.timestamp),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
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
          ..color = Colors.grey.withOpacity(1.0),
      );
      final priceTp = TextPainter(
        text: TextSpan(
          text: y.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
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
    final maPaint = Paint() // paint used for moving average
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = Colors.blue;
    // Draw price bar
    final open = candle.open;
    final close = candle.close;
    final high = candle.high;
    final low = candle.low;
    if (open != null && close != null && high != null && low != null) {
      final color = open > close ? Colors.red : Colors.green;
      canvas.drawLine(
        Offset(x, params.fitPrice(open)),
        Offset(x, params.fitPrice(close)),
        Paint()
          ..strokeWidth = thickWidth
          ..color = color,
      );
      canvas.drawLine(
        Offset(x, params.fitPrice(high)),
        Offset(x, params.fitPrice(low)),
        Paint()
          ..strokeWidth = thinWidth
          ..color = color,
      );
    }
    // Draw volume bar
    final volume = candle.volume;
    if (volume != null) {
      canvas.drawLine(
        Offset(x, params.chartHeight),
        Offset(x, params.fitVolume(volume)),
        Paint()
          ..strokeWidth = thickWidth
          ..color = Colors.grey,
      );
    }
    // Draw average line
    final ma = candle.priceMA;
    final prevMa = params.candles.at(i - 1)?.priceMA;
    if (ma != null && prevMa != null) {
      canvas.drawLine(
        Offset(x - params.candleWidth, params.fitPrice(prevMa)),
        Offset(x, params.fitPrice(ma)),
        maPaint,
      );
    }
    if (i == 0) {
      // In the front, draw an extra line connecting to out-of-window data
      if (ma != null && params.maLeading != null) {
        canvas.drawLine(
          Offset(x - params.candleWidth, params.fitPrice(params.maLeading!)),
          Offset(x, params.fitPrice(ma)),
          maPaint,
        );
      }
    } else if (i == params.candles.length - 1) {
      // At the end, draw an extra line connecting to out-of-window data
      if (ma != null && params.maTrailing != null) {
        canvas.drawLine(
          Offset(x, params.fitPrice(ma)),
          Offset(x + params.candleWidth, params.fitPrice(params.maTrailing!)),
          maPaint,
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
          ..color = Colors.grey.withOpacity(0.2));
    canvas.restore();
    // Draw info pane
    _drawTapInfoOverlay(canvas, params, candle);
  }

  void _drawTapInfoOverlay(canvas, PainterParams params, CandleData candle) {
    final Color textColor = Colors.grey[200]!;
    final Color panelBgColor = Colors.grey[600]!.withOpacity(0.9);
    final xGap = 8.0;
    final yGap = 4.0;

    TextPainter makeTP(String text) => TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
          ),
        )
          ..textDirection = TextDirection.ltr
          ..layout();

    final labels = ["Date", "Open", "High", "Low", "Close", "Volume"]
        .map((text) => makeTP(text))
        .toList();
    final values = [
      intl.DateFormat.yMMMd()
          .format(DateTime.fromMillisecondsSinceEpoch(candle.timestamp * 1000)),
      candle.open?.toStringAsFixed(2) ?? "-",
      candle.high?.toStringAsFixed(2) ?? "-",
      candle.low?.toStringAsFixed(2) ?? "-",
      candle.close?.toStringAsFixed(2) ?? "-",
      candle.volume?.asAbbreviated() ?? "-",
    ].map((text) => makeTP(text)).toList();

    final labelsMaxWidth = labels.map((tp) => tp.width).reduce(max);
    final valuesMaxWidth = values.map((tp) => tp.width).reduce(max);
    final panelWidth = labelsMaxWidth + valuesMaxWidth + xGap * 3;
    final panelHeight =
        values.first.height * values.length + yGap * (values.length + 1);

    canvas.save();
    final pos = params.tapPosition!;
    if (pos.dx <= params.size.width / 2) {
      // show the panel near finger touch position
      canvas.translate(
        pos.dx + params.candleWidth,
        pos.dy - panelHeight - 48,
      );
    } else {
      canvas.translate(
        pos.dx - panelWidth - params.candleWidth,
        pos.dy - panelHeight - 48,
      ); // panel on the left
    }

    // Paint overlay panel and texts
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & Size(panelWidth, panelHeight),
          Radius.circular(8),
        ),
        Paint()..color = panelBgColor);
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

extension Formatting on double {
  String asPercent() {
    final format = this < 100 ? "##0.00" : "#,###";
    final v = intl.NumberFormat(format, "en_US").format(this);
    return "${this >= 0 ? '+' : ''}$v%";
  }

  String asAbbreviated() {
    if (this < 1000) return this.toStringAsFixed(3);
    if (this >= 1e18) return this.toStringAsExponential(3);
    final s = intl.NumberFormat("#,###", "en_US").format(this).split(",");
    const suffixes = ["K", "M", "B", "T", "Q"];
    return "${s[0]}.${s[1]}${suffixes[s.length - 2]}";
  }
}

extension ElementAtOrNull<E> on List<E> {
  E? at(int index) {
    if (index < 0 || index >= length) return null;
    return elementAt(index);
  }
}
