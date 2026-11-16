import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorites_controller.dart';
import '../controllers/shows_controller.dart';
import '../models/tv_show.dart';
import '../services/tvmaze_service.dart';
import '../widgets/show_card.dart';
import 'show_detail_page.dart';

class ShowsPage extends StatefulWidget {
  const ShowsPage({super.key});

  @override
  State<ShowsPage> createState() => _ShowsPageState();
}

class _ShowsPageState extends State<ShowsPage> {
  final _controller = Get.put(ShowsController(TvMazeService()));
  final _favoritesController = Get.find<FavoritesController>();

  void _openShow(TvShow show) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ShowDetailPage(showId: show.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        title: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 11),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Serially',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  'SERIES DISCOVERY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.4,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton.filledTonal(
            tooltip: 'Muat ulang daftar show',
            onPressed: _controller.fetchShows,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _ExploreBanner(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              onChanged: (value) => _controller.searchQuery.value = value,
              decoration: const InputDecoration(
                hintText: 'Cari judul serial...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
            child: Row(
              children: [
                Text(
                  'Pilihan untukmu',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Obx(
                  () => Text(
                    '${_controller.filteredShows.length} serial',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value && _controller.shows.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_controller.errorMessage.isNotEmpty &&
                  _controller.shows.isEmpty) {
                return _ErrorState(
                  message: _controller.errorMessage.value,
                  onRetry: _controller.fetchShows,
                );
              }

              final shows = _controller.filteredShows;
              if (shows.isEmpty) {
                return _EmptyState(
                  message: _controller.shows.isEmpty
                      ? 'Belum ada data serial.'
                      : 'Judul tidak ditemukan.',
                  onRefresh: _controller.fetchShows,
                );
              }

              return RefreshIndicator(
                onRefresh: _controller.fetchShows,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.61,
                  ),
                  itemCount: shows.length,
                  itemBuilder: (context, index) {
                    final show = shows[index];
                    return Obx(
                      () => ShowCard(
                        show: show,
                        isFavorite: _favoritesController.contains(show),
                        onTap: () => _openShow(show),
                        onFavoritePressed: () =>
                            _favoritesController.toggle(show),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ExploreBanner extends StatelessWidget {
  const _ExploreBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101A30), Color(0xFF174A9B), Color(0xFFE53945)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -52,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PILIHAN HARI INI',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.76),
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Malam ini,\nnonton apa?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        height: 1.08,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.movie_filter_rounded,
                size: 74,
                color: Colors.white.withValues(alpha: 0.84),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onRefresh});

  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        children: [
          const SizedBox(height: 160),
          const Icon(Icons.movie_filter_outlined, size: 44),
          const SizedBox(height: 12),
          Center(child: Text(message)),
        ],
      ),
    );
  }
}
