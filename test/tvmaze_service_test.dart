import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latres/app/services/tvmaze_service.dart';

void main() {
  group('TvMazeService', () {
    test('fetches and parses the show list', () async {
      final service = TvMazeService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.toString(), 'https://api.tvmaze.com/shows');
          return http.Response(
            jsonEncode([
              {
                'id': 42,
                'name': 'Example Show',
                'genres': ['Drama'],
                'rating': {'average': 8.3},
                'image': {'medium': 'https://example.com/poster.jpg'},
                'summary': '<p>A <b>short</b> story.</p>',
              },
            ]),
            200,
          );
        }),
      );

      final shows = await service.fetchShows();

      expect(shows, hasLength(1));
      expect(shows.single.id, 42);
      expect(shows.single.name, 'Example Show');
      expect(shows.single.rating, 8.3);
      expect(shows.single.imageUrl, 'https://example.com/poster.jpg');
      expect(shows.single.summary, 'A short story.');
    });

    test(
      'fetches detail by id and handles missing optional API fields',
      () async {
        final service = TvMazeService(
          client: MockClient((request) async {
            expect(request.url.path, '/shows/7');
            return http.Response(
              jsonEncode({
                'id': 7,
                'name': 'No poster',
                'genres': [],
                'rating': {'average': null},
                'image': null,
                'summary': null,
              }),
              200,
            );
          }),
        );

        final show = await service.fetchShow(7);

        expect(show.id, 7);
        expect(show.rating, isNull);
        expect(show.imageUrl, isNull);
        expect(show.summary, isEmpty);
      },
    );

    test('reports an unsuccessful API response', () async {
      final service = TvMazeService(
        client: MockClient((_) async => http.Response('not found', 404)),
      );

      expect(service.fetchShow(123), throwsA(isA<TvMazeException>()));
    });
  });
}
