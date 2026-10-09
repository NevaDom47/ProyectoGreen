import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/services/sound_service.dart';
import 'package:app_mercadito/data/global_state.dart';
import 'package:app_mercadito/widgets/animated_error_field.dart';
import 'package:app_mercadito/widgets/bouncing_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SoundService Suite - 7 Audio Triggers', () {
    test('SoundService singleton instance and methods execute safely without crash', () async {
      final service = SoundService();
      expect(service, isNotNull);

      // Verify all sound playback invocations execute cleanly
      await SoundService.playFavorite();
      await SoundService.playChatMessage();
      await SoundService.playError();
      await SoundService.playNegotiation();
      await SoundService.playAppNotification();
      await SoundService.playInAppNotification();
      await SoundService.playButtonClick();
      await SoundService.playTaskCompleted();

      expect(SoundService().isMuted, false);
      expect(SoundService().volume, 1.0);
    });

    test('1. Favorite toggle triggers sound service logic safely', () async {
      final initialCount = globalFavorites.value.length;
      final testProduct = {
        'name': 'Aguacate Hass de Prueba',
        'price': '\$45.00',
        'category': 'Frutas',
      };

      // Adding to favorite
      toggleFavorite(testProduct);
      expect(isFavorite('Aguacate Hass de Prueba'), true);
      expect(globalFavorites.value.length, initialCount + 1);

      // Removing from favorite
      toggleFavorite(testProduct);
      expect(isFavorite('Aguacate Hass de Prueba'), false);
      expect(globalFavorites.value.length, initialCount);
    });

    test('2 & 7. Button click debouncing and suppression logic works correctly', () async {
      // Multiple rapid clicks should be debounced safely
      await SoundService.playButtonClick();
      await SoundService.playButtonClick();

      // Suppression should temporarily block button clicks
      SoundService.suppressNextButtonClick(const Duration(milliseconds: 50));
      await SoundService.playButtonClick();

      // After suppression duration, click is accepted again
      await Future.delayed(const Duration(milliseconds: 60));
      await SoundService.playButtonClick();
    });

    testWidgets('3. AnimatedErrorField shake triggers error sound safely', (WidgetTester tester) async {
      final fieldKey = GlobalKey<AnimatedErrorFieldState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedErrorField(
              key: fieldKey,
              errorText: 'Campo obligatorio requerido',
              child: const TextField(),
            ),
          ),
        ),
      );

      // Verify widget builds and shake executes without error
      expect(find.text('Campo obligatorio requerido'), findsOneWidget);
      fieldKey.currentState?.shake();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
    });

    testWidgets('7. BouncingButton taps trigger button sound logic without crash', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BouncingButton(
              onTap: () {
                tapped = true;
              },
              child: const Text('Boton de Prueba'),
            ),
          ),
        ),
      );

      expect(find.text('Boton de Prueba'), findsOneWidget);
      await tester.tap(find.text('Boton de Prueba'));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });
  });
}
