import 'package:flutter/material.dart';
import '../../models/categoria.dart';
import '../../models/grupo.dart';
import '../../models/traje.dart';
import '../../models/peca.dart';
import '../../repositories/grupo_repository.dart';
import '../../repositories/categoria_repository.dart';
import '../../repositories/traje_repository.dart';
import '../widgets/base_scaffold.dart';
import 'peca_form.dart'; // Importa o componente PecaForm

class CadastroTrajePage extends StatefulWidget {
  const CadastroTrajePage({super.key});

  @override
  State<CadastroTrajePage> createState() => _CadastroTrajePageState();
}

class _CadastroTrajePageState extends State<CadastroTrajePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantidadeCompletosController = TextEditingController();
  final TextEditingController _quantidadeUsadosController = TextEditingController();

  final GrupoRepository _grupoRepository = GrupoRepository();
  final CategoriaRepository _categoriaRepository = CategoriaRepository();
  final TrajeRepository _trajeRepository = TrajeRepository();

  List<Grupo> _grupos = [];
  List<Categoria> _categorias = [];

  Grupo? _grupoSelecionado;
  Categoria? _categoriaSelecionada;

  bool _carregandoCategorias = false;

  // Lista de peças
  List<Peca> _pecas = [];

  @override
  void initState() {
    super.initState();
    _carregarGrupos();
    _adicionarPeca(); // pelo menos uma peça inicial
  }

  void _adicionarPeca() {
    setState(() {
      _pecas.add(Peca(
        nome: '',
        quantidade: int.parse(_quantidadeCompletosController.text.trim()),
        quantidadeUsados: int.tryParse(_quantidadeUsadosController.text.trim()),
        traje: Traje(nome: "", quantidadeCompletos: 0, categoria: Categoria(nome: '', grupo: Grupo(nome: '')), grupo: Grupo(nome: '')),
      ));
    });
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
    if (!_formKey.currentState!.validate()) return;
    if (_grupoSelecionado == null || _categoriaSelecionada == null) return;
    if (_pecas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos uma peça.')),
      );
      return;
    }

    final traje = Traje(
      nome: _nomeController.text.trim(),
      quantidadeCompletos: int.parse(_quantidadeCompletosController.text.trim()),
      quantidadeUsados: int.tryParse(_quantidadeUsadosController.text.trim()),
      categoria: _categoriaSelecionada!,
      grupo: _grupoSelecionado!,
      pecas: _pecas
    );

    await _trajeRepository.inserir(traje);

    if (mounted) Navigator.pop(context, true);
  }

 @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Cadastrar Traje',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do traje',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do traje';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantidadeCompletosController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade completos',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a quantidade de trajes completos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantidadeUsadosController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade usados',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
              
              DropdownButtonFormField<Grupo>(
                decoration: const InputDecoration(
                  labelText: 'Grupo',
                  labelStyle: TextStyle(color: Colors.white),
                ),
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
                selectedItemBuilder: (BuildContext context) {
                  return _grupos.map((grupo) {
                    return Text(
                      grupo.nome,
                      style: const TextStyle(color: Colors.white), // <-- Texto selecionado (branco)
                    );
                  }).toList();
                },
                validator: (value) =>
                    value == null ? 'Selecione um grupo' : null,
              ),
              const SizedBox(height: 16),
              _carregandoCategorias
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<Categoria>(
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
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
                      selectedItemBuilder: (BuildContext context) {
                        return _categorias.map((categoria) {
                          return Text(
                            categoria.nome,
                            style: const TextStyle(color: Colors.white), // <-- Texto selecionado (branco)
                          );
                        }).toList();
                      },
                      validator: (value) =>
                          value == null ? 'Selecione uma categoria' : null,
                    ),
              const SizedBox(height: 24),
              const Text('Peças do Traje', style: TextStyle(fontWeight: FontWeight.bold)),
                    ..._pecas.asMap().entries.map((entry) {
                      int index = entry.key;
                      Peca peca = entry.value;
                      return Column(
                        key: ValueKey(index),
                        children: [
                          PecaForm(
                            peca: peca,
                            onSave: (Peca updatedPeca) {
                              setState(() {
                                _pecas[index] = updatedPeca;
                              });
                            },
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
