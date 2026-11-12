import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/perfil_medico.dart';
import '../utils/texto.dart';

/// Maneja la notificación permanente que muestra los datos vitales, incluso en la pantalla de bloqueo.
/// Acá se arma el texto; la notificación la crea el código nativo (NotificacionEmergencia.kt),
/// que además la vuelve a mostrar si el usuario la borra y al encender el teléfono.
class NotificacionService {
  static const _dispositivo = MethodChannel('emergency_system/dispositivo');

  // El permiso se pide una sola vez, la primera vez que se muestra la notificación
  static Future<void>? _permiso;

  /// Pide el permiso de notificaciones (Android 13+).
  static Future<void> _pedirPermiso() async {
    await Permission.notification.request();
  }

  /// Arma el texto de la notificación con los datos vitales del perfil,
  /// para que un tercero los vea incluso sin desbloquear el teléfono.
  static String _resumen(PerfilMedico perfil) {
    String lista(Iterable<String> items) => resumirLista(items, 'No');

    final lineas = [
      'Grupo sanguíneo: ${perfil.grupoSanguineo.isEmpty ? 'No registrado' : perfil.grupoSanguineo}',
      'Alergias: ${lista(perfil.alergias.map((a) => a.severidad.isEmpty ? a.nombre : '${a.nombre} (${a.severidad})'))}',
      'Enfermedades: ${lista(perfil.enfermedades.map((e) => e.nombre))}',
      'Medicación: ${lista(perfil.medicacion.map((m) => m.nombre))}',
      for (final c in perfil.contactos)
        'Contacto: ${c.nombre}${c.relacion.isEmpty ? '' : ' (${c.relacion})'} · ${c.telefono}',
    ];
    return lineas.join('\n');
  }

  /// Muestra la notificación con el resumen del [perfil], o la actualiza si ya estaba.
  /// Si el usuario la borra, vuelve a aparecer sola; al actualizarse, no vuelve a aparecer en pantalla.
  /// Se llama al abrir la app y cada vez que se guarda el perfil.
  static Future<void> mostrarNotificacionPermanente(PerfilMedico perfil) async {
    await (_permiso ??= _pedirPermiso());

    final resumen = perfil.estaVacio
        ? 'Toca aquí para ver información vital'
        : _resumen(perfil);
    final titulo = perfil.estaVacio
        ? '🏥 Perfil Médico de Emergencia'
        : '🏥 Emergencia: ${perfil.nombre}';

    try {
      await _dispositivo.invokeMethod('mostrarNotificacion', {
        'titulo': titulo,
        'texto': resumen,
        // Al expandir la notificación se ven todas las líneas del resumen
        'textoLargo': '$resumen\n\nToca para ver el perfil completo',
      });
    } on PlatformException {
      // Si no se puede mostrar, la app sigue funcionando: los datos se ven al abrirla
    }
  }
}
