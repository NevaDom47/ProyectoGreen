import 'package:flutter/foundation.dart';
import '../models/user_report.dart';

/// Service managing user reports (reporting providers and buyers).
/// Provides reactive state via [reportsNotifier], mock data initialization,
/// and methods to submit, filter, and moderate reports.
class ReportsService {
  ReportsService._internal() {
    _initializeMockReports();
  }

  static final ReportsService _instance = ReportsService._internal();
  static ReportsService get instance => _instance;

  /// Reactive state holding the list of all reports.
  final ValueNotifier<List<UserReport>> reportsNotifier = ValueNotifier<List<UserReport>>([]);

  List<UserReport> get allReports => List.unmodifiable(reportsNotifier.value);

  int get pendingCount => reportsNotifier.value.where((r) => r.status == 'pending').length;

  /// Default predefined reasons for reporting a Provider.
  static const List<String> providerReportReasons = [
    'Calidad inferior a la ofrecida en catálogo',
    'Entrega tardía o entrega incompleta',
    'Cobros indebidos o alteración de precio pactado',
    'Comportamiento o trato irrespetuoso',
    'Cancelación de negociación sin justificación',
    'Información engañosa en fotos o descripción',
    'Incumplimiento de políticas de devolución',
    'Otro motivo',
  ];

  /// Default predefined reasons for reporting a Buyer.
  static const List<String> buyerReportReasons = [
    'Falta de pago o retraso injustificado en transferencia',
    'Cancelación de pedido a último momento',
    'Rechazo arbitrario de producto en perfecto estado',
    'Comunicación irrespetuosa u ofensiva en el chat',
    'Intento de negociación fraudulenta fuera de la app',
    'Incumplimiento reiterado en horario de recepción',
    'Solicitudes abusivas fuera del acuerdo inicial',
    'Otro motivo',
  ];

  /// Returns whether a reporter already has an active (non-resolved, non-dismissed)
  /// report against a specific reported user.
  bool hasActiveReport(String reporterId, String reportedId) {
    return reportsNotifier.value.any((r) =>
        r.reporterId.trim() == reporterId.trim() &&
        r.reportedId.trim() == reportedId.trim() &&
        r.status != 'resolved' &&
        r.status != 'dismissed');
  }

  /// Finds the existing active report between two users, if any.
  UserReport? getActiveReport(String reporterId, String reportedId) {
    try {
      return reportsNotifier.value.firstWhere((r) =>
          r.reporterId.trim() == reporterId.trim() &&
          r.reportedId.trim() == reportedId.trim() &&
          r.status != 'resolved' &&
          r.status != 'dismissed');
    } catch (_) {
      return null;
    }
  }

  /// Submits a new user report.
  /// Throws [ArgumentError] if the report violates domain invariants.
  /// Throws [StateError] if there is already an unresolved report for this user pair.
  void submitReport(UserReport report) {
    final validationError = report.validate();
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    if (hasActiveReport(report.reporterId, report.reportedId)) {
      final active = getActiveReport(report.reporterId, report.reportedId);
      throw StateError('Ya existe un reporte activo (#${active?.id}) contra este usuario. No puedes enviar un nuevo reporte hasta que el caso sea resuelto.');
    }

    final updated = List<UserReport>.from(reportsNotifier.value);
    // Add to the front of the list
    updated.insert(0, report);
    reportsNotifier.value = updated;
  }

  /// Updates the moderation status of a report.
  bool updateReportStatus(String reportId, String newStatus, {String? resolutionNotes}) {
    final list = reportsNotifier.value;
    final index = list.indexWhere((r) => r.id == reportId);
    if (index == -1) return false;

    final current = list[index];
    final updatedReport = current.copyWith(
      status: newStatus,
      resolutionNotes: resolutionNotes ?? current.resolutionNotes,
      resolvedAt: (newStatus == 'resolved' || newStatus == 'dismissed')
          ? DateTime.now()
          : current.resolvedAt,
    );

    final newList = List<UserReport>.from(list);
    newList[index] = updatedReport;
    reportsNotifier.value = newList;
    return true;
  }

