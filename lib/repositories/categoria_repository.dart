import '../database/db.dart';
import '../models/categoria.dart';

class CategoriaRepository {
  Future<int> inserir(Categoria categoria) async {
    final db = await DB.instance.database;
    return await db.insert('categorias', categoria.toMap());
  }

  Future<List<Categoria>> listarTodos() async {
    final db = await DB.instance.database;
    final resultado = await db.query('categorias');
    return resultado.map((map) => Categoria.fromMap(map)).toList();
  }

  Future<List<Categoria>> listarCategoriasPaginado(int limit, int offset) async {
    final db = await DB.instance.database;
    final maps = await db.rawQuery('''
      SELECT 
        categorias.id AS categoria_id,
        categorias.nome AS categoria_nome,
        grupos.id AS grupo_id,
        grupos.nome AS grupo_nome
      FROM categorias
      INNER JOIN grupos ON categorias.grupo_id = grupos.id
      LIMIT ? OFFSET ?
    ''', [limit, offset]);
    return maps.map((map) => Categoria.fromMap(map)).toList();
  }

  Future<List<Categoria>> buscarPorGrupo(int grupoId) async {
    final db = await DB.instance.database;
    final maps = await db.rawQuery('''
      SELECT 
        categorias.id AS categoria_id,
        categorias.nome AS categoria_nome,
        grupos.id AS grupo_id,
        grupos.nome AS grupo_nome
      FROM categorias
      INNER JOIN grupos ON categorias.grupo_id = grupos.id
      WHERE grupos.id = ?
    ''', [grupoId]);

    return maps.map((map) => Categoria.fromMap(map)).toList();
  }

  Future<int> atualizar(Categoria categoria) async {
    final db = await DB.instance.database;
    return await db.update(
      'categorias',
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  Future<int> deletar(int id) async {
    final db = await DB.instance.database;
    return await db.delete(
      'categorias',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
