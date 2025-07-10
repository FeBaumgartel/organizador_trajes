import 'integrante.dart';
import 'traje.dart';

class TrajeIntegrante{
  int id;
  Traje traje;
  Integrante integrante;
  bool completo;

  TrajeIntegrante({
    required this.id,
    required this.traje,
    required this.integrante,
    required this.completo
  });
}