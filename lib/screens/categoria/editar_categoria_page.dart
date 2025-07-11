import 'package:flutter/material.dart';
import '../../models/categoria.dart';
import '../../models/grupo.dart';
import '../../repositories/categoria_repository.dart';
import '../../repositories/grupo_repository.dart';
import '../widgets/base_scaffold.dart';

class EditarCategoriaPage extends StatefulWidget {
  final Categoria categoria;

  const EditarCategoriaPage({super.key, required this.categoria});

  @override
  _EditarCategoriaPageState createState() => _EditarCategoriaPageState();
}

class _EditarCategoriaPageState extends State<EditarCategoriaPage> {
  final GrupoRepository _grupoRepository = GrupoRepository();
  final CategoriaRepository _categoriaRepository = CategoriaRepository();

  final TextEditingController _nomeController = TextEditingController();

  List<Grupo> _grupos = [];

  Grupo? _grupoSelecionado;

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.categoria.nome;

    _grupoSelecionado = widget.categoria.grupo; // seleciona o grupo atual
    _carregarGrupos();
  }

  Future<void> _carregarGrupos() async {
    final grupos = await _grupoRepository.listarTodos();
    setState(() {
      _grupos = grupos;
    });
  }

  Future<void> _salvar() async {
    final atualizadoCategoria = widget.categoria.copyWith(
      nome: _nomeController.text,
      grupo: _grupoSelecionado!,
    );

    // Salva a categoria atualizado
    await _categoriaRepository.atualizar(atualizadoCategoria);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Editar Categoria',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome da categoria',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome da categoria';
                }
                return null;
              },
            ),
            DropdownButtonFormField<Grupo>(
              decoration: const InputDecoration(
                labelText: 'Grupo',
                labelStyle: TextStyle(color: Colors.white),
              ),
              value: _grupos.any((g) => g.id == _grupoSelecionado?.id)
                  ? _grupos.firstWhere((g) => g.id == _grupoSelecionado?.id)
                  : null,
              onChanged: (grupo) {
                setState(() => _grupoSelecionado = grupo);
              },
              items: _grupos.map((grupo) {
                return DropdownMenuItem(value: grupo, child: Text(grupo.nome));
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return _grupos.map((grupo) {
                  return Text(
                    grupo.nome,
                    style: const TextStyle(
                      color: Colors.white,
                    ), // <-- Texto selecionado (branco)
                  );
                }).toList();
              },
              validator: (value) => value == null ? 'Selecione um grupo' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvar,
              child: const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
