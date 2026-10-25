import 'package:flutter/material.dart';
import '../models/perfil_medico.dart';
import '../services/auth_service.dart';
import '../theme/colores.dart';
import '../widgets/encabezado.dart';
import 'pantalla_editar_perfil.dart';

/// Secciones del perfil, en el mismo orden en la grilla de la pantalla principal y en el carrusel.
class Categoria {
  final String titulo;
  final IconData icono;
  const Categoria(this.titulo, this.icono);
}

const categorias = [
  Categoria('Enfermedades', Icons.monitor_heart_outlined),
  Categoria('Alergias', Icons.warning_amber_rounded),
  Categoria('Contactos', Icons.contact_phone_outlined),
  Categoria('Vacunas', Icons.vaccines_outlined),
  Categoria('Obra Social', Icons.badge_outlined),
  Categoria('Medicación', Icons.medication_outlined),
  Categoria('Restricciones', Icons.no_food_outlined),
];

/// Muestra el detalle de las secciones del perfil en un carrusel: se pasa de una a otra
/// deslizando o con las flechas. Al salir devuelve el perfil (actualizado si se editó).
class PantallaCategoriaCarousel extends StatefulWidget {
  final PerfilMedico perfil;
  final int indiceInicial;

  const PantallaCategoriaCarousel({
    super.key,
    required this.perfil,
    required this.indiceInicial,
  });

  @override
  State<PantallaCategoriaCarousel> createState() => _PantallaCategoriaCarouselState();
}

class _PantallaCategoriaCarouselState extends State<PantallaCategoriaCarousel> {
  late PageController _ctrl;
  late int _paginaActual;
  late PerfilMedico _perfil;

