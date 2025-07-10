import 'integrante.dart';
import 'peca.dart';
import 'traje.dart';

class PecaIntegrante {
  final int? id;
  final Integrante integrante;
  final Peca peca;
  final Traje traje;

  PecaIntegrante({
    this.id,
    required this.integrante,
    required this.peca,
    required this.traje,
  });

  factory PecaIntegrante.fromMap(Map<String, dynamic> map) {
    return PecaIntegrante(
      id: map['peca_integrante_id'] ?? map['id'],
      integrante: Integrante.fromMap(map),
      peca: Peca.fromMap(map),
      traje: Traje.fromMap(map),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'integrante_id': integrante.id,
      'peca_id': peca.id,
      'traje_id': traje.id,
    };
  }

  PecaIntegrante copyWith({
    int? id,
    Integrante? integrante,
    Peca? peca,
    Traje? traje,
  }) {
    return PecaIntegrante(
      id: id ?? this.id,
      integrante: integrante ?? this.integrante,
      peca: peca ?? this.peca,
      traje: traje ?? this.traje,
    );
  }
}
