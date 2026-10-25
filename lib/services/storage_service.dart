import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/perfil_medico.dart';

/// Los datos médicos se guardan cifrados con flutter_secure_storage (claves en el Android Keystore).
/// El indicador de primer uso no es sensible, así que sigue en shared_preferences.
class StorageService {
  static const _keyPerfil = 'perfil_medico';
  static const _keyPrimerUso = 'primer_uso_completado';

  static const _secure = FlutterSecureStorage();

  /// Guarda el perfil cifrado, reemplazando el anterior.
  static Future<void> guardarPerfil(PerfilMedico perfil) async {
    final json = jsonEncode(perfil.toJson());
    await _secure.write(key: _keyPerfil, value: json);
  }

  /// Lee el perfil guardado. Si no hay ninguno o no se puede leer, devuelve [PerfilMedico.vacio].
  static Future<PerfilMedico> cargarPerfil() async {
    try {
      final json = await _secure.read(key: _keyPerfil);
      if (json == null) return PerfilMedico.vacio;
      return PerfilMedico.fromJson(jsonDecode(json));
    } catch (_) {
      return PerfilMedico.vacio;
    }
  }

  /// Registra que el usuario ya completó el formulario inicial.
  static Future<void> marcarPrimerUsoCompletado() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrimerUso, true);
  }

  /// Indica si la app se abre por primera vez (todavía no se guardó un perfil).
  static Future<bool> esPrimerUso() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_keyPrimerUso) ?? false);
  }
}
