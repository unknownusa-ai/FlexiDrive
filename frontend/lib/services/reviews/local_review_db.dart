import 'package:flexidrive/core/api/api_client.dart';
import 'package:flexidrive/models/reviews/review_models.dart';

class LocalReviewDb {
  LocalReviewDb._();

  static final LocalReviewDb instance = LocalReviewDb._();

  bool? _loaded = false;

  final List<OpinionModel> opinions = [];
  final List<ReviewModel> reviews = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    opinions
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('opinions'),
          OpinionModel.fromJson,
        ).where(
          (opinion) =>
              opinion.description != null &&
              !opinion.description!.startsWith('Opinion de prueba'),
        ),
      );
    reviews
      ..clear()
      ..addAll(
        _parseList(await _loadList('reviews'), ReviewModel.fromJson),
      );
    final visibleOpinionIds = opinions.map((opinion) => opinion.id).toSet();
    reviews.removeWhere(
      (review) => !visibleOpinionIds.contains(review.opinionId),
    );

    _loaded = true;
  }

  List<T> _parseList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) parser,
  ) {
    final raw = (source as List<dynamic>? ?? const []);
    return raw.map((item) => parser(item as Map<String, dynamic>)).toList();
  }

  Future<List<dynamic>> _loadList(String endpoint) =>
      ApiClient.instance.getList(endpoint);
}
