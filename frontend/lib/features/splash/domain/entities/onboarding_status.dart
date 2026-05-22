/// Entidad que representa el estado del onboarding del usuario
class OnboardingStatus {
  /// Crea una instancia y prepara el estado inicial de `OnboardingStatus`.
  const OnboardingStatus({
    required this.hasCompletedOnboarding,
    required this.completedSteps,
    required this.currentStep,
    this.lastShownDate,
  });

  final bool hasCompletedOnboarding;
  final List<int> completedSteps;
  final int currentStep;
  final DateTime? lastShownDate;

  bool get isOnboardingInProgress =>
      !hasCompletedOnboarding && completedSteps.isNotEmpty;

  double get progress =>
      totalSteps > 0 ? completedSteps.length / totalSteps : 0.0;

  static const int totalSteps = 4;

  OnboardingStatus copyWith({
    bool? hasCompletedOnboarding,
    List<int>? completedSteps,
    int? currentStep,
    DateTime? lastShownDate,
  }) {
    return OnboardingStatus(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      completedSteps: completedSteps ?? this.completedSteps,
      currentStep: currentStep ?? this.currentStep,
      lastShownDate: lastShownDate ?? this.lastShownDate,
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'has_completed_onboarding': hasCompletedOnboarding,
        'completed_steps': completedSteps,
        'current_step': currentStep,
        'last_shown_date': lastShownDate?.toIso8601String(),
      };

  /// Crea una instancia y prepara el estado inicial de `OnboardingStatus`.
  factory OnboardingStatus.fromJson(Map<String, dynamic> json) {
    return OnboardingStatus(
      hasCompletedOnboarding:
          json['has_completed_onboarding'] as bool? ?? false,
      completedSteps: (json['completed_steps'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      currentStep: json['current_step'] as int? ?? 0,
      lastShownDate: json['last_shown_date'] != null
          ? DateTime.parse(json['last_shown_date'] as String)
          : null,
    );
  }
}
