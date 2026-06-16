import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static final _auth = LocalAuthentication();

  /// Pide autenticación biométrica o PIN al usuario.
  /// Devuelve true si se autenticó correctamente, false si canceló o falló.
  static Future<bool> pedirAutenticacion() async {
  try {
    final disponible = await _auth.canCheckBiometrics;
    final soportado = await _auth.isDeviceSupported();

    // Agregamos estos prints para ver qué devuelve
    print('canCheckBiometrics: $disponible');
    print('isDeviceSupported: $soportado');

    if (!disponible && !soportado) {
      print('Dispositivo no soportado, retornando false');
      return false;
    }

    final resultado = await _auth.authenticate(
      localizedReason: 'Autenticáte para editar tu perfil médico',
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
      ),
    );

    print('Resultado autenticación: $resultado');
    return resultado;

  } on PlatformException catch (e) {
    print('PlatformException: ${e.code} - ${e.message}');
    return false;
  }
}
}