import 'categoria.dart';
import 'grupo.dart';

class Traje{
  int? id;
  String nome;
  int quantidadeCompletos;
  int? quantidadeUsados;
  Categoria categoria;
  final Grupo grupo;

  Traje({
    this.id,
    required this.nome,
    required this.quantidadeCompletos,
    this.quantidadeUsados,
    required this.categoria,
    required this.grupo
  });

  factory Traje.fromMap(Map<String, dynamic> map) {
    return Traje(
      id: map['traje_id'] ?? map['id'],
      nome: map['traje_nome'] ?? map['nome'],
      quantidadeCompletos: map['traje_quantidade_completos'] ??map['quantidade_completos'],
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
}