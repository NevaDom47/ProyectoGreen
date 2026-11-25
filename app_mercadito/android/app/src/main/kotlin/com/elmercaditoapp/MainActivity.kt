package com.elmercaditoapp

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.graphics.drawable.Icon
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL_NAME = "com.elmercaditoapp/notifications"
        private const val REQ_POST_NOTIFICATIONS = 9001
        private const val EXTRA_ROUTE = "notif_route"
        private const val EXTRA_NOTIF_ID = "notif_id"
    }

    private var methodChannel: MethodChannel? = null
    private var pendingPermissionResult: MethodChannel.Result? = null
    private var pendingLaunchPayload: Map<String, String?>? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private val pendingRunnables = mutableListOf<Runnable>()
    private var channelsInitialized = false

    private data class ChannelSpec(
        val key: String,
        val name: String,
        val description: String
    )

    private val channelSpecs = listOf(
        ChannelSpec("pedidos", "Pedidos y Envíos", "Actualizaciones de despacho y entrega en ruta"),
        ChannelSpec("negociaciones", "Negociaciones y Contraofertas", "Propuestas y cierres con proveedores"),
        ChannelSpec("ofertas", "Ofertas Relámpago", "Descuentos por tiempo limitado y liquidaciones"),
        ChannelSpec("cupones", "Cupones y Descuentos", "Cupones promocionales disponibles y por vencer"),
        ChannelSpec("mercado", "Radar y Precios de Mercado", "Tendencias predictivas y alertas agrícolas"),
        ChannelSpec("vendedores", "Vendedores Seguidos", "Nuevas cosechas, videos y catálogos"),
        ChannelSpec("recomendaciones", "Recomendaciones Inteligentes", "Sugerencias personalizadas según tu consumo"),
        ChannelSpec("sistema", "Sistema y Cuenta", "Avisos de seguridad, verificación y estado")
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureLaunchPayload(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val payload = extractPayload(intent)
        if (payload != null) {
            pendingLaunchPayload = payload
            methodChannel?.invokeMethod("onNotificationTap", payload)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        ensureChannelsCreated()

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasPermission" -> {
                        result.success(hasNotificationPermission())
                    }
                    "requestPermission" -> {
                        requestNotificationPermission(result)
                    }
                    "showNotification" -> {
                        val args = call.arguments as? Map<*, *>
                        if (args == null) {
                            result.error("INVALID_ARGS", "Expected notification arguments map", null)
                            return@setMethodCallHandler
                        }
                        handleShowNotification(args)
                        result.success(true)
                    }
                    "showBatchNotifications" -> {
                        val args = call.arguments as? Map<*, *>
                        if (args == null) {
                            result.error("INVALID_ARGS", "Expected batch arguments map", null)
                            return@setMethodCallHandler
                        }
                        handleShowBatchNotifications(args)
                        result.success(true)
                    }
                    "cancelAllNotifications" -> {
                        cancelAllScheduledAndActive()
                        result.success(true)
                    }
                    "getInitialPayload" -> {
                        result.success(pendingLaunchPayload)
                        pendingLaunchPayload = null
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {
        clearPendingRunnables()
        super.onDestroy()
    }

    private fun channelIdForKey(categoryKey: String): String {
        val normalized = if (channelSpecs.any { it.key == categoryKey }) categoryKey else "sistema"
        return "mercadito_ch_${normalized}_v1"
    }

    private fun notificationManager(): NotificationManager {
        return getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    private fun notificationSoundUri(): Uri {
        return Uri.parse("android.resource://$packageName/${R.raw.notificacion_app}")
    }

    private fun ensureChannelsCreated() {
        if (channelsInitialized || Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = notificationManager()
        val soundUri = notificationSoundUri()
        val audioAttrs = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        for (spec in channelSpecs) {
            val channel = NotificationChannel(
                channelIdForKey(spec.key),
                spec.name,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = spec.description
                enableLights(true)
                enableVibration(true)
                setShowBadge(true)
                setSound(soundUri, audioAttrs)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            manager.createNotificationChannel(channel)
        }
        channelsInitialized = true
    }

    private fun hasNotificationPermission(): Boolean {
        val manager = notificationManager()
        val areEnabled = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            manager.areNotificationsEnabled()
        } else {
            true
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val granted = checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
                PackageManager.PERMISSION_GRANTED
            return granted && areEnabled
        }
        return areEnabled
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(hasNotificationPermission())
            return
        }
        if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            result.success(hasNotificationPermission())
            return
        }
        pendingPermissionResult?.success(false)
        pendingPermissionResult = result
        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQ_POST_NOTIFICATIONS)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQ_POST_NOTIFICATIONS) {
            val granted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }

    private fun handleShowNotification(args: Map<*, *>) {
        ensureChannelsCreated()
        val minimizeApp = args["minimizeApp"] as? Boolean ?: false
        val delayMs = (args["delayMs"] as? Number)?.toLong() ?: 0L

        if (minimizeApp) {
            moveTaskToBack(true)
        }

        if (delayMs > 0L) {
            lateinit var runnable: Runnable
            runnable = Runnable {
                pendingRunnables.remove(runnable)
                dispatchNotification(args)
            }
            pendingRunnables.add(runnable)
            mainHandler.postDelayed(runnable, delayMs)
        } else {
            dispatchNotification(args)
        }
    }

    private fun handleShowBatchNotifications(args: Map<*, *>) {
        ensureChannelsCreated()
        val items = args["items"] as? List<*> ?: return
        val minimizeApp = args["minimizeApp"] as? Boolean ?: false
        val initialDelayMs = (args["initialDelayMs"] as? Number)?.toLong() ?: 0L
        val intervalMs = (args["intervalMs"] as? Number)?.toLong() ?: 900L

        if (minimizeApp) {
            moveTaskToBack(true)
        }

        items.forEachIndexed { index, rawItem ->
            val itemMap = rawItem as? Map<*, *> ?: return@forEachIndexed
            val totalDelay = initialDelayMs + (index * intervalMs)
            if (totalDelay > 0L) {
                lateinit var runnable: Runnable
                runnable = Runnable {
                    pendingRunnables.remove(runnable)
                    dispatchNotification(itemMap)
                }
                pendingRunnables.add(runnable)
                mainHandler.postDelayed(runnable, totalDelay)
            } else {
                dispatchNotification(itemMap)
            }
        }
    }

    private fun dispatchNotification(args: Map<*, *>) {
        val id = (args["id"] as? Number)?.toInt() ?: (System.currentTimeMillis() % 100000).toInt()
        val categoryKey = args["categoryKey"]?.toString() ?: "sistema"
        val categoryLabel = args["categoryLabel"]?.toString() ?: "Sistema"
        val title = args["title"]?.toString() ?: "El Mercadito"
        val body = args["body"]?.toString() ?: ""
        val expandedBody = args["expandedBody"]?.toString()?.takeIf { it.isNotBlank() } ?: body
        val summaryText = args["summaryText"]?.toString()?.takeIf { it.isNotBlank() } ?: categoryLabel
        val colorHex = (args["colorHex"] as? Number)?.toInt() ?: 0xFF016042.toInt()
        val route = args["route"]?.toString() ?: "/notifications"
        val notificationId = args["notificationId"]?.toString() ?: ""
        val actionLabel = args["actionLabel"]?.toString()

        val tapIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(EXTRA_ROUTE, route)
            putExtra(EXTRA_NOTIF_ID, notificationId)
        }

        val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val contentPendingIntent = PendingIntent.getActivity(
            this,
            id,
            tapIntent,
            pendingFlags
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelIdForKey(categoryKey))
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setPriority(Notification.PRIORITY_HIGH)
                .setSound(notificationSoundUri())
                .setDefaults(Notification.DEFAULT_VIBRATE or Notification.DEFAULT_LIGHTS)
        }

        builder.setSmallIcon(R.drawable.ic_stat_mercadito)
            .setContentTitle(title)
            .setContentText(body)
            .setSubText(categoryLabel)
            .setColor(colorHex)
            .setAutoCancel(true)
            .setShowWhen(true)
            .setWhen(System.currentTimeMillis())
            .setContentIntent(contentPendingIntent)

        val largeIcon = try {
            BitmapFactory.decodeResource(resources, R.mipmap.ic_launcher)
        } catch (_: Throwable) {
            null
        }
        if (largeIcon != null) {
            builder.setLargeIcon(largeIcon)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            builder.setVisibility(Notification.VISIBILITY_PUBLIC)
        }

        builder.setStyle(
            Notification.BigTextStyle()
                .bigText(expandedBody)
                .setBigContentTitle(title)
                .setSummaryText(summaryText)
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !actionLabel.isNullOrBlank()) {
            val action = Notification.Action.Builder(
                Icon.createWithResource(this, R.drawable.ic_stat_mercadito),
                actionLabel,
                contentPendingIntent
            ).build()
            builder.addAction(action)
        }

        notificationManager().notify(id, builder.build())
    }

    private fun cancelAllScheduledAndActive() {
        clearPendingRunnables()
        notificationManager().cancelAll()
    }

    private fun clearPendingRunnables() {
        for (runnable in pendingRunnables) {
            mainHandler.removeCallbacks(runnable)
        }
        pendingRunnables.clear()
    }

    private fun captureLaunchPayload(intent: Intent?) {
        val payload = extractPayload(intent)
        if (payload != null) {
            pendingLaunchPayload = payload
        }
    }

    private fun extractPayload(intent: Intent?): Map<String, String?>? {
        if (intent == null) return null
        val route = intent.getStringExtra(EXTRA_ROUTE) ?: return null
        val notifId = intent.getStringExtra(EXTRA_NOTIF_ID)
        return mapOf(
            "route" to route,
            "notificationId" to notifId
        )
    }
}
