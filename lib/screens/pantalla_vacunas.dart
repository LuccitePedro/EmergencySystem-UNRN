// ignore_for_file: slash_for_doc_comments
import 'package:flutter/material.dart';
import '../models/perfil_medico.dart';
import '../services/auth_service.dart';
import 'pantalla_editar_perfil.dart';

/**
 * Pantalla que muestra la lista de vacunas del usuario.
 * Si no hay vacunas registradas, muestra un mensaje vacío.
 * El botón de editar requiere autenticación biométrica antes de permitir cambios.
 * perfil: Perfil médico del usuario que contiene la lista de vacunas.
 */
class PantallaVacunas extends StatelessWidget {
  final PerfilMedico perfil;
  const PantallaVacunas({super.key, required this.perfil});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9183E),
        title: const Text('Vacunas',
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
      body: perfil.vacunas.isEmpty
          ? const Center(
              child: Text('No se registraron vacunas.',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: perfil.vacunas.length,
              itemBuilder: (context, i) =>
                  _TarjetaVacuna(vacuna: perfil.vacunas[i]),
            ),
    );
  }
}

/**
 * Widget que muestra una tarjeta individual de vacuna.
 * Muestra nombre, dosis, marca, fecha de aplicación y localidad.
 * vacuna: Objeto Vacuna con todos sus campos de detalle.
 */
class _TarjetaVacuna extends StatelessWidget {
  final Vacuna vacuna;
  const _TarjetaVacuna({required this.vacuna});

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
            Text(vacuna.nombre,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            if (vacuna.dosis.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(vacuna.dosis,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14)),
            ],
            if (vacuna.marca.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(vacuna.marca,
                  style: const TextStyle(
                      color: Colors.white54,
                      fontStyle: FontStyle.italic,
                      fontSize: 13)),
            ],
            const Divider(color: Colors.white24, height: 16),
            if (vacuna.fecha.isNotEmpty)
              _Fila(label: 'Fecha', valor: vacuna.fecha),
            if (vacuna.localidad.isNotEmpty)
              _Fila(label: 'Localidad', valor: vacuna.localidad),
          ],
        ),
      ),
    );
  }
}

/**
 * Widget que muestra una fila de label y valor con formato enriquecido.
 * El label aparece en cursiva y más claro, el valor en blanco y negrita.
 * label: Nombre del campo a mostrar (ej: 'Fecha').
 * valor: Contenido del campo a mostrar (ej: '20/01/2021').
 */
class _Fila extends StatelessWidget {
  final String label;
  final String valor;
  const _Fila({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: '$label: ',
              style: const TextStyle(
                  color: Colors.white60,
                  fontStyle: FontStyle.italic,
                  fontSize: 13)),
          TextSpan(
              text: valor,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ]),
      ),
    );
  }
}