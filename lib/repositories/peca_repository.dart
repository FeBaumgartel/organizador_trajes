import '../database/db.dart';
import '../models/peca.dart';

class PecaRepository {
  Future<int> inserir(Peca peca) async {
    final db = await DB.instance.database;
    return await db.insert('pecas', peca.toMap());
  }

  Future<List<Peca>> listarPorTraje(int trajeId) async {
    final db = await DB.instance.database;
    final resultado = await db.rawQuery(
      '''
      SELECT 
        pecas.id AS peca_id,
        pecas.nome AS peca_nome,
        pecas.quantidade AS peca_quantidade,
        pecas.quantidade_usados AS peca_quantidade_usados,
        trajes.id AS traje_id,
        trajes.nome AS traje_nome,
        trajes.quantidade_completos AS traje_quantidade_completos,
        trajes.quantidade_usados AS traje_quantidade_usados,
        categorias.id AS categoria_id,
        categorias.nome AS categoria_nome,
        grupos.id AS grupo_id,
        grupos.nome AS grupo_nome
      FROM pecas
      INNER JOIN trajes ON pecas.traje_id = trajes.id
      INNER JOIN categorias ON trajes.categoria_id = categorias.id
      INNER JOIN grupos ON trajes.grupo_id = grupos.id
      WHERE pecas.traje_id = ?
    ''',
      [trajeId],
    );

    return resultado.map((map) => Peca.fromMap(map)).toList();
  }

  Future<List<Peca>> listarPorIntegrante(int integranteId) async {
    final db = await DB.instance.database;
    final maps = await db.rawQuery(
      '''
      SELECT p.*, 
      t.nome AS traje_nome,
      t.quantidade_completos AS traje_quantidade_completos,
      t.quantidade_usados AS traje_quantidade_usados,
      g.nome AS grupo_nome,
      c.nome AS categoria_nome
      FROM pecas p
      INNER JOIN pecas_integrantes pi ON p.id = pi.peca_id
      INNER JOIN trajes t ON p.traje_id = t.id
      INNER JOIN grupos g ON t.grupo_id = g.id
      INNER JOIN categorias c ON t.categoria_id = c.id
      WHERE pi.integrante_id = ?
    ''',
      [integranteId],
    );

    return maps.map((map) {
      final peca = Peca.fromMap(map);
      peca.traje.nome = map['traje_nome'] as String;
      return peca;
    }).toList();
  }

  Future<int> atualizar(Peca peca) async {
    if (peca.id == null) {
      return await inserir(peca);
    }
    final db = await DB.instance.database;
    return await db.update(
      'pecas',
      peca.toMap(),
      where: 'id = ?',
      whereArgs: [peca.id],
    );
  }

  Future<int> deletar(int id) async {
    final db = await DB.instance.database;
    return await db.delete('pecas', where: 'id = ?', whereArgs: [id]);
  }
}
