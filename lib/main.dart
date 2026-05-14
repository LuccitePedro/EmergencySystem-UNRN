import 'package:flutter/material.dart';
// Importamos nuestro nuevo servicio
import 'services/notificacion_service.dart';


// Creamos una llave global para controlar la navegación desde cualquier lado
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Asegura que Flutter esté listo antes de ejecutar código nativo (como las notificaciones)
  WidgetsFlutterBinding.ensureInitialized();
  
  // Le pasamos la llave e Inicializamos y mostramos la notificación
  await NotificacionService.inicializar(navigatorKey);
  await NotificacionService.mostrarNotificacionPermanente();

  runApp(const EmergenciaApp());
}

class EmergenciaApp extends StatelessWidget {
  const EmergenciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, //Asignamos la llave a la app
      debugShowCheckedModeBanner: false,
      title: 'App de Emergencia',
      theme: ThemeData(primarySwatch: Colors.red),
      // Configuramos unas rutas básicas
      initialRoute: '/perfil_medico',
      routes: {
        '/': (context) => const PantallaInicio(),
        '/perfil_medico': (context) => const PantallaPerfilMedico(),
      },
    );
  }
}

// Pantalla normal
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Inicio Normal')));
  }
}

// Pantalla de urgencia
class PantallaPerfilMedico extends StatelessWidget {
  const PantallaPerfilMedico({super.key});
  
  @override
  Widget build(BuildContext context) {
    const Color colorTarjetas = Color(0xFFA03333);

    return Scaffold(
      //appBar es la barra superior de la app
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9183E),
        title: const Text(
          'Persona Equis', //----------------- Valor hardcodeado con fin demostrativo
          style: TextStyle(
            color: Colors.white, 
            fontSize: 28, 
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {  },
          )
        ],
      ),

      // SingleChildScrollView evita que la pantalla se rompa si el contenido es más largo que el teléfono
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //tarjeta de informacion vital
            Card(
              color: colorTarjetas,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alergias: no', style: TextStyle(color: Colors.white, fontSize: 18)), //-------------Valores hardcodeados con un fin demostrativo-----------
                    const Text('Enfermedad: si', style: TextStyle(color: Colors.white, fontSize: 18)),
                    const Text('Medicacion: si', style: TextStyle(color: Colors.white, fontSize: 18)),
                    const Text('Grupo y factor: A+ (positivo)', style: TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 24,),

                    //fila para los botones de accion rapida
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _BotonAccionRapida(
                          icono: Icons.phone,
                          texto: '911',
                          colorFondo: Colors.green
                        ),
                        _BotonAccionRapida(
                          icono: Icons.contact_phone, 
                          texto: 'Emergencia', 
                          colorFondo: Colors.grey
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24,),

            // cuadricula de botones (Grid)
            GridView.count(
              shrinkWrap: true, // Necesario porque está dentro de un SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // Desactiva el scroll interno del Grid
              crossAxisCount: 2,  //dos columnas
              crossAxisSpacing: 16,
              mainAxisExtent: 100,
              mainAxisSpacing: 20,
              childAspectRatio: 2.0,  //hace que los botones sean rectangulares

              children: const [
                _BotonCategoria(texto: 'Enfermedades', colorFondo: colorTarjetas),
                _BotonCategoria(texto: 'Alergias', colorFondo: colorTarjetas),
                _BotonCategoria(texto: 'Número de\nRespaldo', colorFondo: colorTarjetas),
                _BotonCategoria(texto: 'Vacunas', colorFondo: colorTarjetas),
                _BotonCategoria(texto: 'Obra Social', colorFondo: colorTarjetas),
                _BotonCategoria(texto: 'Medicación', colorFondo: colorTarjetas),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


//------ CLASES REUTILIZABLES ------

// Widget para loos botones redondos
class _BotonAccionRapida extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color colorFondo;

  const _BotonAccionRapida({
    required this.icono, 
    required this.texto, 
    required this.colorFondo
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: colorFondo,
          radius: 35,
          child: Icon(icono, color: Colors.white, size: 35),
        ),
        const SizedBox(height: 8),
        Text(texto, style: const TextStyle(color: Colors.white, fontSize: 18)),
      ],
    );
  }
}

// Wisget para los botones rectangulares
class _BotonCategoria extends StatelessWidget {
  final String texto;
  final Color colorFondo;

  const _BotonCategoria({
    required this.texto,
    required this.colorFondo,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorFondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
        ),
      ),
      onPressed: () {
        // aca iria la logica al tocar el boton(llevar hacia la pagina correspondiente)
      },
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}