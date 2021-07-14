import 'package:flutter/material.dart';

import 'package:interactive_chart/candle_data.dart';
import 'package:interactive_chart/interactive_chart.dart';
import 'package:interactive_chart/chart_style.dart';

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
  bool _darkMode = false;
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
              priceGainColor: Colors.purple,
              priceLossColor: Colors.deepPurple,
              volumeColor: Colors.pink,
              trendLineColor: Colors.teal,
              priceGridLineColor: Colors.green,
              priceLabelStyle: TextStyle(color: Colors.orange[800]!),
              dateLabelStyle: TextStyle(color: Colors.indigo),
              selectionHighlightColor: Colors.yellow.withOpacity(0.5),
              overlayBackgroundColor: Colors.blue[100]!.withOpacity(0.8),
              overlayTextStyle: TextStyle(color: Colors.blue[900]),
            ),
          ),
        ),
      ),
    );
  }
}
