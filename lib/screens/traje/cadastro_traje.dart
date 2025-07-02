import 'package:flutter/material.dart';

class CadastroTrajePage extends StatelessWidget {
  const CadastroTrajePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Traje')),
      body: const Center(
        child: Text('Aqui você criará um traje'),
      ),
    );
  }
}