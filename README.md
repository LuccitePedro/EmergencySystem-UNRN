# EmergencySystem UNRN

Sistema de tarjeta médica de emergencia desarrollado para la Universidad Nacional de Río Negro (UNRN).
Nació a partir de una situación real vivida en la institución, donde un alumno de primer año se descompensó
y nadie sabía a quién contactar ni qué condiciones médicas tenía.

---

## Índice

- [Descripción](#descripción)
- [Descargar la app](#descargar-la-app)
- [Características](#características)
- [Pantallas de la aplicación](#pantallas-de-la-aplicación)
- [Seguridad y privacidad](#seguridad-y-privacidad)
- [Tecnologías utilizadas](#tecnologías-utilizadas)
- [Instalación para desarrolladores](#instalación-para-desarrolladores)
- [Modo de uso](#modo-de-uso)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Pruebas](#pruebas)
- [Limitaciones conocidas](#limitaciones-conocidas)
- [Estado del proyecto](#estado-del-proyecto)
- [Autores](#autores)

---

## Descripción

EmergencySystem es una aplicación móvil para Android que permite a cualquier persona tener a mano su
información médica esencial en caso de emergencia. Si el usuario no puede comunicarse por sus propios
medios, cualquier tercero que tome el dispositivo puede ver de forma inmediata los datos necesarios para
actuar con rapidez: grupo sanguíneo, alergias, enfermedades, medicación y a quién llamar.

La información está disponible **incluso con el teléfono bloqueado**, a través de una notificación
permanente, pero **solo el dueño puede modificarla**.

Los datos se almacenan **cifrados y localmente en el dispositivo**, sin servidores externos ni conexión a
internet.

---

## Descargar la app

Se instala directamente con el archivo **APK**, que se descarga
desde la sección **Releases** de este repositorio.

**[⬇ Descargar la última versión](https://github.com/LuccitePedro/EmergencySystem-UNRN/releases/latest)**

### Cómo instalarla
1. Desde el celular Android, abrí el enlace de arriba y tocá el archivo `EmergencySystem-vX.X.X.apk`
   para descargarlo.
2. Cuando termine, abrí el archivo descargado.
3. Si aparece el aviso de que no se permiten apps de origen desconocido, tocá **Configuración**, activá
   **Permitir de esta fuente** y volvé atrás.
4. Tocá **Instalar**. Si Google Play Protect muestra un aviso, elegí **Más detalles → Instalar de todas
   formas**. Aparece porque la app no viene de la Play Store.
5. Abrí la app y **aceptá el permiso de notificaciones**, para que tus datos se vean aunque el teléfono
   esté bloqueado.

### Cómo actualizarla
Descargá el APK de la versión nueva desde Releases e instalalo encima de la anterior. **Tus datos se
conservan**; no hace falta desinstalar.

> Requiere Android 7.0 o superior. No está disponible para iPhone.

---

## Características

### Información siempre visible
- **Tarjeta de emergencia en la pantalla principal**: grupo y factor sanguíneo, alergias (con su
  severidad), enfermedades y medicación, mostrando los datos reales y no solo un "Sí/No".
- **Notificación permanente**: muestra los datos vitales y los contactos de emergencia en la barra de
  notificaciones y en la pantalla de bloqueo. Al tocarla se abre el perfil completo. No se puede descartar
  deslizando, y cuando se actualizan los datos se renueva en silencio, sin volver a aparecer en pantalla.
- **Resúmenes que no crecen sin límite**: si hay muchos elementos cargados, la tarjeta principal y la
  notificación muestran los tres primeros y resumen el resto (por ejemplo, *"Penicilina, Polen, Látex y 5 más"*).

### Llamadas rápidas
- **Botón de llamada al 911** con un solo toque.
- **Hasta dos contactos de emergencia** con su propio botón de llamada. Si no hay ninguno cargado, la app
  avisa al tocar el botón.
- **Llamadas con el teléfono bloqueado**: al guardar el perfil con algún contacto, la app pide permiso
  para hacer llamadas. Con ese permiso, los botones de los contactos llaman directo, sin desbloquear el
  teléfono. Sin el permiso, se abre el marcador y Android pide desbloquear. El 911 siempre abre el
  marcador, porque Android no permite que una app llame directo a un número de emergencia.

### Perfil médico completo
Siete secciones, navegables desde la grilla de la pantalla principal o deslizando de una a otra:

| Sección | Datos que guarda |
|---|---|
| Enfermedades | Nombre, tratamiento actual, fecha de diagnóstico |
| Alergias | Nombre, reacción, severidad (leve / moderada / grave) y qué hacer |
| Contactos | Nombre, relación y teléfono (máximo 2) |
| Vacunas | Nombre, dosis, marca, fecha de aplicación y localidad |
| Obra social | Nombre y número de socio |
| Medicación | Nombre, dosis, marca, frecuencia, vía de administración y para qué es |
| Restricciones alimentarias | Por ejemplo: sin gluten, sin lactosa |

- Las **alergias se colorean según su severidad** (bordó, naranja o rojo intenso) para identificar
  rápido las más peligrosas.
- Las listas largas tienen una **barra de desplazamiento arrastrable** para recorrerlas rápido.

### Carga de datos cuidada
- **Fechas validadas**: los campos de fecha solo aceptan números, ponen las barras automáticamente
  (`20012021` → `20/01/2021`) y rechazan fechas incompletas, inexistentes (como el 31/02) o futuras.
- **Campos obligatorios mínimos**: solo el nombre del usuario es obligatorio; cada sección se completa si
  corresponde.

### Edición protegida
- El **lápiz** (arriba a la derecha) abre el formulario de edición solo después de autenticarse con
  **huella** o con el **PIN, patrón o contraseña del dispositivo**.
- Si la app se abrió **sobre la pantalla de bloqueo**, antes de editar se pide **desbloquear el teléfono**.
  Así, un tercero puede ver los datos pero no cambiarlos.

### Diseño
- Interfaz basada en **Material 3**, con la paleta propia de la app (rojo `#F9183E` y bordó `#A03333`).
- Botones con respuesta visual al tocar, íconos por sección y animaciones suaves al cambiar de página.
- La grilla de secciones se adapta: **3 columnas en tablet, 2 en teléfono**.

---

## Pantallas de la aplicación

1. **Pantalla de carga**: decide si es el primer uso (va al formulario) o si ya hay un perfil (va a la
   pantalla principal).
2. **Formulario de perfil**: se usa en el primer uso y cada vez que se edita. Tiene una sección por cada
   tipo de dato, con diálogos para agregar elementos y un botón para eliminar cada uno.
3. **Pantalla principal**: encabezado con el nombre, tarjeta de datos vitales, botones de llamada y
   grilla con las siete secciones.
4. **Secciones (carrusel)**: el detalle de cada categoría. Se pasa de una a otra deslizando o con las
   flechas, y el indicador de abajo muestra en cuál se está. El botón **Inicio** vuelve a la pantalla
   principal.

---

## Seguridad y privacidad

| Aspecto | Cómo se resuelve |
|---|---|
| Dónde están los datos | Solo en el dispositivo; la app no usa internet ni servidores |
| Cifrado | El perfil se guarda con `flutter_secure_storage` (RSA OAEP + AES‑GCM, claves en el Android Keystore) |
| Copias de seguridad | El backup automático de Android está desactivado (`allowBackup="false"`), porque las claves del Keystore no se pueden restaurar en otro equipo |
| Quién puede editar | Solo quien se autentica con huella o con las credenciales del dispositivo |
| Qué ve un tercero | Los datos vitales y los contactos, aun con el teléfono bloqueado. Es intencional: es la función principal de la app |

> **Importante:** quien tenga el teléfono en la mano puede leer los datos vitales desde la pantalla de
> bloqueo. Conviene cargar solo la información que realmente sirva en una emergencia.

---

## Tecnologías utilizadas

- [Flutter](https://flutter.dev/) — framework principal de desarrollo
- [Dart](https://dart.dev/) — lenguaje de programación
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) — almacenamiento cifrado del perfil médico
- [shared_preferences](https://pub.dev/packages/shared_preferences) — preferencias no sensibles (si ya se completó el primer uso)
- [local_auth](https://pub.dev/packages/local_auth) — autenticación con huella, PIN, patrón o contraseña
- [url_launcher](https://pub.dev/packages/url_launcher) — llamadas telefónicas directas
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) — notificación permanente
- [permission_handler](https://pub.dev/packages/permission_handler) — permiso de notificaciones en Android 13+

Además, la app usa un canal nativo en Kotlin (`MainActivity.kt`) para saber si el dispositivo está
bloqueado y pedir que se desbloquee antes de editar.

---

## Instalación para desarrolladores

Para modificar o compilar la app desde el código. Si solo querés usarla, mirá
[Descargar la app](#descargar-la-app).

### Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versión 3.0 o superior)
- **JDK 17** (por ejemplo [Eclipse Temurin](https://adoptium.net/)). Gradle no funciona con Java 8.
  Si Flutter no lo encuentra solo:
  ```bash
  flutter config --jdk-dir "C:\Program Files\Eclipse Adoptium\jdk-17..."
  ```
- Android Studio o VS Code con la extensión de Flutter
- Dispositivo Android (recomendado) o emulador

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

3. Correr la aplicación en modo desarrollo:
   ```bash
   flutter run
   ```

4. O generar e instalar la versión final (release):
   ```bash
   flutter build apk --release
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

> **Modo desarrollo vs. release:** en modo desarrollo (`flutter run`), los botones de llamada muestran un
> aviso en lugar de llamar de verdad, para no hacer llamadas por error mientras se prueba. En la versión
> release llaman realmente.

### Conectar el dispositivo sin cable (depuración inalámbrica)

Si el cable USB no funciona o solo carga, se puede conectar por Wi‑Fi (Android 11 o superior, misma red
que la PC):

1. En el dispositivo: *Opciones de desarrollador → Depuración inalámbrica → Vincular dispositivo con
   código de vinculación*.
2. En la PC:
   ```bash
   adb pair <IP>:<puerto de vinculación> <código>
   adb connect <IP>:<puerto de conexión>
   ```
3. Verificar con `flutter devices` y correr la app normalmente.

### Publicar una versión nueva
1. Subir el número de versión en `pubspec.yaml` (por ejemplo `version: 1.0.1+2`).
2. Generar el APK con `flutter build apk --release`.
3. En GitHub: **Releases → Draft a new release**, crear la etiqueta (por ejemplo `v1.0.1`), adjuntar el
   APK renombrado como `EmergencySystem-v1.0.1.apk` y publicar.

> **Importante:** el APK queda firmado con la clave de la PC donde se compila. Para que los usuarios
> puedan instalar la actualización encima de la versión anterior (y conservar sus datos), todas las
> versiones tienen que compilarse en la misma PC, o con la misma clave de firma.

---

## Modo de uso

### Primer uso
1. Al abrir la app por primera vez, se pide permiso para mostrar notificaciones: hay que **aceptarlo** para
   que los datos se vean en la pantalla de bloqueo.
2. Aparece el formulario vacío. Solo el **nombre** es obligatorio; el resto se completa si corresponde.
3. Al tocar **Guardar perfil**, la app pasa directamente a la pantalla principal.

> Se pide responsabilidad a la hora de cargar los datos: en una emergencia, quien te asista va a confiar
> en esa información.

### Uso diario
- **Ver los datos**: en la pantalla principal o en la notificación, sin desbloquear el teléfono.
- **Ver el detalle**: tocar cualquier sección de la grilla y deslizar para pasar a las demás.
- **Llamar**: tocar el botón del 911 o el del contacto.
- **Editar**: tocar el lápiz, autenticarse, modificar y tocar **Guardar**. La notificación se actualiza sola.

### En una emergencia (para terceros)
1. Encender la pantalla del teléfono y bajar la barra de notificaciones: ahí están los datos vitales y los
   contactos.
2. Tocar la notificación para ver el perfil completo.
3. Usar los botones para llamar al 911 o al contacto de emergencia.

---

## Estructura del proyecto

```
lib/
├── main.dart                          # Arranque, pantalla de carga y pantalla principal
├── models/
│   └── perfil_medico.dart             # Modelos de datos y conversión a/desde JSON
├── screens/
│   ├── pantalla_editar_perfil.dart    # Formulario de alta y edición del perfil
│   └── pantalla_categoria_carousel.dart  # Detalle de las 7 secciones (carrusel)
├── services/
│   ├── auth_service.dart              # Autenticación y desbloqueo del dispositivo
│   ├── notificacion_service.dart      # Notificación permanente con los datos vitales
│   └── storage_service.dart           # Guardado cifrado del perfil
├── theme/
│   └── colores.dart                   # Paleta de colores y tema Material 3
├── utils/
│   └── texto.dart                     # Resumen de listas largas
└── widgets/
    ├── curved_header.dart             # Fondo curvo del encabezado
    └── encabezado.dart                # Encabezado con título y lápiz de edición

android/app/src/main/kotlin/ar/edu/unrn/emergencysystem/
└── MainActivity.kt                    # Mostrar sobre la pantalla de bloqueo y pedir desbloqueo
```

**Identificador de la aplicación:** `ar.edu.unrn.emergencysystem`

---

## Pruebas

```bash
flutter analyze   # análisis estático
flutter test      # pruebas automáticas
```

Las pruebas automáticas (`test/widget_test.dart`) verifican que:
- el perfil se guarda y se recupera en JSON sin perder datos;
- un perfil vacío se detecta como vacío;
- la pantalla principal muestra los datos reales, el lápiz de edición y como máximo dos contactos;
- sin contactos aparece un único botón de emergencia;
- las listas largas se resumen ("y N más");
- el campo de fecha acepta solo fechas válidas y no futuras;
- con muchas alergias, la tarjeta principal no crece y la sección se puede recorrer hasta la última.

Además, la app se probó en una **Samsung Galaxy Tab S9 FE (Android 16)**: primer uso, edición con
huella, guardado cifrado, notificación, las siete secciones y la carga de 30 alergias.

---

## Limitaciones conocidas

- **Llamadas:** se probaron en una tablet sin línea telefónica, por lo que no se pudo realizar una llamada
  real. La funcionalidad usa el marcador estándar de Android, pero falta verificarla en un teléfono.
- **Dispositivo sin bloqueo de pantalla:** si el dispositivo no tiene PIN, patrón, contraseña ni huella,
  la edición queda permitida, ya que cualquiera podría entrar al teléfono de todas formas.
- **Cambio de teléfono:** como los datos están cifrados con claves del dispositivo y el backup está
  desactivado, al cambiar de teléfono hay que volver a cargar el perfil.
- Solo disponible para Android.

---

## Estado del proyecto

La aplicación es una **versión prototipo completa y funcional**, con todas las características principales
implementadas y probadas en un dispositivo real.

Pendiente para futuras versiones:
- Verificar las llamadas en un teléfono con línea
- Versión para iOS

La app se distribuye únicamente mediante el APK de [Releases](https://github.com/LuccitePedro/EmergencySystem-UNRN/releases);

---

## Autores

### Luccite, Pedro
### Romero, Santino

---

> Desarrollado en el marco de la **Universidad Nacional de Río Negro (UNRN)**.
