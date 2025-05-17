import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class TimeSeriesChart extends StatelessWidget {
  final List<Map<String, dynamic>> historicalData;

  TimeSeriesChart({required this.historicalData});

  @override
  Widget build(BuildContext context) {
    // Siapkan data untuk suhu
    final series = [
      charts.Series<TimeSeriesData, DateTime>(
        id: 'Temperature',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (TimeSeriesData data, _) => data.time,
        measureFn: (TimeSeriesData data, _) => data.value,
        data: historicalData
            .map((feed) => TimeSeriesData(
                  DateTime.parse(feed['created_at']),
                  double.tryParse(feed['field4'] ?? '0') ?? 0,
                ))
            .toList(),
      )
    ];

    return Container(
      height: 200,
      padding: EdgeInsets.all(8),
      child: charts.TimeSeriesChart(
        series,
        animate: true,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        behaviors: [
          charts.SlidingViewport(),
          charts.PanAndZoomBehavior(),
        ],
      ),
    );
  }
}

class TimeSeriesData {
  final DateTime time;
  final double value;

  TimeSeriesData(this.time, this.value);
}