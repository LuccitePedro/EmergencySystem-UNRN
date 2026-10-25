import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Llamadas a los contactos de emergencia.
/// Con el permiso CALL_PHONE la llamada sale directo, aunque el teléfono esté bloqueado;
/// sin el permiso se abre el marcador con el número cargado (y Android pide desbloquear).
class LlamadaService {
  static const _dispositivo = MethodChannel('emergency_system/dispositivo');

  /// Pide el permiso para llamar directo. Se llama cuando el dueño guarda el perfil
  /// con algún contacto, así no le aparece a un tercero en plena emergencia.
  static Future<void> pedirPermiso() async {
    try {
      await Permission.phone.request();
    } catch (_) {
      // Si no se puede pedir, las llamadas siguen funcionando con el marcador
    }
  }

  /// Llama al [telefono]: directo si hay permiso; si no, abre el marcador.
  static Future<void> llamar(String telefono) async {
    try {
      final llamo = await _dispositivo.invokeMethod<bool>('llamarDirecto', {'telefono': telefono});
      if (llamo == true) return;
    } on PlatformException {
      // Sigue con el marcador
    }
    await abrirMarcador(telefono);
  }

  /// Abre el marcador con el [telefono] cargado, para que la persona toque "Llamar".
  /// Se usa siempre para el 911: Android no permite que una app llame directo a emergencias.
  static Future<void> abrirMarcador(String telefono) async {
    final uri = Uri(scheme: 'tel', path: telefono);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
