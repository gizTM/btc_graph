import 'package:btc_graph/entities/bit_coin_rate.dart';
import 'package:btc_graph/entities/bit_coin_rate_graph_data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? db;
  static final DatabaseService instance = DatabaseService._constructor();

  final _btcRateTableName = 'btc_rate';
  final _btcRateIdColumnName = 'id';

  DatabaseService._constructor();

  Future<Database> get database async {
    if (db != null) return db!;
    db = await getDatabase();
    return db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'master_db.db');
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        db.execute('''
      CREATE TABLE $_btcRateTableName (
        $_btcRateIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
        ${BitCoinRate.unitKey} TEXT,
        ${BitCoinRate.symbolKey} TEXT,
        ${BitCoinRate.rateKey} REAL,
        ${BitCoinRate.rateStringKey} TEXT,
        ${BitCoinRate.descKey} TEXT,
        ${BitCoinRate.updatedTimeKey} TEXT,
        ${BitCoinRateGraphData.updatedTimeKey} TEXT
      )
      ''');
      },
    );
    return database;
  }

  Future<int> addRate(BitCoinRateGraphData rate) async {
    final db = await database;
    return db.insert(_btcRateTableName, rate.toDBJSON());
  }

  Future<List<BitCoinRateGraphData>> getRateList() async {
    final db = await database;
    final objList = await db.query(_btcRateTableName);
    return objList.map((e) => BitCoinRateGraphData.fromDBJSON(e)).toList();
  }

  Future<int> deleteAllRates() async {
    final db = await database;
    return db.delete(_btcRateTableName);
  }
}
