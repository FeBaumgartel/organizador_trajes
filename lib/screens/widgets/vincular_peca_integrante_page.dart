import 'package:flutter/material.dart';
import '../../models/grupo.dart';
import '../../models/categoria.dart';
import '../../models/integrante.dart';
import '../../models/traje.dart';
import '../../models/peca.dart';
import '../../models/peca_integrante.dart';
import '../../repositories/grupo_repository.dart';
import '../../repositories/categoria_repository.dart';
import '../../repositories/integrante_repository.dart';
import '../../repositories/traje_repository.dart';
import '../../repositories/peca_integrante_repository.dart';
import '../../repositories/peca_repository.dart';
import '../widgets/base_scaffold.dart';

class VincularPecaIntegrantePage extends StatefulWidget {
  const VincularPecaIntegrantePage({super.key});

  @override
  State<VincularPecaIntegrantePage> createState() => _VincularPecaIntegrantePageState();
}

class _VincularPecaIntegrantePageState extends State<VincularPecaIntegrantePage> {
  final _grupoRepository = GrupoRepository();
  final _categoriaRepository = CategoriaRepository();
  final _integranteRepository = IntegranteRepository();
  final _trajeRepository = TrajeRepository();
  final _pecaIntegranteRepository = PecaIntegranteRepository();
  final _pecaRepository = PecaRepository();

  List<Grupo> _grupos = [];
  List<Categoria> _categorias = [];
  List<Integrante> _integrantes = [];
  List<Traje> _trajes = [];
  List<Peca> _pecas = [];
  List<int> _pecasSelecionadas = [];

  Grupo? _grupoSelecionado;
  Categoria? _categoriaSelecionada;
  Integrante? _integranteSelecionado;
  Traje? _trajeSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarGrupos();
  }

  Future<void> _carregarGrupos() async {
    final grupos = await _grupoRepository.listarTodos();
    setState(() => _grupos = grupos);
  }

  Future<void> _carregarCategorias() async {
    if (_grupoSelecionado == null) return;
    final categorias = await _categoriaRepository.buscarPorGrupo(_grupoSelecionado!.id!);
    setState(() {
      _categoriaSelecionada = null;
      _categorias = categorias;
      _integrantes = [];
      _trajes = [];
      _pecas = [];
      _pecasSelecionadas.clear();
    });
  }

  Future<void> _carregarIntegrantesETrajes() async {
    if (_categoriaSelecionada == null) return;

    final integrantes = await _integranteRepository.buscarPorCategoria(_categoriaSelecionada!.id!);
    final trajes = await _trajeRepository.buscarPorCategoria(_categoriaSelecionada!.id!);

    setState(() {
      _integrantes = integrantes;
      _trajes = trajes;
      _integranteSelecionado = null;
      _trajeSelecionado = null;
      _pecas = [];
      _pecasSelecionadas.clear();
    });
  }

  Future<void> _carregarPecas() async {
    if (_trajeSelecionado == null) return;

    final pecas = await _pecaRepository.listarPorTraje(_trajeSelecionado!.id!);

    setState(() {
      _pecas = pecas;
      _pecasSelecionadas.clear();
      print(_trajeSelecionado!.nome);
    });
  }

  Future<void> _salvar() async {
    if (_integranteSelecionado == null || _trajeSelecionado == null || _pecasSelecionadas.isEmpty) return;

    for (final pecaId in _pecasSelecionadas) {
      final peca = _pecas.firstWhere((p) => p.id == pecaId);
      final pecaIntegrante = PecaIntegrante(
        integrante: _integranteSelecionado!,
        peca: peca,
        traje: _trajeSelecionado!,
      );
      await _pecaIntegranteRepository.inserir(pecaIntegrante);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Peças vinculadas com sucesso!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Vincular Peça ao Integrante',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<Grupo>(
                decoration: const InputDecoration(labelText: 'Grupo'),
                value: _grupoSelecionado,
                onChanged: (grupo) {
                  setState(() {
                    _grupoSelecionado = grupo;
                    _categoriaSelecionada = null;
                  });
                  _carregarCategorias();
                },
                items: _grupos.map((g) => DropdownMenuItem(value: g, child: Text(g.nome))).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Categoria>(
                decoration: const InputDecoration(labelText: 'Categoria'),
                value: _categoriaSelecionada,
                onChanged: (categoria) {
                  setState(() => _categoriaSelecionada = categoria);
                  _carregarIntegrantesETrajes();
                },
                items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c.nome))).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Integrante>(
                decoration: const InputDecoration(labelText: 'Integrante'),
                value: _integranteSelecionado,
                onChanged: (integrante) => setState(() => _integranteSelecionado = integrante),
                items: _integrantes.map((i) => DropdownMenuItem(value: i, child: Text(i.nome))).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Traje>(
                decoration: const InputDecoration(labelText: 'Traje'),
                value: _trajeSelecionado,
                onChanged: (traje) {
                  setState(() => _trajeSelecionado = traje);
                  _carregarPecas();
                },
                items: _trajes.map((t) => DropdownMenuItem(value: t, child: Text(t.nome))).toList(),
              ),
              const SizedBox(height: 24),
              if (_pecas.isNotEmpty) const Text('Selecione as peças:', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children: _pecas.map((peca) {
                  final selected = _pecasSelecionadas.contains(peca.id);
                  return FilterChip(
                    label: Text(peca.nome),
                    selected: selected,
                    onSelected: (bool value) {
                      setState(() {
                        if (value) {
                          _pecasSelecionadas.add(peca.id!);
                        } else {
                          _pecasSelecionadas.remove(peca.id!);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text('Vincular Peças'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
