import 'package:flutter/material.dart';
import '../../models/integrante.dart';
import '../../repositories/integrante_repository.dart';
import 'cadastro_integrante_page.dart';
import 'editar_integrante_page.dart';
import 'visualizar_integrante_page.dart';
import '../widgets/base_scaffold.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../widgets/vincular_peca_integrante_page.dart';

class IntegrantesPage extends StatefulWidget {
  const IntegrantesPage({super.key});

  @override
  State<IntegrantesPage> createState() => _IntegrantesPageState();
}

class _IntegrantesPageState extends State<IntegrantesPage> {
  final IntegranteRepository _repository = IntegranteRepository();
  final ScrollController _scrollController = ScrollController();

  final int _pageSize = 5;
  List<Integrante> _integrantes = [];
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

    final novasIntegrantes = await _repository.listarIntegrantesPaginado(
      _pageSize,
      _offset,
    );

    setState(() {
      _integrantes.addAll(novasIntegrantes);
      _isLoading = false;
      _offset += _pageSize;
      if (novasIntegrantes.length < _pageSize) {
        _hasMore = false;
      }
    });
  }

  void _editarIntegrante(Integrante integrante) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarIntegrantePage(integrante: integrante),
      ),
    );
  }

  void _deletarIntegrante(Integrante integrante) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir o integrante "${integrante.nome}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deletar(integrante.id!);
      _resetarLista();
    }
  }

  void _resetarLista() {
    setState(() {
      _integrantes.clear();
      _offset = 0;
      _hasMore = true;
    });
    _carregarMais();
  }

  Future<void> _abrirCadastro() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CadastroIntegrantePage()),
    );

    if (resultado == true) {
      _resetarLista();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Integrantes',
      body: _integrantes.isEmpty && _isLoading
          ? ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => const IntegranteSkeleton(),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: _integrantes.length + (_isLoading || _hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _integrantes.length) {
                  final integrante = _integrantes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        integrante.nome,
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        'Grupo: ${integrante.grupo.nome} | Categoria: ${integrante.categoria.nome}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.black),
                            onPressed: () => _editarIntegrante(integrante),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deletarIntegrante(integrante),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VisualizarIntegrantePage(
                              integrante: integrante,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Theme.of(context).primaryColor,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.group_add),
            label: 'Cadastrar novo integrante',
            onTap: _abrirCadastro,
          ),
          SpeedDialChild(
            child: const Icon(Icons.link),
            label: 'Associar Peças a Integrante',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VincularPecaIntegrantePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class IntegranteSkeleton extends StatelessWidget {
  const IntegranteSkeleton({super.key});

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
      subtitle: Container(height: 12, color: Colors.white24),
      trailing: Container(width: 24, height: 24, color: Colors.white24),
    );
  }
}
