import 'package:btc_graph/entities/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Currency', () {
    test('toOpposite()', () {
      expect(Currency.usd().toOpposite(), Currency.thb());
      expect(Currency.thb().toOpposite(), Currency.usd());
    });
  });
}