  /// Deletes a report by its ID.
  bool deleteReport(String reportId) {
    final list = reportsNotifier.value;
    final initialLength = list.length;
    final filtered = list.where((r) => r.id != reportId).toList();
    if (filtered.length != initialLength) {
      reportsNotifier.value = filtered;
      return true;
    }
    return false;
  }

  /// Finds a single report by ID.
  UserReport? getReportById(String reportId) {
    try {
      return reportsNotifier.value.firstWhere((r) => r.id == reportId);
    } catch (_) {
      return null;
    }
  }

  /// Resets reports to original seed data (useful for testing).
  void resetToMockData() {
    _initializeMockReports();
  }

  void _initializeMockReports() {
    reportsNotifier.value = [
      UserReport(
        id: 'REP-2026-081',
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
        reporterId: 'BUY-88291',
        reporterName: 'Restaurante El Criollo',
        reporterRole: 'comprador',
        reporterAvatar: 'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=150',
        reporterContact: '+1 809-555-0192',
        reportedId: 'PROV-1024',
        reportedName: 'Don Pedro H. (AgroTecomán)',
        reportedRole: 'proveedor',
        reportedAvatar: 'assets/images/Foto Sin perfil Proveedor.png',
        reportedLocation: 'Tecomán, Colima',
        reasons: [
          'Calidad inferior a la ofrecida en catálogo',
          'Cancelación de negociación sin justificación',
        ],
        comment: 'El lote de papa blanca llegó con más del 25% de merma podrida. Rechazaron la reposición acordada en la negociación formal.',
        status: 'pending',
      ),
      UserReport(
        id: 'REP-2026-079',
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
        reporterId: 'PROV-3310',
        reporterName: 'Finca Hermanos Ruiz',
        reporterRole: 'proveedor',
        reporterAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
        reporterContact: '+1 809-555-4488',
        reportedId: 'BUY-44912',
        reportedName: 'Supermercado Central',
        reportedRole: 'comprador',
        reportedAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        reportedLocation: 'Santo Domingo Este, RD',
        reasons: [
          'Cancelación de pedido a último momento',
          'Incumplimiento reiterado en horario de recepción',
        ],
        comment: 'El camión con 50 sacos de cebolla esperó 5 horas en su andén y cancelaron la orden unilateralmente sin pagar el flete acordado.',
        status: 'in_review',
        resolutionNotes: 'Equipo de soporte contactó al comprador para mediar el reembolso del flete.',
      ),
      UserReport(
        id: 'REP-2026-065',
        createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        reporterId: 'BUY-11003',
        reporterName: 'AgroComercial Bella Vista',
        reporterRole: 'comprador',
        reporterAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        reporterContact: '+1 829-555-7733',
        reportedId: 'PROV-5099',
        reportedName: 'Invernaderos del Sur',
        reportedRole: 'proveedor',
        reportedAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        reportedLocation: 'San Juan de la Maguana',
        reasons: [
          'Cobros indebidos o alteración de precio pactado',
        ],
        comment: 'Cobró un recargo del 15% adicional al momento del despacho que no estaba estipulado en la orden confirmada.',
        status: 'resolved',
        resolutionNotes: 'El proveedor emitió nota de crédito y ajustó el cobro indebido satisfactoriamente.',
        resolvedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      UserReport(
        id: 'REP-2026-052',
        createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 8)),
        reporterId: 'PROV-8812',
        reporterName: 'Cooperativa Agrícola del Cibao',
        reporterRole: 'proveedor',
        reporterAvatar: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
        reporterContact: '+1 849-555-9012',
        reportedId: 'BUY-77218',
        reportedName: 'Bodega La Esperanza',
        reportedRole: 'comprador',
        reportedAvatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
        reportedLocation: 'Santiago de los Caballeros',
        reasons: [
          'Comunicación irrespetuosa u ofensiva en el chat',
          'Intento de negociación fraudulenta fuera de la app',
        ],
        comment: 'Comprador insistió en realizar pago mediante cheque sin fondos fuera de la plataforma y utilizó lenguaje ofensivo en el chat.',
        status: 'dismissed',
        resolutionNotes: 'El usuario fue amonestado por violar los términos de servicio; reporte archivado con apercibimiento.',
        resolvedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      UserReport(
        id: 'REP-2026-041',
        createdAt: DateTime(2026, 3, 28, 14, 30),
        reporterId: 'PROV-1024',
        reporterName: 'Don Pedro H.',
        reporterRole: 'proveedor',
        reporterAvatar: '',
        reportedId: 'BUY-19402',
        reportedName: 'Carlos Rodríguez',
        reportedRole: 'comprador',
        reportedAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBjICzybPKvS5Xqs5EgqqAa5omMklKIYUcyKDaRL_07LUHApmJPULuU_BJ1BSfuxjDNuOJN4_BUJ78BS5ynmTkM1oYFgbZ6NpSZmRSNZ8eBgQybBhxe1cfxRN2suyyZ71WQq-Oodoe2-TigzReePlYj8obUTsbIptPvEXrgcyCW0lwCNDwVDjN3iDhSNbGWZ2ogRZYyPAvoOhZG-PRqCeIecaAhdGT_irbaIDi_hGq2eLMhZurCKAf8wh4KNUDW7KrBSGkxU582zB4',
        reportedLocation: 'Cuauhtémoc, CDMX',
        reasons: ['Falta de pago o retraso injustificado en transferencia'],
        comment: 'El comprador no realizó el pago acordado tras la entrega del pedido de jitomates en almacén.',
        status: 'in_review',
        resolutionNotes: 'Caso en proceso de mediación bancaria con el comprador.',
      ),
      UserReport(
        id: 'REP-2026-039',
        createdAt: DateTime(2026, 3, 29, 9, 15),
        reporterId: 'PROV-3310',
        reporterName: 'Finca Hermanos Ruiz',
        reporterRole: 'proveedor',
        reporterAvatar: '',
        reportedId: 'BUY-33910',
        reportedName: 'Ana María López',
        reportedRole: 'comprador',
        reportedAvatar: '',
        reportedLocation: 'Zapopan, Jal.',
        reasons: ['Cancelación de pedido a último momento'],
        comment: 'Canceló la orden de 30 cajas de aguacate cuando el flete ya estaba en camino.',
        status: 'pending',
      ),
      UserReport(
        id: 'REP-2026-030',
        createdAt: DateTime(2026, 4, 1, 8, 45),
        reporterId: 'BUY-88291',
        reporterName: 'Juan Pérez',
        reporterRole: 'comprador',
        reporterAvatar: '',
        reportedId: 'BOT-9999',
        reportedName: 'Spam Bot 2024',
        reportedRole: 'proveedor',
        reportedAvatar: '',
        reportedLocation: 'Red Global',
        reasons: ['Intento de negociación fraudulenta fuera de la app'],
        comment: 'Envía enlaces sospechosos de phishing en el chat privado repetidamente.',
        status: 'resolved',
        resolutionNotes: 'Cuenta de bot suspendida y bloqueada por el sistema de seguridad.',
        resolvedAt: DateTime(2026, 4, 1, 10, 0),
      ),
      UserReport(
        id: 'REP-2026-025',
        createdAt: DateTime(2026, 4, 1, 11, 20),
        reporterId: 'PROV-5099',
        reporterName: 'Invernaderos del Sur',
        reporterRole: 'proveedor',
        reporterAvatar: '',
        reportedId: 'BUY-88291',
        reportedName: 'Juan Pérez',
        reportedRole: 'comprador',
        reportedAvatar: '',
        reportedLocation: 'Cuauhtémoc, CDMX',
        reasons: ['Incumplimiento reiterado en horario de recepción'],
        comment: 'No se encontraba en el almacén durante la ventana de entrega acordada de 8:00 a 11:00 AM.',
        status: 'in_review',
        resolutionNotes: 'Notificación enviada al comprador para coordinar nueva entrega.',
      ),
    ];
  }
}
