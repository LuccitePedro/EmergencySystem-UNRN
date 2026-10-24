import 'package:flutter/material.dart';
import '../theme/colores.dart';
import 'curved_header.dart';

/// Encabezado curvo con el título en un recuadro centrado y el lápiz de edición a la derecha.
/// El recuadro tiene el mismo margen a ambos lados, así el lápiz nunca lo tapa
/// y el título queda centrado en la pantalla.
class Encabezado extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final VoidCallback onEditar;

  const Encabezado({
    super.key,
    required this.titulo,
    this.subtitulo,
    required this.onEditar,
  });

  // Espacio que deja la curva abajo y margen superior del recuadro
  static const _margenArriba = 12.0;
  static const _margenAbajo = 44.0;
  static const _margenLateral = 56.0;

  @override
  Widget build(BuildContext context) {
    return CurvedHeader(
      height: subtitulo == null ? 150 : 165,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                _margenLateral, _margenArriba, _margenLateral, _margenAbajo),
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colores.bordo,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animación suave cuando cambia el título (al deslizar entre secciones)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      titulo,
                      key: ValueKey(titulo),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (subtitulo != null)
                    Text(
                      subtitulo!,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: _margenArriba,
            bottom: _margenAbajo,
            right: 4,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                tooltip: 'Editar perfil',
                onPressed: onEditar,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
