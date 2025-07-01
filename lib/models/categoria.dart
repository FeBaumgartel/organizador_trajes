import 'grupo.dart';

class Categoria{
  int id;
  String nome;
  Grupo grupo;

  Categoria({
    required this.id,
    required this.nome,
    required this.grupo
  });
}