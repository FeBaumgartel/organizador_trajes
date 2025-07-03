import 'grupo.dart';
import 'categoria.dart';

class Integrante{
  final int? id;
  final String nome;
  final Categoria categoria;
  final Grupo grupo;

  Integrante({
    this.id,
    required this.nome,
    required this.categoria,
    required this.grupo
  });

  factory Integrante.fromMap(Map<String, dynamic> map) {
    return Integrante(
      id: map['integrante_id'] ?? map['id'],
      nome: map['integrante_nome'] ?? map['nome'],
      categoria: Categoria.fromMap(map),
      grupo: Grupo.fromMap(map),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'categoria_id': categoria.id,
      'grupo_id': grupo.id,
    };
  }

  // Método copyWith
  Integrante copyWith({
    int? id,
    String? nome,
    Grupo? grupo,
    Categoria? categoria,
  }) {
    return Integrante(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      grupo: grupo ?? this.grupo,
      categoria: categoria ?? this.categoria,
    );
  }
}