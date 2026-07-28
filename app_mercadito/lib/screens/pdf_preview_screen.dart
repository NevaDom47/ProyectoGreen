import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../services/pdf_invoice_service.dart';
import 'package:google_fonts/google_fonts.dart';

class PdfPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> negotiation;

  const PdfPreviewScreen({super.key, required this.negotiation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Previsualizar Comprobante',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF0C6648),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PdfPreview(
        build: (format) => PdfInvoiceService.generateInvoice(negotiation),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: Color(0xFF0C6648)),
        ),
        pdfFileName: 'comprobante_${negotiation['invoice_id'] ?? 'factura'}.pdf',
      ),
    );
  }
}
