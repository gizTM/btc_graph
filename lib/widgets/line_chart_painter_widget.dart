import 'dart:async';
import 'dart:math' as math;

import 'package:btc_graph/entities/bit_coin_rate.dart';
import 'package:btc_graph/widgets/line_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

class LineChartPainterWidget extends StatefulWidget {
  const LineChartPainterWidget({
    super.key,
    required this.data,
    this.chartHeight = 500,
  });

  final List<LineChartRecord> data;
  final double chartHeight;

  @override
  State<LineChartPainterWidget> createState() => _LineChartPainterWidgetState();
}

class _LineChartPainterWidgetState extends State<LineChartPainterWidget> {
  late Timer timer;
  double percentage = 0;

  @override
  void initState() {
    // setup animation timer and update variable
    final fps = 50.0;
    final totalAnimDuration = 1.0; // animate for x seconds
    double percentStep = 1.0 / (totalAnimDuration * fps);
    int frameDuration = (1000 ~/ fps);
    timer = Timer.periodic(Duration(milliseconds: frameDuration), (timer) {
      setState(() {
        percentage += percentStep;
        percentage = percentage > 1.0 ? 1.0 : percentage;
        if (percentage >= 1.0) {
          timer.cancel();
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ChartPainter(
        dateList: widget.data.map((e) => e.time).toList(),
        valueList: widget.data.map((e) => e.value).toList(),
        min: widget.data.fold(double.maxFinite, (acc, e) => acc > e.value ? e.value : acc),
        max: widget.data.fold(0.0, (acc, e) => acc < e.value ? e.value : acc),
      ),
      child: Container(),
    );
  }
}

class ChartPainter extends CustomPainter {
  const ChartPainter({
    required this.dateList,
    required this.valueList,
    required this.min,
    required this.max,
  });

  final List<DateTime> dateList;
  final List<double> valueList;
  final double min;
  final double max;

  static const padding = 5.0;
  static const yLabelWidth = 50.0;
  static const xLabelHeight = 40.0;

  @override
  void paint(Canvas canvas, Size size) {
    final clipRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.clipRect(clipRect);
    canvas.drawPaint(Paint()..color = Colors.black.withAlpha(0));

    final chartWidth = size.width - padding - yLabelWidth;
    final chartHeight = size.height - padding - xLabelHeight;

    final rect = Rect.fromLTWH(
      padding + yLabelWidth,
      padding,
      chartWidth,
      chartHeight,
    );
    final chBorder = Paint()
      ..color = Colors.grey.withAlpha(100)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dpPaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // draw chart guides
    _drawChartGuides(
      canvas,
      chBorder,
      rect,
      chartWidth,
      chartHeight,
    );
    _drawAxes(size, canvas);

    _drawDataPoints(canvas, dpPaint, rect, chartWidth, chartHeight);
    _drawAxesLabel(rect, chartWidth, chartHeight, canvas);
  }

  void _drawAxesLabel(
    Rect rect,
    double chartWidth,
    double chartHeight,
    Canvas canvas,
  ) {
    final bottom = rect.bottom - 25;
    final yLabelList = max == min
        ? [max]
        : [
            max,
            (max + min) / 2,
            min,
          ];
    for (int i = 0; i < yLabelList.length; i++) {
      final yRatio = (chartHeight - 50) / math.max(1, max - min);
      final y = (yLabelList[i] - min) * yRatio;
      _drawText(
        canvas,
        Offset(0, bottom - y),
        150,
        TextStyle(color: Colors.black, fontSize: 8),
        btcFormat.format(yLabelList[i]),
      );
    }
    final firstTs = dateList[0].millisecondsSinceEpoch;
    final lastTs = dateList[dateList.length - 1].millisecondsSinceEpoch;
    final xLabelList = dateList.isEmpty
        ? []
        : [
            firstTs,
            (firstTs + lastTs) ~/ 2,
            lastTs,
          ];
    for (int i = 0; i < xLabelList.length; i++) {
      final yRatio = (chartWidth - yLabelWidth) / math.max(1, lastTs - firstTs);
      final y = (xLabelList[i] - firstTs) * yRatio;
      _drawText(
        canvas,
        Offset(rect.left + y, rect.bottom),
        150,
        TextStyle(color: Colors.black, fontSize: 8),
        DateFormat('HH:mm:ss').format(
          DateTime.fromMillisecondsSinceEpoch(xLabelList[i]),
        ),
      );
    }
  }

  void _drawDataPoints(
    Canvas canvas,
    dpPaint,
    Rect rect,
    double chartWidth,
    double chartHeight,
  ) {
    // final offset = chartHeight * (valueList.length == 1 ? );
    final offset = 0;
    // final offset = (max + min) / 2;
    // this ratio is the number of y pixels per unit data
    final yRatio = (chartHeight - 50) / math.max(1, (max + offset) - (min - offset));
    double colW = chartWidth / (valueList.length - 1);
    final p = Path();
    double x = rect.left;
    bool first = true;
    final bottom = rect.bottom - 25;
    for (final d in valueList) {
      final y = (d - min) * yRatio;
      if (first) {
        p.moveTo(x, bottom - y);
        first = false;
      } else {
        p.lineTo(x, bottom - y);
      }
      x += colW;
    }

    p.moveTo(x - colW, bottom);
    p.moveTo(rect.left, bottom);
    canvas.drawPath(p, dpPaint);
  }

  void _drawChartGuides(Canvas canvas, Paint chBorder, Rect rect, double chartW, double chartH) {
    double x = rect.left;
    double colW = chartW / 6.0;
    for (int i = 1; i < 10; i++) {
      final p1 = Offset(x, rect.bottom);
      final p2 = Offset(x, rect.top);
      canvas.drawLine(p1, p2, chBorder);
      x += colW;
    }

    // draw horizontal lines
    final yD = chartH / 3.0;
    canvas.drawLine(
        Offset(rect.left, rect.bottom - yD), Offset(rect.right, rect.bottom - yD), chBorder);
    canvas.drawLine(Offset(rect.left, rect.bottom - yD * 2),
        Offset(rect.right, rect.bottom - yD * 2), chBorder);
  }

  void _drawAxes(Size size, Canvas canvas) {
    final origin = Offset(
      padding + yLabelWidth,
      size.height - padding - xLabelHeight,
    );

    // draw y axis
    canvas.drawLine(
      origin,
      Offset(
        padding + yLabelWidth,
        padding,
      ),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1,
    );

    // draw x axis
    canvas.drawLine(
      origin,
      Offset(
        size.width - padding,
        size.height - padding - xLabelHeight,
      ),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1,
    );
  }

  void _drawText(Canvas canvas, Offset position, double width, TextStyle style, String text) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: width);
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;
}
