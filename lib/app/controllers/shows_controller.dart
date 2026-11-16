import 'package:get/get.dart';

import '../models/tv_show.dart';
import '../services/tvmaze_service.dart';

class ShowsController extends GetxController {
  ShowsController(this._service);

  final TvMazeService _service;
  final shows = <TvShow>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;

  List<TvShow> get filteredShows {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return shows;
    return shows
        .where((show) => show.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    fetchShows();
  }

  Future<void> fetchShows() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      shows.assignAll(await _service.fetchShows());
    } on Exception catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
