import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Servicio centralizado para la reproducción de efectos de sonido en El Mercadito.
/// Maneja los 7 eventos de audio solicitados con reproductores dedicados para evitar
/// que los sonidos se corten entre sí y con manejo seguro para pruebas y plataformas.
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;

  SoundService._internal();

  bool isMuted = false;
  double volume = 1.0;

  // Reproductores dedicados con inicialización lazy para permitir reproducción fluida y simultánea
  AudioPlayer? _btnPlayer;
  AudioPlayer? _favPlayer;
  AudioPlayer? _chatPlayer;
  AudioPlayer? _errorPlayer;
  AudioPlayer? _negPlayer;
  AudioPlayer? _notifAppPlayer;
  AudioPlayer? _notifInAppPlayer;
  AudioPlayer? _taskCompletedPlayer;

  AudioPlayer _getPlayer(int type) {
    switch (type) {
      case 0:
        return _favPlayer ??= (AudioPlayer()..audioCache.prefix = 'assets/');
      case 1:
        return _chatPlayer ??= (AudioPlayer()..audioCache.prefix = 'assets/');
      case 2:
        return _errorPlayer ??= (AudioPlayer()..audioCache.prefix = 'assets/');
      case 3:
        return _negPlayer ??= (AudioPlayer()..audioCache.prefix = 'assets/');
      case 4:
        return _notifAppPlayer ??= (AudioPlayer()..audioCache.prefix = 'assets/');
      case 5:
        return _notifInAppPlayer ??= (AudioPlayer()..audioCache.prefix = 'assets/');
      case 7:
        return _taskCompletedPlayer ??= (AudioPlayer()..audioCache.prefix = 'assets/');
      default:
        return _btnPlayer ??= (AudioPlayer()..audioCache.prefix = 'assets/');
    }
  }

  bool get _canPlayAudio {
    if (isMuted) return false;
    // Si estamos en un entorno de pruebas, evitamos llamar canales nativos no implementados
    final bindingStr = WidgetsBinding.instance.runtimeType.toString();
    if (bindingStr.contains('TestWidgetsFlutterBinding') ||
        bindingStr.contains('AutomatedTestWidgetsFlutterBinding')) {
      return false;
    }
    return true;
  }

  Future<void> _play(String assetSubpath, int playerType) async {
    if (!_canPlayAudio) return;
    try {
      final player = _getPlayer(playerType);
      await player.stop();
      await player.play(
        AssetSource(assetSubpath),
        volume: volume,
      );
    } catch (e) {
      debugPrint('SoundService: error playing $assetSubpath: $e');
    }
  }

  static int _lastButtonClickMs = 0;
  static bool _suppressButtonClick = false;

  /// Suprime el sonido genérico de botón temporalmente (p. ej. al enviar mensaje,
  /// aceptar negociación o marcar favorito) para que no se superpongan sonidos.
  static void suppressNextButtonClick([Duration duration = const Duration(milliseconds: 350)]) {
    _suppressButtonClick = true;
    Future.delayed(duration, () {
      _suppressButtonClick = false;
    });
  }

  // ---------------------------------------------------------------------------
  // 1. Favorito: Agregar o quitar producto o proveedor
  // ---------------------------------------------------------------------------
  static Future<void> playFavorite() async {
    suppressNextButtonClick();
    await _instance._play('sounds/agregar_favorito.mp3', 0);
  }

  // ---------------------------------------------------------------------------
  // 2. Chat: Enviar o recibir mensaje en el chat
  // ---------------------------------------------------------------------------
  static Future<void> playChatMessage() async {
    suppressNextButtonClick();
    await _instance._play('sounds/chat_mensaje.mp3', 1);
  }

  // ---------------------------------------------------------------------------
  // 3. Error: Validación de campos obligatorios en formularios
  // ---------------------------------------------------------------------------
  static Future<void> playError() async {
    await _instance._play('sounds/error.mp3', 2);
  }

  // ---------------------------------------------------------------------------
  // 4. Negociación: Completar una negociación (en chat o pantalla de negociación)
  // ---------------------------------------------------------------------------
  static Future<void> playNegotiation() async {
    suppressNextButtonClick();
    await _instance._play('sounds/negociacion.mp3', 3);
  }

  // ---------------------------------------------------------------------------
  // 5. Notificación externa: Barra del teléfono (cuando no está dentro de la app)
  // ---------------------------------------------------------------------------
  static Future<void> playAppNotification() async {
    await _instance._play('sounds/notificacion_app.mp3', 4);
  }

  // ---------------------------------------------------------------------------
  // 6. Notificación interna: Al recibir notificación mientras navega en la app
  // ---------------------------------------------------------------------------
  static Future<void> playInAppNotification() async {
    await _instance._play('sounds/notificacion_interna.mp3', 5);
  }

  // ---------------------------------------------------------------------------
  // 7. Botones: Al tocar un botón o acción interactiva general
  // ---------------------------------------------------------------------------
  static Future<void> playButtonClick() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    // Si está suprimido (por envío de mensaje o negociación) o si se pulsó hace menos de 90ms, ignorar
    if (_suppressButtonClick || (now - _lastButtonClickMs < 90)) {
      return;
    }
    _lastButtonClickMs = now;
    await _instance._play('sounds/boton_click.mp3', 6);
  }

  // ---------------------------------------------------------------------------
  // 8. Tarea Completada: Al reclamar una tarea pendiente
  // ---------------------------------------------------------------------------
  static Future<void> playTaskCompleted() async {
    suppressNextButtonClick();
    await _instance._play('sounds/tarea_completada.mp3', 7);
  }

  /// Limpia los reproductores al cerrar la app
  void dispose() {
    try {
      _btnPlayer?.dispose();
      _favPlayer?.dispose();
      _chatPlayer?.dispose();
      _errorPlayer?.dispose();
      _negPlayer?.dispose();
      _notifAppPlayer?.dispose();
      _notifInAppPlayer?.dispose();
      _taskCompletedPlayer?.dispose();
    } catch (_) {}
  }
}

/// Factory de splash de Material que emite el sonido interactivo de botón
/// en cualquier widget interactivo (ElevatedButton, IconButton, InkWell, etc.)
class SoundFeedbackSplashFactory extends InteractiveInkFeatureFactory {
  final InteractiveInkFeatureFactory parentFactory;

  const SoundFeedbackSplashFactory([this.parentFactory = InkRipple.splashFactory]);

  @override
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    SoundService.playButtonClick();
    return parentFactory.create(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      textDirection: textDirection,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      borderRadius: borderRadius,
      customBorder: customBorder,
      radius: radius,
      onRemoved: onRemoved,
    );
  }
}
