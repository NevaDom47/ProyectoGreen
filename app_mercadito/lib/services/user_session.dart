import 'package:flutter/material.dart';

class DaySchedule {
  final String dayName;
  bool isActive;
  TimeOfDay openTime;
  TimeOfDay closeTime;

  DaySchedule({
    required this.dayName,
    this.isActive = true,
    this.openTime = const TimeOfDay(hour: 8, minute: 0),
    this.closeTime = const TimeOfDay(hour: 18, minute: 0),
  });

  DaySchedule copyWith({
    String? dayName,
    bool? isActive,
    TimeOfDay? openTime,
    TimeOfDay? closeTime,
  }) {
    return DaySchedule(
      dayName: dayName ?? this.dayName,
      isActive: isActive ?? this.isActive,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }

  String formatTime(BuildContext context, TimeOfDay time) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: false);
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final hourOfPeriod = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minuteStr = time.minute.toString().padLeft(2, '0');
    final periodStr = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hourOfPeriod:$minuteStr $periodStr';
  }

  String get formattedRange {
    if (!isActive) return 'Cerrado';
    return '${formatTimeOfDay(openTime)} - ${formatTimeOfDay(closeTime)}';
  }
}

class UserSession {
  /// The currently active role ('comprador' or 'proveedor').
  /// Initially null to simulate first-time login where no role is chosen yet.
  static String? selectedRole;

  /// Returns standard 8-digit formatted ID according to role:
  /// Provider: PROV-00000001
  /// Buyer: BUY-00000001
  static String get currentUserId {
    return selectedRole == 'proveedor' ? 'PROV-00000001' : 'BUY-00000001';
  }

  static String get formattedId => 'ID: #$currentUserId';

  /// Standard ID generator helper for any sequence number
  static String formatUserId(String role, int sequenceNumber) {
    final prefix = role.toLowerCase() == 'proveedor' ? 'PROV' : 'BUY';
    return '$prefix-${sequenceNumber.toString().padLeft(8, '0')}';
  }

  // Buyer Onboarding Details
  static String? fullName;
  static String? email;
  static String? phone;
  static String? country;
  static String? state;
  static String? streetAddress;
  static String? profilePictureUrl;
  static bool isBuyerOnboarded = false;
  static bool isEmailVerified = false;
  static bool? _isFirstTimeUserOverride;
  static bool get isFirstTimeUser => _isFirstTimeUserOverride ?? (selectedRole == null);
  static set isFirstTimeUser(bool value) => _isFirstTimeUserOverride = value;

  // Fecha de nacimiento y verificación de edad
  static DateTime? birthDate;
  static bool hasAdultConsent = false;

