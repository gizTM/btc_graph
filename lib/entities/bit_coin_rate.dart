import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

final btcFormat = NumberFormat("#,##0.####", "en_US");

class BitCoinRate {
  const BitCoinRate({
    required this.unit,
    required this.symbol,
    required this.rate,
    required this.rateString,
    required this.desc,
    // updated time from api (time new price was updated)
    required this.updatedTime,
  });

  final String unit;
  final String symbol;
  final double rate;
  final String rateString;
  final String desc;
  final DateTime updatedTime;

  static final unitKey = 'unit';
  static final symbolKey = 'symbol';
  static final rateKey = 'rate_float';
  static final rateStringKey = 'rate';
  static final descKey = 'description';
  static final updatedTimeKey = 'rate_updated_time';

  factory BitCoinRate.fromDBJSON(Map<String, dynamic> json) {
    try {
      return BitCoinRate(
        unit: json[unitKey] as String,
        symbol: json[symbolKey] as String,
        rate: double.tryParse(json[rateKey].toString()) ?? 0.0,
        rateString: json[rateStringKey] as String,
        desc: json[descKey] as String,
        updatedTime: DateTime.parse(json[updatedTimeKey].toString()),
      );
    } catch (e) {
      throw Exception('[BitCoinRate] fromDBJSON(): $e');
    }
  }

  factory BitCoinRate.fromApiJSON(Map<String, dynamic> json) {
    try {
      final bpi = json['bpi']['USD'];
      return BitCoinRate(
        unit: bpi['code'] as String,
        symbol: bpi['symbol'] as String,
        rate: double.tryParse(bpi['rate_float'].toString()) ?? 0.0,
        rateString: bpi['rate'] as String,
        desc: bpi['description'] as String,
        updatedTime: DateTime.parse(json['time']['updatedISO'].toString()),
      );
    } catch (e) {
      throw Exception('[BitCoinRate] fromApiJSON: $e');
    }
  }

  Map<String, dynamic> toDBJSON() {
    return {
      unitKey: unit,
      symbolKey: symbol,
      rateKey: rate,
      rateStringKey: rateString,
      descKey: desc,
      updatedTimeKey: updatedTime.toUtc().toIso8601String(),
    };
  }

  factory BitCoinRate.empty() => BitCoinRate(
        unit: '',
        symbol: '',
        rate: 0,
        rateString: '0',
        desc: '',
        updatedTime: DateTime.now(),
      );

  BitCoinRate copyWith({
    String? unit,
    String? symbol,
    double? rate,
    String? rateString,
    String? desc,
    DateTime? updatedTime,
  }) =>
      BitCoinRate(
        unit: unit ?? this.unit,
        symbol: symbol ?? this.symbol,
        rate: rate ?? this.rate,
        rateString: rateString ?? this.rateString,
        desc: desc ?? this.desc,
        updatedTime: updatedTime ?? this.updatedTime,
      );

  @override
  bool operator ==(Object other) =>
      other is BitCoinRate &&
      other.unit == unit &&
      other.symbol == symbol &&
      other.rate == rate &&
      other.rateString == rateString &&
      other.desc == other.desc &&
      const DeepCollectionEquality().equals(other.updatedTime, updatedTime);

  @override
  int get hashCode => Object.hash(
        unit,
        symbol,
        rate,
        rateString,
        desc,
        updatedTime,
      );
}
