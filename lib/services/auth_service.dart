import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static final _auth = LocalAuthentication();

  /// Pide autenticación biométrica o PIN al usuario.
  /// Devuelve true si se autenticó correctamente, false si canceló o falló.
  static Future<bool> pedirAutenticacion() async {
    try {
      // Verificamos si el dispositivo soporta biometría
      final disponible = await _auth.canCheckBiometrics;
      final soportado = await _auth.isDeviceSupported();

      if (!disponible && !soportado) {
        // El dispositivo no tiene ningún método de autenticación configurado
        return false;
      }

      return await _auth.authenticate(
        localizedReason: 'Autenticáte para editar tu perfil médico',
        options: const AuthenticationOptions(
          biometricOnly: false, // Permite PIN/patrón además de huella
          stickyAuth: true,     // Si el usuario sale de la app, retoma la autenticación
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}