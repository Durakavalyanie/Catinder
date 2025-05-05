import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:kototinder/models/cat.dart';
import 'package:kototinder/cubits/liked_cats_cubit.dart';

class CatStorage {
  static final CatStorage _instance = CatStorage._internal();
  factory CatStorage() => _instance;
  CatStorage._internal();

  late Database _db;

  Future<void> init() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'cats.db');
    _db = await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE cachedCats('
          'imageUrl TEXT PRIMARY KEY, '
          'breed TEXT, '
          'description TEXT'
          ')',
        );
        await db.execute(
          'CREATE TABLE catActions('
          'imageUrl TEXT PRIMARY KEY, '
          'action TEXT, '
          'timestamp INTEGER'
          ')',
        );
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 3) {
          await db.execute(
            'CREATE TABLE cachedCats('
            'imageUrl TEXT PRIMARY KEY, '
            'breed TEXT, '
            'description TEXT'
            ')',
          );
        }
        if (oldV < 4) {
          await db.execute(
            'CREATE TABLE catActions('
            'imageUrl TEXT PRIMARY KEY, '
            'action TEXT, '
            'timestamp INTEGER'
            ')',
          );
        }
      },
    );
  }

  Future<void> saveCachedCat(Cat cat) async {
    await _db.insert(
      'cachedCats',
      {
        'imageUrl': cat.imageUrl,
        'breed': cat.breed,
        'description': cat.description,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Cat>> getCachedCats() async {
    final maps = await _db.query('cachedCats');
    return maps
        .map((row) => Cat(
              imageUrl: row['imageUrl'] as String? ?? '',
              breed: row['breed'] as String? ?? '',
              description: row['description'] as String? ?? '',
            ))
        .toList();
  }

  Future<void> setCatAction(String imageUrl, String action,
      [DateTime? timestamp]) async {
    await _db.insert(
      'catActions',
      {
        'imageUrl': imageUrl,
        'action': action,
        'timestamp': (timestamp ?? DateTime.now()).millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveCatAction(Cat cat, String action) async {
    await _db.insert(
      'catActions',
      {
        'imageUrl': cat.imageUrl,
        'breed': cat.breed,
        'description': cat.description,
        'action': action,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LikedCat>> getLikedCatsWithTimestamp() async {
    final result = await _db.rawQuery('''
      SELECT c.imageUrl, c.breed, c.description, a.timestamp
      FROM cachedCats c
      JOIN catActions a ON c.imageUrl = a.imageUrl
      WHERE a.action = 'liked'
      ORDER BY a.timestamp DESC
    ''');

    return result.map((row) {
      return LikedCat(
        cat: Cat(
          imageUrl: row['imageUrl'] as String,
          breed: row['breed'] as String,
          description: row['description'] as String,
        ),
        likedAt: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
      );
    }).toList();
  }
}
