import 'package:hive/hive.dart';

part 'tv_show.g.dart';

@HiveType(typeId: 0)
class TvShow {
  const TvShow({
    required this.id,
    required this.name,
    required this.genres,
    this.rating,
    this.imageUrl,
    this.summary = '',
  });

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> genres;

  @HiveField(3)
  final double? rating;

  @HiveField(4)
  final String? imageUrl;

  @HiveField(5)
  final String summary;

  factory TvShow.fromJson(Map<String, dynamic> json) {
    final ratingData = json['rating'];
    final imageData = json['image'];
    final average = ratingData is Map ? ratingData['average'] : null;
    final mediumImage = imageData is Map ? imageData['medium'] : null;
    final originalImage = imageData is Map ? imageData['original'] : null;
    final rawGenres = json['genres'];

    return TvShow(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? 'Tanpa judul',
      genres: rawGenres is List
          ? rawGenres.whereType<String>().toList(growable: false)
          : const [],
      rating: average is num ? average.toDouble() : null,
      imageUrl: mediumImage is String
          ? mediumImage
          : originalImage is String
          ? originalImage
          : null,
      summary: _plainText(json['summary'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'genres': genres,
    'rating': rating == null ? null : {'average': rating},
    'image': imageUrl == null ? null : {'medium': imageUrl},
    'summary': summary,
  };

  static String _plainText(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
