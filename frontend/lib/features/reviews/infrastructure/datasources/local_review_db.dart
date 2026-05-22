import 'dart:convert';

import 'package:flexidrive/core/api/api_client.dart';
import 'package:flexidrive/features/reviews/domain/entities/review_models.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Define la responsabilidad de `LocalReviewDb` dentro de este módulo.
class LocalReviewDb {
  /// Crea una instancia y prepara el estado inicial de `LocalReviewDb`.
  LocalReviewDb._();

  static final LocalReviewDb instance = LocalReviewDb._();
  static const _opinionsOverridesKey = 'reviews_opinions_overrides_v1';
  static const _reviewsOverridesKey = 'reviews_reviews_overrides_v1';
  static const _deletedReviewsKey = 'reviews_deleted_ids_v1';

  bool? _loaded = false;

  final List<OpinionModel> opinions = [];
  final List<ReviewModel> reviews = [];
  final List<OpinionModel> _overriddenOpinions = [];
  final List<ReviewModel> _overriddenReviews = [];
  final Set<int> _deletedReviewIds = <int>{};
  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  /// Carga los datos necesarios para cargar if needed.
  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    final remoteOpinions = _parseList(
      await _safeLoadList('opinions'),
      OpinionModel.fromJson,
    ).where(
      (opinion) =>
          opinion.description != null &&
          !opinion.description!.startsWith('Opinion de prueba'),
    );
    final remoteReviews = _parseList(
      await _safeLoadList('reviews'),
      ReviewModel.fromJson,
    );

    _overriddenOpinions
      ..clear()
      ..addAll(await _loadOpinionOverrides());
    _overriddenReviews
      ..clear()
      ..addAll(await _loadReviewOverrides());
    _deletedReviewIds
      ..clear()
      ..addAll(await _loadDeletedReviewIds());

    _mergeData(
      remoteOpinions.toList(),
      remoteReviews,
    );

