## 0.3.0

* BREAKING: Add support for multiple trend lines.
* The old `trend` property is changed to `trends`, to support multiple data points per `CandleData`.
* The old `trendLineColor` property is changed to `trendLineStyles`.
* Updated example project to reflect above changes.

## 0.2.1

* Add `onTap` event and `onCandleResize` event.
* Allow `overlayInfo` to return an empty object.
* Update example project.

## 0.2.0

* BREAKING: Organize folder structures, now you only need to import `package:interactive_chart/interactive_chart.dart`.
* BREAKING: Change CandleData `timestamp` to milliseconds, you might need to multiply your data by 1000 when creating CandleData objects.
* Fix an issue where zooming was occasionally not smooth.
* Fix an issue where overlay panel was occasionally clipped.

## 0.1.1

* Improve performance.
* Allow `high` and `low` prices to be optional.
* Align date/time labels towards vertical bottom.

## 0.1.0

* Initial Open Source release.