import 'package:flutter/material.dart';
import '../../models/peca.dart';

class PecaForm extends StatefulWidget {
  final Peca peca;
  final Function(Peca) onSave;

  const PecaForm({super.key, required this.peca, required this.onSave});

  @override
  State<PecaForm> createState() => _PecaFormState();
}

class _PecaFormState extends State<PecaForm> {
  late TextEditingController _nomeController;
  late TextEditingController _quantidadeController;
  late TextEditingController _quantidadeUsadosController;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(text: widget.peca.nome);
    _quantidadeController = TextEditingController(
      text: widget.peca.quantidade.toString(),
    );
    _quantidadeUsadosController = TextEditingController(
      text: widget.peca.quantidadeUsados?.toString() ?? '0',
    );

    _nomeController.addListener(_onFormChanged);
    _quantidadeController.addListener(_onFormChanged);
    _quantidadeUsadosController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final nome = _nomeController.text;
    final quantidade = int.tryParse(_quantidadeController.text) ?? 0;
    final quantidadeUsados =
        int.tryParse(_quantidadeUsadosController.text) ?? 0;

    final updatedPeca = widget.peca.copyWith(
      nome: nome,
      quantidade: quantidade,
      quantidadeUsados: quantidadeUsados,
    );

    widget.onSave(updatedPeca);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _quantidadeUsadosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome da Peça'),
            ),
            TextField(
              controller: _quantidadeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
            TextField(
              controller: _quantidadeUsadosController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade Usada'),
            ),
          ],
        ),
      ),
    );
  }
}
