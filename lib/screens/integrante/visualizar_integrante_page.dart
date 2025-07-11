import 'package:flutter/material.dart';
import '../../models/integrante.dart';
import '../../models/peca.dart';
import '../../models/traje.dart';
import '../../repositories/peca_repository.dart';
import '../widgets/base_scaffold.dart';

class VisualizarIntegrantePage extends StatefulWidget {
  final Integrante integrante;

  const VisualizarIntegrantePage({super.key, required this.integrante});

  @override
  State<VisualizarIntegrantePage> createState() =>
      _VisualizarIntegrantePageState();
}

class _VisualizarIntegrantePageState extends State<VisualizarIntegrantePage> {
  final PecaRepository _pecaRepository = PecaRepository();
  final Map<Traje, List<Peca>> _pecasPorTraje = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarPecas();
  }

  Future<void> _carregarPecas() async {
    final pecas = await _pecaRepository.listarPorIntegrante(
      widget.integrante.id!,
    );

    final Map<int, Traje> trajesMap = {};
    for (var peca in pecas) {
      final traje = peca.traje;
      trajesMap[traje.id!] = traje;
    }

    final Map<Traje, List<Peca>> agrupado = {};
    for (var peca in pecas) {
      final traje = trajesMap[peca.traje.id!]!;
      agrupado.putIfAbsent(traje, () => []).add(peca);
    }

    setState(() {
      _pecasPorTraje.clear();
      _pecasPorTraje.addAll(agrupado);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: widget.integrante.nome,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pecasPorTraje.isEmpty
          ? const Center(child: Text('Nenhuma peça vinculada.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: _pecasPorTraje.entries.map((entry) {
                final traje = entry.key;
                final pecas = entry.value;

                return ExpansionTile(
                  title: Text(
                    traje.nome,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Grupo: ${traje.grupo.nome} | Categoria: ${traje.categoria.nome}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  children: pecas.map((peca) {
                    return ListTile(
                      title: Text(
                        peca.nome,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Quantidade Livre: ${peca.quantidade - (peca.quantidadeUsados ?? 0)}',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
    );
  }
}
