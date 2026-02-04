import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expenses.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  // Insert expense
  Future<int> insertExpense(Expense expense) async {
    Database db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  // Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(
      DateTime start, DateTime end) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String category) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  // Update expense
  Future<int> updateExpense(Expense expense) async {
    Database db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Delete expense
  Future<int> deleteExpense(int id) async {
    Database db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get total expenses for a month
  Future<double> getMonthlyTotal(int year, int month) async {
    Database db = await database;
    DateTime start = DateTime(year, month, 1);
    DateTime end = DateTime(year, month + 1, 0, 23, 59, 59);

    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ?',
      [start.toIso8601String(), end.toIso8601String()],
    );

    return result.first['total'] ?? 0.0;
  }

  // Get category totals for a month
  Future<Map<String, double>> getCategoryTotals(int year, int month) async {
    Database db = await database;
    DateTime start = DateTime(year, month, 1);
    DateTime end = DateTime(year, month + 1, 0, 23, 59, 59);

    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ? GROUP BY category',
      [start.toIso8601String(), end.toIso8601String()],
    );

    Map<String, double> categoryTotals = {};
    for (var row in result) {
      categoryTotals[row['category']] = row['total'];
    }
    return categoryTotals;
  }

  // Close database
  Future<void> close() async {
    Database db = await database;
    db.close();
  }
}