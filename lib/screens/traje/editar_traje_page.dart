import 'package:flutter/material.dart';
import '../../models/traje.dart';
import '../../models/peca.dart';
import '../../models/categoria.dart';
import '../../models/grupo.dart';
import '../../repositories/traje_repository.dart';
import '../../repositories/peca_repository.dart';
import '../../repositories/categoria_repository.dart';
import '../../repositories/grupo_repository.dart';
import '../widgets/base_scaffold.dart';
import 'peca_form.dart';  // Importa o componente PecaForm

class EditarTrajePage extends StatefulWidget {
  final Traje traje;

  const EditarTrajePage({super.key, required this.traje});

  @override
  _EditarTrajePageState createState() => _EditarTrajePageState();
}

class _EditarTrajePageState extends State<EditarTrajePage> {
  final GrupoRepository _grupoRepository = GrupoRepository();
  final CategoriaRepository _categoriaRepository = CategoriaRepository();
  final TrajeRepository _trajeRepository = TrajeRepository();
  final PecaRepository _pecaRepository = PecaRepository();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _quantidadeUsadosController = TextEditingController();

  List<Grupo> _grupos = [];
  List<Categoria> _categorias = [];

  Grupo? _grupoSelecionado;
  Categoria? _categoriaSelecionada;

  bool _carregandoCategorias = false;

  List<Peca> _pecas = [];

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.traje.nome;
    _quantidadeController.text = widget.traje.quantidadeCompletos.toString();
    _quantidadeUsadosController.text = (widget.traje.quantidadeUsados ?? 0).toString();

    _grupoSelecionado = widget.traje.grupo; // seleciona o grupo atual
    _carregarGrupos().then((_) {
      if (_grupoSelecionado != null) {
        _carregarCategoriasDoGrupo(_grupoSelecionado!.id!).then((_) {
          setState(() {
            _categoriaSelecionada = widget.traje.categoria; // seleciona a categoria atual
          });
        });
      }
    });

    _carregarPecas();
  }

  Future<void> _carregarGrupos() async {
    final grupos = await _grupoRepository.listarTodos();
    setState(() {
      _grupos = grupos;
      // não define _grupoSelecionado aqui, pois já foi definido no initState
    });
  }

  Future<void> _carregarCategoriasDoGrupo(int grupoId) async {
    setState(() {
      _carregandoCategorias = true;
      _categorias = [];
    });

    final categorias = await _categoriaRepository.buscarPorGrupo(grupoId);

    setState(() {
      _categorias = categorias;
      _carregandoCategorias = false;
      // _categoriaSelecionada será definido externamente
    });
  }

  Future<void> _carregarPecas() async {
    final pecas = await _pecaRepository.listarPorTraje(widget.traje.id!);
    setState(() {
      _pecas.addAll(pecas); // Agora estamos adicionando as peças corretamente
    });
  }

  void _adicionarPeca() {
    setState(() {
      // Adiciona uma nova peça em branco
      _pecas.add(Peca(
        nome: '',
        quantidade: 0,
        quantidadeUsados: 0,
        trajeId: widget.traje.id, // Associa o traje ao criar uma nova peça
        traje: widget.traje, // Associa o traje ao criar uma nova peça
      ));
    });
  }

  Future<void> _salvar() async {
    // Cria um novo traje com as alterações
    final atualizadoTraje = widget.traje.copyWith(
      nome: _nomeController.text,
      quantidadeCompletos: int.parse(_quantidadeController.text),
      quantidadeUsados: int.tryParse(_quantidadeUsadosController.text),
      categoria: _categoriaSelecionada!,
      grupo: _grupoSelecionado!,
    );

    // Salva o traje atualizado
    await _trajeRepository.atualizar(atualizadoTraje);

    // Salva as peças atualizadas
    for (var peca in _pecas) {
      await _pecaRepository.atualizar(peca);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Editar Traje',
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
                controller: _quantidadeController,
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
                value: _grupos.any((g) => g.id == _grupoSelecionado?.id)
                  ? _grupos.firstWhere((g) => g.id == _grupoSelecionado?.id)
                  : null,
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
                      value: _categorias.any((g) => g.id == _categoriaSelecionada?.id)
                        ? _categorias.firstWhere((g) => g.id == _categoriaSelecionada?.id)
                        : null,
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
                      validator: (value) => value == null ? 'Selecione uma categoria' : null,
                    ),
              const SizedBox(height: 24),
              // Lista de peças, usando PecaForm para editar cada uma delas
              ..._pecas.map((peca) {
                return PecaForm(
                  peca: peca,
                  onSave: (Peca updatedPeca) {
                    setState(() {
                      final index = _pecas.indexOf(peca);
                      _pecas[index] = updatedPeca;
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 24),
              // Botão "Adicionar Peça"
              TextButton.icon(
                onPressed: _adicionarPeca,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Peça'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