    _loaded = true;
    changes.value = changes.value + 1;
  }

  Future<ReviewModel> addOrUpdateReview({
    required int userId,
    required int publicationId,
    required int rating,
    String? description,
    int? reviewId,
  }) async {
    await loadIfNeeded();

    final existingReview = reviewId == null
        ? null
        : reviews.firstWhere(
            (review) => review.id == reviewId,
            orElse: () => ReviewModel(
              id: 0,
              userId: 0,
              publicationId: 0,
              opinionId: 0,
              date: DateTime.fromMillisecondsSinceEpoch(0),
            ),
          );

    final hasExistingReview = existingReview != null && existingReview.id != 0;
    final resolvedOpinionId =
        hasExistingReview ? existingReview.opinionId : _nextOpinionId();

    final savedOpinion = await _saveOpinion(
      opinionId: resolvedOpinionId,
      rating: rating,
      description: description,
      isUpdate: hasExistingReview,
    );
    _upsertOpinion(savedOpinion);
    _upsertOverriddenOpinion(savedOpinion);

    ReviewModel savedReview;
    if (hasExistingReview) {
      savedReview = ReviewModel(
        id: existingReview.id,
        userId: userId,
        publicationId: publicationId,
        opinionId: savedOpinion.id,
        date: DateTime.now(),
      );
      try {
        savedReview = ReviewModel.fromJson(
          await ApiClient.instance.patchMap(
            'reviews/${existingReview.id}',
            {
              'usuario_id': userId,
              'publicacion_id': publicationId,
              'opinion_id': savedOpinion.id,
              'fecha': savedReview.date.toIso8601String(),
            },
          ),
        );
      } catch (_) {}
    } else {
      savedReview = await _createReview(
        userId: userId,
        publicationId: publicationId,
        opinionId: savedOpinion.id,
      );
    }

    _deletedReviewIds.remove(savedReview.id);
    _upsertReview(savedReview);
    _upsertOverriddenReview(savedReview);
    await _saveOverrides();
    changes.value = changes.value + 1;
    return savedReview;
  }

  /// Elimina los datos vinculados a eliminar reseña.
  Future<void> deleteReview(int reviewId) async {
    await loadIfNeeded();
    final review = reviews.firstWhere(
      (item) => item.id == reviewId,
      orElse: () => ReviewModel(
        id: 0,
        userId: 0,
        publicationId: 0,
        opinionId: 0,
        date: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
    if (review.id == 0) return;

    try {
      await ApiClient.instance.delete('reviews/$reviewId');
    } catch (_) {}

    reviews.removeWhere((item) => item.id == reviewId);
    _overriddenReviews.removeWhere((item) => item.id == reviewId);
    _deletedReviewIds.add(reviewId);

    final opinionId = review.opinionId;
    final stillUsed = reviews.any((item) => item.opinionId == opinionId);
    if (!stillUsed) {
      opinions.removeWhere((item) => item.id == opinionId);
      _overriddenOpinions.removeWhere((item) => item.id == opinionId);
      try {
        await ApiClient.instance.delete('opinions/$opinionId');
      } catch (_) {}
    }

    await _saveOverrides();
    changes.value = changes.value + 1;
  }

  Future<OpinionModel> _saveOpinion({
    required int opinionId,
    required int rating,
    String? description,
    required bool isUpdate,
  }) async {
    if (isUpdate) {
      try {
        return OpinionModel.fromJson(
          await ApiClient.instance.patchMap(
            'opinions/$opinionId',
            {
              'calificacion': rating,
              'descripcion': description ?? '',
            },
          ),
        );
      } catch (_) {
        return OpinionModel(
          id: opinionId,
          rating: rating,
          description: description,
        );
      }
    }

    try {
      return OpinionModel.fromJson(
        await ApiClient.instance.postMap(
          'opinions',
          {
            'calificacion': rating,
            'descripcion': description ?? '',
          },
        ),
      );
    } catch (_) {
      return OpinionModel(
        id: opinionId,
        rating: rating,
        description: description,
      );
    }
  }

  Future<ReviewModel> _createReview({
    required int userId,
    required int publicationId,
    required int opinionId,
  }) async {
    final now = DateTime.now();
    try {
      return ReviewModel.fromJson(
        await ApiClient.instance.postMap(
          'reviews',
          {
            'usuario_id': userId,
            'publicacion_id': publicationId,
            'opinion_id': opinionId,
            'fecha': now.toIso8601String(),
          },
        ),
      );
    } catch (_) {
      return ReviewModel(
        id: _nextReviewId(),
        userId: userId,
        publicationId: publicationId,
        opinionId: opinionId,
        date: now,
      );
    }
  }

  void _mergeData(
    List<OpinionModel> remoteOpinions,
    List<ReviewModel> remoteReviews,
  ) {
    final mergedOpinions = <int, OpinionModel>{
      for (final opinion in remoteOpinions) opinion.id: opinion,
      for (final opinion in _overriddenOpinions) opinion.id: opinion,
    };

    final mergedReviews = <int, ReviewModel>{
      for (final review in remoteReviews)
        if (!_deletedReviewIds.contains(review.id)) review.id: review,
      for (final review in _overriddenReviews)
        if (!_deletedReviewIds.contains(review.id)) review.id: review,
    };

    final visibleOpinionIds = mergedOpinions.keys.toSet();
    final visibleReviews = mergedReviews.values
        .where((review) => visibleOpinionIds.contains(review.opinionId))
        .toList();

    opinions
      ..clear()
      ..addAll(mergedOpinions.values);
    reviews
      ..clear()
      ..addAll(visibleReviews);
  }

  /// Gestiona siguiente opinion id dentro de esta parte del flujo.
  int _nextOpinionId() {
    if (opinions.isEmpty) return 1;
    return opinions.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Gestiona siguiente reseña id dentro de esta parte del flujo.
  int _nextReviewId() {
    if (reviews.isEmpty) return 1;
    return reviews.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Gestiona upsert opinion dentro de esta parte del flujo.
  void _upsertOpinion(OpinionModel opinion) {
    final index = opinions.indexWhere((item) => item.id == opinion.id);
    if (index == -1) {
      opinions.add(opinion);
    } else {
      opinions[index] = opinion;
    }
  }

  /// Gestiona upsert reseña dentro de esta parte del flujo.
  void _upsertReview(ReviewModel review) {
    final index = reviews.indexWhere((item) => item.id == review.id);
    if (index == -1) {
      reviews.add(review);
    } else {
      reviews[index] = review;
    }
  }

  /// Gestiona upsert overridden opinion dentro de esta parte del flujo.
  void _upsertOverriddenOpinion(OpinionModel opinion) {
    final index =
        _overriddenOpinions.indexWhere((item) => item.id == opinion.id);
    if (index == -1) {
      _overriddenOpinions.add(opinion);
    } else {
      _overriddenOpinions[index] = opinion;
    }
  }

  /// Gestiona upsert overridden reseña dentro de esta parte del flujo.
  void _upsertOverriddenReview(ReviewModel review) {
    final index = _overriddenReviews.indexWhere((item) => item.id == review.id);
    if (index == -1) {
      _overriddenReviews.add(review);
    } else {
      _overriddenReviews[index] = review;
    }
  }

  List<T> _parseList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) parser,
  ) {
    final raw = (source as List<dynamic>? ?? const []);
    return raw.map((item) => parser(item as Map<String, dynamic>)).toList();
  }

  /// Gestiona carga segura de lista dentro de esta parte del flujo.
  Future<List<dynamic>> _safeLoadList(String endpoint) async {
    try {
      return await ApiClient.instance
          .getList(endpoint, useCache: false)
          .timeout(const Duration(seconds: 6));
    } catch (_) {
      return const [];
    }
  }

  /// Carga los cambios locales sobrescritos de opinion.
  Future<List<OpinionModel>> _loadOpinionOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_opinionsOverridesKey);
    if (raw == null || raw.isEmpty) return <OpinionModel>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <OpinionModel>[];
      return decoded
          .whereType<Map>()
          .map(
            (item) => OpinionModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } catch (_) {
      return <OpinionModel>[];
    }
  }

  /// Carga los cambios locales sobrescritos de reseña.
  Future<List<ReviewModel>> _loadReviewOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_reviewsOverridesKey);
    if (raw == null || raw.isEmpty) return <ReviewModel>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <ReviewModel>[];
      return decoded
          .whereType<Map>()
          .map(
            (item) => ReviewModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } catch (_) {
      return <ReviewModel>[];
    }
  }

  /// Carga los datos necesarios para cargar deleted reseña ids.
  Future<Set<int>> _loadDeletedReviewIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_deletedReviewsKey) ?? const <String>[];
    return raw.map((item) => int.tryParse(item)).whereType<int>().toSet();
  }

  /// Guardar cambios locales esta parte del flujo de trabajo.
  Future<void> _saveOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _opinionsOverridesKey,
      jsonEncode(_overriddenOpinions.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(
      _reviewsOverridesKey,
      jsonEncode(_overriddenReviews.map((item) => item.toJson()).toList()),
    );
    await prefs.setStringList(
      _deletedReviewsKey,
      _deletedReviewIds.map((id) => id.toString()).toList(),
    );
  }
}
