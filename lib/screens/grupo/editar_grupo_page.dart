import 'package:flutter/material.dart';
import '../../models/grupo.dart';
import '../../repositories/grupo_repository.dart';
import '../widgets/base_scaffold.dart';

class EditarGrupoPage extends StatefulWidget {
  final Grupo grupo;

  const EditarGrupoPage({super.key, required this.grupo});

  @override
  _EditarGrupoPageState createState() => _EditarGrupoPageState();
}

class _EditarGrupoPageState extends State<EditarGrupoPage> {
  final GrupoRepository _grupoRepository = GrupoRepository();

  final TextEditingController _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.grupo.nome;
  }

  Future<void> _salvar() async {
    // Cria um novo grupo com as alterações
    final atualizadoGrupo = widget.grupo.copyWith(
      nome: _nomeController.text,
    );

    // Salva o grupo atualizado
    await _grupoRepository.atualizar(atualizadoGrupo);


    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Editar Grupo',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do grupo',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome do grupo';
                }
                return null;
              },
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
