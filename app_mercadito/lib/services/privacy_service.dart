import 'package:flutter/foundation.dart';

/// Configuración de privacidad para usuarios con rol de Comprador
class BuyerPrivacySettings {
  final bool showProfilePicture;
  final bool showName;
  final bool showLocation;
  final bool showPublicProfile;
  final bool showNegotiationHistory;
  final bool showLoyaltyLevel;
  final bool showShoppingPreferences;
  final bool allowProviderOffers;

  const BuyerPrivacySettings({
    this.showProfilePicture = true,
    this.showName = true,
    this.showLocation = true,
    this.showPublicProfile = true,
    this.showNegotiationHistory = true,
    this.showLoyaltyLevel = true,
    this.showShoppingPreferences = true,
    this.allowProviderOffers = true,
  });

  BuyerPrivacySettings copyWith({
    bool? showProfilePicture,
    bool? showName,
    bool? showLocation,
    bool? showPublicProfile,
    bool? showNegotiationHistory,
    bool? showLoyaltyLevel,
    bool? showShoppingPreferences,
    bool? allowProviderOffers,
  }) {
    return BuyerPrivacySettings(
      showProfilePicture: showProfilePicture ?? this.showProfilePicture,
      showName: showName ?? this.showName,
      showLocation: showLocation ?? this.showLocation,
      showPublicProfile: showPublicProfile ?? this.showPublicProfile,
      showNegotiationHistory: showNegotiationHistory ?? this.showNegotiationHistory,
      showLoyaltyLevel: showLoyaltyLevel ?? this.showLoyaltyLevel,
      showShoppingPreferences: showShoppingPreferences ?? this.showShoppingPreferences,
      allowProviderOffers: allowProviderOffers ?? this.allowProviderOffers,
    );
  }
}

/// Configuración de privacidad para usuarios con rol de Proveedor
class ProviderPrivacySettings {
  final bool showLocation;
  final bool showContactInfo;
  final bool showBusinessHours;
  final bool showOnlineStatus;
  final bool showLastSeen;

  const ProviderPrivacySettings({
    this.showLocation = true,
    this.showContactInfo = true,
    this.showBusinessHours = true,
    this.showOnlineStatus = true,
    this.showLastSeen = true,
  });

  ProviderPrivacySettings copyWith({
    bool? showLocation,
    bool? showContactInfo,
    bool? showBusinessHours,
    bool? showOnlineStatus,
    bool? showLastSeen,
  }) {
    return ProviderPrivacySettings(
      showLocation: showLocation ?? this.showLocation,
      showContactInfo: showContactInfo ?? this.showContactInfo,
      showBusinessHours: showBusinessHours ?? this.showBusinessHours,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      showLastSeen: showLastSeen ?? this.showLastSeen,
    );
  }
}

/// Servicio global para gestionar y consultar la privacidad según el rol del usuario
class PrivacyService {
  static final ValueNotifier<BuyerPrivacySettings> buyerNotifier =
      ValueNotifier<BuyerPrivacySettings>(const BuyerPrivacySettings());

  static final ValueNotifier<ProviderPrivacySettings> providerNotifier =
      ValueNotifier<ProviderPrivacySettings>(const ProviderPrivacySettings());

  static BuyerPrivacySettings get buyerSettings => buyerNotifier.value;
  static ProviderPrivacySettings get providerSettings => providerNotifier.value;

  static void saveBuyerSettings(BuyerPrivacySettings newSettings) {
    buyerNotifier.value = newSettings;
  }

  static void saveProviderSettings(ProviderPrivacySettings newSettings) {
    providerNotifier.value = newSettings;
  }

  static void resetToDefaults() {
    buyerNotifier.value = const BuyerPrivacySettings();
    providerNotifier.value = const ProviderPrivacySettings();
  }
}
