import 'categoria.dart';
import 'traje.dart';

class Integrante{
  int id;
  String nome;
  Categoria categoria;

  Integrante({
    required this.id,
    required this.nome,
    required this.categoria
  });
}