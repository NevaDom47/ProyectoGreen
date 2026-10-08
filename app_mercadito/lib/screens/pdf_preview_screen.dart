import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../services/pdf_invoice_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/skeleton_loading.dart';

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
        loadingWidget: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  ShimmerBox(width: 140, height: 32, borderRadius: 8),
                  ShimmerBox(width: 80, height: 24, borderRadius: 8),
                ],
              ),
              const SizedBox(height: 24),
              const ShimmerBox(width: double.infinity, height: 18, borderRadius: 6),
              const SizedBox(height: 12),
              const ShimmerBox(width: 200, height: 14, borderRadius: 6),
              const SizedBox(height: 28),
              const ShimmerBox(width: double.infinity, height: 160, borderRadius: 12),
              const SizedBox(height: 20),
              const ShimmerBox(width: double.infinity, height: 80, borderRadius: 12),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: const ShimmerBox(width: 160, height: 40, borderRadius: 8),
              ),
            ],
          ),
        ),
        pdfFileName: 'comprobante_${negotiation['invoice_id'] ?? 'factura'}.pdf',
      ),
    );
  }
}
