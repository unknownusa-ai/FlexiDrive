import 'onboarding_step.dart';

/// Entidad que representa todo el contenido del onboarding
class OnboardingContent {
  /// Crea una instancia y prepara el estado inicial de `OnboardingContent`.
  const OnboardingContent({
    required this.steps,
    required this.currentStepIndex,
    required this.isCompleted,
    this.wasSkipped = false,
  });

  final List<OnboardingStep> steps;
  final int currentStepIndex;
  final bool isCompleted;
  final bool wasSkipped;

  int get totalSteps => steps.length;
  int get completedSteps => steps.where((s) => s.isCompleted).length;
  double get progress => totalSteps > 0 ? completedSteps / totalSteps : 0.0;
  OnboardingStep? get currentStep =>
      currentStepIndex < steps.length ? steps[currentStepIndex] : null;
  bool get isLastStep => currentStepIndex >= totalSteps - 1;
  bool get isFirstStep => currentStepIndex == 0;

  OnboardingContent copyWith({
    List<OnboardingStep>? steps,
    int? currentStepIndex,
    bool? isCompleted,
    bool? wasSkipped,
  }) {
    return OnboardingContent(
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      wasSkipped: wasSkipped ?? this.wasSkipped,
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'steps': steps.map((s) => s.toJson()).toList(),
        'current_step_index': currentStepIndex,
        'is_completed': isCompleted,
        'was_skipped': wasSkipped,
      };

  /// Crea una instancia y prepara el estado inicial de `OnboardingContent`.
  factory OnboardingContent.fromJson(Map<String, dynamic> json) {
    return OnboardingContent(
      steps: (json['steps'] as List<dynamic>)
          .map((e) => OnboardingStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentStepIndex: json['current_step_index'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      wasSkipped: json['was_skipped'] as bool? ?? false,
    );
  }
}
