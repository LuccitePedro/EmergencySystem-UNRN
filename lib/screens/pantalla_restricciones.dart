import 'package:flutter/material.dart';
import '../models/perfil_medico.dart';
import '../widgets/seccion_card.dart';

class PantallaRestriccionesAlimentarias extends StatelessWidget {
  final PerfilMedico perfil;
  const PantallaRestriccionesAlimentarias({super.key, required this.perfil});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9183E),
        title: const Text('Restricciones Alimentarias',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Editar',
            onPressed: () {
              // TODO: pantalla de edición
            },
          ),
        ],
      ),
      body: perfil.restriccionesAlimentarias.isEmpty
          ? const _SinDatos(mensaje: 'No se registraron restricciones alimentarias.')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: perfil.restriccionesAlimentarias.length,
              itemBuilder: (context, i) =>
                  SeccionCard(texto: perfil.restriccionesAlimentarias[i]),
            ),
    );
  }
}

class _SinDatos extends StatelessWidget {
  final String mensaje;
  const _SinDatos({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(mensaje, style: const TextStyle(fontSize: 16, color: Colors.grey)),
    );
  }
}