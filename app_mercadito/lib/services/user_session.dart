class UserSession {
  /// The currently active role ('comprador' or 'proveedor').
  /// Initially null to simulate first-time login where no role is chosen yet.
  static String? selectedRole;

  // Buyer Onboarding Details
  static String? fullName;
  static String? email;
  static String? phone;
  static String? country;
  static String? state;
  static String? streetAddress;
  static String? profilePictureUrl;
  static bool isBuyerOnboarded = false;

  // Provider Onboarding Details
  static bool isProviderOnboarded = false;
  static String? specialty;
  static String? salesType;
  static String? businessDescription;
  static String? bannerPictureUrl;

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

    isProviderOnboarded = false;
    specialty = null;
    salesType = null;
    businessDescription = null;
    bannerPictureUrl = null;
  }
}
