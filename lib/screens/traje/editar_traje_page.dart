import 'package:flutter/material.dart';
import '../../models/traje.dart';
import '../../models/peca.dart';
import '../../repositories/traje_repository.dart';
import '../../repositories/peca_repository.dart';
import '../widgets/base_scaffold.dart';
import 'peca_form.dart';  // Importa o componente PecaForm

class EditarTrajePage extends StatefulWidget {
  final Traje traje;

  const EditarTrajePage({super.key, required this.traje});

  @override
  _EditarTrajePageState createState() => _EditarTrajePageState();
}

class _EditarTrajePageState extends State<EditarTrajePage> {
  final TrajeRepository _trajeRepository = TrajeRepository();
  final PecaRepository _pecaRepository = PecaRepository();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _quantidadeUsadosController = TextEditingController();

  List<Peca> _pecas = [];

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os dados do traje
    _nomeController.text = widget.traje.nome;
    _quantidadeController.text = widget.traje.quantidadeCompletos.toString();
    _quantidadeUsadosController.text = (widget.traje.quantidadeUsados ?? 0).toString();

    _carregarPecas();
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
                  labelText: 'Nome do Traje',
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
                  labelText: 'Quantidade Completos',
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
                  labelText: 'Quantidade Usados',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
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
