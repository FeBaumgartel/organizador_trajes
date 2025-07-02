import 'package:organizador_trajes/models/grupo.dart';

class Categoria {
  final int? id;
  final String nome;
  final Grupo grupo;

  Categoria({
    this.id,
    required this.nome,
    required this.grupo,
  });

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['categoria_id'] ?? map['id'],
      nome: map['categoria_nome'] ?? map['nome'],
      grupo: Grupo.fromMap(map),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'grupo_id': grupo.id, // Usa apenas o id para salvar no banco
    };
  }
}
