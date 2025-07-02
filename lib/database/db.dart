import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  // Construtor privado
  DB._();
  // Instância singleton
  static final DB instance = DB._();
  // Instância do banco
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    return await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'organizador_trajes.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_grupo);
    await db.execute(_categoria);
    await db.execute(_traje);
    await db.execute(_pecaTraje);
    await db.execute(_integrante);
    await db.execute(_trajeIntegrante);
    await db.execute(_pecaIntegrante);
  }

  String get _grupo => '''
    CREATE TABLE grupos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL
    );
  ''';

  String get _categoria => '''
    CREATE TABLE categorias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      grupo_id INTEGER NOT NULL,
      FOREIGN KEY (grupo_id) REFERENCES grupos(id)
    );
  ''';

  String get _traje => '''
    CREATE TABLE trajes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      categoria_id INTEGER NOT NULL,
      FOREIGN KEY (categoria_id) REFERENCES categorias(id)
    );
  ''';

  String get _pecaTraje => '''
    CREATE TABLE pecas_traje (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      traje_id INTEGER NOT NULL,
      FOREIGN KEY (traje_id) REFERENCES trajes(id)
    );
  ''';

  String get _integrante => '''
    CREATE TABLE integrantes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      categoria_id INTEGER NOT NULL,
      grupo_id INTEGER NOT NULL,
      FOREIGN KEY (categoria_id) REFERENCES categorias(id),
      FOREIGN KEY (grupo_id) REFERENCES grupos(id)
    );
  ''';

  String get _trajeIntegrante => '''
    CREATE TABLE trajes_integrantes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      traje_id INTEGER NOT NULL,
      integrante_id INTEGER NOT NULL,
      completo INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (traje_id) REFERENCES trajes(id),
      FOREIGN KEY (integrante_id) REFERENCES integrantes(id)
    );
  ''';

  String get _pecaIntegrante => '''
    CREATE TABLE pecas_integrantes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      integrante_id INTEGER NOT NULL,
      peca_id INTEGER NOT NULL,
      traje_id INTEGER NOT NULL,
      FOREIGN KEY (integrante_id) REFERENCES integrantes(id),
      FOREIGN KEY (peca_id) REFERENCES pecas_traje(id),
      FOREIGN KEY (traje_id) REFERENCES trajes(id)
    );
  ''';
}
