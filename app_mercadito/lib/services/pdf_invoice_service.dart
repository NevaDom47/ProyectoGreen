import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfInvoiceService {
  static Future<Uint8List> generateInvoice(Map<String, dynamic> negotiation) async {
    final ttf = await PdfGoogleFonts.plusJakartaSansRegular();
    final ttfBold = await PdfGoogleFonts.plusJakartaSansBold();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: ttf,
        bold: ttfBold,
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Mercadito',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#0C6648'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '¡TRATO HECHO CON ÉXITO!',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#0C6648'),
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'COMPROBANTE',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#333333'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        negotiation['invoice_id'] ?? '#FAC0001',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColor.fromHex('#666666'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 32),

              // Investment Summary
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F5F7F5'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INVERSIÓN FINAL ACORDADA',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#666666'),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      negotiation['total'] ?? '\$6,750.00',
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#0C6648'),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${negotiation['date'] ?? '12 de Octubre, 2023'} • ${negotiation['time'] ?? '10:45 AM'}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColor.fromHex('#666666'),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 32),

              // Details
              pw.Text(
                'Detalle del acuerdo mutuo',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#333333'),
                ),
              ),
              pw.SizedBox(height: 16),
              
              _buildDetailRow('Producto', negotiation['product'] ?? 'Tomates Cherry Orgánicos'),
              pw.SizedBox(height: 8),
              _buildDetailRow('Precio por kg', negotiation['price'] ?? '\$45.00 / kg'),
              pw.SizedBox(height: 8),
              _buildDetailRow('Volumen Total', negotiation['quantity'] ?? '150 kg'),
              pw.SizedBox(height: 8),
              _buildDetailRow(
                (negotiation['role'] ?? 'Comprador').toString().toUpperCase(), 
                (negotiation['buyer'] ?? 'Juan Pérez').split(' • ').first
              ),
              
              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColor.fromHex('#E0E0E0')),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Este documento es un comprobante generado automáticamente por Mercadito.',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColor.fromHex('#999999'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColor.fromHex('#666666'),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#333333'),
          ),
        ),
      ],
    );
  }
}