  @override
  void initState() {
    super.initState();
    _perfil = widget.perfil;
    _paginaActual = widget.indiceInicial;
    _ctrl = PageController(initialPage: widget.indiceInicial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Pide autenticación y abre el formulario de edición; al volver muestra los datos nuevos.
  Future<void> _irAEditar() async {
    final autenticado = await AuthService.pedirAutenticacion();
    if (!autenticado || !mounted) return;
    final actualizado = await Navigator.push<PerfilMedico>(
      context,
      MaterialPageRoute(builder: (_) => PantallaEditarPerfil(perfilActual: _perfil)),
    );
    if (actualizado != null) setState(() => _perfil = actualizado);
  }

  /// Desliza el carrusel hasta la página [i] con una animación.
  void _irAPagina(int i) => _ctrl.animateToPage(i,
      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

  @override
  Widget build(BuildContext context) {
    return PopScope<PerfilMedico>(
      // Al volver con el botón de atrás también se devuelve el perfil actualizado
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _perfil);
      },
      child: Scaffold(
        body: Column(
          children: [
            Encabezado(titulo: categorias[_paginaActual].titulo, onEditar: _irAEditar),
            Expanded(
              child: PageView(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _paginaActual = i),
                children: [
                  _PaginaEnfermedades(perfil: _perfil),
                  _PaginaAlergias(perfil: _perfil),
                  _PaginaContactos(perfil: _perfil),
                  _PaginaVacunas(perfil: _perfil),
                  _PaginaObraSocial(perfil: _perfil),
                  _PaginaMedicacion(perfil: _perfil),
                  _PaginaRestricciones(perfil: _perfil),
                ],
              ),
            ),
            _BottomNav(
              paginaActual: _paginaActual,
              total: categorias.length,
              onAnterior: _paginaActual > 0 ? () => _irAPagina(_paginaActual - 1) : null,
              onSiguiente: _paginaActual < categorias.length - 1
                  ? () => _irAPagina(_paginaActual + 1)
                  : null,
              onInicio: () => Navigator.pop(context, _perfil),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NAVEGACIÓN INFERIOR
// ─────────────────────────────────────────────

/// Barra inferior del carrusel: flechas anterior/siguiente, botón Inicio e indicador de página.
class _BottomNav extends StatelessWidget {
  final int paginaActual;
  final int total;
  final VoidCallback? onAnterior;
  final VoidCallback? onSiguiente;
  final VoidCallback onInicio;

  const _BottomNav({
    required this.paginaActual,
    required this.total,
    required this.onAnterior,
    required this.onSiguiente,
    required this.onInicio,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BotonFlecha(icono: Icons.chevron_left, onTap: onAnterior),
                FilledButton.icon(
                  onPressed: onInicio,
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Inicio'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colores.bordo,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                _BotonFlecha(icono: Icons.chevron_right, onTap: onSiguiente),
              ],
            ),
            const SizedBox(height: 14),
            // Indicador de página: el punto actual se estira como una píldora
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                total,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == paginaActual ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == paginaActual ? Colores.bordo : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Flecha circular; se muestra gris y desactivada si [onTap] es null.
class _BotonFlecha extends StatelessWidget {
  final IconData icono;
  final VoidCallback? onTap;

  const _BotonFlecha({required this.icono, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onTap,
      icon: Icon(icono, size: 28),
      style: IconButton.styleFrom(
        backgroundColor: Colores.bordo,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.white,
        minimumSize: const Size(48, 48),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIDGETS COMPARTIDOS DE CONTENIDO
// ─────────────────────────────────────────────

/// Mensaje con ícono que se muestra cuando una sección no tiene datos.
class _SinDatos extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  const _SinDatos({required this.mensaje, required this.icono});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(mensaje, style: const TextStyle(fontSize: 16, color: Colores.textoSuave)),
          ],
        ),
      );
}

/// Tarjeta de un elemento del perfil: ícono, título, etiqueta opcional y filas "dato: valor".
/// Las filas con valor vacío no se muestran.
class _Tarjeta extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? etiqueta;
  final List<(String, String)> filas;
  final Color color;

  const _Tarjeta({
    required this.icono,
    required this.titulo,
    this.etiqueta,
    this.filas = const [],
    this.color = Colores.bordo,
  });

  @override
  Widget build(BuildContext context) {
    final visibles = filas.where((f) => f.$2.isNotEmpty);
    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: visibles.isEmpty ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white24,
              child: Icon(icono, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(titulo,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      if (etiqueta != null && etiqueta!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                              color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                          child: Text(etiqueta!,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  for (final (label, valor) in visibles)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                          text: '$label: ',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        TextSpan(
                          text: valor,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ])),
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

/// Lista de tarjetas que se construyen a medida que se ven en pantalla.
class _Lista<T> extends StatelessWidget {
  final List<T> items;
  final _Tarjeta Function(T) tarjeta;
  final String vacio;
  final IconData icono;

  const _Lista({
    required this.items,
    required this.tarjeta,
    required this.vacio,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _SinDatos(mensaje: vacio, icono: icono);
    // Con muchos elementos aparece una barra lateral que se puede arrastrar para recorrerlos rápido
    return Scrollbar(
      interactive: true,
      radius: const Radius.circular(4),
      thickness: 6,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) => tarjeta(items[i]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PÁGINAS DE CONTENIDO
// ─────────────────────────────────────────────

class _PaginaEnfermedades extends StatelessWidget {
  final PerfilMedico perfil;
  const _PaginaEnfermedades({required this.perfil});

  @override
  Widget build(BuildContext context) => _Lista<Enfermedad>(
        items: perfil.enfermedades,
        vacio: 'No se registraron enfermedades.',
        icono: categorias[0].icono,
        tarjeta: (e) => _Tarjeta(
          icono: categorias[0].icono,
          titulo: e.nombre,
          filas: [('Diagnóstico', e.fechaDiagnostico), ('Tratamiento', e.tratamiento)],
        ),
      );
}

class _PaginaAlergias extends StatelessWidget {
  final PerfilMedico perfil;
  const _PaginaAlergias({required this.perfil});

  @override
  Widget build(BuildContext context) => _Lista<Alergia>(
        items: perfil.alergias,
        vacio: 'No se registraron alergias.',
        icono: categorias[1].icono,
        tarjeta: (a) => _Tarjeta(
          icono: categorias[1].icono,
          titulo: a.nombre,
          etiqueta: a.severidad,
          color: Colores.severidad(a.severidad),
          filas: [('Reacción', a.reaccion), ('Qué hacer', a.queHacer)],
        ),
      );
}

class _PaginaContactos extends StatelessWidget {
  final PerfilMedico perfil;
  const _PaginaContactos({required this.perfil});

  @override
  Widget build(BuildContext context) => _Lista<ContactoEmergencia>(
        items: perfil.contactos,
        vacio: 'No se registraron contactos de emergencia.',
        icono: categorias[2].icono,
        tarjeta: (c) => _Tarjeta(
          icono: Icons.person_outline,
          titulo: c.nombre,
          etiqueta: c.relacion,
          filas: [('Teléfono', c.telefono)],
        ),
      );
}

class _PaginaVacunas extends StatelessWidget {
  final PerfilMedico perfil;
  const _PaginaVacunas({required this.perfil});

  @override
  Widget build(BuildContext context) => _Lista<Vacuna>(
        items: perfil.vacunas,
        vacio: 'No se registraron vacunas.',
        icono: categorias[3].icono,
        tarjeta: (v) => _Tarjeta(
          icono: categorias[3].icono,
          titulo: v.nombre,
          etiqueta: v.dosis,
          filas: [('Marca', v.marca), ('Fecha', v.fecha), ('Localidad', v.localidad)],
        ),
      );
}

/// Página de obra social: una sola tarjeta con el nombre y el número de socio.
class _PaginaObraSocial extends StatelessWidget {
  final PerfilMedico perfil;
  const _PaginaObraSocial({required this.perfil});

  @override
  Widget build(BuildContext context) {
    if (perfil.obraSocial.isEmpty && perfil.numeroSocio.isEmpty) {
      return _SinDatos(mensaje: 'No se registró obra social.', icono: categorias[4].icono);
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Tarjeta(
          icono: categorias[4].icono,
          titulo: perfil.obraSocial.isEmpty ? 'Obra social no registrada' : perfil.obraSocial,
          filas: [('Número de socio', perfil.numeroSocio)],
        ),
      ],
    );
  }
}

class _PaginaMedicacion extends StatelessWidget {
  final PerfilMedico perfil;
  const _PaginaMedicacion({required this.perfil});

  @override
  Widget build(BuildContext context) => _Lista<Medicamento>(
        items: perfil.medicacion,
        vacio: 'No se registró medicación.',
        icono: categorias[5].icono,
        tarjeta: (m) => _Tarjeta(
          icono: categorias[5].icono,
          titulo: m.nombre,
          etiqueta: m.dosis,
          filas: [
            ('Marca', m.marca),
            ('Frecuencia', m.frecuencia),
            ('Vía', m.via),
            ('Para qué', m.indicacion),
          ],
        ),
      );
}

class _PaginaRestricciones extends StatelessWidget {
  final PerfilMedico perfil;
  const _PaginaRestricciones({required this.perfil});

  @override
  Widget build(BuildContext context) => _Lista<String>(
        items: perfil.restriccionesAlimentarias,
        vacio: 'No se registraron restricciones alimentarias.',
        icono: categorias[6].icono,
        tarjeta: (r) => _Tarjeta(icono: categorias[6].icono, titulo: r),
      );
}
