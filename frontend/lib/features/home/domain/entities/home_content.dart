import 'home_section.dart';

/// Entidad que representa el contenido completo de la página home
class HomeContent {
  const HomeContent({
    required this.sections,
    required this.lastUpdated,
    this.userGreeting,
    this.hasNewNotifications = false,
  });

  final List<HomeSection> sections;
  final DateTime lastUpdated;
  final String? userGreeting;
  final bool hasNewNotifications;

  HomeSection? get featuredSection =>
      sections.where((s) => s.type == HomeSectionType.featured).firstOrNull;

  List<HomeSection> get visibleSections =>
      sections.where((s) => s.isVisible).toList();

  HomeContent copyWith({
    List<HomeSection>? sections,
    DateTime? lastUpdated,
    String? userGreeting,
    bool? hasNewNotifications,
  }) {
    return HomeContent(
      sections: sections ?? this.sections,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      userGreeting: userGreeting ?? this.userGreeting,
      hasNewNotifications: hasNewNotifications ?? this.hasNewNotifications,
    );
  }

  Map<String, dynamic> toJson() => {
        'sections': sections.map((s) => s.toJson()).toList(),
        'last_updated': lastUpdated.toIso8601String(),
        'user_greeting': userGreeting,
        'has_new_notifications': hasNewNotifications,
      };

  factory HomeContent.fromJson(Map<String, dynamic> json) {
    return HomeContent(
      sections: (json['sections'] as List<dynamic>)
          .map((e) => HomeSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      userGreeting: json['user_greeting'] as String?,
      hasNewNotifications: json['has_new_notifications'] as bool? ?? false,
    );
  }
}
