import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  // Initialize the Database
  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();  
    final path = join(dbPath, 'expenses.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount REAL,
            category TEXT,
            date TEXT
          )
        ''');
      },
    );
  }


    String _formatDateForQuery(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }


  Future<List<Expense>> getExpensesForDate(DateTime date) async {
    final db = await database;
    final dateString = _formatDateForQuery(date);


    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: "strftime('%Y-%m-%d', date) = ?", 
      whereArgs: [dateString],
      orderBy: "id DESC", 
    );

    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }


  // Insert new expense 
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    // Ensure the date is stored in a consistent format (ISO8601 recommended)
    return await db.insert('expenses', expense.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all expenses 
  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expenses', orderBy: "date DESC");

    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }


  // Update an expense
  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Delete an expense
  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
