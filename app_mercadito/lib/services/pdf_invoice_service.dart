import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfInvoiceService {
  static Future<Uint8List> generateInvoice(Map<String, dynamic> negotiation) async {
    // Fonts: Plus Jakarta Sans Regular & Bold
    final ttf = await PdfGoogleFonts.plusJakartaSansRegular();
    final ttfBold = await PdfGoogleFonts.plusJakartaSansBold();

    // Load assets safely (with graceful fallbacks for isolated test environments)
    String? logoSvg;
    try {
      logoSvg = await rootBundle.loadString('assets/images/logos/logo_horizontal_color.svg');
    } catch (_) {}

    pw.MemoryImage? decorTopRight;
    try {
      final bytesTop = await rootBundle.load('assets/images/pdf/decor_top_right.png');
      decorTopRight = pw.MemoryImage(bytesTop.buffer.asUint8List());
    } catch (_) {}

    pw.MemoryImage? decorBottomLeft;
    try {
      final bytesBottom = await rootBundle.load('assets/images/pdf/decor_bottom_left.png');
      decorBottomLeft = pw.MemoryImage(bytesBottom.buffer.asUint8List());
    } catch (_) {}

    // Extract dynamic data from negotiation map with robust defaults matching template
    final String invoiceIdRaw = negotiation['invoice_id'] ?? negotiation['invoiceNumber'] ?? '0001-00001234';
    final String invoiceNumber = invoiceIdRaw.startsWith('#FAC-')
        ? '0001-${invoiceIdRaw.replaceAll('#FAC-', '')}'
        : (invoiceIdRaw.startsWith('#') ? invoiceIdRaw.substring(1) : invoiceIdRaw);

    final String dateStr = negotiation['date'] ?? '06/10/2026';
    final String timeStr = negotiation['time'] ?? '10:33 AM';
    final String dateTimeLabel = negotiation['datetime_label'] ??
        (dateStr.contains('Oct') || dateStr.contains('202')
            ? '$dateStr - $timeStr'
            : 'Jueves 12 Octubre 2023 - $timeStr');

    final String totalAmount = negotiation['total'] ?? '\$ 6,750.00';

    // Provider details
    final String providerName = negotiation['provider_name'] ?? negotiation['supplier'] ?? 'MANUEL ENRIQUEZ GUITIERRES';
    final String providerId = negotiation['provider_id'] ?? '#PROV-000000001';
    final String providerPhone = negotiation['provider_phone'] ?? '829-942-1923';
    final String providerProvince = negotiation['provider_province'] ?? 'CONSTANZA';
    final String providerAddress = negotiation['provider_address'] ?? 'CALLE SALOME UREÑA NO.13';

    // Buyer details
    final String rawBuyer = (negotiation['buyer'] ?? negotiation['buyer_name'] ?? 'Estela Domínguez').toString();
    final String buyerName = rawBuyer.contains(' • ') ? rawBuyer.split(' • ').first : rawBuyer;
    final String buyerId = negotiation['buyer_id'] ?? '#BUY-8899665512';
    final String buyerProvince = negotiation['buyer_province'] ?? negotiation['province'] ?? 'San Pedro Macoris';
    final String paymentMethod = negotiation['payment_method'] ?? 'Transferencia bancaria';

    // Product rows
    final List<Map<String, dynamic>> items;
    if (negotiation['items'] is List && (negotiation['items'] as List).isNotEmpty) {
      items = (negotiation['items'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else {
      final product = negotiation['product'] ?? 'TOMATE CHERRY';
      final formattedProduct = product.toString().contains(' - ') ? product : 'Vegetal - $product';
      final quality = negotiation['quality'] ?? '1RA';
      final volume = negotiation['quantity'] ?? '1KG';
      final price = negotiation['price'] ?? '\$1000';
      final total = negotiation['item_total'] ?? price;

      items = [
        {
          'product': formattedProduct,
          'quality': quality,
          'volume': volume,
          'price': price,
          'total': total,
        },
        if (negotiation['include_sample_rows'] == true || negotiation['product'] == null) ...[
          {
            'product': 'Fruta - LIMON',
            'quality': '2DA',
            'volume': '1LB',
            'price': '\$1000',
            'total': '\$1000',
          },
          {
            'product': 'Vegetal - PEPINO',
            'quality': '3RA',
            'volume': '1KG',
            'price': '\$1000',
            'total': '\$1000',
          },
          {
            'product': 'Fruta - FRESA',
            'quality': '1RA',
            'volume': '1LB',
            'price': '\$1000',
            'total': '\$1000',
          },
        ],
      ];
    }

    final String observations = negotiation['notes'] ??
        negotiation['observations'] ??
        'Se aplica un descuento por ser "Cliente frecuente".';

    final String subtotalStr = negotiation['subtotal'] ?? negotiation['sub_total'] ?? '\$4000';
    final String discountStr = negotiation['discount'] ?? negotiation['descuentos'] ?? '\$1000';
    final String finalTotalStr = negotiation['total_neto'] ?? negotiation['final_total'] ?? (items.length > 1 ? '\$3800' : totalAmount);

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: ttf,
        bold: ttfBold,
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero, // Edge-to-edge for corner background decorations
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // 1. Top-Right Decorative Banner
              if (decorTopRight != null)
                pw.Positioned(
                  top: 0,
                  right: 0,
                  child: pw.Image(
                    decorTopRight,
                    width: 220,
                    fit: pw.BoxFit.contain,
                  ),
                ),

              // 2. Bottom-Left Decorative Banner
              if (decorBottomLeft != null)
                pw.Positioned(
                  bottom: 0,
                  left: 0,
                  child: pw.Image(
                    decorBottomLeft,
                    width: 220,
                    fit: pw.BoxFit.contain,
                  ),
                ),

              // 3. Document Body Content
              pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(38, 38, 38, 32),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ROW ---
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left: Logo & Provider Info
                        pw.Expanded(
                          flex: 6,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (logoSvg != null && logoSvg.isNotEmpty)
                                pw.SvgImage(
                                  svg: logoSvg,
                                  height: 38,
                                )
                              else
                                pw.Text(
                                  'Mercadito',
                                  style: pw.TextStyle(
                                    fontSize: 24,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromHex('#016142'),
                                  ),
                                ),
                              pw.SizedBox(height: 12),
                              _buildInfoLine('PROVEEDOR:', providerName.toUpperCase()),
                              _buildInfoLine('ID:', providerId.toUpperCase()),
                              _buildInfoLine('TELÉFONO:', providerPhone),
                              _buildInfoLine('PROVINCIA:', providerProvince.toUpperCase()),
                              _buildInfoLine('DIRECCION:', providerAddress.toUpperCase()),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        // Right: Title, Number & Date Pill
                        pw.Expanded(
                          flex: 4,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                'NEGOCIACIÓN',
                                style: pw.TextStyle(
                                  fontSize: 22,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#1C201D'),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              pw.SizedBox(height: 3),
                              pw.Text(
                                'N° : $invoiceNumber',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColor.fromHex('#333333'),
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 12),
                              pw.Text(
                                'FECHA:',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#555555'),
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                                decoration: pw.BoxDecoration(
                                  color: PdfColor.fromHex('#F4F6F4'),
                                  borderRadius: pw.BorderRadius.circular(6),
                                ),
                                child: pw.Text(
                                  dateStr,
                                  style: pw.TextStyle(
                                    fontSize: 13,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromHex('#222222'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 18),

                    // --- INVERSIÓN FINAL ACORDADA (HERO CARD) ---
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#F5F7F5'),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'INVERSION FINAL ACORDADA',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#666666'),
                              letterSpacing: 0.8,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            totalAmount,
                            style: pw.TextStyle(
                              fontSize: 27,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#016142'),
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            dateTimeLabel,
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              color: PdfColor.fromHex('#777777'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 10),

                    // --- COMPRADOR INFORMATION CARD ---
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#F5F7F5'),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              _buildBuyerField('Comprador:', buyerName),
                              _buildBuyerField('ID:', buyerId),
                            ],
                          ),
                          pw.SizedBox(height: 6),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              _buildBuyerField('Provincia:', buyerProvince),
                              _buildBuyerField('Forma de pago:', paymentMethod),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 14),

                    // --- PRODUCT TABLE ---
                    pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColor.fromHex('#333333'),
                        width: 0.8,
                      ),
                      columnWidths: const {
                        0: pw.FlexColumnWidth(3.8), // PRODUCTO
                        1: pw.FlexColumnWidth(1.4), // CALIDAD
                        2: pw.FlexColumnWidth(1.6), // VOLUMEN
                        3: pw.FlexColumnWidth(1.6), // PRECIO
                        4: pw.FlexColumnWidth(1.6), // TOTAL
                      },
                      children: [
                        // Header
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: PdfColors.white),
                          children: [
                            _buildTableCell('PRODUCTO', isHeader: true, align: pw.TextAlign.left),
                            _buildTableCell('CALIDAD', isHeader: true, align: pw.TextAlign.center),
                            _buildTableCell('VOLUMEN', isHeader: true, align: pw.TextAlign.center),
                            _buildTableCell('PRECIO', isHeader: true, align: pw.TextAlign.center),
                            _buildTableCell('TOTAL', isHeader: true, align: pw.TextAlign.center),
                          ],
                        ),
                        // Items
                        ...items.map((item) {
                          return pw.TableRow(
                            children: [
                              _buildTableCell(item['product'] ?? '', align: pw.TextAlign.left),
                              _buildTableCell(item['quality'] ?? '1RA', align: pw.TextAlign.center),
                              _buildTableCell(item['volume'] ?? '1KG', align: pw.TextAlign.center),
                              _buildTableCell(item['price'] ?? '', align: pw.TextAlign.center),
                              _buildTableCell(item['total'] ?? '', align: pw.TextAlign.center),
                            ],
                          );
                        }),
                      ],
                    ),

                    // --- OBSERVACIONES & TOTALES ROW ---
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left: Observaciones
                        pw.Expanded(
                          flex: 52,
                          child: pw.Container(
                            height: 68,
                            padding: const pw.EdgeInsets.all(7),
                            decoration: pw.BoxDecoration(
                              border: pw.Border(
                                left: pw.BorderSide(color: PdfColor.fromHex('#333333'), width: 0.8),
                                right: pw.BorderSide(color: PdfColor.fromHex('#333333'), width: 0.8),
                                bottom: pw.BorderSide(color: PdfColor.fromHex('#333333'), width: 0.8),
                              ),
                            ),
                            child: pw.RichText(
                              text: pw.TextSpan(
                                children: [
                                  pw.TextSpan(
                                    text: 'Observaciones: ',
                                    style: pw.TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColor.fromHex('#222222'),
                                    ),
                                  ),
                                  pw.TextSpan(
                                    text: observations,
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      color: PdfColor.fromHex('#444444'),
                                      lineSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Right: Subtotal, Descuentos & Total
                        pw.Expanded(
                          flex: 48,
                          child: pw.Column(
                            children: [
                              // SUB-TOTAL
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                                decoration: pw.BoxDecoration(
                                  border: pw.Border(
                                    right: pw.BorderSide(color: PdfColor.fromHex('#333333'), width: 0.8),
                                    bottom: pw.BorderSide(color: PdfColor.fromHex('#333333'), width: 0.8),
                                  ),
                                ),
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      'SUB- TOTAL:',
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#222222'),
                                      ),
                                    ),
                                    pw.Text(
                                      subtotalStr,
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        color: PdfColor.fromHex('#222222'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // DESCUENTOS
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                                decoration: pw.BoxDecoration(
                                  border: pw.Border(
                                    right: pw.BorderSide(color: PdfColor.fromHex('#333333'), width: 0.8),
                                    bottom: pw.BorderSide(color: PdfColor.fromHex('#333333'), width: 0.8),
                                  ),
                                ),
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      'DESCUENTOS:',
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#222222'),
                                      ),
                                    ),
                                    pw.Text(
                                      discountStr,
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        color: PdfColor.fromHex('#222222'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // TOTAL BANNER
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: pw.BoxDecoration(
                                  color: PdfColor.fromHex('#016142'),
                                  border: pw.Border.all(color: PdfColor.fromHex('#016142'), width: 0.8),
                                ),
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      'TOTAL:',
                                      style: pw.TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.white,
                                      ),
                                    ),
                                    pw.Text(
                                      finalTotalStr,
                                      style: pw.TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.Spacer(),

                    // --- FOOTER WEBSITE ---
                    pw.Align(
                      alignment: pw.Alignment.bottomRight,
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Text(
                          'www.diaztecnologies.es',
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColor.fromHex('#555555'),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildInfoLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2.2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label ',
              style: pw.TextStyle(
                fontSize: 7.8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#222222'),
              ),
            ),
            pw.TextSpan(
              text: value,
              style: pw.TextStyle(
                fontSize: 7.8,
                color: PdfColor.fromHex('#444444'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildBuyerField(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label ',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#222222'),
            ),
          ),
          pw.TextSpan(
            text: value,
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColor.fromHex('#333333'),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5.5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColor.fromHex('#222222'),
        ),
      ),
    );
  }
}
