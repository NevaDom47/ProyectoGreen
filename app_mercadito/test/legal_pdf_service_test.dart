import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/services/legal_pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LegalPdfService Tests', () {
    test('getTermsPdf returns exact original PDF bytes matching %PDF header and size', () async {
      final Uint8List bytes = await LegalPdfService.getTermsPdf();
      expect(bytes.isNotEmpty, isTrue);
      // Valid PDF headers start with %PDF (0x25, 0x50, 0x44, 0x46)
      expect(bytes[0], equals(0x25));
      expect(bytes[1], equals(0x50));
      expect(bytes[2], equals(0x44));
      expect(bytes[3], equals(0x46));
      expect(bytes.length, equals(281541));
    });

    test('getPrivacyPdf returns exact original PDF bytes matching %PDF header and size', () async {
      final Uint8List bytes = await LegalPdfService.getPrivacyPdf();
      expect(bytes.isNotEmpty, isTrue);
      expect(bytes[0], equals(0x25));
      expect(bytes[1], equals(0x50));
      expect(bytes[2], equals(0x44));
      expect(bytes[3], equals(0x46));
      expect(bytes.length, equals(260732));
    });

    test('Multiple calls return fresh clones to prevent ArrayBuffer detachment', () async {
      final Uint8List call1 = await LegalPdfService.getTermsPdf();
      final Uint8List call2 = await LegalPdfService.getTermsPdf();
      expect(identical(call1, call2), isFalse);
      expect(call1.length, equals(call2.length));
    });
  });
}
