/// Entidad que representa un paso del onboarding
class OnboardingStep {
  const OnboardingStep({
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.order,
    this.isCompleted = false,
  });

  final int id;
  final String title;
  final String description;
  final String imageAsset;
  final int order;
  final bool isCompleted;

  OnboardingStep copyWith({
    int? id,
    String? title,
    String? description,
    String? imageAsset,
    int? order,
    bool? isCompleted,
  }) {
    return OnboardingStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageAsset: imageAsset ?? this.imageAsset,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'image_asset': imageAsset,
        'order': order,
        'is_completed': isCompleted,
      };

  factory OnboardingStep.fromJson(Map<String, dynamic> json) {
    return OnboardingStep(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      imageAsset: json['image_asset'] as String,
      order: json['order'] as int,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }
}
