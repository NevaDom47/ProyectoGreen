import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/widgets/animated_error_field.dart';
import 'package:app_mercadito/widgets/bouncing_button.dart';
import 'package:app_mercadito/widgets/skeleton_loading.dart';
import 'package:app_mercadito/screens/buyer_onboarding_screen.dart';
import 'package:app_mercadito/screens/provider_onboarding_screen.dart';

void main() {
  group('AnimatedErrorField Widget Tests', () {
    testWidgets('renders child without error border when errorText is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedErrorField(
              errorText: null,
              child: Container(
                key: const ValueKey('child_box'),
                height: 50,
                width: 200,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('child_box')), findsOneWidget);
      expect(find.text('Por favor ingresa tu nombre completo.'), findsNothing);
    });

    testWidgets('renders error text beneath child and applies red border when errorText is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: AnimatedErrorField(
              errorText: 'Por favor ingresa tu nombre completo.',
              child: const TextField(
                key: ValueKey('test_field'),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Por favor ingresa tu nombre completo.'), findsOneWidget);
      expect(find.byKey(const ValueKey('test_field')), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('Por favor ingresa tu nombre completo.'));
      expect(textWidget.style?.color, const Color(0xFFFF6B6B));
    });
  });

  group('BouncingButton Widget Tests', () {
    testWidgets('triggers onTap callback when pressed and performs micro-bounce', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BouncingButton(
                onTap: () {
                  tapped = true;
                },
                child: const Text('BOTÓN REBOTANTE'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('BOTÓN REBOTANTE'), findsOneWidget);
      await tester.tap(find.text('BOTÓN REBOTANTE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(tapped, isTrue);
    });
  });

  group('SkeletonScreenLoader & Skeletons Tests', () {
    testWidgets('renders skeleton view when isLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonScreenLoader(
              isLoading: true,
              skeleton: SkeletonProvidersView(),
              child: Text('Contenido Real'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(SkeletonProvidersView), findsOneWidget);
      expect(find.text('Contenido Real'), findsNothing);
    });

    testWidgets('renders child content when isLoading is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonScreenLoader(
              isLoading: false,
              skeleton: SkeletonProvidersView(),
              child: Text('Contenido Real'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Contenido Real'), findsOneWidget);
    });

    testWidgets('verifies individual specialized skeletons build cleanly', (tester) async {
      final skeletons = [
        const SkeletonCartView(),
        const SkeletonNotificationsView(),
        const SkeletonMarketView(),
        const SkeletonTasksView(),
        const SkeletonProfileView(),
        const SkeletonFormView(),
        const SkeletonHomeFeedView(),
      ];

      for (var skeleton in skeletons) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 700,
                width: 400,
                child: skeleton,
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.byWidget(skeleton), findsOneWidget);
      }
    });
  });

  group('Screen Error Shakes & Validation Integration Tests', () {
    testWidgets('BuyerOnboardingScreen shows inline red errors when empty on CONTINUE', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: BuyerOnboardingScreen(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('CONTINUAR'));
      await tester.tap(find.text('CONTINUAR'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor ingresa tu nombre completo.'), findsOneWidget);
      expect(find.text('Por favor ingresa tu número de teléfono.'), findsOneWidget);
    });

    testWidgets('ProviderOnboardingScreen shows inline red errors when empty on CONTINUAR', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ProviderOnboardingScreen(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('CONTINUAR'));
      await tester.tap(find.text('CONTINUAR'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor ingresa el nombre de tu negocio.'), findsOneWidget);
      expect(find.text('Por favor ingresa tu número de teléfono.'), findsOneWidget);
    });
  });
}
