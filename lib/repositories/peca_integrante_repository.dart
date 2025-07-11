import '../database/db.dart';
import '../models/peca_integrante.dart';

class PecaIntegranteRepository {
  Future<int> inserir(PecaIntegrante pecaIntegrante) async {
    final db = await DB.instance.database;
    return await db.insert('pecas_integrantes', pecaIntegrante.toMap());
  }

  Future<List<PecaIntegrante>> listarPorIntegrante(int integranteId) async {
    final db = await DB.instance.database;
    final resultado = await db.rawQuery(
      '''
      SELECT 
        pi.id AS pi_id,
        pi.peca_id,
        pi.traje_id,
        pi.integrante_id,
        p.nome AS peca_nome,
        t.nome AS traje_nome
      FROM pecas_integrantes pi
      INNER JOIN pecas p ON pi.peca_id = p.id
      INNER JOIN trajes t ON pi.traje_id = t.id
      WHERE pi.integrante_id = ?
    ''',
      [integranteId],
    );

    return resultado.map((map) => PecaIntegrante.fromMap(map)).toList();
  }

  Future<int> deletar(int id) async {
    final db = await DB.instance.database;
    return await db.delete(
      'pecas_integrantes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletarPorIntegrante(int integranteId) async {
    final db = await DB.instance.database;
    await db.delete(
      'pecas_integrantes',
      where: 'integrante_id = ?',
      whereArgs: [integranteId],
    );
  }
}
