import 'package:btc_graph/entities/bit_coin_rate.dart';
import 'package:btc_graph/entities/bit_coin_rate_graph_data.dart';
import 'package:btc_graph/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database_service_test.mocks.dart';

@GenerateMocks([DatabaseService])
void main() {
  late Database database;
  late MockDatabaseService dbService;

  String tableRate = 'btc_rate_table';

  BitCoinRateGraphData testBTCRate = BitCoinRateGraphData(
    rateData: BitCoinRate.empty(),
    updatedTime: DateTime.now(),
  );
  List<BitCoinRateGraphData> rateList = List.generate(10, (index) => testBTCRate);

  setUpAll(() async {
    sqfliteFfiInit();
    database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await database.execute('''
      CREATE TABLE $tableRate (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ${BitCoinRate.unitKey} TEXT,
        ${BitCoinRate.symbolKey} TEXT,
        ${BitCoinRate.rateKey} REAL,
        ${BitCoinRate.rateStringKey} TEXT,
        ${BitCoinRate.descKey} TEXT,
        ${BitCoinRate.updatedTimeKey} TEXT,
        ${BitCoinRateGraphData.updatedTimeKey} TEXT
      )
      ''');
    dbService = MockDatabaseService();
    dbService.db = database;
    when(dbService.getDatabase()).thenAnswer((_) async => database);
    when(dbService.addRate(any)).thenAnswer((_) async => 1);
    when(dbService.getRateList()).thenAnswer((_) async => rateList);
    when(dbService.deleteAllRates()).thenAnswer((_) async => rateList.length);
  });

  group('Database Test', () {
    test('sqflite version', () async {
      expect(await database.getVersion(), 0);
    });
    test('Add item to database', () async {
      final i = await database.insert(
        tableRate,
        BitCoinRateGraphData(
          rateData: BitCoinRate(
            unit: 'GBP',
            symbol: 'gbp',
            rate: 100.3,
            rateString: '100.30',
            desc: 'test gbp',
            updatedTime: DateTime.now(),
          ),
          updatedTime: DateTime.now(),
        ).toDBJSON(),
      );
      final p = await database.query(tableRate);
      expect(p.length, i);
    });
    test('Add two items to database', () async {
      await database.insert(
        tableRate,
        BitCoinRateGraphData(
          rateData: BitCoinRate(
            unit: 'SYP',
            symbol: 'syp',
            rate: 170.32,
            rateString: '170.32',
            desc: 'test syp',
            updatedTime: DateTime.now(),
          ),
          updatedTime: DateTime.now(),
        ).toDBJSON(),
      );
      await database.insert(
        tableRate,
        BitCoinRateGraphData(
          rateData: BitCoinRate(
            unit: 'THB',
            symbol: 'thb',
            rate: 76456.322,
            rateString: '76456.322',
            desc: 'test thb',
            updatedTime: DateTime.now(),
          ),
          updatedTime: DateTime.now(),
        ).toDBJSON(),
      );
      final p = await database.query(tableRate);
      expect(p.length, 3);
    });
    test('Delete the all items', () async {
      await database.delete(tableRate);
      final p = await database.query(tableRate);
      expect(p.length, 0);
    });
    test('Close db', () async {
      await database.close();
      expect(database.isOpen, false);
    });
  });

  group("Service test", () {
    test("create rate", () async {
      verifyNever(dbService.addRate(testBTCRate));
      expect(await dbService.addRate(testBTCRate), 1);
      verify(dbService.addRate(testBTCRate)).called(1);
    });
    test("get all rates", () async {
      verifyNever(dbService.getRateList());
      expect(await dbService.getRateList(), rateList);
      verify(dbService.getRateList()).called(1);
    });
    test("delete all rates", () async {
      verifyNever(dbService.deleteAllRates());
      expect(await dbService.deleteAllRates(), 10);
      verify(dbService.deleteAllRates()).called(1);
    });
  });
}
