// lib/screens/cadastro_categoria_page.dart

import 'package:flutter/material.dart';
import '../../models/categoria.dart';
import '../../models/grupo.dart';
import '../../repositories/categoria_repository.dart';
import '../../repositories/grupo_repository.dart';
import '../widgets/base_scaffold.dart';

class CadastroCategoriaPage extends StatefulWidget {
  const CadastroCategoriaPage({super.key});

  @override
  State<CadastroCategoriaPage> createState() => _CadastroCategoriaPageState();
}

class _CadastroCategoriaPageState extends State<CadastroCategoriaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();

  final CategoriaRepository _categoriaRepository = CategoriaRepository();
  final GrupoRepository _grupoRepository = GrupoRepository();

  List<Grupo> _grupos = [];
  Grupo? _grupoSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarGrupos();
  }

  Future<void> _carregarGrupos() async {
    final grupos = await _grupoRepository.listarTodos();
    setState(() {
      _grupos = grupos;
    });
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate() && _grupoSelecionado != null) {
      final novaCategoria = Categoria(
        nome: _nomeController.text,
        grupo: Grupo(
          id: _grupoSelecionado!.id!,
          nome: '',
        ), // só precisa do id nesse ponto
      );

      await _categoriaRepository.inserir(novaCategoria);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Cadastrar Categoria',
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
            const SizedBox(height: 16),
            DropdownButtonFormField<Grupo>(
              decoration: const InputDecoration(
                labelText: 'Grupo',
                labelStyle: TextStyle(color: Colors.white),
              ),
              dropdownColor: Colors.black87,
              value: _grupoSelecionado,
              onChanged: (grupo) {
                setState(() {
                  _grupoSelecionado = grupo;
                });
              },
              items: _grupos.map((grupo) {
                return DropdownMenuItem<Grupo>(
                  value: grupo,
                  child: Text(
                    grupo.nome,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              validator: (value) => value == null ? 'Selecione um grupo' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }
}
