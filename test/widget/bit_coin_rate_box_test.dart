// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:btc_graph/entities/bit_coin_rate.dart';
import 'package:btc_graph/widgets/bit_coin_rate_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final time = DateTime(2025, 1, 25, 22, 34, 0);
final time2 = DateTime(2025, 1, 26, 1, 4, 21);

final mockRateRecords = [
  BitCoinRate(
    unit: 'USD',
    symbol: '&#36;',
    rate: 5302.032,
    rateString: '5302.032',
    desc: 'usd desc',
    updatedTime: time,
  ),
  BitCoinRate(
    unit: 'EURO',
    symbol: '&euro;',
    rate: 3002,
    rateString: '3002.0',
    desc: 'euro desc',
    updatedTime: time,
  ),
  BitCoinRate(
    unit: 'SYP',
    symbol: '&#163;',
    rate: 983772.345743,
    rateString: '983772.345743',
    desc: 'syrian pound desc',
    updatedTime: time2,
  ),
];

void main() {
  group('BitCoinRateBox', () {
    testWidgets('USD', (WidgetTester tester) async {
      await tester.pumpWidget(WidgetsApp(
        color: Colors.white,
        builder: (context, _) => BitCoinRateBox(
          rateRecord: mockRateRecords[0],
        ),
      ));

      expect(find.text('\$ 5,302.032'), findsOneWidget);
      expect(find.text('Updated: Sat 25/01/2025 22:34:00'), findsOneWidget);
    });
    testWidgets('EURO', (WidgetTester tester) async {
      await tester.pumpWidget(WidgetsApp(
        color: Colors.white,
        builder: (context, _) => BitCoinRateBox(
          rateRecord: mockRateRecords[1],
        ),
      ));

      expect(find.text('€ 3,002'), findsOneWidget);
      expect(find.text('Updated: Sat 25/01/2025 22:34:00'), findsOneWidget);
    });

    testWidgets('SYP', (WidgetTester tester) async {
      await tester.pumpWidget(WidgetsApp(
        color: Colors.white,
        builder: (context, _) => BitCoinRateBox(
          rateRecord: mockRateRecords[2],
        ),
      ));

      expect(find.text('£ 983,772.3457'), findsOneWidget);
      expect(find.text('Updated: Sun 26/01/2025 01:04:21'), findsOneWidget);
    });
  });
}
