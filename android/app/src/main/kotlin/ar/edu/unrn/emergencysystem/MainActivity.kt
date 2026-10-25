package ar.edu.unrn.emergencysystem

import android.Manifest
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// local_auth necesita FlutterFragmentActivity (con FlutterActivity la autenticación falla siempre)
class MainActivity: FlutterFragmentActivity() {
    private val canal = "emergency_system/dispositivo"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Estas líneas le dicen a Android: "Mostrame aunque el teléfono esté bloqueado"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            // Para versiones más antiguas de Android
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val keyguard = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, canal).setMethodCallHandler { call, result ->
            when (call.method) {
                // true si la app se está mostrando sobre la pantalla de bloqueo
                "estaBloqueado" -> result.success(keyguard.isKeyguardLocked)
                // true si el dispositivo tiene PIN, patrón, contraseña o huella configurados
                "tieneBloqueoSeguro" -> result.success(keyguard.isDeviceSecure)
                // Muestra el desbloqueo del sistema (pide el PIN/patrón/contraseña del dispositivo)
                "pedirDesbloqueo" -> {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                        result.success(false)
                    } else {
                        keyguard.requestDismissKeyguard(this, object : KeyguardManager.KeyguardDismissCallback() {
                            override fun onDismissSucceeded() = result.success(true)
                            override fun onDismissCancelled() = result.success(false)
                            override fun onDismissError() = result.success(false)
                        })
                    }
                }
                // Inicia la llamada directamente (sin abrir el marcador), así funciona aunque el teléfono
                // esté bloqueado: la pantalla de la llamada se muestra sobre el bloqueo.
                // Devuelve false si no hay permiso CALL_PHONE o no se pudo llamar, para usar el marcador.
                "llamarDirecto" -> {
                    val telefono = call.argument<String>("telefono")
                    val permitido = checkSelfPermission(Manifest.permission.CALL_PHONE) ==
                        PackageManager.PERMISSION_GRANTED
                    if (telefono.isNullOrBlank() || !permitido) {
                        result.success(false)
                    } else {
                        try {
                            startActivity(Intent(Intent.ACTION_CALL, Uri.fromParts("tel", telefono, null)))
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
