import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/perfil_medico.dart';
import '../utils/texto.dart';

class NotificacionService {
  static final FlutterLocalNotificationsPlugin _notificacionesPlugin =
      FlutterLocalNotificationsPlugin();

  // Se inicializa una sola vez, la primera vez que se muestra la notificación
  static Future<void>? _inicializacion;

  static Future<void> _inicializar() async {
    // Pedir permiso en Android 13+
    await Permission.notification.request();

    const AndroidInitializationSettings configuracionAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings configuraciones = InitializationSettings(
      android: configuracionAndroid,
    );

    // Al tocar la notificación Android abre la app, que arranca directo en el perfil médico
    await _notificacionesPlugin.initialize(settings: configuraciones);
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

  static Future<void> mostrarNotificacionPermanente(PerfilMedico perfil) async {
    await (_inicializacion ??= _inicializar());

    final resumen = perfil.estaVacio
        ? 'Toca aquí para ver información vital'
        : _resumen(perfil);
    final titulo = perfil.estaVacio
        ? '🏥 Perfil Médico de Emergencia'
        : '🏥 Emergencia: ${perfil.nombre}';

    final AndroidNotificationDetails detallesAndroid = AndroidNotificationDetails(
      'canal_emergencia_01',
      'Acceso de Emergencia',
      channelDescription: 'Mantiene el acceso rápido a los datos médicos',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true, // Esto hace que no se pueda borrar deslizando
      autoCancel: false,
      onlyAlertOnce: true, // Al actualizar los datos no vuelve a aparecer en pantalla
      fullScreenIntent: true, // ESTO ES CLAVE: Le dice a Android que es una urgencia (como una llamada)
      visibility: NotificationVisibility.public, // Para que se vea en la pantalla de bloqueo
      // Al expandir la notificación se ven todas las líneas del resumen
      styleInformation: BigTextStyleInformation(
        '$resumen\n\nToca para ver el perfil completo',
        contentTitle: titulo,
      ),
    );

    final NotificationDetails detallesPlataforma =
        NotificationDetails(android: detallesAndroid);

    // Acá usamos 'id', 'title', 'body', 'notificationDetails'
    await _notificacionesPlugin.show(
      id: 0,
      title: titulo,
      body: resumen,
      notificationDetails: detallesPlataforma,
    );
  }
}
