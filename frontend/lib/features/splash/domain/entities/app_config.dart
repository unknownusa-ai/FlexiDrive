/// Entidad que representa la configuración de la aplicación
class AppConfig {
  const AppConfig({
    required this.hasSeenOnboarding,
    required this.lastVersionOpened,
    required this.firstLaunchDate,
    this.hasAcceptedTerms = false,
    this.hasAcceptedPrivacyPolicy = false,
    this.preferredLanguage = 'es',
    this.themeMode = 'system',
  });

  final bool hasSeenOnboarding;
  final String lastVersionOpened;
  final DateTime firstLaunchDate;
  final bool hasAcceptedTerms;
  final bool hasAcceptedPrivacyPolicy;
  final String preferredLanguage;
  final String themeMode;

  bool get isFirstLaunch => !hasSeenOnboarding;

  AppConfig copyWith({
    bool? hasSeenOnboarding,
    String? lastVersionOpened,
    DateTime? firstLaunchDate,
    bool? hasAcceptedTerms,
    bool? hasAcceptedPrivacyPolicy,
    String? preferredLanguage,
    String? themeMode,
  }) {
    return AppConfig(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      lastVersionOpened: lastVersionOpened ?? this.lastVersionOpened,
      firstLaunchDate: firstLaunchDate ?? this.firstLaunchDate,
      hasAcceptedTerms: hasAcceptedTerms ?? this.hasAcceptedTerms,
      hasAcceptedPrivacyPolicy:
          hasAcceptedPrivacyPolicy ?? this.hasAcceptedPrivacyPolicy,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'has_seen_onboarding': hasSeenOnboarding,
        'last_version_opened': lastVersionOpened,
        'first_launch_date': firstLaunchDate.toIso8601String(),
        'has_accepted_terms': hasAcceptedTerms,
        'has_accepted_privacy_policy': hasAcceptedPrivacyPolicy,
        'preferred_language': preferredLanguage,
        'theme_mode': themeMode,
      };

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      hasSeenOnboarding: json['has_seen_onboarding'] as bool? ?? false,
      lastVersionOpened: json['last_version_opened'] as String? ?? '',
      firstLaunchDate: json['first_launch_date'] != null
          ? DateTime.parse(json['first_launch_date'] as String)
          : DateTime.now(),
      hasAcceptedTerms: json['has_accepted_terms'] as bool? ?? false,
      hasAcceptedPrivacyPolicy:
          json['has_accepted_privacy_policy'] as bool? ?? false,
      preferredLanguage: json['preferred_language'] as String? ?? 'es',
      themeMode: json['theme_mode'] as String? ?? 'system',
    );
  }
}
