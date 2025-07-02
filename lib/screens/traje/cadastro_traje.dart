import 'package:flutter/material.dart';
import '../../models/categoria.dart';
import '../../models/grupo.dart';
import '../../models/traje.dart';
import '../../models/peca.dart';
import '../../repositories/grupo_repository.dart';
import '../../repositories/categoria_repository.dart';
import '../../repositories/traje_repository.dart';
import '../../repositories/peca_repository.dart';
import '../widgets/base_scaffold.dart';

class CadastroTrajePage extends StatefulWidget {
  const CadastroTrajePage({super.key});

  @override
  State<CadastroTrajePage> createState() => _CadastroTrajePageState();
}

class _CadastroTrajePageState extends State<CadastroTrajePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantidadeCompletosController = TextEditingController();

  final GrupoRepository _grupoRepository = GrupoRepository();
  final CategoriaRepository _categoriaRepository = CategoriaRepository();
  final TrajeRepository _trajeRepository = TrajeRepository();
  final PecaRepository _pecaRepository = PecaRepository();

  List<Grupo> _grupos = [];
  List<Categoria> _categorias = [];

  Grupo? _grupoSelecionado;
  Categoria? _categoriaSelecionada;

  bool _carregandoGrupos = true;
  bool _carregandoCategorias = false;

  // Lista de peças
  List<Map<String, TextEditingController>> _pecasControllers = [];

  @override
  void initState() {
    super.initState();
    _carregarGrupos();
    _adicionarPeca(); // pelo menos uma
  }

  void _adicionarPeca() {
    setState(() {
      _pecasControllers.add({
        'nome': TextEditingController(),
        'quantidade': TextEditingController(),
      });
    });
  }

  void _removerPeca(int index) {
    setState(() {
      _pecasControllers.removeAt(index);
    });
  }

  Future<void> _carregarGrupos() async {
    final grupos = await _grupoRepository.listarTodos();
    setState(() {
      _grupos = grupos;
      _carregandoGrupos = false;
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
    if (!_formKey.currentState!.validate()) return;
    if (_grupoSelecionado == null || _categoriaSelecionada == null) return;
    if (_pecasControllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos uma peça.')),
      );
      return;
    }

    final traje = Traje(
      nome: _nomeController.text.trim(),
      quantidadeCompletos: int.parse(_quantidadeCompletosController.text.trim()),
      categoria: _categoriaSelecionada!,
      grupo: _grupoSelecionado!,
    );

    final id = await _trajeRepository.inserir(traje);
    traje.id = id; // agora contém o ID

    for (var pecas in _pecasControllers) {
      final peca = Peca(
        nome: pecas['nome']!.text.trim(),
        quantidade: int.parse(pecas['quantidade']!.text.trim()),
        traje: traje, // agora com ID válido
      );
      await _pecaRepository.inserir(peca);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Cadastrar Traje',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _carregandoGrupos
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(labelText: 'Nome do Traje'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantidadeCompletosController,
                      decoration: const InputDecoration(labelText: 'Qtd. Completos'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Informe a quantidade' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Grupo>(
                      decoration: const InputDecoration(labelText: 'Grupo'),
                      value: _grupoSelecionado,
                      onChanged: (grupo) {
                        setState(() => _grupoSelecionado = grupo);
                        _carregarCategoriasDoGrupo(grupo!.id!);
                      },
                      items: _grupos.map((grupo) {
                        return DropdownMenuItem(
                          value: grupo,
                          child: Text(grupo.nome),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'Selecione um grupo' : null,
                    ),
                    const SizedBox(height: 16),
                    _carregandoCategorias
                        ? const CircularProgressIndicator()
                        : DropdownButtonFormField<Categoria>(
                            decoration: const InputDecoration(labelText: 'Categoria'),
                            value: _categoriaSelecionada,
                            onChanged: (categoria) {
                              setState(() {
                                _categoriaSelecionada = categoria;
                              });
                            },
                            items: _categorias.map((categoria) {
                              return DropdownMenuItem(
                                value: categoria,
                                child: Text(categoria.nome),
                              );
                            }).toList(),
                            validator: (value) =>
                                value == null ? 'Selecione uma categoria' : null,
                          ),
                    const SizedBox(height: 24),
                    const Text('Peças do Traje', style: TextStyle(fontWeight: FontWeight.bold)),
                    ..._pecasControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      var pecas = entry.value;
                      return Column(
                        key: ValueKey(index),
                        children: [
                          TextFormField(
                            controller: pecas['nome'],
                            decoration: InputDecoration(labelText: 'Nome da Peça ${index + 1}'),
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? 'Informe o nome' : null,
                          ),
                          TextFormField(
                            controller: pecas['quantidade'],
                            decoration: const InputDecoration(labelText: 'Quantidade'),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? 'Informe a quantidade' : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: _pecasControllers.length > 1
                                  ? () => _removerPeca(index)
                                  : null,
                            ),
                          ),
                          const Divider(),
                        ],
                      );
                    }),
                    TextButton.icon(
                      onPressed: _adicionarPeca,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar Peça'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _salvar,
                      child: const Text('Salvar Traje'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
