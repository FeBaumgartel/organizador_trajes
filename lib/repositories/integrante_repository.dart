import '../database/db.dart';
import '../models/integrante.dart';

class IntegranteRepository {
  Future<int> inserir(Integrante integrante) async {
    final db = await DB.instance.database;
    return await db.insert('integrantes', integrante.toMap());
  }

  Future<List<Integrante>> listarTodos() async {
    final db = await DB.instance.database;
    final resultado = await db.query('integrantes');
    return resultado.map((map) => Integrante.fromMap(map)).toList();
  }

  Future<List<Integrante>> listarIntegrantesPaginado(
    int limit,
    int offset,
  ) async {
    final db = await DB.instance.database;
    final maps = await db.rawQuery(
      '''
      SELECT 
        integrantes.id AS integrante_id,
        integrantes.nome AS integrante_nome,
        grupos.id AS grupo_id,
        grupos.nome AS grupo_nome,
        categorias.id AS categoria_id,
        categorias.nome AS categoria_nome
      FROM integrantes
      INNER JOIN grupos ON integrantes.grupo_id = grupos.id
      INNER JOIN categorias ON integrantes.categoria_id = categorias.id
      LIMIT ? OFFSET ?
    ''',
      [limit, offset],
    );

    return maps.map((map) => Integrante.fromMap(map)).toList();
  }

  Future<List<Integrante>> buscarPorCategoria(int categoriaId) async {
    final db = await DB.instance.database;
    final maps = await db.rawQuery(
      '''
      SELECT 
        integrantes.id AS integrante_id,
        integrantes.nome AS integrante_nome,
        grupos.id AS grupo_id,
        grupos.nome AS grupo_nome,
        categorias.id AS categoria_id,
        categorias.nome AS categoria_nome
      FROM integrantes
      INNER JOIN grupos ON integrantes.grupo_id = grupos.id
      INNER JOIN categorias ON integrantes.categoria_id = categorias.id
      WHERE categorias.id = ?
    ''',
      [categoriaId],
    );

    return maps.map((map) => Integrante.fromMap(map)).toList();
  }

  Future<int> atualizar(Integrante integrante) async {
    final db = await DB.instance.database;
    return await db.update(
      'integrantes',
      integrante.toMap(),
      where: 'id = ?',
      whereArgs: [integrante.id],
    );
  }

  Future<int> deletar(int id) async {
    final db = await DB.instance.database;
    return await db.delete('integrantes', where: 'id = ?', whereArgs: [id]);
  }
}
