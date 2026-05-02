class QuickBooksSettings {
  final String accessToken;
  final String refreshToken;
  final String realmId; // Company ID
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final DateTime tokenExpiresAt;
  final bool isProduction;

  const QuickBooksSettings({
    required this.accessToken,
    required this.refreshToken,
    required this.realmId,
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    required this.tokenExpiresAt,
    this.isProduction = false,
  });

  bool get isTokenExpired => DateTime.now().isAfter(tokenExpiresAt);

  factory QuickBooksSettings.fromFirestore({
    required Map<String, dynamic> configData,
    required Map<String, dynamic> qbData,
  }) {
    final tokens = qbData['tokens'] as Map<String, dynamic>? ?? {};

    // Calculate expiry if not explicitly stored as a timestamp
    // If expires_in is 3600, and we don't know when it was issued, we might have to be conservative
    // However, usually we'd store a 'tokenExpiresAt' ourselves.
    // Looking at the screenshot, there's no 'tokenExpiresAt'.
    // I'll assume for now we use DateTime.now() if we're just loading,
    // but the service should ideally handle this.

    return QuickBooksSettings(
      accessToken: tokens['access_token'] as String? ?? '',
      refreshToken: tokens['refresh_token'] as String? ?? '',
      realmId: qbData['realmId'] as String? ?? '',
      clientId: configData['QB_clientId'] as String? ?? '',
      clientSecret: configData['QB_SKId'] as String? ?? '',
      redirectUri: configData['QUICKBOOKS_REDIRECT_URI'] as String? ?? '',
      // Default to expired if we don't have a stored expiry, to force a refresh
      tokenExpiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      isProduction: false, // Default to false, can be made dynamic if needed
    );
  }

  Map<String, dynamic> toTokenUpdateMap() {
    return {
      'tokens.access_token': accessToken,
      'tokens.refresh_token': refreshToken,
      'tokens.expires_in': 3600, // Standard QuickBooks expiry
      // We could add an internal field for tracking expiry if we want
    };
  }

  QuickBooksSettings copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    return QuickBooksSettings(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      realmId: realmId,
      clientId: clientId,
      clientSecret: clientSecret,
      redirectUri: redirectUri,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      isProduction: isProduction,
    );
  }
}
