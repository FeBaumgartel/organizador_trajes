class Grupo {
  final int? id;
  final String nome;

  Grupo({this.id, required this.nome});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
    };
  }

  factory Grupo.fromMap(Map<String, dynamic> map) {
    return Grupo(
      id: map['id'],
      nome: map['nome'],
    );
  }
}