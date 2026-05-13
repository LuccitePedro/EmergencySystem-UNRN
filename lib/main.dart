import 'package:flutter/material.dart';
// Importamos nuestro nuevo servicio
import 'services/notificacion_service.dart';

void main() async {
  // Asegura que Flutter esté listo antes de ejecutar código nativo (como las notificaciones)
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos y mostramos la notificación
  await NotificacionService.inicializar();
  await NotificacionService.mostrarNotificacionPermanente();

  runApp(const EmergenciaApp());
}

class EmergenciaApp extends StatelessWidget {
  const EmergenciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App de Emergencia',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const Scaffold(
        backgroundColor: Colors.redAccent,
        body: Center(
          child: Text(
            '¡HOLA MUNDO!\nInformación de Emergencia',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24, 
              color: Colors.white, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
}