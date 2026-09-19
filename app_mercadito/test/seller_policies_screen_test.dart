import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/screens/seller_policies_screen.dart';
import 'package:app_mercadito/services/user_session.dart';

void main() {
  setUp(() {
    UserSession.clear();
  });

  testWidgets('SellerPoliciesScreen enforces max 5 policies and max 80 characters limit', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      UserSession.clear();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: SellerPoliciesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial count (default has 3 policies)
    expect(find.text('Políticas Vigentes (3/5)'), findsOneWidget);

    // Add 4th policy with text
    final inputField = find.byType(TextField);
    await tester.enterText(inputField, 'Política número 4 con envío rápido');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Añadir a la lista'));
    await tester.pumpAndSettle();

    expect(find.text('Políticas Vigentes (4/5)'), findsOneWidget);

    // Try to enter more than 80 characters for 5th policy
    const longText = 'Esta es una politica extremadamente larga que tiene mucho mas de ochenta caracteres y debe ser truncada automaticamente por el limite de 80 caracteres';
    await tester.enterText(inputField, longText);
    await tester.pumpAndSettle();

    final TextField textFieldWidget = tester.widget(inputField);
    expect(textFieldWidget.maxLength, 80);

    await tester.tap(find.text('Añadir a la lista'));
    await tester.pumpAndSettle();

    // Now 5 policies are reached
    expect(find.text('Políticas Vigentes (5/5)'), findsOneWidget);
    expect(find.text('Máximo alcanzado'), findsOneWidget);
    expect(find.text('Límite de 5 políticas alcanzado'), findsWidgets);

    // Verify text field is now disabled
    final TextField disabledField = tester.widget(inputField);
    expect(disabledField.enabled, isFalse);

    // Save policies and verify UserSession has 5 policies
    await tester.tap(find.text('Guardar Políticas'));
    await tester.pumpAndSettle();

    expect(UserSession.sellerPolicies, isNotNull);
    expect(UserSession.sellerPolicies!.length, 5);
    expect(UserSession.sellerPolicies!.every((p) => p.length <= 80), isTrue);
  });
}
