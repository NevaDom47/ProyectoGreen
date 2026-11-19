import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/home_feed_screen.dart';
import 'package:app_mercadito/services/user_session.dart';
import 'package:app_mercadito/theme/app_theme.dart';
import 'package:app_mercadito/data/global_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Buyer Drawer Menu Options Tests', () {
    setUp(() {
      UserSession.clear();
      stopGlobalFlashTimer();
    });

    tearDown(() {
      stopGlobalFlashTimer();
    });

    testWidgets('Drawer displays exactly the 9 options defined for Rol de Comprador', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        stopGlobalFlashTimer();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      UserSession.selectedRole = 'comprador';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeFeedScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();

      // Open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold).first);
      scaffoldState.openDrawer();
      await tester.pump(const Duration(milliseconds: 350));

      // 1. Tareas
      expect(find.text('Tareas'), findsOneWidget);
      // 2. Reseñas
      expect(find.text('Reseñas'), findsOneWidget);
      // 3. Cupones
      expect(find.text('Cupones'), findsOneWidget);
      // 4. Productos Favoritos
      expect(find.text('Productos Favoritos'), findsOneWidget);
      // 5. Proveedores Favoritos
      expect(find.text('Proveedores Favoritos'), findsOneWidget);
      // 6. Mapa de Proveedores
      expect(find.text('Mapa de Proveedores'), findsOneWidget);
      // 7. Configuración
      expect(find.text('Configuración'), findsOneWidget);
      // 8. Políticas legales
      expect(find.text('Políticas legales'), findsOneWidget);
      // 9. Ayuda
      expect(find.text('Ayuda'), findsOneWidget);
      // Cerrar sesión
      expect(find.text('Cerrar sesión'), findsOneWidget);

      // Verificación de que NO se muestran opciones exclusivas de Proveedor
      expect(find.text('Negociaciones'), findsNothing);
      expect(find.text('Compradores'), findsNothing);
      expect(find.text('Gestión de Cupones'), findsNothing);
      expect(find.text('Gestor de Ofertas'), findsNothing);
      expect(find.text('Gestion Producto'), findsNothing);
      expect(find.text('Dashboard'), findsNothing);
      expect(find.text('Reportes'), findsNothing);
    });

    testWidgets('Drawer displays provider options when role is proveedor', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        stopGlobalFlashTimer();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      UserSession.selectedRole = 'proveedor';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeFeedScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();

      // Open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold).first);
      scaffoldState.openDrawer();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Negociaciones'), findsOneWidget);
      expect(find.text('Compradores'), findsOneWidget);
      expect(find.text('Gestión de Cupones'), findsOneWidget);
      expect(find.text('Gestor de Ofertas'), findsOneWidget);
      expect(find.text('Gestion Producto'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Reportes'), findsOneWidget);
    });
  });
}
