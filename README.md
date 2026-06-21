#  EmergencySystem UNRN

Sistema de tarjeta médica de emergencia desarrollado para la Universidad Nacional de Río Negro (UNRN). 
Nació a partir de una situación real vivida en la institución, donde un alumno de primer año se descompensó 
y nadie sabía a quién contactar ni qué condiciones médicas tenía.

---

##  Descripción

EmergencySystem es una aplicación móvil que permite a cualquier persona
tener a mano su información médica esencial en caso de emergencia. Si el usuario no puede comunicarse 
por sus propios medios, cualquier tercero que tome el dispositivo puede ver de forma inmediata los datos 
necesarios para actuar con rapidez y eficiencia.

Los datos se almacenan **localmente en el dispositivo**, sin servidores externos, garantizando la 
privacidad de la información en todo momento.

---

##  Características

- **Tarjeta de emergencia visible al instante** — grupo sanguíneo, alergias, enfermedades y medicación en la pantalla principal
- **Llamada rápida al 911** y al contacto de emergencia personal con un solo toque
- **Perfil médico completo** con secciones para alergias, enfermedades, medicación, vacunas, obra social y restricciones alimentarias
- **Detalle por sección** — Severidad de alergias, tratamientos, vía de administración de medicamentos, marca y localidad de vacunas, entre otros.
- **Edición protegida** — El botón de editar requiere autenticación biométrica o PIN para evitar modificaciones no autorizadas
- **Notificación permanente** — Acceso directo al perfil médico desde la barra de notificaciones, incluso con el teléfono bloqueado
- **Sin conexión a internet** — Funciona completamente offline
- **Almacenamiento local** — Los datos se guardan en el dispositivo y persisten entre sesiones

---

##  Tecnologías utilizadas

- [Flutter](https://flutter.dev/) — framework principal de desarrollo
- [Dart](https://dart.dev/) — lenguaje de programación
- [shared_preferences](https://pub.dev/packages/shared_preferences) — almacenamiento local de datos
- [local_auth](https://pub.dev/packages/local_auth) — autenticación biométrica y PIN
- [url_launcher](https://pub.dev/packages/url_launcher) — llamadas telefónicas directas
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) — notificación permanente en la barra del sistema
- [permission_handler](https://pub.dev/packages/permission_handler) — manejo de permisos en Android

---

##  Instalación

### Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (versión 3.0 o superior)
- Android Studio o VS Code con extensión de Flutter
- Dispositivo Android o emulador configurado

### Pasos

1. Clonar el repositorio:
```bash
git clone https://github.com/LuccitePedro/EmergencySystem-UNRN.git
cd EmergencySystem-UNRN
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Correr la aplicación:
```bash
flutter run
```

> **Nota:** Para la autenticación biométrica y las llamadas telefónicas, la app debe correrse en un dispositivo Android físico. Algunas funcionalidades no están disponibles en emuladores o en la versión web. 

> **Nota:** En un futuro se lanzará a la Play Store de Android, para una instalación común y corriente. Lamentablemente, esta aplicación no estará disponible en la App Store de iOS por el momento.

---

##  Modo de uso (Luego de instalación)

### Primeros pasos en la aplicación
- Al iniciar, vemos una sección de datos vacíos que tenemos que llenar (no es obligatorio si no poseemos una de esas secciones como puede ser una enfermedad)
- Se pide responsabilidad y consciencia a la hora de rellenar estos datos, ya que tu vida puede estar en riesgo y los terceros dependen de esa información.
>***Detalle a tener en cuenta***: Una vez terminados los pasos anteriores, se debe cerrar la aplicación y volver a abrir, probablemente si no se hace esto, quede en una pantalla de carga.

### Dentro de la app
- Una vez que volvemos a abrir la aplicación, podemos ver todos los datos que ingresamos en la anterior sección.
- En un futuro, se implementarán las ediciones y datos adicionales del usuario.
>**Esta aplicación es una versión prototipo completa.**

---

##  Estado del proyecto

La aplicación se encuentra en una versión funcional con las características principales implementadas. 

Funcionalidades pendientes para futuras versiones:
- Corrección de errores los cuales no afectan a la funcionalidad 
- Implementación de funcionalidades tales como **edición**, sección de **datos personales**
- Optimización general de rendimiento
- Lanzamiento en Play Store
- Implementación en iOS y posible lanzamiento en App Store

---

##  Autores

### Luccite, Pedro 
### Romero, Santino

---

> Desarrollado en el marco de la **Universidad Nacional de Río Negro (UNRN)**.