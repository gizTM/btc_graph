import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:btc_graph/core/constant.dart';
import 'package:btc_graph/entities/bit_coin_rate.dart';
import 'package:btc_graph/entities/bit_coin_rate_graph_data.dart';
import 'package:btc_graph/entities/currency.dart';
import 'package:btc_graph/services/database_service.dart';
import 'package:btc_graph/widgets/bit_coin_rate_box.dart';
import 'package:btc_graph/widgets/line_chart_painter_widget.dart';
import 'package:btc_graph/widgets/line_chart_widget.dart';
import 'package:dartz/dartz.dart' show Either, left, right;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _databaseService = DatabaseService.instance;

  final _currentRateStreamController = StreamController<Either<String, BitCoinRate>>();
  late final Timer _timer;

  final _bitCoinRates = ValueNotifier<List<BitCoinRateGraphData>>([]);
  Currency _currency = Currency.usd();

  bool _useCustomPainterGraph = false;

  @override
  void initState() {
    _fetchBTCListFromDB();
    Future.delayed(Duration(milliseconds: 1200), () {
      _timer = Timer.periodic(Duration(seconds: Constant.btcRetrievalInterval), (_) async {
        _retrieveBtcData(null);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Bit coin dashboard')),
      drawer: _buildAppDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildCurrentData(),
            _buildGraph(context),
            SizedBox(height: 30),
            _buildCurrencyToggleButton(context),
          ],
        ),
      ),
    );
  }

  Drawer _buildAppDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10),
            ListTile(title: Text('Display options', style: TextStyle(fontSize: 24))),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: const Text(
                        'Use graph made with custom painter',
                      ),
                    ),
                    Switch(
                      value: _useCustomPainterGraph,
                      onChanged: (val) {
                        setState(() {
                          _useCustomPainterGraph = val;
                        });
                        // close drawer
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                  foregroundColor: Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.white),
                    SizedBox(width: 5),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Clear graph line from db',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog.adaptive(
                        scrollable: true,
                        insetPadding: EdgeInsets.all(32),
                        title: Text('Want to delete?'),
                        content: Text(
                            'Do you want to remove all bit coin rate from database? Data in graph will be lost.'),
                        actions: [
                          RawMaterialButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Platform.isIOS
                              ? RawMaterialButton(
                                  onPressed: _deleteFromDB,
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                                  ),
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: _deleteFromDB,
                                  child: Text('Delete'),
                                ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _deleteFromDB() {
    // close dialog
    Navigator.pop(context);
    _databaseService.deleteAllRates();
    _bitCoinRates.value = [];
    _currentRateStreamController.add(left('Database cleared'));
    // close drawer
    Navigator.pop(context);
  }

  SizedBox _buildCurrencyToggleButton(BuildContext context) {
    final btnList = CurrencyType.values;
    return SizedBox(
      width: MediaQuery.of(context).size.width * .8,
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: ToggleButtons(
            constraints: BoxConstraints.expand(width: constraints.maxWidth / 2 - 2),
            isSelected: btnList.map((e) => e == _currency.type).toList(),
            selectedColor: Colors.white,
            fillColor: Theme.of(context).colorScheme.primary,
            selectedBorderColor: Theme.of(context).colorScheme.primary,
            borderColor: Colors.grey,
            borderRadius: BorderRadius.circular(20),
            onPressed: (index) {
              if (_currency.index == index) return;
              _onConvertCurrency();
            },
            children: btnList.map((e) => Text(e.name.toUpperCase())).toList(),
          ),
        ),
      ),
    );
  }

  SizedBox _buildGraph(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).width * .8,
      child: ValueListenableBuilder(
        valueListenable: _bitCoinRates,
        builder: (context, rates, _) => Stack(
          children: [
            _useCustomPainterGraph
                ? LineChartPainterWidget(
                    data: rates
                        .map(
                          (e) => (time: e.updatedTime, value: e.rateData.rate * _currency.factor),
                        )
                        .toList(),
                  )
                : LineChartWidget(
                    data: rates
                        .map(
                          (e) => (time: e.updatedTime, value: e.rateData.rate * _currency.factor),
                        )
                        .toList(),
                  ),
            if (rates.isEmpty) Center(child: Text('No accumulated data')),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentData() {
    return StreamBuilder<Either<String, BitCoinRate>>(
      stream: _currentRateStreamController.stream,
      initialData: left('No data'),
      builder: (context, sn) {
        if (sn.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
                child: Center(
                  child: sn.data?.fold(
                        (error) => Text(error),
                        (rateRecord) => BitCoinRateBox(
                          rateRecord: rateRecord,
                          rateFactor: _currency.factor,
                          unitSymbol: _currency.symbol,
                        ),
                      ) ??
                      const SizedBox.shrink(),
                ),
              ),
            ],
          );
        }
        return Text('No data');
      },
    );
  }

  Future<void> _fetchBTCListFromDB() async {
    final list = await _databaseService.getRateList();
    _bitCoinRates.value = list;
  }

  Future<void> _retrieveBtcData(_) async {
    final result = await http.get(Uri.parse(Constant.btcRetrievalUrl));
    if (result.statusCode != 200) {
      final errMsg = 'Error: ${result.body}';
      _currentRateStreamController.add(left(errMsg));
      return;
    }
    final body = jsonDecode(result.body);
    final BitCoinRate bpiRate = BitCoinRate.fromApiJSON(body);
    _currentRateStreamController.add(right(bpiRate));
    final newGraphData = BitCoinRateGraphData(
      rateData: bpiRate,
      updatedTime: DateTime.now(),
    );
    _databaseService.addRate(newGraphData);
    _bitCoinRates.value = [
      ..._bitCoinRates.value,
      newGraphData,
    ];
    return;
  }

  Future<void> _onConvertCurrency() async {
    double factor = 1;
    final updatedCurrency = _currency.toOpposite();
    if (updatedCurrency.type != CurrencyType.usd) {
      final result = await http.get(Uri.parse(
          'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json'));
      final body = jsonDecode(result.body);
      factor = double.tryParse(body['usd'][updatedCurrency.type.name].toString()) ?? 1;
    }
    setState(() {
      _currency = updatedCurrency.copyWith(factor: factor);
    });
  }
}
