/// Pure Dart domain model representing a report filed by a user against another user
/// (e.g., Buyer reporting Provider or Provider reporting Buyer).
///
/// Follows Backend Core Specialist guidelines: immutable, no UI dependencies,
/// strict types, copyWith, and full JSON serialization.
class UserReport {
  final String id;
  final DateTime createdAt;

  // Reporter unique data
  final String reporterId;
  final String reporterName;
  final String reporterRole; // 'comprador' | 'proveedor' | 'admin'
  final String reporterAvatar;
  final String? reporterContact;

  // Reported user unique data
  final String reportedId;
  final String reportedName;
  final String reportedRole; // 'comprador' | 'proveedor'
  final String reportedAvatar;
  final String reportedLocation;

  // Report specifics
  final List<String> reasons;
  final String comment; // Mandatory, max 200 chars
  final String status; // 'pending', 'in_review', 'resolved', 'dismissed'
  final String? resolutionNotes;
  final DateTime? resolvedAt;

  const UserReport({
    required this.id,
    required this.createdAt,
    required this.reporterId,
    required this.reporterName,
    required this.reporterRole,
    required this.reporterAvatar,
    this.reporterContact,
    required this.reportedId,
    required this.reportedName,
    required this.reportedRole,
    required this.reportedAvatar,
    required this.reportedLocation,
    required this.reasons,
    required this.comment,
    this.status = 'pending',
    this.resolutionNotes,
    this.resolvedAt,
  });

  /// Validates domain invariants for this report.
  /// Returns null if valid, or an error description string if invalid.
  String? validate() {
    if (comment.trim().isEmpty) {
      return 'El comentario es obligatorio para generar un reporte.';
    }
    if (charactersLength > 200) {
      return 'El comentario no puede exceder los 200 caracteres.';
    }
    if (reasons.isEmpty) {
      return 'Debe seleccionar al menos un motivo del reporte.';
    }
    if (reporterId.trim().isEmpty || reportedId.trim().isEmpty) {
      return 'Los datos de identificación de los usuarios son obligatorios.';
    }
    return null;
  }

  bool get isValid => validate() == null;

  int get charactersLength => comment.runes.length;

  UserReport copyWith({
    String? id,
    DateTime? createdAt,
    String? reporterId,
    String? reporterName,
    String? reporterRole,
    String? reporterAvatar,
    String? reporterContact,
    String? reportedId,
    String? reportedName,
    String? reportedRole,
    String? reportedAvatar,
    String? reportedLocation,
    List<String>? reasons,
    String? comment,
    String? status,
    String? resolutionNotes,
    DateTime? resolvedAt,
  }) {
    return UserReport(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      reporterRole: reporterRole ?? this.reporterRole,
      reporterAvatar: reporterAvatar ?? this.reporterAvatar,
      reporterContact: reporterContact ?? this.reporterContact,
      reportedId: reportedId ?? this.reportedId,
      reportedName: reportedName ?? this.reportedName,
      reportedRole: reportedRole ?? this.reportedRole,
      reportedAvatar: reportedAvatar ?? this.reportedAvatar,
      reportedLocation: reportedLocation ?? this.reportedLocation,
      reasons: reasons ?? List<String>.from(this.reasons),
      comment: comment ?? this.comment,
      status: status ?? this.status,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reporterRole': reporterRole,
      'reporterAvatar': reporterAvatar,
      'reporterContact': reporterContact,
      'reportedId': reportedId,
      'reportedName': reportedName,
      'reportedRole': reportedRole,
      'reportedAvatar': reportedAvatar,
      'reportedLocation': reportedLocation,
      'reasons': reasons,
      'comment': comment,
      'status': status,
      'resolutionNotes': resolutionNotes,
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory UserReport.fromJson(Map<String, dynamic> json) {
    return UserReport(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reporterId: json['reporterId'] as String,
      reporterName: json['reporterName'] as String,
      reporterRole: json['reporterRole'] as String? ?? 'comprador',
      reporterAvatar: json['reporterAvatar'] as String? ?? '',
      reporterContact: json['reporterContact'] as String?,
      reportedId: json['reportedId'] as String,
      reportedName: json['reportedName'] as String,
      reportedRole: json['reportedRole'] as String? ?? 'proveedor',
      reportedAvatar: json['reportedAvatar'] as String? ?? '',
      reportedLocation: json['reportedLocation'] as String? ?? 'República Dominicana',
      reasons: (json['reasons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      comment: json['comment'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      resolutionNotes: json['resolutionNotes'] as String?,
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserReport &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserReport(id: $id, reporter: $reporterName, reported: $reportedName, status: $status)';
}
