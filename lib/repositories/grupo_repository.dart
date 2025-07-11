import '../database/db.dart';
import '../models/grupo.dart';

class GrupoRepository {
  Future<int> inserir(Grupo grupo) async {
    final db = await DB.instance.database;
    return await db.insert('grupos', grupo.toMap());
  }

  Future<List<Grupo>> listarTodos() async {
    final db = await DB.instance.database;
    final resultado = await db.query('grupos');
    return resultado.map((map) => Grupo.fromMap(map)).toList();
  }

  Future<List<Grupo>> listarGruposPaginado(int limit, int offset) async {
    final db = await DB.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'grupos',
      limit: limit,
      offset: offset,
      orderBy: 'id DESC',
    );
    return maps.map((map) => Grupo.fromMap(map)).toList();
  }

  Future<int> atualizar(Grupo grupo) async {
    final db = await DB.instance.database;
    return await db.update(
      'grupos',
      grupo.toMap(),
      where: 'id = ?',
      whereArgs: [grupo.id],
    );
  }

  Future<int> deletar(int id) async {
    final db = await DB.instance.database;
    return await db.delete('grupos', where: 'id = ?', whereArgs: [id]);
  }
}
