import 'package:flutter/material.dart';
import '../../models/integrante.dart';
import '../../models/categoria.dart';
import '../../models/grupo.dart';
import '../../repositories/integrante_repository.dart';
import '../../repositories/categoria_repository.dart';
import '../../repositories/grupo_repository.dart';
import '../widgets/base_scaffold.dart';

class EditarIntegrantePage extends StatefulWidget {
  final Integrante integrante;

  const EditarIntegrantePage({super.key, required this.integrante});

  @override
  _EditarIntegrantePageState createState() => _EditarIntegrantePageState();
}

class _EditarIntegrantePageState extends State<EditarIntegrantePage> {
  final GrupoRepository _grupoRepository = GrupoRepository();
  final CategoriaRepository _categoriaRepository = CategoriaRepository();
  final IntegranteRepository _integranteRepository = IntegranteRepository();

  final TextEditingController _nomeController = TextEditingController();

  List<Grupo> _grupos = [];
  List<Categoria> _categorias = [];

  Grupo? _grupoSelecionado;
  Categoria? _categoriaSelecionada;

  bool _carregandoCategorias = false;

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.integrante.nome;

    _grupoSelecionado = widget.integrante.grupo; // seleciona o grupo atual
    _carregarGrupos().then((_) {
      if (_grupoSelecionado != null) {
        _carregarCategoriasDoGrupo(_grupoSelecionado!.id!).then((_) {
          setState(() {
            _categoriaSelecionada = widget.integrante.categoria; // seleciona a categoria atual
          });
        });
      }
    });
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

  Future<void> _salvar() async {
    // Cria um novo integrante com as alterações
    final atualizadoIntegrante = widget.integrante.copyWith(
      nome: _nomeController.text,
      categoria: _categoriaSelecionada!,
      grupo: _grupoSelecionado!,
    );

    // Salva o integrante atualizado
    await _integranteRepository.atualizar(atualizadoIntegrante);


    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Editar Integrante',
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
