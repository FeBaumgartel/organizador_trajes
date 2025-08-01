import 'package:flutter/material.dart';
import '../../models/categoria.dart';
import '../../repositories/categoria_repository.dart';
import 'cadastro_categoria_page.dart';
import 'editar_categoria_page.dart';
import '../widgets/base_scaffold.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  final CategoriaRepository _repository = CategoriaRepository();
  final ScrollController _scrollController = ScrollController();

  final int _pageSize = 5;
  List<Categoria> _categorias = [];
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

    final novasCategorias = await _repository.listarCategoriasPaginado(
      _pageSize,
      _offset,
    );

    setState(() {
      _categorias.addAll(novasCategorias);
      _isLoading = false;
      _offset += _pageSize;
      if (novasCategorias.length < _pageSize) {
        _hasMore = false;
      }
    });
  }

  void _editarCategoria(Categoria categoria) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarCategoriaPage(categoria: categoria),
      ),
    );
  }

  void _deletarCategoria(Categoria categoria) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir a categoria "${categoria.nome}"?',
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
      await _repository.deletar(categoria.id!);
      _resetarLista();
    }
  }

  void _resetarLista() {
    setState(() {
      _categorias.clear();
      _offset = 0;
      _hasMore = true;
    });
    _carregarMais();
  }

  Future<void> _abrirCadastro() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CadastroCategoriaPage()),
    );

    if (resultado == true) {
      _resetarLista();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Categorias',
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastro,
        tooltip: 'Cadastrar nova categoria',
        child: const Icon(Icons.add),
      ),
      body: _categorias.isEmpty && _isLoading
          ? ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => const CategoriaSkeleton(),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: _categorias.length + (_isLoading || _hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _categorias.length) {
                  final categoria = _categorias[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        categoria.nome,
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        'Grupo: ${categoria.grupo.nome}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.black),
                            onPressed: () => _editarCategoria(categoria),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deletarCategoria(categoria),
                          ),
                        ],
                      ),
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
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class CategoriaSkeleton extends StatelessWidget {
  const CategoriaSkeleton({super.key});

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
