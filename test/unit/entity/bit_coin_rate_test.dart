import 'package:btc_graph/entities/bit_coin_rate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('BitCoinRate', () {
    test('empty()', () {
      final data = BitCoinRate.empty();
      final now = DateTime.now();
      expect(data.unit, '');
      expect(data.symbol, '');
      expect(data.rate, 0);
      expect(data.rateString, '0');
      expect(data.desc, '');
      expect(
        DateFormat('dd/MM/yyyy HH:mm:ss').format(data.updatedTime),
        DateFormat('dd/MM/yyyy HH:mm:ss').format(now),
      );
    });

    test('BitCoinRate.copyWith()', () {
      final data = BitCoinRate(
        unit: 'USD',
        symbol: 'usd',
        rate: 876.234,
        rateString: '098765',
        desc: 'test usd',
        updatedTime: DateTime.now(),
      );
      expect(data.rateString, '098765');
      final changeRateString = data.copyWith(rateString: '2345sdw');
      expect(changeRateString.rateString, '2345sdw');
    });

    group('BitCoinRate.fromDBJSON()', () {
      test('valid json', () {
        final data = BitCoinRate.fromDBJSON({
          'unit': 'GBP',
          'symbol': 'pound',
          'rate_float': 9876,
          'rate': '234',
          'description': 'hello test',
          'rate_updated_time': '2025-01-26T12:00:22.936407',
        });
        expect(
          data,
          BitCoinRate(
            unit: 'GBP',
            symbol: 'pound',
            rate: 9876,
            rateString: '234',
            desc: 'hello test',
            updatedTime: DateTime(2025, 1, 26, 12, 0, 22, 936, 407),
          ),
        );
      });

      test('invalid json', () {
        expect(
            () => BitCoinRate.fromDBJSON({
                  'unit': 'GBP',
                  'symbol': 'pound',
                  'rate_float': 9876,
                  'rate': '234',
                  'description': 'hello test',
                }),
            throwsA(isA<Exception>()));
      });
    });
  });
}
