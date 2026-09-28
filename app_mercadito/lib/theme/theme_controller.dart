import 'dart:async';
import 'package:flutter/material.dart';

/// Opciones de preferencia de tema seleccionables por el usuario:
/// - [day]: Modo Día permanente (tema claro)
/// - [night]: Modo Noche permanente (tema oscuro)
/// - [automatic]: Automático según la zona horaria / horario local del dispositivo
enum AppThemePreference {
  day,
  night,
  automatic,
}

class ThemeController {
  // Notificador con la preferencia seleccionada por el usuario
  static final ValueNotifier<AppThemePreference> preference =
      ValueNotifier<AppThemePreference>(AppThemePreference.automatic);

  // Notificador con el ThemeMode efectivo de Flutter (light o dark)
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static Timer? _autoCheckTimer;
  static bool _initialized = false;

  /// Determina si una hora específica (o la hora local actual) corresponde a la noche.
  /// Rango nocturno: desde las 19:00 (7:00 PM) hasta las 05:59:59 (6:00 AM).
  /// Rango diurno: desde las 06:00 (6:00 AM) hasta las 18:59:59 (7:00 PM).
  static bool isNightTime([DateTime? time]) {
    final now = time ?? DateTime.now();
    return now.hour >= 19 || now.hour < 6;
  }

  /// Inicializa el controlador y establece el tema según la hora actual y la preferencia.
  static void init() {
    if (_initialized) return;
    _initialized = true;
    _evaluateTheme();

    // Verificación periódica cada minuto para alternar automáticamente
    // entre el día y la noche cuando la hora cambie mientras la app está abierta.
    _autoCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (preference.value == AppThemePreference.automatic) {
        _evaluateTheme();
      }
    });
  }

  /// Cambia la preferencia del usuario (Día, Noche o Automático) y actualiza el tema.
  static void setPreference(AppThemePreference newPreference) {
    preference.value = newPreference;
    _evaluateTheme();
  }

  /// Evalúa y aplica el ThemeMode correspondiente.
  static void _evaluateTheme() {
    switch (preference.value) {
      case AppThemePreference.day:
        themeMode.value = ThemeMode.light;
        break;
      case AppThemePreference.night:
        themeMode.value = ThemeMode.dark;
        break;
      case AppThemePreference.automatic:
        themeMode.value = isNightTime() ? ThemeMode.dark : ThemeMode.light;
        break;
    }
  }

  /// Devuelve una descripción en texto del estado actual del modo automático.
  static String getAutomaticStatusDescription([DateTime? time]) {
    final now = time ?? DateTime.now();
    final isNight = isNightTime(now);
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final timeStr = '$displayHour:$minute $period';

    if (isNight) {
      return 'Hora local $timeStr • Noche activa (7:00 PM – 6:00 AM)';
    } else {
      return 'Hora local $timeStr • Día activo (6:00 AM – 7:00 PM)';
    }
  }

  /// Verifica si el modo oscuro está activo actualmente en pantalla.
  static bool isDarkModeActive(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ||
        themeMode.value == ThemeMode.dark;
  }

  /// Limpieza de recursos si fuera necesario.
  static void dispose() {
    _autoCheckTimer?.cancel();
    _autoCheckTimer = null;
    _initialized = false;
  }
}