  static int get userAge {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  static bool get isAdult => userAge >= 18;

  // Tutorial / Guía interactiva
  static bool hasSeenNavTutorial = false;

  // Provider Onboarding Details
  static bool isProviderOnboarded = false;
  static String? specialty;
  static String? salesType;
  static String? businessDescription;
  static String? bannerPictureUrl;
  static DateTime? businessNameLastChangedDate;

  // Seller Policies
  static List<String>? sellerPolicies;
  static const List<String> defaultSellerPolicies = [
    'Muestra disponible para órdenes mayores a 5 toneladas.',
    'Negociación de precios habilitada para compras recurrentes.',
    'Garantía de calidad Mercadito (Reembolso parcial si la merma supera el 5%).',
  ];

  static List<String> get currentSellerPolicies =>
      (sellerPolicies != null && sellerPolicies!.isNotEmpty)
          ? List<String>.from(sellerPolicies!)
          : List<String>.from(defaultSellerPolicies);

  // Business Hours / Schedule
  static List<DaySchedule>? weeklySchedule;

  static List<DaySchedule> get defaultWeeklySchedule => [
    DaySchedule(dayName: 'Lunes', isActive: true, openTime: const TimeOfDay(hour: 8, minute: 0), closeTime: const TimeOfDay(hour: 18, minute: 0)),
    DaySchedule(dayName: 'Martes', isActive: true, openTime: const TimeOfDay(hour: 8, minute: 0), closeTime: const TimeOfDay(hour: 18, minute: 0)),
    DaySchedule(dayName: 'Miércoles', isActive: true, openTime: const TimeOfDay(hour: 8, minute: 0), closeTime: const TimeOfDay(hour: 18, minute: 0)),
    DaySchedule(dayName: 'Jueves', isActive: true, openTime: const TimeOfDay(hour: 8, minute: 0), closeTime: const TimeOfDay(hour: 18, minute: 0)),
    DaySchedule(dayName: 'Viernes', isActive: true, openTime: const TimeOfDay(hour: 8, minute: 0), closeTime: const TimeOfDay(hour: 18, minute: 0)),
    DaySchedule(dayName: 'Sábado', isActive: true, openTime: const TimeOfDay(hour: 8, minute: 0), closeTime: const TimeOfDay(hour: 18, minute: 0)),
    DaySchedule(dayName: 'Domingo', isActive: false, openTime: const TimeOfDay(hour: 8, minute: 0), closeTime: const TimeOfDay(hour: 18, minute: 0)),
  ];

  static List<DaySchedule> get currentWeeklySchedule {
    if (weeklySchedule != null && weeklySchedule!.isNotEmpty) {
      return weeklySchedule!.map((d) => d.copyWith()).toList();
    }
    return defaultWeeklySchedule;
  }

  static void saveWeeklySchedule(List<DaySchedule> schedule) {
    weeklySchedule = schedule.map((d) => d.copyWith()).toList();

    // Sync legacy string fields for compatibility across screens
    final monday = schedule.firstWhere((d) => d.dayName == 'Lunes', orElse: () => schedule.first);
    weekdaySchedule = monday.formattedRange;

    final saturday = schedule.firstWhere((d) => d.dayName == 'Sábado', orElse: () => DaySchedule(dayName: 'Sábado', isActive: false));
    isSaturdayClosed = !saturday.isActive;
    saturdaySchedule = saturday.formattedRange;

    final sunday = schedule.firstWhere((d) => d.dayName == 'Domingo', orElse: () => DaySchedule(dayName: 'Domingo', isActive: false));
    isSundayClosed = !sunday.isActive;
    sundaySchedule = sunday.formattedRange;
  }

  static String weekdaySchedule = '8:00 AM - 6:00 PM';
  static String saturdaySchedule = '8:00 AM - 6:00 PM';
  static String sundaySchedule = 'Cerrado';
  static bool isSundayClosed = true;
  static bool isSaturdayClosed = false;

  // Business Verification Details (Formal verification for merchants: DGII, RNC, documents)
  static String verificationStatus = 'not_submitted'; // 'not_submitted', 'pending', 'verified', 'rejected'
  static bool get isProviderVerified => verificationStatus == 'verified';
  static bool get isVerificationPending => verificationStatus == 'pending';
  static bool get isVerificationRejected => verificationStatus == 'rejected';

  static int verificationRejectionCount = 0;
  static DateTime? verificationLockoutUntil;

  static bool get isVerificationLockedOut {
    if (verificationLockoutUntil != null) {
      if (DateTime.now().isBefore(verificationLockoutUntil!)) {
        return true;
      }
    }
    return false;
  }

  static int get lockoutDaysRemaining {
    if (verificationLockoutUntil == null) return 0;
    final diff = verificationLockoutUntil!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 1;
  }

  static bool get canSubmitVerification {
    if (isProviderVerified) return false;
    if (isVerificationPending) return false;
    if (isVerificationLockedOut) return false;
    return true;
  }

  static String? verifiedCommercialName;
  static String? verifiedRncNumber;
  static String? verifiedDgiiStatus;
  static String? verifiedDocumentType;
  static String? verifiedDocumentFileName;
  static String? verifiedAddressProofFileName;
  static String? verifiedRepresentativeIdFileName;
  static String? verificationRejectionReason;
  static DateTime? verificationSubmittedDate;

  static void submitVerification({
    required String commercialName,
    required String rncNumber,
    required String dgiiStatus,
    required String documentType,
    required String documentFileName,
    required String addressProofFileName,
    required String representativeIdFileName,
  }) {
    if (!canSubmitVerification) return;

    verifiedCommercialName = commercialName;
    verifiedRncNumber = rncNumber;
    verifiedDgiiStatus = dgiiStatus;
    verifiedDocumentType = documentType;
    verifiedDocumentFileName = documentFileName;
    verifiedAddressProofFileName = addressProofFileName;
    verifiedRepresentativeIdFileName = representativeIdFileName;
    verificationRejectionReason = null;
    verificationSubmittedDate = DateTime.now();
    verificationStatus = 'pending';
  }

  static void approveVerification() {
    verificationStatus = 'verified';
    verifiedDgiiStatus = verifiedDgiiStatus ?? 'REGISTRADO Y ACTIVO';
    verifiedCommercialName = verifiedCommercialName ?? fullName ?? 'Agro Negocios Dominicanos';
    verifiedRncNumber = verifiedRncNumber ?? '1-32-45678-9';
    verificationRejectionCount = 0;
    verificationLockoutUntil = null;
  }

  static void rejectVerification(String reason) {
    verificationStatus = 'rejected';
    verificationRejectionReason = reason;
    verificationRejectionCount++;
    if (verificationRejectionCount >= 3) {
      verificationLockoutUntil = DateTime.now().add(const Duration(days: 30));
    }
  }

  static void resetVerification() {
    verificationStatus = 'not_submitted';
    verifiedCommercialName = null;
    verifiedRncNumber = null;
    verifiedDgiiStatus = null;
    verifiedDocumentType = null;
    verifiedDocumentFileName = null;
    verifiedAddressProofFileName = null;
    verifiedRepresentativeIdFileName = null;
    verificationRejectionReason = null;
    verificationSubmittedDate = null;
    verificationRejectionCount = 0;
    verificationLockoutUntil = null;
  }

  /// Helper to check if the user has completed their onboarding role selection.
  static bool get hasRole => selectedRole != null;

  /// Resets the role back to null (for testing/logout purposes).
  static void clear() {
    selectedRole = null;
    fullName = null;
    email = null;
    phone = null;
    country = null;
    state = null;
    streetAddress = null;
    profilePictureUrl = null;
    isBuyerOnboarded = false;
    isEmailVerified = false;
    _isFirstTimeUserOverride = null;
    birthDate = null;
    hasAdultConsent = false;

    isProviderOnboarded = false;
    specialty = null;
    salesType = null;
    businessDescription = null;
    bannerPictureUrl = null;
    businessNameLastChangedDate = null;

    sellerPolicies = null;
    weeklySchedule = null;
    weekdaySchedule = '8:00 AM - 6:00 PM';
    saturdaySchedule = '8:00 AM - 6:00 PM';
    sundaySchedule = 'Cerrado';
    isSundayClosed = true;
    isSaturdayClosed = false;

    resetVerification();
  }
}

