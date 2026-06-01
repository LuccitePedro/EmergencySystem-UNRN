import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/notificacion_service.dart';
import 'models/perfil_medico.dart';
import 'screens/pantalla_alergias.dart';
import 'screens/pantalla_enfermedades.dart';
import 'screens/pantalla_medicacion.dart';
import 'screens/pantalla_vacunas.dart';
import 'screens/pantalla_obra_social.dart';
import 'screens/pantalla_contactos.dart';
import 'screens/pantalla_restricciones.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificacionService.inicializar(navigatorKey);
  await NotificacionService.mostrarNotificacionPermanente();
  runApp(const EmergenciaApp());
}

class EmergenciaApp extends StatelessWidget {
  const EmergenciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'App de Emergencia',
      theme: ThemeData(primarySwatch: Colors.red),
      initialRoute: '/perfil_medico',
      routes: {
        '/': (context) => const PantallaInicio(),
        '/perfil_medico': (context) => const PantallaPerfilMedico(),
      },
    );
  }
}

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Inicio Normal')));
  }
}

// ─────────────────────────────────────────────
//  PANTALLA PRINCIPAL DE EMERGENCIA
// ─────────────────────────────────────────────
class PantallaPerfilMedico extends StatelessWidget {
  const PantallaPerfilMedico({super.key});

  // Datos del perfil — luego vendrán de shared_preferences
  static const perfil = PerfilMedico.ejemplo;

  Future<void> _llamar911(BuildContext context) async {
    if (kDebugMode) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Modo desarrollo'),
          content: const Text('En producción, esto llamaría al 911.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: '911');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _llamarContactoEmergencia(BuildContext context) async {
    if (perfil.contactos.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Sin contacto'),
          content: const Text('No hay ningún contacto de emergencia registrado.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }
    if (kDebugMode) {
      final c = perfil.contactos.first;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Modo desarrollo'),
          content: Text('En producción, esto llamaría a ${c.nombre} (${c.telefono}).'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: perfil.contactos.first.telefono);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _navegar(BuildContext context, Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    const Color colorTarjetas = Color(0xFFA03333);

    final categorias = [
      _Categoria(
        texto: 'Enfermedades',
        icono: Icons.local_hospital_outlined,
        pantalla: PantallaEnfermedades(perfil: perfil),
        tieneData: perfil.enfermedades.isNotEmpty,
      ),
      _Categoria(
        texto: 'Alergias',
        icono: Icons.warning_amber_outlined,
        pantalla: PantallaAlergias(perfil: perfil),
        tieneData: perfil.alergias.isNotEmpty,
      ),
      _Categoria(
        texto: 'Contacto\nRespaldo',
        icono: Icons.contact_phone_outlined,
        pantalla: PantallaContactos(perfil: perfil),
        tieneData: perfil.contactos.isNotEmpty,
      ),
      _Categoria(
        texto: 'Vacunas',
        icono: Icons.vaccines_outlined,
        pantalla: PantallaVacunas(perfil: perfil),
        tieneData: perfil.vacunas.isNotEmpty,
      ),
      _Categoria(
        texto: 'Obra Social',
        icono: Icons.card_membership_outlined,
        pantalla: PantallaObraSocial(perfil: perfil),
        tieneData: perfil.obraSocial.isNotEmpty,
      ),
      _Categoria(
        texto: 'Medicación',
        icono: Icons.medication_outlined,
        pantalla: PantallaMedicacion(perfil: perfil),
        tieneData: perfil.medicacion.isNotEmpty,
      ),
      _Categoria(
        texto: 'Restricciones\nAlimentarias',
        icono: Icons.no_meals_outlined,
        pantalla: PantallaRestriccionesAlimentarias(perfil: perfil),
        tieneData: perfil.restriccionesAlimentarias.isNotEmpty,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9183E),
        title: Text(
          perfil.nombre,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Editar perfil',
            onPressed: () {
              // TODO: navegar a pantalla de edición general
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Tarjeta de datos vitales ──
            Card(
              color: colorTarjetas,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FilaVital(
                      icono: Icons.bloodtype,
                      label: 'Grupo / Factor',
                      valor: perfil.grupoSanguineo,
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    _FilaVital(
                      icono: Icons.warning_amber,
                      label: 'Alergias',
                      valor: perfil.alergias.isEmpty ? 'Sin alergias conocidas' : perfil.alergias.join(', '),
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    _FilaVital(
                      icono: Icons.local_hospital,
                      label: 'Enfermedades',
                      valor: perfil.enfermedades.isEmpty ? 'Ninguna' : perfil.enfermedades.join(', '),
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    _FilaVital(
                      icono: Icons.medication,
                      label: 'Medicación',
                      valor: perfil.medicacion.isEmpty ? 'Sin medicación' : perfil.medicacion.join(', '),
                    ),
                    const SizedBox(height: 20),

                    // ── Botones de acción rápida ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _BotonAccionRapida(
                          icono: Icons.emergency,
                          titulo: '911',
                          subtitulo: 'Ambulancia',
                          colorFondo: Colors.green.shade700,
                          onTap: () => _llamar911(context),
                        ),
                        _BotonAccionRapida(
                          icono: Icons.person,
                          titulo: perfil.contactos.isEmpty
                              ? 'Sin contacto'
                              : perfil.contactos.first.nombre.split(' ').first,
                          subtitulo: perfil.contactos.isEmpty
                              ? 'Agregá uno'
                              : perfil.contactos.first.relacion,
                          colorFondo: Colors.blue.shade700,
                          onTap: () => _llamarContactoEmergencia(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Grilla de categorías ──
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 90,
              ),
              itemCount: categorias.length,
              itemBuilder: (context, i) {
                final cat = categorias[i];
                return _BotonCategoria(
                  texto: cat.texto,
                  icono: cat.icono,
                  colorFondo: colorTarjetas,
                  tieneData: cat.tieneData,
                  onTap: () => _navegar(context, cat.pantalla),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIDGETS INTERNOS
// ─────────────────────────────────────────────

class _FilaVital extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  const _FilaVital({required this.icono, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 2),
              Text(valor, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BotonAccionRapida extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Color colorFondo;
  final VoidCallback onTap;

  const _BotonAccionRapida({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.colorFondo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: colorFondo,
            radius: 30,
            child: Icon(icono, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            titulo,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitulo,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BotonCategoria extends StatelessWidget {
  final String texto;
  final IconData icono;
  final Color colorFondo;
  final bool tieneData;
  final VoidCallback onTap;

  const _BotonCategoria({
    required this.texto,
    required this.icono,
    required this.colorFondo,
    required this.tieneData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorFondo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          if (!tieneData) ...[
            const SizedBox(width: 4),
            const Icon(Icons.circle, color: Colors.orangeAccent, size: 8),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DATO AUXILIAR
// ─────────────────────────────────────────────
class _Categoria {
  final String texto;
  final IconData icono;
  final Widget pantalla;
  final bool tieneData;
  const _Categoria({
    required this.texto,
    required this.icono,
    required this.pantalla,
    required this.tieneData,
  });
}