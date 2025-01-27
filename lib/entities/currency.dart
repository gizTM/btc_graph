enum CurrencyType {
  usd,
  thb,
}

class Currency {
  const Currency({
    required this.type,
    required this.symbol,
    required this.factor,
    required this.index,
  });

  final CurrencyType type;
  final String symbol;
  final double factor;
  final int index;

  factory Currency.usd() => Currency(
        type: CurrencyType.usd,
        symbol: '&#36;',
        factor: 1,
        index: 0,
      );

  factory Currency.thb() => Currency(
        type: CurrencyType.thb,
        symbol: '&#3647;',
        factor: 1,
        index: 1,
      );

  Currency toOpposite() {
    switch (type) {
      case CurrencyType.usd:
        return Currency.thb();
      default:
        return Currency.usd();
    }
  }

  Currency copyWith({
    CurrencyType? type,
    String? symbol,
    double? factor,
    int? index,
  }) =>
      Currency(
        type: type ?? this.type,
        symbol: symbol ?? this.symbol,
        factor: factor ?? this.factor,
        index: index ?? this.index,
      );

  @override
  bool operator ==(Object other) =>
      other is Currency &&
      other.type == type &&
      other.factor == factor &&
      other.index == index &&
      other.symbol == symbol;

  @override
  int get hashCode => Object.hash(type, symbol, factor, index);
}
