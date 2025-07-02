import 'package:flutter/material.dart';

class GradienteBackground extends StatelessWidget {
  final Widget child;

  const GradienteBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF000000), // Preto
            Color(0xFFDD0000), // Vermelho
            Color(0xFFFFCC00), // Amarelo
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}