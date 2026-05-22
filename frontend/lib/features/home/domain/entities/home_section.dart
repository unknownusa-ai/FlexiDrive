/// Tipos de secciones disponibles en home
enum HomeSectionType {
  featured,
  popular,
  recent,
  recommended,
  categories,
  promotions,
}

/// Entidad que representa una sección de la página home
class HomeSection {
  /// Crea una instancia y prepara el estado inicial de `HomeSection`.
  const HomeSection({
    required this.id,
    required this.type,
    required this.title,
    required this.data,
    this.isVisible = true,
    this.displayOrder = 0,
    this.metadata,
  });

  final String id;
  final HomeSectionType type;
  final String title;
  final List<dynamic> data;
  final bool isVisible;
  final int displayOrder;
  final Map<String, dynamic>? metadata;

  HomeSection copyWith({
    String? id,
    HomeSectionType? type,
    String? title,
    List<dynamic>? data,
    bool? isVisible,
    int? displayOrder,
    Map<String, dynamic>? metadata,
  }) {
    return HomeSection(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      data: data ?? this.data,
      isVisible: isVisible ?? this.isVisible,
      displayOrder: displayOrder ?? this.displayOrder,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Serializa esta instancia a un mapa JSON compatible con persistencia.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'data': data,
        'is_visible': isVisible,
        'display_order': displayOrder,
        'metadata': metadata,
      };

  /// Crea una instancia y prepara el estado inicial de `HomeSection`.
  factory HomeSection.fromJson(Map<String, dynamic> json) {
    return HomeSection(
      id: json['id'] as String,
      type: HomeSectionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HomeSectionType.featured,
      ),
      title: json['title'] as String,
      data: json['data'] as List<dynamic>? ?? [],
      isVisible: json['is_visible'] as bool? ?? true,
      displayOrder: json['display_order'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
