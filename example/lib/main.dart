import 'package:flutter/material.dart';

import 'package:interactive_chart/interactive_chart.dart';
import 'mock_data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<CandleData> _data = MockDataTesla.candles;
  bool _darkMode = true;
  bool _showAverage = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _darkMode ? Brightness.dark : Brightness.light,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Interactive Chart Demo"),
          actions: [
            IconButton(
              icon: Icon(_darkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: () => setState(() => _darkMode = !_darkMode),
            ),
            IconButton(
              icon: Icon(
                _showAverage ? Icons.show_chart : Icons.bar_chart_outlined,
              ),
              onPressed: () {
                setState(() => _showAverage = !_showAverage);
                if (_showAverage) {
                  CandleData.computeMA(_data, 7);
                } else {
                  CandleData.deleteMA(_data);
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          minimum: const EdgeInsets.all(24.0),
          child: InteractiveChart(
            candles: _data,
            style: ChartStyle(
              priceGainColor: Colors.teal[200]!,
              priceLossColor: Colors.blueGrey,
              volumeColor: Colors.teal.withOpacity(0.8),
              trendLineColor: Colors.blueGrey[200]!,
              priceGridLineColor: Colors.blue[200]!,
              priceLabelStyle: TextStyle(color: Colors.blue[200]),
              timeLabelStyle: TextStyle(color: Colors.blue[200]),
              selectionHighlightColor: Colors.red.withOpacity(0.2),
              overlayBackgroundColor: Colors.red[900]!.withOpacity(0.6),
              overlayTextStyle: TextStyle(color: Colors.red[100]),
              timeLabelHeight: 32,
            ),
            overlayInfo: (candle) => {
              "💎": "🤚    ",
              "高": "${candle.high?.toStringAsFixed(2)}",
              "低": "${candle.low?.toStringAsFixed(2)}",
            },
            priceLabel: (price) => "${price.round()} 💎",
          ),
        ),
      ),
    );
  }
}
