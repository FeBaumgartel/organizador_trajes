import 'package:organizador_trajes/models/peca.dart';

import 'categoria.dart';
import 'grupo.dart';

class Traje{
  int? id;
  String nome;
  int quantidadeCompletos;
  int? quantidadeUsados;
  Categoria categoria;
  final Grupo grupo;
  List<Peca>? pecas;

  Traje({
    this.id,
    required this.nome,
    required this.quantidadeCompletos,
    this.quantidadeUsados,
    required this.categoria,
    required this.grupo,
    this.pecas
  });

  factory Traje.fromMap(Map<String, dynamic> map) {
    return Traje(
      id: map['traje_id'] ?? map['id'],
      nome: map['traje_nome'] ?? map['nome'],
      quantidadeCompletos: map['traje_quantidade_completos'] ?? map['quantidade_completos'],
      quantidadeUsados: map['traje_quantidade_usados'] ??map['quantidade_usados'],
      categoria: Categoria.fromMap(map),
      grupo: Grupo.fromMap(map),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'quantidade_completos': quantidadeCompletos,
      'quantidade_usados': quantidadeUsados,
      'categoria_id': categoria.id,
      'grupo_id': grupo.id,
    };
  }

  // Método copyWith
  Traje copyWith({
    int? id,
    String? nome,
    int? quantidadeCompletos,
    int? quantidadeUsados,
    Grupo? grupo,
    Categoria? categoria,
  }) {
    return Traje(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      quantidadeCompletos: quantidadeCompletos ?? this.quantidadeCompletos,
      quantidadeUsados: quantidadeUsados ?? this.quantidadeUsados,
      grupo: grupo ?? this.grupo,
      categoria: categoria ?? this.categoria,
    );
  }
}