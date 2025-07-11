import 'package:flutter/material.dart';
import 'gradiente_background.dart';

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  const BaseScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: GradienteBackground(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
