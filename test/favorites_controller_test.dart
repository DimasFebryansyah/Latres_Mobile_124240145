import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:latres/app/controllers/favorites_controller.dart';
import 'package:latres/app/models/tv_show.dart';

void main() {
  late Directory directory;
  late Box<TvShow> box;

  setUp(() async {
    await Hive.close();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TvShowAdapter());
    }
    directory = await Directory.systemTemp.createTemp('serially-favorites-');
    Hive.init(directory.path);
    box = await Hive.openBox<TvShow>('favorite_shows');
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('adds and removes a show from Hive favorites', () async {
    final controller = FavoritesController(box);
    final show = TvShow(
      id: 8,
      name: 'Favorite show',
      genres: const ['Drama'],
      rating: 7.5,
    );

    await controller.toggle(show);

    expect(controller.contains(show), isTrue);
    expect(controller.favorites.single.name, 'Favorite show');
    expect(box.containsKey(show.id), isTrue);

    await controller.remove(show);

    expect(controller.contains(show), isFalse);
    expect(controller.favorites, isEmpty);
    expect(box.containsKey(show.id), isFalse);
  });

  test('migrates legacy JSON favorites to typed Hive objects', () async {
    final legacyBox = await Hive.openBox<String>('favorites');
    final show = TvShow(
      id: 21,
      name: 'Legacy favorite',
      genres: const ['Comedy'],
      rating: 8.2,
    );
    await legacyBox.put('21', jsonEncode(show.toJson()));

    await FavoritesController.migrateLegacyFavorites(
      legacyBox: legacyBox,
      targetBox: box,
    );

    expect(box.get(21)?.name, 'Legacy favorite');
    expect(box.get(21)?.genres, ['Comedy']);
  });

  test('rejects malformed legacy favorite data', () async {
    final legacyBox = await Hive.openBox<String>('favorites');
    await legacyBox.put('broken', 'not-json');

    await expectLater(
      FavoritesController.migrateLegacyFavorites(
        legacyBox: legacyBox,
        targetBox: box,
      ),
      throwsFormatException,
    );
  });
}
