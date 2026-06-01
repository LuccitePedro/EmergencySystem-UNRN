import 'package:flutter/material.dart';

/// Tarjeta simple para mostrar un ítem de texto en las pantallas de categoría.
class SeccionCard extends StatelessWidget {
  final String texto;
  const SeccionCard({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFA03333),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          texto,
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
      ),
    );
  }
}