import 'package:flutter/material.dart';
import '../../repositories/grupo_repository.dart';
import '../../models/grupo.dart';
import '../widgets/base_scaffold.dart';

class CadastroGrupoPage extends StatefulWidget {
  const CadastroGrupoPage({super.key});

  @override
  State<CadastroGrupoPage> createState() => _CadastroGrupoPageState();
}

class _CadastroGrupoPageState extends State<CadastroGrupoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final GrupoRepository _repository = GrupoRepository();

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final grupo = Grupo(nome: _nomeController.text);
      await _repository.inserir(grupo);

      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Cadastrar Grupo',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
              ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
