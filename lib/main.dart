import 'package:flutter/material.dart';
import 'models/grupo.dart';
import 'repositories/grupo_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // necessário para usar o banco antes do runApp

  final repo = GrupoRepository();

  // Inserir
  await repo.inserir(Grupo(nome: 'Grupo de Teatro'));

  // Listar
  final grupos = await repo.listarTodos();
  for (var g in grupos) {
    print('Grupo: ${g.id} - ${g.nome}');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organizador de Trajes',
      home: Scaffold(
        appBar: AppBar(title: const Text('Trajes')),
        body: const Center(child: Text('Veja o console')),
      ),
    );
  }
}
