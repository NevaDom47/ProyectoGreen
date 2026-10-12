import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import '../data/privacy_pdf_data.dart';
import '../data/terms_pdf_data.dart';

class LegalPdfService {
  static Uint8List? _termsCache;
  static Uint8List? _privacyCache;

  /// Obtiene los bytes EXACTOS y originales del documento PDF de Términos y Condiciones.
  /// Sin ningún resumen ni modificación: el documento oficial 100% íntegro.
  static Future<Uint8List> getTermsPdf() async {
    if (_termsCache != null) {
      return Uint8List.fromList(_termsCache!);
    }

    for (final path in [
      'assets/documents/Terminos_y_Condiciones_Mercadito.pdf',
      'assets/images/pdf/Terminos_y_Condiciones_Mercadito.pdf',
    ]) {
      try {
        final byteData = await rootBundle.load(path);
        if (byteData.lengthInBytes > 0) {
          _termsCache = Uint8List.fromList(
            byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
          );
          return Uint8List.fromList(_termsCache!);
        }
      } catch (_) {}
    }

    // Si la sesión de depuración web aún no ha indexado los assets en memoria,
    // provee los bytes binarios idénticos del PDF original sin resumir.
    _termsCache = originalTermsPdfBytes;
    return Uint8List.fromList(_termsCache!);
  }

  /// Obtiene los bytes EXACTOS y originales del documento PDF de Política de Privacidad.
  /// Sin ningún resumen ni modificación: el documento oficial 100% íntegro.
  static Future<Uint8List> getPrivacyPdf() async {
    if (_privacyCache != null) {
      return Uint8List.fromList(_privacyCache!);
    }

    for (final path in [
      'assets/documents/Politica_de_Privacidad_Mercadito.pdf',
      'assets/images/pdf/Politica_de_Privacidad_Mercadito.pdf',
    ]) {
      try {
        final byteData = await rootBundle.load(path);
        if (byteData.lengthInBytes > 0) {
          _privacyCache = Uint8List.fromList(
            byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
          );
          return Uint8List.fromList(_privacyCache!);
        }
      } catch (_) {}
    }

    // Si la sesión de depuración web aún no ha indexado los assets en memoria,
    // provee los bytes binarios idénticos del PDF original sin resumir.
    _privacyCache = originalPrivacyPdfBytes;
    return Uint8List.fromList(_privacyCache!);
  }
}
