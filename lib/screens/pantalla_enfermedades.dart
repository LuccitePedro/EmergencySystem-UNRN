import 'package:flutter/material.dart';
import '../models/perfil_medico.dart';
import '../services/auth_service.dart';
import 'pantalla_editar_perfil.dart';

class PantallaEnfermedades extends StatelessWidget {
  final PerfilMedico perfil;
  const PantallaEnfermedades({super.key, required this.perfil});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9183E),
        title: const Text('Enfermedades',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final autenticado = await AuthService.pedirAutenticacion();
              if (!autenticado || !context.mounted) return;
              final perfilActualizado = await Navigator.push<PerfilMedico>(
                context,
                MaterialPageRoute(
                  builder: (_) => PantallaEditarPerfil(perfilActual: perfil),
                ),
              );
              if (perfilActualizado != null && context.mounted) {
                Navigator.pop(context, perfilActualizado);
              }
            },
          ),
        ],
      ),
      body: perfil.enfermedades.isEmpty
          ? const Center(
              child: Text('No se registraron enfermedades.',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: perfil.enfermedades.length,
              itemBuilder: (context, i) =>
                  _TarjetaEnfermedad(enfermedad: perfil.enfermedades[i]),
            ),
    );
  }
}

class _TarjetaEnfermedad extends StatelessWidget {
  final Enfermedad enfermedad;
  const _TarjetaEnfermedad({required this.enfermedad});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFA03333),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(enfermedad.nombre,
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            if (enfermedad.fechaDiagnostico.isNotEmpty) ...[
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(children: [
                  const TextSpan(
                      text: 'Diagnóstico: ',
                      style: TextStyle(
                          color: Colors.white60,
                          fontStyle: FontStyle.italic,
                          fontSize: 13)),
                  TextSpan(
                      text: enfermedad.fechaDiagnostico,
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                ]),
              ),
            ],
            if (enfermedad.tratamiento.isNotEmpty) ...[
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(children: [
                  const TextSpan(
                      text: 'Tratamiento: ',
                      style: TextStyle(
                          color: Colors.white60,
                          fontStyle: FontStyle.italic,
                          fontSize: 13)),
                  TextSpan(
                      text: enfermedad.tratamiento,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}