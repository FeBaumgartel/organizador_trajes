// grupos_page.dart
import 'package:flutter/material.dart';
import 'cadastro_grupo_page.dart';
import 'editar_grupo_page.dart';
import '../../models/grupo.dart';
import '../../repositories/grupo_repository.dart';
import '../widgets/base_scaffold.dart';

class GruposPage extends StatefulWidget {
  const GruposPage({super.key});

  @override
  State<GruposPage> createState() => _GruposPageState();
}

class _GruposPageState extends State<GruposPage> {
  final GrupoRepository _repository = GrupoRepository();
  final ScrollController _scrollController = ScrollController();

  final int _pageSize = 5;
  List<Grupo> _grupos = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _carregarMaisGrupos();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_isLoading &&
          _hasMore) {
        _carregarMaisGrupos();
      }
    });
  }

  Future<void> _carregarMaisGrupos() async {
    setState(() => _isLoading = true);

    final novosGrupos = await _repository.listarGruposPaginado(_pageSize, _offset);

    setState(() {
      _grupos.addAll(novosGrupos);
      _isLoading = false;
      _offset += _pageSize;
      if (novosGrupos.length < _pageSize) {
        _hasMore = false;
      }
    });
  }

  void _editarGrupo(Grupo grupo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarGrupoPage(grupo: grupo),
      ),
    );
  }

  void _deletarGrupo(Grupo grupo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o grupo "${grupo.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deletar(grupo.id!);
      _resetarLista();
    }
  }

  void _resetarLista() {
    setState(() {
      _grupos.clear();
      _offset = 0;
      _hasMore = true;
    });
    _carregarMaisGrupos();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Grupos',
      body: _grupos.isEmpty && _isLoading
    ? ListView.builder(
        itemCount: 5, // Exibe 5 skeletons
        itemBuilder: (_, __) => const GrupoSkeleton(),
      )
    : ListView.builder(
        controller: _scrollController,
        itemCount: _grupos.length + (_isLoading || _hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _grupos.length) {
            final grupo = _grupos[index];
            return ListTile(
              title: Text(
                grupo.nome,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => _editarGrupo(grupo),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deletarGrupo(grupo),
                  ),
                ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CadastroGrupoPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Cadastrar novo grupo',
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class GrupoSkeleton extends StatelessWidget {
  const GrupoSkeleton({super.key});

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
      trailing: Container(
        width: 24,
        height: 24,
        color: Colors.white24,
      ),
    );
  }
}