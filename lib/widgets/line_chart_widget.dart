import 'package:btc_graph/entities/bit_coin_rate.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// final List<Color> gradientColors = [
//   Colors.deepPurpleAccent,
//   Colors.indigo,
//   Colors.green,
//   Colors.yellow,
//   Colors.red,
// ];

final List<Color> gradientColors = [
  Colors.deepPurple,
  Colors.blue,
];

typedef LineChartRecord = ({
  DateTime time,
  double value,
});

class LineChartWidget extends StatefulWidget {
  const LineChartWidget({
    super.key,
    required this.data,
  });

  final List<LineChartRecord> data;

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  late TrackballBehavior _trackballBehavior;

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
      enable: true,
      lineType: TrackballLineType.none,
      activationMode: ActivationMode.singleTap,
      tooltipSettings: InteractiveTooltip(
        canShowMarker: false,
        format: '@ point.x \n point.y',
      ),
      tooltipAlignment: ChartAlignment.near,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat('HH:mm'),
      ),
      primaryYAxis: NumericAxis(
        axisLabelFormatter: (args) => ChartAxisLabel(
          btcFormat.format(args.value),
          TextStyle(),
        ),
      ),
      trackballBehavior: _trackballBehavior,
      series: <CartesianSeries>[
        AreaSeries<LineChartRecord, DateTime>(
          dataSource: widget.data,
          xValueMapper: (val, _) => val.time,
          yValueMapper: (val, _) => val.value,
          gradient: LinearGradient(
            colors: gradientColors.map((c) => c.withAlpha(150)).toList(),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderWidth: 3,
          borderGradient: LinearGradient(
            colors: gradientColors.map((c) => c.withAlpha(200)).toList(),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          enableTrackball: true,
        ),
      ],
    );
  }
}
