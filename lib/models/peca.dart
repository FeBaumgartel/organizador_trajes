import 'traje.dart';

class Peca{
  int? id;
  String nome;
  int quantidade;
  int? quantidadeUsados;
  Traje traje;

  Peca({
    this.id,
    required this.nome,
    required this.quantidade,
    this.quantidadeUsados,
    required this.traje
  });

  factory Peca.fromMap(Map<String, dynamic> map) {
    return Peca(
      id: map['peca_id'] ?? map['id'],
      nome: map['peca_nome'] ?? map['nome'],
      quantidade: map['peca_quantidade'] ??map['quantidade'],
      quantidadeUsados: map['peca_quantidade_usados'] ??map['quantidade_usados'],
      traje: Traje.fromMap(map),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'quantidade': quantidade,
      'quantidade_usados': quantidadeUsados,
      'traje_id': traje.id,
    };
  }
}