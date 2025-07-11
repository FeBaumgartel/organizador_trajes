import 'package:flutter/material.dart';
import '../../models/integrante.dart';
import '../../models/categoria.dart';
import '../../models/grupo.dart';
import '../../repositories/integrante_repository.dart';
import '../../repositories/categoria_repository.dart';
import '../../repositories/grupo_repository.dart';
import '../widgets/base_scaffold.dart';

class CadastroIntegrantePage extends StatefulWidget {
  const CadastroIntegrantePage({super.key});

  @override
  State<CadastroIntegrantePage> createState() => _CadastroIntegrantePageState();
}

class _CadastroIntegrantePageState extends State<CadastroIntegrantePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();

  final IntegranteRepository _integranteRepository = IntegranteRepository();
  final GrupoRepository _grupoRepository = GrupoRepository();
  final CategoriaRepository _categoriaRepository = CategoriaRepository();

  List<Grupo> _grupos = [];
  List<Categoria> _categorias = [];

  Grupo? _grupoSelecionado;
  Categoria? _categoriaSelecionada;

  bool _carregandoCategorias = false;

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

  Future<void> _carregarCategoriasDoGrupo(int grupoId) async {
    setState(() {
      _carregandoCategorias = true;
      _categoriaSelecionada = null;
      _categorias = [];
    });

    final categorias = await _categoriaRepository.buscarPorGrupo(grupoId);

    setState(() {
      _categorias = categorias;
      _carregandoCategorias = false;
    });
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate() &&
        _grupoSelecionado != null &&
        _categoriaSelecionada != null) {
      final novoIntegrante = Integrante(
        nome: _nomeController.text,
        grupo: Grupo(id: _grupoSelecionado!.id!, nome: ''),
        categoria: Categoria(
          id: _categoriaSelecionada!.id!,
          nome: '',
          grupo: _grupoSelecionado!,
        ),
      );

      await _integranteRepository.inserir(novoIntegrante);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Cadastrar Integrante',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do integrante',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome do integrante';
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
                _carregarCategoriasDoGrupo(grupo!.id!);
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
            const SizedBox(height: 16),
            _carregandoCategorias
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<Categoria>(
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    dropdownColor: Colors.black87,
                    value: _categoriaSelecionada,
                    onChanged: (categoria) {
                      setState(() {
                        _categoriaSelecionada = categoria;
                      });
                    },
                    items: _categorias.map((categoria) {
                      return DropdownMenuItem<Categoria>(
                        value: categoria,
                        child: Text(
                          categoria.nome,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    validator: (value) =>
                        value == null ? 'Selecione uma categoria' : null,
                  ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }
}
