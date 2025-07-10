import 'package:organizador_trajes/repositories/peca_repository.dart';

import '../database/db.dart';
import '../models/traje.dart';

class TrajeRepository {
  Future<int> inserir(Traje traje) async {
  PecaRepository pecaRepository = PecaRepository();
    final db = await DB.instance.database;
    int trajeId = await db.insert('trajes', traje.toMap());
    traje.id = trajeId;
    for(var peca in traje.pecas ?? []){
      peca.traje = traje;
      await pecaRepository.inserir(peca);
    }
    return trajeId;
  }


  Future<List<Traje>> listarTrajesPaginado(int limit, int offset) async {
    final db = await DB.instance.database;
    final resultado = await db.rawQuery('''
      SELECT 
        trajes.id AS traje_id,
        trajes.nome AS traje_nome,
        trajes.quantidade_completos AS traje_quantidade_completos,
        trajes.quantidade_usados AS traje_quantidade_usados,
        categorias.id AS categoria_id,
        categorias.nome AS categoria_nome,
        grupos.id AS grupo_id,
        grupos.nome AS grupo_nome
      FROM trajes
      INNER JOIN categorias ON trajes.categoria_id = categorias.id
      INNER JOIN grupos ON trajes.grupo_id = grupos.id
      LIMIT ? OFFSET ?
    ''', [limit, offset]);

    return resultado.map((map) => Traje.fromMap(map)).toList();
  }

  Future<List<Traje>> buscarPorCategoria(int categoriaId) async {
    final db = await DB.instance.database;
    final maps = await db.rawQuery('''
      SELECT 
        trajes.id AS traje_id,
        trajes.nome AS traje_nome,
        trajes.quantidade_completos AS traje_quantidade_completos,
        categorias.id AS categoria_id,
        categorias.nome AS categoria_nome,
        grupos.id AS grupo_id,
        grupos.nome AS grupo_nome
      FROM trajes
      INNER JOIN categorias ON trajes.categoria_id = categorias.id
      INNER JOIN grupos ON trajes.grupo_id = grupos.id
      WHERE categorias.id = ?
    ''', [categoriaId]);

    return maps.map((map) => Traje.fromMap(map)).toList();
  }

  Future<Traje> buscarPorId(int id) async {
    final db = await DB.instance.database;
    final resultado = await db.rawQuery('''
      SELECT 
        trajes.id AS traje_id,
        trajes.nome AS traje_nome,
        trajes.quantidade_completos AS traje_quantidade_completos,
        trajes.quantidade_usados AS traje_quantidade_usados,
        categorias.id AS categoria_id,
        categorias.nome AS categoria_nome,
        grupos.id AS grupo_id,
        grupos.nome AS grupo_nome
      FROM trajes
      INNER JOIN categorias ON trajes.categoria_id = categorias.id
      INNER JOIN grupos ON trajes.grupo_id = grupos.id
      WHERE trajes.id = ?
    ''', [id]);

    if (resultado.isNotEmpty) {
      return Traje.fromMap(resultado.first);
    } else {
      throw Exception('Traje não encontrado');
    }
  }

  Future<int> atualizar(Traje traje) async {
    final db = await DB.instance.database;
    return await db.update(
      'trajes',
      traje.toMap(),
      where: 'id = ?',
      whereArgs: [traje.id],
    );
  }

  Future<int> deletar(int id) async {
    final db = await DB.instance.database;
    return await db.delete(
      'trajes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
