import 'package:flutter/material.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.system);
final ValueNotifier<String> appLanguage = ValueNotifier('Spanish');

void main() {
  runApp(const AppMercadito());
}

class AppMercadito extends StatelessWidget {
  const AppMercadito({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, _) {
        return MaterialApp.router(
          title: 'El Mercadito',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode, // Switch between System/Light/Dark dynamically
          routerConfig: appRouter,
        );
      },
    );
  }
}
