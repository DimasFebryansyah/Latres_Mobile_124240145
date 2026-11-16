import 'dart:convert';

import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/tv_show.dart';

class FavoritesController extends GetxController {
  FavoritesController(this._box);

  final Box<TvShow> _box;
  final favorites = <TvShow>[].obs;

  static Future<void> migrateLegacyFavorites({
    required Box<String> legacyBox,
    required Box<TvShow> targetBox,
  }) async {
    for (final value in legacyBox.values) {
      final decoded = jsonDecode(value);
      if (decoded is! Map) {
        throw const FormatException('Data favorit lama tidak valid.');
      }
      final show = TvShow.fromJson(Map<String, dynamic>.from(decoded));
      if (!targetBox.containsKey(show.id)) {
        await targetBox.put(show.id, show);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    _reload();
  }

  bool contains(TvShow show) =>
      favorites.any((favorite) => favorite.id == show.id);

  Future<void> toggle(TvShow show) async {
    if (contains(show)) {
      await _box.delete(show.id);
    } else {
      await _box.put(show.id, show);
    }
    _reload();
  }

  Future<void> remove(TvShow show) async {
    await _box.delete(show.id);
    _reload();
  }

  void _reload() {
    favorites.assignAll(_box.values);
  }
}
