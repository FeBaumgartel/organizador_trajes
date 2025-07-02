import 'package:flutter/material.dart';
import 'screens/grupo/grupo_page.dart';
import 'screens/categoria/categoria_page.dart';
import 'screens/integrante/integrante_page.dart';
import 'screens/traje/traje_page.dart';
// Adicione outras páginas

void main() {
  runApp(const MaterialApp(home: HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _paginaSelecionada = 0;

  final _telas = const [
    GruposPage(),
    CategoriasPage(),
    IntegrantesPage(),
    TrajesPage(),
    // Outras telas aqui (TrajesPage, PecasPage, IntegrantesPage)
  ];

  void _onIconTapped(int index) {
    setState(() {
      _paginaSelecionada = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _telas[_paginaSelecionada],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.group),
              tooltip: 'Grupos',
              onPressed: () => _onIconTapped(0),
            ),
            IconButton(
              icon: const Icon(Icons.category),
              tooltip: 'Categorias',
              onPressed: () => _onIconTapped(1),
            ),
            IconButton(
              icon: const Icon(Icons.category),
              tooltip: 'Integrantes',
              onPressed: () => _onIconTapped(2),
            ),
            IconButton(
              icon: const Icon(Icons.category),
              tooltip: 'Trajes',
              onPressed: () => _onIconTapped(3),
            ),
            // Adicione mais ícones aqui conforme suas entidades
          ],
        ),
      ),
    );
  }
}
