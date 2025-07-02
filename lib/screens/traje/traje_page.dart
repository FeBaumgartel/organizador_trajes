import 'package:flutter/material.dart';
import '../widgets/base_scaffold.dart';
import 'cadastro_traje.dart';

class TrajesPage extends StatelessWidget {
  const TrajesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Trajes',
      body: const Center(
        child: Text(
          'Listagem de Trajes',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CadastroTrajePage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Cadastrar novo traje',
      ),
    );
  }
}