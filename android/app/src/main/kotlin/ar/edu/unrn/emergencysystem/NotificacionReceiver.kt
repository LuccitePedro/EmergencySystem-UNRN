package ar.edu.unrn.emergencysystem

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

// Mantiene siempre visible la notificación de emergencia, sin tener que abrir la app:
// - Al borrarla (deslizándola o con "Borrar todo"), la vuelve a mostrar con el mismo contenido.
// - Al encender el teléfono, muestra un aviso genérico. Los datos están cifrados y acá no se leen;
//   al tocarlo se abre la app, que vuelve a poner la notificación con los datos completos.
//   Android envía el aviso de encendido después del primer desbloqueo del teléfono.
class NotificacionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            NotificacionEmergencia.ACCION_REPONER -> NotificacionEmergencia.mostrar(
                context,
                intent.getStringExtra(NotificacionEmergencia.EXTRA_TITULO) ?: TITULO_GENERICO,
                intent.getStringExtra(NotificacionEmergencia.EXTRA_TEXTO) ?: TEXTO_GENERICO,
                intent.getStringExtra(NotificacionEmergencia.EXTRA_TEXTO_LARGO) ?: TEXTO_GENERICO
            )
            Intent.ACTION_BOOT_COMPLETED -> {
                if (perfilCompletado(context)) {
                    NotificacionEmergencia.mostrar(context, TITULO_GENERICO, TEXTO_GENERICO, TEXTO_GENERICO)
                }
            }
        }
    }

    // Solo tiene sentido si el usuario ya guardó su perfil (mismo indicador que usa StorageService)
    private fun perfilCompletado(context: Context): Boolean =
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .getBoolean("flutter.primer_uso_completado", false)

    private companion object {
        const val TITULO_GENERICO = "🏥 Perfil médico de emergencia"
        const val TEXTO_GENERICO = "Tocá para ver los datos vitales"
    }
}
