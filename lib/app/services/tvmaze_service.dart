import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/tv_show.dart';

class TvMazeException implements Exception {
  const TvMazeException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TvMazeService {
  TvMazeService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://api.tvmaze.com';
  final http.Client _client;

  Future<List<TvShow>> fetchShows() async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/shows'))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw TvMazeException(
        'TVMaze mengembalikan status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const TvMazeException(
        'Format daftar show dari TVMaze tidak valid.',
      );
    }

    return decoded
        .whereType<Map>()
        .map((item) => TvShow.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<TvShow> fetchShow(int id) async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/shows/$id'))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw TvMazeException(
        'Detail show tidak ditemukan (status ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const TvMazeException(
        'Format detail show dari TVMaze tidak valid.',
      );
    }

    return TvShow.fromJson(Map<String, dynamic>.from(decoded));
  }
}
