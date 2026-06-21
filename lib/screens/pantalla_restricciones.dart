// ignore_for_file: slash_for_doc_comments
import 'package:flutter/material.dart';
import '../models/perfil_medico.dart';
import '../services/auth_service.dart';
import 'pantalla_editar_perfil.dart';

/**
 * Pantalla que muestra la lista de restricciones alimentarias del usuario.
 * Si no hay restricciones registradas, muestra un mensaje vacío.
 * El botón de editar requiere autenticación biométrica antes de permitir cambios.
 * perfil: Perfil médico del usuario que contiene la lista de restricciones alimentarias.
 */
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
          /**
           * Botón de edición protegido por autenticación.
           * Se encarga de pedir autenticación biométrica o PIN antes de
           * navegar al formulario de edición.
           * Return: PerfilMedico actualizado si el usuario guardó cambios, null si canceló.
           */
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
      body: perfil.restriccionesAlimentarias.isEmpty
          ? const Center(
              child: Text('No se registraron restricciones alimentarias.',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: perfil.restriccionesAlimentarias.length,
              itemBuilder: (context, i) => Card(
                color: const Color(0xFFA03333),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Text(perfil.restriccionesAlimentarias[i],
                      style: const TextStyle(
                          color: Colors.white, fontSize: 17)),
                ),
              ),
            ),
    );
  }
}