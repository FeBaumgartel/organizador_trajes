class Grupo {
  final int? id;
  final String nome;

  Grupo({this.id, required this.nome});

  factory Grupo.fromMap(Map<String, dynamic> map) {
    return Grupo(
      id: map['grupo_id'] ?? map['id'],
      nome: map['grupo_nome'] ?? map['nome'],
    );
  }

  Map<String, dynamic> toMap() {
    return {if (id != null) 'id': id, 'nome': nome};
  }

  // Método copyWith
  Grupo copyWith({int? id, String? nome}) {
    return Grupo(id: id ?? this.id, nome: nome ?? this.nome);
  }
}
