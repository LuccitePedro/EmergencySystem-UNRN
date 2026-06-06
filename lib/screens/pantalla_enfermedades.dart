import 'package:flutter/material.dart';
import '../models/perfil_medico.dart';
import '../widgets/seccion_card.dart';
import '../services/auth_service.dart';

class _SinDatos extends StatelessWidget {
  final String mensaje;
  const _SinDatos({required this.mensaje});
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      mensaje,
      style: const TextStyle(fontSize: 16, color: Colors.grey),
    ),
  );
}

class PantallaEnfermedades extends StatelessWidget {
  final PerfilMedico perfil;
  const PantallaEnfermedades({super.key, required this.perfil});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9183E),
        title: const Text(
          'Enfermedades',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Editar',
            onPressed: () async {
              final autenticado = await AuthService.pedirAutenticacion();
              if (!autenticado) return;
              // TODO: navegar a edición
            },
          ),
        ],
      ),
      body: perfil.enfermedades.isEmpty
          ? const _SinDatos(mensaje: 'No se registraron enfermedades.')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: perfil.enfermedades.length,
              itemBuilder: (context, i) =>
                  SeccionCard(texto: perfil.enfermedades[i]),
            ),
    );
  }
}
