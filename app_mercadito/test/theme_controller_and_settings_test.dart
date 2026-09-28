import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/theme/app_theme.dart';
import 'package:app_mercadito/theme/theme_controller.dart';
import 'package:app_mercadito/screens/settings_screen.dart';
import 'package:app_mercadito/services/notification_service.dart';

void main() {
  group('ThemeController tests', () {
    tearDown(() {
      ThemeController.setPreference(AppThemePreference.automatic);
    });

    test('isNightTime calculates correct night and day intervals', () {
      // 19:00 (7:00 PM) -> Night
      final nightStart = DateTime(2026, 9, 24, 19, 0);
      expect(ThemeController.isNightTime(nightStart), isTrue);

      // 23:30 (11:30 PM) -> Night
      final midnight = DateTime(2026, 9, 24, 23, 30);
      expect(ThemeController.isNightTime(midnight), isTrue);

      // 03:00 (3:00 AM) -> Night
      final earlyMorning = DateTime(2026, 9, 24, 3, 0);
      expect(ThemeController.isNightTime(earlyMorning), isTrue);

      // 05:59 (5:59 AM) -> Night
      final beforeDawn = DateTime(2026, 9, 24, 5, 59);
      expect(ThemeController.isNightTime(beforeDawn), isTrue);

      // 06:00 (6:00 AM) -> Day
      final dawn = DateTime(2026, 9, 24, 6, 0);
      expect(ThemeController.isNightTime(dawn), isFalse);

      // 12:00 (Noon) -> Day
      final noon = DateTime(2026, 9, 24, 12, 0);
      expect(ThemeController.isNightTime(noon), isFalse);

      // 18:59 (6:59 PM) -> Day
      final dusk = DateTime(2026, 9, 24, 18, 59);
      expect(ThemeController.isNightTime(dusk), isFalse);
    });

    test('ThemeController switches mode properly for Day and Night preferences', () {
      ThemeController.setPreference(AppThemePreference.day);
      expect(ThemeController.preference.value, AppThemePreference.day);
      expect(ThemeController.themeMode.value, ThemeMode.light);

      ThemeController.setPreference(AppThemePreference.night);
      expect(ThemeController.preference.value, AppThemePreference.night);
      expect(ThemeController.themeMode.value, ThemeMode.dark);
    });

    test('ThemeController automatic description includes local hour and status', () {
      final nightTime = DateTime(2026, 9, 24, 20, 45); // 8:45 PM
      final descNight = ThemeController.getAutomaticStatusDescription(nightTime);
      expect(descNight, contains('Noche activa'));
      expect(descNight, contains('8:45 PM'));

      final dayTime = DateTime(2026, 9, 24, 10, 15); // 10:15 AM
      final descDay = ThemeController.getAutomaticStatusDescription(dayTime);
      expect(descDay, contains('Día activo'));
      expect(descDay, contains('10:15 AM'));
    });
  });

  group('AppTheme token validation', () {
    test('Modo dia y noche.md color tokens match required specifications', () {
      expect(AppTheme.lightBackground, const Color(0xFFF7F9F8));
      expect(AppTheme.darkBackground, const Color(0xFF101815));

      expect(AppTheme.lightSecondaryBackground, const Color(0xFFEEF5F1));
      expect(AppTheme.darkSecondaryBackground, const Color(0xFF17221E));

      expect(AppTheme.lightCard, const Color(0xFFFFFFFF));
      expect(AppTheme.darkCard, const Color(0xFF1C2924));

      expect(AppTheme.lightCardElevated, const Color(0xFFFFFFFF));
      expect(AppTheme.darkCardElevated, const Color(0xFF22332C));

      expect(AppTheme.darkPrimary, const Color(0xFF67C83B));
      expect(AppTheme.darkPrimaryCta, const Color(0xFF2F7D59));
      expect(AppTheme.darkPrimaryLight, const Color(0xFF203D31));

      expect(AppTheme.darkTextPrimary, const Color(0xFFF1F5F3));
      expect(AppTheme.darkTextSecondary, const Color(0xFFAAB8B1));
      expect(AppTheme.darkTextTertiary, const Color(0xFF718078));

      expect(AppTheme.darkBorder, const Color(0xFF2B3A34));
      expect(AppTheme.darkInput, const Color(0xFF1C3028));
      expect(AppTheme.darkIcon, const Color(0xFFA7B8B0));

      expect(AppTheme.functionalSuccess, const Color(0xFF67C83B));
      expect(AppTheme.functionalOffer, const Color(0xFFF5A623));
      expect(AppTheme.functionalDiscount, const Color(0xFFFFB340));
      expect(AppTheme.functionalError, const Color(0xFFFF6B6B));
      expect(AppTheme.functionalInfo, const Color(0xFF58A6FF));
      expect(AppTheme.functionalFavorite, const Color(0xFFFF6B81));
    });
  });

  group('SettingsScreen theme selector UI', () {
    testWidgets('renders Dia, Noche, Automatico options and toggles preferences', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SettingsScreen(),
        ),
      );

      // Verify that the 3 options are shown
      expect(find.text('Día'), findsOneWidget);
      expect(find.text('Noche'), findsOneWidget);
      expect(find.text('Automático'), findsOneWidget);

      // Tap "Noche"
      await tester.tap(find.text('Noche'));
      await tester.pumpAndSettle();

      expect(ThemeController.preference.value, AppThemePreference.night);
      expect(ThemeController.themeMode.value, ThemeMode.dark);
      expect(find.text('Modo Noche fijado permanentemente'), findsNothing);

      // Tap "Día"
      await tester.tap(find.text('Día'));
      await tester.pumpAndSettle();

      expect(ThemeController.preference.value, AppThemePreference.day);
      expect(ThemeController.themeMode.value, ThemeMode.light);
      expect(find.text('Modo Día fijado permanentemente'), findsNothing);

      // Tap "Automático"
      await tester.tap(find.text('Automático'));
      await tester.pumpAndSettle();

      expect(ThemeController.preference.value, AppThemePreference.automatic);
      expect(find.text('Cambio automático según tu zona horaria'), findsNothing);
    });

    testWidgets('verifies day mode icons have #285E44 and circles have #DCE7E3', (tester) async {
      ThemeController.setPreference(AppThemePreference.day);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify circle containers have color #DCE7E3
      final circleFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final boxDec = widget.decoration as BoxDecoration;
          return boxDec.color == const Color(0xFFDCE7E3);
        }
        return false;
      });
      expect(circleFinder, findsWidgets);

      // Verify icons with color #285E44
      final iconFinder = find.byWidgetPredicate((widget) {
        if (widget is Icon) {
          return widget.color == const Color(0xFF285E44);
        }
        return false;
      });
      expect(iconFinder, findsWidgets);
    });

    testWidgets('hides Configuración de Alertas tile when notifications are deactivated', (tester) async {
      NotificationService().toggleNotificationsEnabled(true);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Configuración de Alertas'), findsOneWidget);

      // Disable notifications
      NotificationService().toggleNotificationsEnabled(false);
      await tester.pumpAndSettle();

      expect(find.text('Configuración de Alertas'), findsNothing);

      // Re-enable
      NotificationService().toggleNotificationsEnabled(true);
      await tester.pumpAndSettle();

      expect(find.text('Configuración de Alertas'), findsOneWidget);
    });
  });
}
