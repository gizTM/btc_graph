import 'package:btc_graph/entities/bit_coin_rate.dart';
import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' as html_parser;
import 'package:intl/intl.dart';

class BitCoinRateBox extends StatelessWidget {
  const BitCoinRateBox({
    super.key,
    required this.rateRecord,
    this.rateFactor = 1,
    this.unitSymbol,
  });

  final BitCoinRate rateRecord;
  final double rateFactor;
  final String? unitSymbol;

  @override
  Widget build(BuildContext context) {
    final symbol = html_parser.DocumentFragment.html(unitSymbol ?? rateRecord.symbol).text ?? '';
    return Container(
        padding: EdgeInsets.all(16),
        // decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text('$symbol ${btcFormat.format(rateRecord.rate * rateFactor)}',
                style: TextStyle(fontSize: 35)),
            Text(
              'Updated: ${DateFormat('E dd/MM/yyyy HH:mm:ss').format(rateRecord.updatedTime.toLocal())}',
            )
          ],
        ));
  }
}
