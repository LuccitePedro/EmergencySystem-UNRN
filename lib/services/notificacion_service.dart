import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificacionService {
  static final FlutterLocalNotificationsPlugin _notificacionesPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> inicializar() async {
    // Pedir permiso en Android 13+
    await Permission.notification.request();

    const AndroidInitializationSettings configuracionAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings configuraciones = InitializationSettings(
      android: configuracionAndroid,
    );

    // Acá usamos 'settings' que es lo que pide la versión de tu paquete
    await _notificacionesPlugin.initialize(
      settings: configuraciones, 
    );
  }

  static Future<void> mostrarNotificacionPermanente() async {
    const AndroidNotificationDetails detallesAndroid = AndroidNotificationDetails(
      'canal_emergencia_01', 
      'Acceso de Emergencia', 
      channelDescription: 'Mantiene el acceso rápido a los datos médicos',
      importance: Importance.max, 
      priority: Priority.high,
      ongoing: true, // Esto hace que no se pueda borrar deslizando
      autoCancel: false,
      fullScreenIntent: true, // ESTO ES CLAVE: Le dice a Android que es una urgencia (como una llamada)
      visibility: NotificationVisibility.public, // Para que se vea en la pantalla de bloqueo
    );

    const NotificationDetails detallesPlataforma =
        NotificationDetails(android: detallesAndroid);

    // Acá usamos 'id', 'title', 'body', 'notificationDetails'
    await _notificacionesPlugin.show(
      id: 0, 
      title: '🏥 Perfil Médico de Emergencia', 
      body: 'Toca aquí para ver información vital', 
      notificationDetails: detallesPlataforma, 
    );
  }
}