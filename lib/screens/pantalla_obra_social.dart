// ignore_for_file: slash_for_doc_comments
import 'package:flutter/material.dart';
import '../models/perfil_medico.dart';
import '../services/auth_service.dart';
import 'pantalla_editar_perfil.dart';

/**
 * Pantalla que muestra los datos de obra social del usuario.
 * Muestra el nombre de la obra social y el número de socio.
 * El botón de editar requiere autenticación biométrica antes de permitir cambios.
 * perfil: Perfil médico del usuario con los datos de obra social.
 */
class PantallaObraSocial extends StatelessWidget {
  final PerfilMedico perfil;
  const PantallaObraSocial({super.key, required this.perfil});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9183E),
        title: const Text('Obra Social',
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _TarjetaDato(
              label: 'Obra Social',
              valor: perfil.obraSocial.isEmpty ? 'No registrada' : perfil.obraSocial,
            ),
            const SizedBox(height: 12),
            _TarjetaDato(
              label: 'Número de socio',
              valor: perfil.numeroSocio.isEmpty ? 'No registrado' : perfil.numeroSocio,
            ),
          ],
        ),
      ),
    );
  }
}

/**
 * Widget que muestra una tarjeta con un campo de dato simple.
 * Muestra el label en gris clarito y el valor en blanco y negrita.
 * label: Nombre del campo (ej: 'Obra Social').
 * valor: Contenido del campo (ej: 'OSDE 310').
 */
class _TarjetaDato extends StatelessWidget {
  final String label;
  final String valor;
  const _TarjetaDato({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFA03333),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white60,
                    fontStyle: FontStyle.italic,
                    fontSize: 13)),
            const SizedBox(height: 6),
            Text(valor,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}