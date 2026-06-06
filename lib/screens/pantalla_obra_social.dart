import 'package:flutter/material.dart';
import '../models/perfil_medico.dart';
import '../services/auth_service.dart';

class PantallaObraSocial extends StatelessWidget {
  final PerfilMedico perfil;
  const PantallaObraSocial({super.key, required this.perfil});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFA03333);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9183E),
        title: const Text(
          'Obra Social',
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _FilaDato(
              label: 'Obra Social',
              valor: perfil.obraSocial.isEmpty
                  ? 'No registrada'
                  : perfil.obraSocial,
            ),
            const SizedBox(height: 12),
            _FilaDato(
              label: 'Número de socio',
              valor: perfil.numeroSocio.isEmpty
                  ? 'No registrado'
                  : perfil.numeroSocio,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaDato extends StatelessWidget {
  final String label;
  final String valor;
  const _FilaDato({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFA03333),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valor,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
