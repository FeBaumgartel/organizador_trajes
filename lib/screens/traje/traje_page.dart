import 'package:flutter/material.dart';
import '../../models/traje.dart';
import '../../models/peca.dart';
import '../../repositories/traje_repository.dart';
import '../../repositories/peca_repository.dart';
import '../widgets/base_scaffold.dart';
import 'cadastro_traje_page.dart';
import 'editar_traje_page.dart'; // Tela de edição

class TrajesPage extends StatefulWidget {
  const TrajesPage({super.key});

  @override
  State<TrajesPage> createState() => _TrajesPageState();
}

class _TrajesPageState extends State<TrajesPage> {
  final PecaRepository _pecaRepository = PecaRepository();
  final TrajeRepository _trajeRepository = TrajeRepository();
  final ScrollController _scrollController = ScrollController();

  final int _pageSize = 5;
  final List<Traje> _trajes = [];
  final Map<int, List<Peca>> _pecasPorTraje = {};
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

    final novosTrajes = await _trajeRepository.listarTrajesPaginado(_pageSize, _offset);
    for (var traje in novosTrajes) {
      final pecas = await _pecaRepository.listarPorTraje(traje.id!);
      _pecasPorTraje[traje.id!] = pecas;
    }

    setState(() {
      _trajes.addAll(novosTrajes);
      _isLoading = false;
      _offset += _pageSize;
      if (novosTrajes.length < _pageSize) {
        _hasMore = false;
      }
    });
  }

  void _resetarLista() {
    setState(() {
      _trajes.clear();
      _offset = 0;
      _hasMore = true;
    });
    _carregarMais();
  }

  // Função para navegar para a tela de edição
  void _editarTraje(Traje traje) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarTrajePage(traje: traje),
      ),
    );
  }

  void _deletarTraje(Traje traje) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o traje "${traje.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirm == true) {
      await _trajeRepository.deletar(traje.id!);
      _resetarLista();
    }
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () => _editarTraje(traje),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deletarTraje(traje),
                        ),
                      ],
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
            
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final resultado = Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CadastroTrajePage()),
          );

          if (resultado == true) {
            _resetarLista();
          }
        },
        tooltip: 'Cadastrar novo traje',
        child: const Icon(Icons.add),
      )
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
