import 'package:flutter/material.dart';
import '../../models/traje.dart';
import '../../models/peca.dart';
import '../../repositories/traje_repository.dart';
import '../../repositories/peca_repository.dart';
import '../widgets/base_scaffold.dart';

class TrajesPage extends StatefulWidget {
  const TrajesPage({super.key});

  @override
  State<TrajesPage> createState() => _TrajesPageState();
}

class _TrajesPageState extends State<TrajesPage> {
  final TrajeRepository _trajeRepository = TrajeRepository();
  final PecaRepository _pecaRepository = PecaRepository();

  final int _pageSize = 5;
  final ScrollController _scrollController = ScrollController();

  List<Traje> _trajes = [];
  Map<int, List<Peca>> _pecasPorTraje = {};
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _carregarMais();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _carregarMais();
      }
    });
  }

  Future<void> _carregarMais() async {
    setState(() => _isLoading = true);

    final novosTrajes = await _trajeRepository.listarTodos(); // aqui pode adicionar paginação se precisar
    for (var traje in novosTrajes) {
      final pecas = await _pecaRepository.listarPorTraje(traje.id!);
      _pecasPorTraje[traje.id!] = pecas;
    }

    setState(() {
      _trajes.addAll(novosTrajes);
      _offset += _pageSize;
      _isLoading = false;
      if (novosTrajes.length < _pageSize) {
        _hasMore = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Trajes',
      body: _trajes.isEmpty && _isLoading
          ? ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => const TrajeSkeleton(),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: _trajes.length + (_isLoading || _hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _trajes.length) {
                  final traje = _trajes[index];
                  final pecas = _pecasPorTraje[traje.id!] ?? [];

                  return ExpansionTile(
                    title: Text(
                      traje.nome,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Grupo: ${traje.grupo.nome} | Categoria: ${traje.categoria.nome} | Qtd. Completos: ${traje.quantidadeCompletos}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    children: pecas.isEmpty
                        ? [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Nenhuma peça cadastrada.', style: TextStyle(color: Colors.white54)),
                            ),
                          ]
                        : pecas.map((peca) {
                            return ListTile(
                              title: Text(
                                peca.nome,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Quantidade: ${peca.quantidade} | Usados: ${peca.quantidadeUsados ?? 0}',
                                style: const TextStyle(color: Colors.white54),
                              ),
                            );
                          }).toList(),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class TrajeSkeleton extends StatelessWidget {
  const TrajeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      title: Container(
        height: 16,
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.white24,
      ),
      subtitle: Container(
        height: 12,
        color: Colors.white24,
      ),
    );
  }
}
