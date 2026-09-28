import 'package:flutter/material.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

// Variables globales para compatibilidad en toda la aplicación
final ValueNotifier<ThemeMode> appThemeMode = ThemeController.themeMode;
final ValueNotifier<AppThemePreference> appThemePreference = ThemeController.preference;
final ValueNotifier<String> appLanguage = ValueNotifier('Spanish');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ThemeController.init();
  runApp(const AppMercadito());
}

class AppMercadito extends StatelessWidget {
  const AppMercadito({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, currentMode, _) {
        return MaterialApp.router(
          title: 'El Mercadito',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}
