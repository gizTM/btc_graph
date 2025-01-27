import 'package:btc_graph/entities/bit_coin_rate.dart';

class BitCoinRateGraphData {
  const BitCoinRateGraphData({
    required this.rateData,
    // time when api is called
    required this.updatedTime,
  });

  final BitCoinRate rateData;
  final DateTime updatedTime;

  static final rateDataKey = 'rate_data';
  static final updatedTimeKey = 'graph_updated_date';

  factory BitCoinRateGraphData.fromDBJSON(Map<String, dynamic> json) {
    return BitCoinRateGraphData(
      rateData: BitCoinRate.fromDBJSON(json),
      updatedTime: DateTime.parse(json[updatedTimeKey].toString()),
    );
  }

  Map<String, dynamic> toDBJSON() {
    return {
      ...rateData.toDBJSON(),
      updatedTimeKey: updatedTime.toUtc().toIso8601String(),
    };
  }

  factory BitCoinRateGraphData.empty() => BitCoinRateGraphData(
        rateData: BitCoinRate.empty(),
        updatedTime: DateTime.now(),
      );

  BitCoinRateGraphData copyWith({
    BitCoinRate? rateData,
    DateTime? updatedTime,
  }) =>
      BitCoinRateGraphData(
        rateData: rateData ?? this.rateData,
        updatedTime: updatedTime ?? this.updatedTime,
      );
}
