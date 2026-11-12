package ar.edu.unrn.emergencysystem

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat

// Notificación permanente con los datos vitales. Se crea acá (y no con un plugin de Flutter) porque
// necesita saber cuándo el usuario la borra: en Android 14+ las notificaciones fijas se pueden borrar
// deslizando, así que al borrarla se vuelve a mostrar enseguida con el mismo contenido.
object NotificacionEmergencia {
    private const val CANAL_ID = "canal_emergencia_01"
    private const val NOTIFICACION_ID = 0

    const val ACCION_REPONER = "ar.edu.unrn.emergencysystem.REPONER_NOTIFICACION"
    const val EXTRA_TITULO = "titulo"
    const val EXTRA_TEXTO = "texto"
    const val EXTRA_TEXTO_LARGO = "textoLargo"

    // Muestra (o actualiza) la notificación. [textoLargo] es lo que se ve al expandirla.
    fun mostrar(context: Context, titulo: String, texto: String, textoLargo: String) {
        if (!puedeNotificar(context)) return
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        crearCanal(manager)

        val abrirApp = PendingIntent.getActivity(
            context, 0,
            Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        // Android ejecuta este aviso cuando el usuario borra la notificación. Lleva el contenido
        // en memoria para volver a mostrarla igual, sin guardar los datos sin cifrar.
        val alBorrar = PendingIntent.getBroadcast(
            context, 0,
            Intent(context, NotificacionReceiver::class.java)
                .setAction(ACCION_REPONER)
                .putExtra(EXTRA_TITULO, titulo)
                .putExtra(EXTRA_TEXTO, texto)
                .putExtra(EXTRA_TEXTO_LARGO, textoLargo),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notificacion = NotificationCompat.Builder(context, CANAL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(titulo)
            .setContentText(texto)
            .setStyle(NotificationCompat.BigTextStyle().bigText(textoLargo).setBigContentTitle(titulo))
            .setContentIntent(abrirApp)
            .setDeleteIntent(alBorrar)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true) // al actualizar los datos no vuelve a aparecer en pantalla
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC) // visible en la pantalla de bloqueo
            .build()

        manager.notify(NOTIFICACION_ID, notificacion)
    }

    private fun crearCanal(manager: NotificationManager) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O || manager.getNotificationChannel(CANAL_ID) != null) return
        val canal = NotificationChannel(CANAL_ID, "Acceso de Emergencia", NotificationManager.IMPORTANCE_HIGH)
        canal.description = "Mantiene el acceso rápido a los datos médicos"
        manager.createNotificationChannel(canal)
    }

    // En Android 13+ hace falta el permiso de notificaciones que la app pide al abrirse
    private fun puedeNotificar(context: Context): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
}
