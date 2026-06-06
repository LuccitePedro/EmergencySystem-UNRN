import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/notificacion_service.dart';
import 'services/storage_service.dart';
import 'models/perfil_medico.dart';
import 'screens/pantalla_alergias.dart';
import 'screens/pantalla_enfermedades.dart';
import 'screens/pantalla_medicacion.dart';
import 'screens/pantalla_vacunas.dart';
import 'screens/pantalla_obra_social.dart';
import 'screens/pantalla_contactos.dart';
import 'screens/pantalla_restricciones.dart';
import 'screens/pantalla_editar_perfil.dart';
import 'services/auth_service.dart';

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
      home: const PantallaCarga(),
    );
  }
}

// ─────────────────────────────────────────────
//  PANTALLA DE CARGA
// ─────────────────────────────────────────────
class PantallaCarga extends StatefulWidget {
  const PantallaCarga({super.key});

  @override
  State<PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga> {
  @override
  void initState() {
    super.initState();
    _decidirRuta();
  }

  Future<void> _decidirRuta() async {
    final esPrimero = await StorageService.esPrimerUso();
    final perfil = await StorageService.cargarPerfil();

    if (!mounted) return;

    if (esPrimero) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PantallaEditarPerfil(
            perfilActual: PerfilMedico.vacio,
            esPrimerUso: true,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PantallaPerfilMedico(perfil: perfil)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF9183E),
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PANTALLA PRINCIPAL
// ─────────────────────────────────────────────
class PantallaPerfilMedico extends StatefulWidget {
  final PerfilMedico perfil;
  const PantallaPerfilMedico({super.key, required this.perfil});

  @override
  State<PantallaPerfilMedico> createState() => _PantallaPerfilMedicoState();
}

class _PantallaPerfilMedicoState extends State<PantallaPerfilMedico> {
  late PerfilMedico _perfil;

  @override
  void initState() {
    super.initState();
    _perfil = widget.perfil;
  }

  Future<void> _llamar911() async {
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

  Future<void> _llamarContactoEmergencia() async {
    if (_perfil.contactos.isEmpty) {
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
      final c = _perfil.contactos.first;
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
    final uri = Uri(scheme: 'tel', path: _perfil.contactos.first.telefono);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _navegar(Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
  }

  Future<void> _irAEditar() async {
  final autenticado = await AuthService.pedirAutenticacion();
  if (!autenticado) return; // Si no se autenticó, no hace nada

  final perfilActualizado = await Navigator.push<PerfilMedico>(
    context,
    MaterialPageRoute(
      builder: (_) => PantallaEditarPerfil(perfilActual: _perfil),
    ),
  );
  if (perfilActualizado != null) {
    setState(() => _perfil = perfilActualizado);
  }
}

  @override
  Widget build(BuildContext context) {
    const Color colorTarjetas = Color(0xFFA03333);

    final categorias = [
      _Categoria(
        texto: 'Enfermedades',
        icono: Icons.local_hospital_outlined,
        pantalla: PantallaEnfermedades(perfil: _perfil),
        tieneData: _perfil.enfermedades.isNotEmpty,
      ),
      _Categoria(
        texto: 'Alergias',
        icono: Icons.warning_amber_outlined,
        pantalla: PantallaAlergias(perfil: _perfil),
        tieneData: _perfil.alergias.isNotEmpty,
      ),
      _Categoria(
        texto: 'Número de\nRespaldo',
        icono: Icons.contact_phone_outlined,
        pantalla: PantallaContactos(perfil: _perfil),
        tieneData: _perfil.contactos.isNotEmpty,
      ),
      _Categoria(
        texto: 'Vacunas',
        icono: Icons.vaccines_outlined,
        pantalla: PantallaVacunas(perfil: _perfil),
        tieneData: _perfil.vacunas.isNotEmpty,
      ),
      _Categoria(
        texto: 'Obra Social',
        icono: Icons.card_membership_outlined,
        pantalla: PantallaObraSocial(perfil: _perfil),
        tieneData: _perfil.obraSocial.isNotEmpty,
      ),
      _Categoria(
        texto: 'Medicación',
        icono: Icons.medication_outlined,
        pantalla: PantallaMedicacion(perfil: _perfil),
        tieneData: _perfil.medicacion.isNotEmpty,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9183E),
        title: Text(
          _perfil.nombre.isEmpty ? 'Mi perfil' : _perfil.nombre,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Editar perfil',
            onPressed: _irAEditar,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                      valor: _perfil.grupoSanguineo.isEmpty ? 'No registrado' : _perfil.grupoSanguineo,
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    _FilaVital(
                      icono: Icons.warning_amber,
                      label: 'Alergias',
                      valor: _perfil.alergias.isEmpty ? 'Sin alergias conocidas' : _perfil.alergias.join(', '),
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    _FilaVital(
                      icono: Icons.local_hospital,
                      label: 'Enfermedades',
                      valor: _perfil.enfermedades.isEmpty ? 'Ninguna' : _perfil.enfermedades.join(', '),
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    _FilaVital(
                      icono: Icons.medication,
                      label: 'Medicación',
                      valor: _perfil.medicacion.isEmpty ? 'Sin medicación' : _perfil.medicacion.join(', '),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _BotonAccionRapida(
                          icono: Icons.emergency,
                          titulo: '911',
                          subtitulo: 'Ambulancia',
                          colorFondo: Colors.green.shade700,
                          onTap: _llamar911,
                        ),
                        _BotonAccionRapida(
                          icono: Icons.person,
                          titulo: _perfil.contactos.isEmpty
                              ? 'Sin contacto'
                              : _perfil.contactos.first.nombre.split(' ').first,
                          subtitulo: _perfil.contactos.isEmpty
                              ? 'Agregá uno'
                              : _perfil.contactos.first.relacion,
                          colorFondo: Colors.blue.shade700,
                          onTap: _llamarContactoEmergencia,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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
                  onTap: () => _navegar(cat.pantalla),
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
          Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          Text(subtitulo, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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