import 'package:flutter_test/flutter_test.dart';
import 'package:app_mercadito/services/pdf_invoice_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PdfInvoiceService Tests', () {
    test('generateInvoice creates valid PDF document for sample negotiation matching the new design', () async {
      final mockNegotiation = {
        'invoice_id': '0001-00001234',
        'provider_name': 'MANUEL ENRIQUEZ GUITIERRES',
        'provider_id': '#PROV-000000001',
        'provider_phone': '829-942-1923',
        'provider_province': 'CONSTANZA',
        'provider_address': 'CALLE SALOME UREÑA NO.13',
        'buyer_name': 'Estela Domínguez',
        'buyer_id': '#BUY-8899665512',
        'buyer_province': 'San Pedro Macoris',
        'payment_method': 'Transferencia bancaria',
        'date': '06/10/2026',
        'time': '10:33 AM',
        'total': '\$6,750.00',
        'subtotal': '\$4000',
        'discount': '\$1000',
        'observation': 'Se aplica un descuento por ser "Cliente frecuente".',
        'items': [
          {
            'name': 'Vegetal - TOMATE CHERRY',
            'quality': '1RA',
            'volume': '1KG',
            'price': '\$1000',
            'total': '\$1000',
          },
          {
            'name': 'Fruta - LIMON',
            'quality': '2DA',
            'volume': '1LB',
            'price': '\$1000',
            'total': '\$1000',
          },
          {
            'name': 'Vegetal - PEPINO',
            'quality': '3RA',
            'volume': '1KG',
            'price': '\$1000',
            'total': '\$1000',
          },
          {
            'name': 'Fruta - FRESA',
            'quality': '1RA',
            'volume': '1LB',
            'price': '\$1000',
            'total': '\$1000',
          },
        ],
      };

      final pdfBytes = await PdfInvoiceService.generateInvoice(mockNegotiation);
      expect(pdfBytes, isNotEmpty);
      // Valid PDF documents start with '%PDF-'
      final header = String.fromCharCodes(pdfBytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });

    test('generateInvoice handles empty negotiation map gracefully with default values', () async {
      final pdfBytes = await PdfInvoiceService.generateInvoice({});
      expect(pdfBytes, isNotEmpty);
      final header = String.fromCharCodes(pdfBytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });
  });
}
