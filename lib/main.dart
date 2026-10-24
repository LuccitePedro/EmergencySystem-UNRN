import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/notificacion_service.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'models/perfil_medico.dart';
import 'theme/colores.dart';
import 'widgets/encabezado.dart';
import 'utils/texto.dart';
import 'screens/pantalla_editar_perfil.dart';
import 'screens/pantalla_categoria_carousel.dart';

void main() {
  // La primera pantalla se dibuja enseguida; permisos y notificación se resuelven después
  runApp(const EmergenciaApp());
}

class EmergenciaApp extends StatelessWidget {
  const EmergenciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EmergencySystem',
      theme: temaApp(),
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

    // Sin await: no hace falta esperar el permiso de notificaciones para mostrar el perfil
    NotificacionService.mostrarNotificacionPermanente(perfil);

    var perfilInicial = perfil;
    if (esPrimero) {
      // Se usa push (no pushReplacement) para que al guardar el formulario vuelva acá
      // y se pueda seguir a la pantalla principal sin reiniciar la app.
      final completado = await Navigator.push<PerfilMedico>(
        context,
        MaterialPageRoute(
          builder: (_) => PantallaEditarPerfil(
            perfilActual: PerfilMedico.vacio,
            esPrimerUso: true,
          ),
        ),
      );
      if (!mounted) return;
      perfilInicial = completado ?? perfil;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PantallaPerfilMedico(perfil: perfilInicial)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colores.rojo,
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

  void _avisar(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  /// En modo debug muestra un diálogo en vez de llamar, para no hacer llamadas reales al probar.
  Future<void> _llamar(String telefono, String nombre) async {
    if (kDebugMode) {
      _avisar('Modo desarrollo', 'En producción, esto llamaría a $nombre ($telefono).');
      return;
    }
    final uri = Uri(scheme: 'tel', path: telefono);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _llamarContactoEmergencia(ContactoEmergencia? c) {
    if (c == null) {
      _avisar('Sin contacto', 'No hay ningún contacto de emergencia registrado.');
      return;
    }
    _llamar(c.telefono, c.nombre);
  }

  Future<void> _irAEditar() async {
    final autenticado = await AuthService.pedirAutenticacion();
    if (!autenticado || !mounted) return;
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
    // Se muestran hasta 2 contactos; si no hay ninguno, un botón que avisa que falta cargarlo
    final List<ContactoEmergencia?> contactos =
        _perfil.contactos.isEmpty ? [null] : _perfil.contactos.take(2).toList();

    return Scaffold(
      body: Column(
        children: [
          Encabezado(
            titulo: _perfil.nombre.isEmpty ? 'Mi perfil' : _perfil.nombre,
            subtitulo: 'Tarjeta médica de emergencia',
            onEditar: _irAEditar,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                // Tarjeta de info vital
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LineaInfo(Icons.bloodtype_outlined, 'Grupo y factor',
                            _grupoConDescripcion(_perfil.grupoSanguineo)),
                        _LineaInfo(
                            Icons.warning_amber_rounded,
                            'Alergias',
                            resumirLista(
                                _perfil.alergias.map((a) => a.severidad.isEmpty
                                    ? a.nombre
                                    : '${a.nombre} (${a.severidad})'),
                                'No registradas')),
                        _LineaInfo(Icons.monitor_heart_outlined, 'Enfermedades',
                            resumirLista(_perfil.enfermedades.map((e) => e.nombre), 'No registradas')),
                        _LineaInfo(Icons.medication_outlined, 'Medicación',
                            resumirLista(_perfil.medicacion.map((m) => m.nombre), 'No registrada')),
                        const Divider(color: Colors.white24, height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _BotonLlamada(
                              icono: Icons.phone,
                              colorFondo: Colores.verde,
                              titulo: '911',
                              onTap: () => _llamar('911', 'el 911'),
                            ),
                            for (final c in contactos)
                              _BotonLlamada(
                                icono: Icons.person,
                                colorFondo: Colores.gris,
                                titulo: c == null ? 'Emergencia' : c.nombre.split(' ').first,
                                onTap: () => _llamarContactoEmergencia(c),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Grilla de categorías: 3 columnas en tablet, 2 en teléfono.
                // Se usa Wrap centrado para que la última fila incompleta quede en el medio.
                LayoutBuilder(
                  builder: (context, constraints) {
                    const espacio = 12.0;
                    final columnas = constraints.maxWidth > 600 ? 3 : 2;
                    final ancho = (constraints.maxWidth - espacio * (columnas - 1)) / columnas;
                    return Wrap(
                      alignment: WrapAlignment.center,
                      spacing: espacio,
                      runSpacing: espacio,
                      children: [
                        for (var i = 0; i < categorias.length; i++)
                          SizedBox(
                            width: ancho,
                            height: ancho / 1.5,
                            child: _BotonCategoria(
                              categoria: categorias[i],
                              onTap: () => _abrirCategoria(i),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
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
  final IconData icono;
  final String label;
  final String valor;
  const _LineaInfo(this.icono, this.label, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Colors.white70, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(
                text: '$label: ',
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: valor,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ])),
          ),
        ],
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
    return Column(
      children: [
        Material(
          color: colorFondo,
          elevation: 3,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 72,
              height: 72,
              child: Icon(icono, color: Colors.white, size: 36),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(titulo,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _BotonCategoria extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onTap;

  const _BotonCategoria({required this.categoria, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colores.bordo,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(categoria.icono, color: Colors.white, size: 34),
            const SizedBox(height: 8),
            Text(
              categoria.titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
