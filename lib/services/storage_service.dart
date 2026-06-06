import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/perfil_medico.dart';

class StorageService {
  static const _keyPerfil = 'perfil_medico';
  static const _keyPrimerUso = 'primer_uso_completado';

  static Future<void> guardarPerfil(PerfilMedico perfil) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(perfil.toJson());
    await prefs.setString(_keyPerfil, json);
  }

  static Future<PerfilMedico> cargarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyPerfil);
    if (json == null) return PerfilMedico.vacio;
    try {
      return PerfilMedico.fromJson(jsonDecode(json));
    } catch (_) {
      return PerfilMedico.vacio;
    }
  }

  static Future<void> marcarPrimerUsoCompletado() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrimerUso, true);
  }

  static Future<bool> esPrimerUso() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_keyPrimerUso) ?? false);
  }

  static Future<void> borrarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}