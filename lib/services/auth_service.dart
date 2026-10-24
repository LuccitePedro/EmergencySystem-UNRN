import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static final _auth = LocalAuthentication();
  static const _dispositivo = MethodChannel('emergency_system/dispositivo');

  /// Pide autenticación antes de permitir editar el perfil médico.
  /// - Si el teléfono está bloqueado (la app se abrió sobre la pantalla de bloqueo),
  ///   pide desbloquear el dispositivo con su PIN, patrón o contraseña.
  /// - Si está desbloqueado, pide huella o, en su defecto, el PIN/contraseña del dispositivo.
  /// - Si el dispositivo no tiene ningún bloqueo configurado, permite editar,
  ///   ya que cualquiera que tenga el teléfono podría desbloquearlo igual.
  /// Devuelve true si se autenticó correctamente, false si canceló o falló.
  static Future<bool> pedirAutenticacion() async {
    try {
      final bloqueado = await _dispositivo.invokeMethod<bool>('estaBloqueado') ?? false;
      if (bloqueado) {
        return await _dispositivo.invokeMethod<bool>('pedirDesbloqueo') ?? false;
      }

      final tieneBloqueo = await _dispositivo.invokeMethod<bool>('tieneBloqueoSeguro') ?? false;
      if (!tieneBloqueo) return true;

      return await _auth.authenticate(
        localizedReason: 'Autenticáte para editar tu perfil médico',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
