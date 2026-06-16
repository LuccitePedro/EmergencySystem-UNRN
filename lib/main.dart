import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/notificacion_service.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'models/perfil_medico.dart';
import 'widgets/curved_header.dart';
import 'screens/pantalla_editar_perfil.dart';
import 'screens/pantalla_categoria_carousel.dart';

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
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
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

  Future<void> _irAEditar() async {
    final autenticado = await AuthService.pedirAutenticacion();
    if (!autenticado || !context.mounted) return;
    final actualizado = await Navigator.push<PerfilMedico>(
      context,
      MaterialPageRoute(builder: (_) => PantallaEditarPerfil(perfilActual: _perfil)),
    );
    if (actualizado != null) setState(() => _perfil = actualizado);
  }

  Future<void> _abrirCategoria(int indice) async {
    final actualizado = await Navigator.push<PerfilMedico>(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaCategoriaCarousel(
          perfil: _perfil,
          indiceInicial: indice,
        ),
      ),
    );
    if (actualizado != null) setState(() => _perfil = actualizado);
  }

  String _grupoConDescripcion(String grupo) {
    if (grupo.isEmpty) return 'No registrado';
    final positivo = grupo.contains('+');
    return '$grupo (${positivo ? 'positivo' : 'negativo'})';
  }

  @override
  Widget build(BuildContext context) {
    final contactoNombre = _perfil.contactos.isEmpty
        ? 'Emergencia'
        : _perfil.contactos.first.nombre.split(' ').first;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header curvo
          CurvedHeader(
            height: 160,
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 48, 44),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA03333),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        _perfil.nombre.isEmpty ? 'Mi perfil' : _perfil.nombre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    onPressed: _irAEditar,
                  ),
                ),
              ],
            ),
          ),

          // Cuerpo
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Tarjeta info vital
                  Card(
                    color: const Color(0xFFA03333),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LineaInfo('Alergias',
                              _perfil.alergias.isEmpty ? 'No' : 'Si'),
                          _LineaInfo('Enfermedad',
                              _perfil.enfermedades.isEmpty ? 'No' : 'Si'),
                          _LineaInfo('Medicación',
                              _perfil.medicacion.isEmpty ? 'No' : 'Si'),
                          _LineaInfo('Grupo y factor',
                              _grupoConDescripcion(_perfil.grupoSanguineo)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _BotonLlamada(
                                icono: Icons.phone,
                                colorFondo: Colors.green.shade600,
                                titulo: '911',
                                onTap: _llamar911,
                              ),
                              _BotonLlamada(
                                icono: Icons.person,
                                colorFondo: Colors.grey.shade500,
                                titulo: contactoNombre,
                                onTap: _llamarContactoEmergencia,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Grilla de categorías
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: [
                      _BotonCategoria(texto: 'Enfermedades', onTap: () => _abrirCategoria(0)),
                      _BotonCategoria(texto: 'Alergias', onTap: () => _abrirCategoria(1)),
                      _BotonCategoria(texto: 'Número de\nRespaldo', onTap: () => _abrirCategoria(2)),
                      _BotonCategoria(texto: 'Vacunas', onTap: () => _abrirCategoria(3)),
                      _BotonCategoria(texto: 'Obra Social', onTap: () => _abrirCategoria(4)),
                      _BotonCategoria(texto: 'Medicación', onTap: () => _abrirCategoria(5)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIDGETS INTERNOS
// ─────────────────────────────────────────────

class _LineaInfo extends StatelessWidget {
  final String label;
  final String valor;
  const _LineaInfo(this.label, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: valor,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ]),
      ),
    );
  }
}

class _BotonLlamada extends StatelessWidget {
  final IconData icono;
  final Color colorFondo;
  final String titulo;
  final VoidCallback onTap;

  const _BotonLlamada({
    required this.icono,
    required this.colorFondo,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: colorFondo,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icono, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 6),
          Text(titulo,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _BotonCategoria extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;

  const _BotonCategoria({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFA03333),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}