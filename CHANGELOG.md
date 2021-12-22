## 0.3.4

* Fix a potential crash if volume numbers are null.

## 0.3.3

* Fix an issue where `onTap` event was not firing. [(Issue #8)](https://github.com/fluttercandies/flutter-interactive-chart/issues/8)

## 0.3.2

* Add `initialVisibleCandleCount` parameter for setting a default zoom level. [(Issue #6)](https://github.com/fluttercandies/flutter-interactive-chart/issues/6)

## 0.3.1

* Allow web and desktop users to zoom the chart with mouse scroll wheel. [(Issue #4)](https://github.com/fluttercandies/flutter-interactive-chart/issues/4)

## 0.3.0

* BREAKING: Add support for multiple trend lines. [(Issue #2)](https://github.com/fluttercandies/flutter-interactive-chart/issues/2)
* The old `trend` property is changed to `trends`, to support multiple data points per `CandleData`.
* The old `trendLineColor` property is changed to `trendLineStyles`.
* The `CandleData.computeMA` helper function no longer modifies data in-place. To migrate,
  change `CandleData.computeMA(data)` to the following two lines:
  `final ma = CandleData.computeMA(data); ` and
  `for (int i = 0; i < data.length; i++) { data[i].trends = [ma[i]]; }`.
* Update example project to reflect above changes.

## 0.2.1

* Add `onTap` event and `onCandleResize` event.
* Allow `overlayInfo` to return an empty object.
* Update example project.

## 0.2.0

* BREAKING: Organize folder structures, now you only need to
  import `package:interactive_chart/interactive_chart.dart`.
* BREAKING: Change CandleData `timestamp` to milliseconds, you might need to multiply your data by
  1000 when creating CandleData objects.
* Fix an issue where zooming was occasionally not smooth.
* Fix an issue where overlay panel was occasionally clipped.

## 0.1.1

* Improve performance.
* Allow `high` and `low` prices to be optional.
* Align date/time labels towards vertical bottom.

## 0.1.0

* Initial Open Source release.