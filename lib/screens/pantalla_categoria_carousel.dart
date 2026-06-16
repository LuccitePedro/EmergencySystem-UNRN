import 'package:flutter/material.dart';
import '../models/perfil_medico.dart';
import '../services/auth_service.dart';
import '../widgets/curved_header.dart';
import 'pantalla_editar_perfil.dart';

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

  static const _titulos = [
    'Enfermedades',
    'Alergias',
    'Número de Respaldo',
    'Vacunas',
    'Obra Social',
    'Medicación',
  ];

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

  Future<void> _irAEditar() async {
    final autenticado = await AuthService.pedirAutenticacion();
    if (!autenticado || !context.mounted) return;
    final actualizado = await Navigator.push<PerfilMedico>(
      context,
      MaterialPageRoute(builder: (_) => PantallaEditarPerfil(perfilActual: _perfil)),
    );
    if (actualizado != null) setState(() => _perfil = actualizado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header curvo
          CurvedHeader(
            height: 150,
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 44),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA03333),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Text(
                        _titulos[_paginaActual],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: _irAEditar,
                  ),
                ),
              ],
            ),
          ),

          // Contenido con PageView
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
              ],
            ),
          ),

          // Navegación inferior
          _BottomNav(
            paginaActual: _paginaActual,
            total: _titulos.length,
            onAnterior: _paginaActual > 0
                ? () => _ctrl.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut)
                : null,
            onSiguiente: _paginaActual < _titulos.length - 1
                ? () => _ctrl.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut)
                : null,
            onInicio: () => Navigator.pop(context, _perfil),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NAVEGACIÓN INFERIOR
// ─────────────────────────────────────────────

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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BotonFlecha(
                icono: Icons.chevron_left,
                activo: onAnterior != null,
                onTap: onAnterior,
              ),
              GestureDetector(
                onTap: onInicio,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA03333),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text('Inicio',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              _BotonFlecha(
                icono: Icons.chevron_right,
                activo: onSiguiente != null,
                onTap: onSiguiente,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              total,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == paginaActual ? 10 : 8,
                height: i == paginaActual ? 10 : 8,
                decoration: BoxDecoration(
                  color: i == paginaActual
                      ? const Color(0xFFA03333)
                      : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonFlecha extends StatelessWidget {
  final IconData icono;
  final bool activo;
  final VoidCallback? onTap;

  const _BotonFlecha({required this.icono, required this.activo, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: activo ? const Color(0xFFA03333) : Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Icon(icono, color: Colors.white, size: 28),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIDGETS COMPARTIDOS DE CONTENIDO
// ─────────────────────────────────────────────

class _SinDatos extends StatelessWidget {
  final String mensaje;
  const _SinDatos({required this.mensaje});

  @override
  Widget build(BuildContext context) => Center(
        child: Text(mensaje,
            style: const TextStyle(fontSize: 16, color: Colors.grey)),
      );
}

Widget _filaRichText(String label, String valor) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: [
        TextSpan(
          text: '$label: ',
          style: const TextStyle(
              color: Colors.white60,
              fontStyle: FontStyle.italic,
              fontSize: 13),
        ),
        TextSpan(
          text: valor,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────
//  PÁGINAS DE CONTENIDO
// ─────────────────────────────────────────────

class _PaginaEnfermedades extends StatelessWidget {
  final PerfilMedico perfil;
  const _PaginaEnfermedades({required this.perfil});

  @override
  Widget build(BuildContext context) {
    if (perfil.enfermedades.isEmpty) {
      return const _SinDatos(mensaje: 'No se registraron enfermedades.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: perfil.enfermedades.length,
      itemBuilder: (_, i) {
        final e = perfil.enfermedades[i];
        return Card(
          color: const Color(0xFFA03333),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(e.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                if (e.fechaDiagnostico.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _filaRichText('Diagnóstico', e.fechaDiagnostico),
                ],
                if (e.tratamiento.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _filaRichText('Tratamiento', e.tratamiento),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaginaAlergias extends StatelessWidget {
  final PerfilMedico perfil;
  const _PaginaAlergias({required this.perfil});

  Color _colorSeveridad(String sev) {
    switch (sev) {
      case 'Grave':
        return Colors.red.shade900;
      case 'Moderada':
        return Colors.orange.shade900;
      default:
        return const Color(0xFFA03333);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (perfil.alergias.isEmpty) {
      return const _SinDatos(mensaje: 'No se registraron alergias.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: perfil.alergias.length,
      itemBuilder: (_, i) {
        final a = perfil.alergias[i];
        return Card(
          color: _colorSeveridad(a.severidad),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(a.nombre,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(a.severidad,
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
                if (a.reaccion.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _filaRichText('Reacción', a.reaccion),
                ],
                if (a.queHacer.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _filaRichText('Qué hacer', a.queHacer),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaginaContactos extends StatelessWidget {
  final PerfilMedico perfil;
  const _PaginaContactos({required this.perfil});

  @override
  Widget build(BuildContext context) {
    if (perfil.contactos.isEmpty) {
      return const _SinDatos(mensaje: 'No se registraron contactos de emergencia.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: perfil.contactos.length,
      itemBuilder: (_, i) {
        final c = perfil.contactos[i];
        return Card(
          color: const Color(0xFFA03333),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(c.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(c.relacion,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(c.telefono,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaginaVacunas extends StatelessWidget {
  final PerfilMedico perfil;
  const _PaginaVacunas({required this.perfil});

  @override
  Widget build(BuildContext context) {
    if (perfil.vacunas.isEmpty) {
      return const _SinDatos(mensaje: 'No se registraron vacunas.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: perfil.vacunas.length,
      itemBuilder: (_, i) {
        final v = perfil.vacunas[i];
        return Card(
          color: const Color(0xFFA03333),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(v.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                if (v.dosis.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _filaRichText(v.dosis, v.marca.isEmpty ? '—' : v.marca),
                ],
                if (v.fecha.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _filaRichText('Fecha', v.fecha),
                ],
                if (v.localidad.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _filaRichText('Localidad', v.localidad),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaginaObraSocial extends StatelessWidget {
  final PerfilMedico perfil;
  const _PaginaObraSocial({required this.perfil});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

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
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white60,
                    fontStyle: FontStyle.italic,
                    fontSize: 13)),
            const SizedBox(height: 6),
            Text(valor,
                textAlign: TextAlign.center,
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

class _PaginaMedicacion extends StatelessWidget {
  final PerfilMedico perfil;
  const _PaginaMedicacion({required this.perfil});

  @override
  Widget build(BuildContext context) {
    if (perfil.medicacion.isEmpty) {
      return const _SinDatos(mensaje: 'No se registró medicación.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: perfil.medicacion.length,
      itemBuilder: (_, i) {
        final m = perfil.medicacion[i];
        return Card(
          color: const Color(0xFFA03333),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(m.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                if (m.dosis.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(m.dosis,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ],
                if (m.marca.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(m.marca,
                      style: const TextStyle(
                          color: Colors.white54,
                          fontStyle: FontStyle.italic,
                          fontSize: 13)),
                ],
                if (m.frecuencia.isNotEmpty || m.via.isNotEmpty || m.indicacion.isNotEmpty)
                  const Divider(color: Colors.white24, height: 16),
                if (m.frecuencia.isNotEmpty) _filaRichText('Frecuencia', m.frecuencia),
                if (m.via.isNotEmpty) _filaRichText('Vía', m.via),
                if (m.indicacion.isNotEmpty) _filaRichText('Para qué', m.indicacion),
              ],
            ),
          ),
        );
      },
    );
  }
}