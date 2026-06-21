// ignore_for_file: slash_for_doc_comments

import 'package:flutter/material.dart';
import '../models/perfil_medico.dart';
import '../services/auth_service.dart';
import 'pantalla_editar_perfil.dart';


/**
 * Pantalla que muestra la lista de alergias del usuario.
 * Si no hay alergias registradas, muestra un mensaje vacío.
 * El botón de editar requiere autenticación biométrica antes de permitir cambios.
 * perfil: Perfil médico del usuario que contiene la lista de alergias.
 */

class PantallaAlergias extends StatelessWidget {
  final PerfilMedico perfil;
  const PantallaAlergias({super.key, required this.perfil});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9183E),
        title: const Text('Alergias',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          /**
           * Botón de edición protegido por autenticación.
           * Se encarga de pedir autenticación biométrica o PIN antes de
           * navegar al formulario de edición. Si el usuario no se autentica,
           * no ocurre ninguna acción.
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
      body: perfil.alergias.isEmpty
          ? const Center(
              child: Text('No se registraron alergias.',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: perfil.alergias.length,
              itemBuilder: (context, i) => _TarjetaAlergia(alergia: perfil.alergias[i]),
            ),
    );
  }
}

/**
 * Widget que muestra una tarjeta individual de alergia.
 * El color de la tarjeta varía según la severidad:
 * Grave = rojo oscuro, Moderada = naranja oscuro, Leve = rojo estándar.
 * alergia: Objeto Alergia con nombre, severidad, reacción y qué hacer.
 */
class _TarjetaAlergia extends StatelessWidget {
  final Alergia alergia;
  const _TarjetaAlergia({required this.alergia});

/**
   * Se encarga de retornar el color de fondo de la tarjeta según la severidad.
   * Return: Color correspondiente a la severidad de la alergia.
   */
  Color _colorSeveridad() {
    switch (alergia.severidad) {
      case 'Grave': return Colors.red.shade900;
      case 'Moderada': return Colors.orange.shade900;
      default: return const Color(0xFFA03333);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _colorSeveridad(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(alergia.nombre,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(alergia.severidad,
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
            if (alergia.reaccion.isNotEmpty) ...[
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(children: [
                  const TextSpan(
                      text: 'Reacción: ',
                      style: TextStyle(color: Colors.white60, fontStyle: FontStyle.italic, fontSize: 13)),
                  TextSpan(
                      text: alergia.reaccion,
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                ]),
              ),
            ],
            if (alergia.queHacer.isNotEmpty) ...[
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(children: [
                  const TextSpan(
                      text: 'Qué hacer: ',
                      style: TextStyle(color: Colors.white60, fontStyle: FontStyle.italic, fontSize: 13)),
                  TextSpan(
                      text: alergia.queHacer,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}